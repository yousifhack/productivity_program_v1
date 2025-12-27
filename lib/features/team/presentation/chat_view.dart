import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'package:productivity_program_v1/core/services/chat_repository.dart';

class ChatView extends ConsumerStatefulWidget {
  const ChatView({
    super.key,
    required this.myUid,
    required this.otherUid,
    required this.otherName,
    required this.onBack,
  });

  final String myUid;
  final String otherUid;
  final String otherName;
  final VoidCallback onBack;

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
  final input = TextEditingController();
  bool sending = false;

  // Voice record
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  int? _recordingStartedAtMs;
  String? _recordingPath;

  // Voice play
  final AudioPlayer _player = AudioPlayer();
  String? _playingMsgId;
  StreamSubscription<PlayerState>? _playerSub;

  @override
  void initState() {
    super.initState();

    // Mark as read once we open the chat
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(chatRepositoryProvider).markRead(
            myUid: widget.myUid,
            otherUid: widget.otherUid,
          );
    });
  }

  @override
  void dispose() {
    input.dispose();
    _playerSub?.cancel();
    _player.dispose();
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatId = ChatRepository.chatIdFor(widget.myUid, widget.otherUid);
    final stream = ref.read(chatRepositoryProvider).messagesStream(chatId: chatId);

    final textNow = input.text.trim();
    final canSendText = textNow.isNotEmpty && !sending;
    final canUseMic = textNow.isEmpty && !sending;

    return Column(
      children: [
        SizedBox(
          height: 52,
          child: Row(
            children: [
              IconButton(onPressed: widget.onBack, icon: const Icon(Icons.arrow_back)),
              Expanded(
                child: Text(widget.otherName, style: const TextStyle(fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: StreamBuilder(
            stream: stream,
            builder: (context, snap) {
              if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());

              final docs = snap.data!.docs;
              if (docs.isEmpty) return const Center(child: Text('No messages yet.'));

              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(12),
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final d = docs[i];
                  final m = d.data();

                  final sender = (m['senderUid'] ?? '').toString();
                  final kind = (m['kind'] ?? 'text').toString();
                  final mine = sender == widget.myUid;

                  if (kind == 'voice') {
                    final storagePath = (m['storagePath'] ?? '').toString();
                    final durationMs = m['durationMs'] is int ? (m['durationMs'] as int) : null;
                    return _VoiceBubble(
                      mine: mine,
                      durationMs: durationMs,
                      isPlaying: _playingMsgId == d.id,
                      onToggle: () => _togglePlay(msgId: d.id, storagePath: storagePath),
                    );
                  }

                  final text = (m['text'] ?? '').toString();
                  return _TextBubble(mine: mine, text: text);
                },
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
              top: 8,
              bottom: 10 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: input,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Message...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) {
                      if (!mounted) return;
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Mic (only when text is empty)
                SizedBox(
                  height: 48,
                  width: 56,
                  child: OutlinedButton(
                    onPressed: canUseMic ? _toggleRecord : null,
                    child: Icon(_isRecording ? Icons.stop : Icons.mic),
                  ),
                ),
                const SizedBox(width: 8),

                SizedBox(
                  height: 48,
                  width: 56,
                  child: FilledButton(
                    onPressed: canSendText ? _sendText : null,
                    child: sending
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.send),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _sendText() async {
    final text = input.text.trim();
    if (text.isEmpty) return;

    setState(() => sending = true);
    try {
      await ref.read(chatRepositoryProvider).sendText(
            myUid: widget.myUid,
            otherUid: widget.otherUid,
            text: text,
          );

      if (!mounted) return;
      input.clear();

      await ref.read(chatRepositoryProvider).markRead(
            myUid: widget.myUid,
            otherUid: widget.otherUid,
          );
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  Future<void> _toggleRecord() async {
    if (_isRecording) {
      await _stopAndSendVoice();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    final perm = await _recorder.hasPermission();
    if (!perm) return;

    final dir = await getTemporaryDirectory();
    if (!mounted) return;

    final path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    _recordingPath = path;
    _recordingStartedAtMs = DateTime.now().millisecondsSinceEpoch;

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: path,
    );

    if (!mounted) return;
    setState(() => _isRecording = true);
  }

  Future<void> _stopAndSendVoice() async {
    setState(() => sending = true);

    try {
      final stoppedPath = await _recorder.stop();
      if (!mounted) return;

      setState(() => _isRecording = false);

      final p = stoppedPath ?? _recordingPath;
      if (p == null) return;

      final file = File(p);
      if (!await file.exists()) return;

      final size = await file.length();
      if (size < 800) return; // discard tiny clips silently

      final started = _recordingStartedAtMs;
      final durationMs = started == null ? null : (DateTime.now().millisecondsSinceEpoch - started);

      await ref.read(chatRepositoryProvider).sendVoice(
            myUid: widget.myUid,
            otherUid: widget.otherUid,
            filePath: p,
            durationMs: durationMs,
          );

      await ref.read(chatRepositoryProvider).markRead(
            myUid: widget.myUid,
            otherUid: widget.otherUid,
          );
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  Future<void> _togglePlay({
    required String msgId,
    required String storagePath,
  }) async {
    try {
      // Same message playing -> pause and clear
      if (_playingMsgId == msgId && _player.playing) {
        await _player.pause();
        if (!mounted) return;
        setState(() => _playingMsgId = null);
        return;
      }

      if (!mounted) return;
      setState(() => _playingMsgId = msgId);

      // IMPORTANT: prevent multiple listeners leaking
      await _playerSub?.cancel();
      _playerSub = null;

      final url = await ref.read(chatRepositoryProvider).getVoiceUrl(storagePath);
      if (!mounted) return;

      await _player.setUrl(url);
      await _player.play();

      _playerSub = _player.playerStateStream.listen((state) {
        if (!mounted) return;
        if (state.processingState == ProcessingState.completed) {
          setState(() => _playingMsgId = null);
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _playingMsgId = null);
    }
  }
}

class _TextBubble extends StatelessWidget {
  const _TextBubble({required this.mine, required this.text});
  final bool mine;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: mine ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: mine ? Theme.of(context).colorScheme.onPrimary : null,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _VoiceBubble extends StatelessWidget {
  const _VoiceBubble({
    required this.mine,
    required this.durationMs,
    required this.isPlaying,
    required this.onToggle,
  });

  final bool mine;
  final int? durationMs;
  final bool isPlaying;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final label = durationMs == null ? 'Voice message' : 'Voice • ${_mmss(durationMs!)}';

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: mine ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onToggle,
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              color: mine ? Theme.of(context).colorScheme.onPrimary : null,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: mine ? Theme.of(context).colorScheme.onPrimary : null,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _mmss(int ms) {
    final total = (ms / 1000).floor();
    final m = total ~/ 60;
    final s = total % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
