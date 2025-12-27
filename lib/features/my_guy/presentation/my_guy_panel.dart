import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class MyGuyPanel extends StatefulWidget {
  const MyGuyPanel({super.key, required this.uid});
  final String uid;

  @override
  State<MyGuyPanel> createState() => _MyGuyPanelState();
}

class _MyGuyPanelState extends State<MyGuyPanel> {
  final _input = TextEditingController();
  bool _sending = false;
  String? _errorText;

  CollectionReference<Map<String, dynamic>> get _aiMsgs =>
      FirebaseFirestore.instance.collection('users').doc(widget.uid).collection('aiMessages');

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSend = _input.text.trim().isNotEmpty && !_sending;
    final stream = _aiMsgs.orderBy('createdAt', descending: true).limit(80).snapshots();

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: stream,
            builder: (context, snap) {
              if (snap.hasError) {
                return Center(child: Text('AI messages error: ${snap.error}'));
              }
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());

              final docs = snap.data!.docs;
              if (docs.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('My_Guy is ready. Ask anything about tasks, planning, or next steps.'),
                  ),
                );
              }

              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(12),
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final m = docs[i].data();
                  final role = (m['role'] ?? '').toString(); // "user" | "ai"
                  final text = (m['text'] ?? '').toString();
                  final mine = role == 'user';

                  return Align(
                    alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      constraints: const BoxConstraints(maxWidth: 420),
                      decoration: BoxDecoration(
                        color: mine
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
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
                },
              );
            },
          ),
        ),

        if (_errorText != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _errorText!,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
              ),
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
                    controller: _input,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Message My_Guy...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) {
                      if (!mounted) return;
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  width: 56,
                  child: FilledButton(
                    onPressed: canSend ? _send : null,
                    child: _sending
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

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _sending = true;
      _errorText = null;
    });

    try {
      await FirebaseFunctions.instance.httpsCallable('myGuySend').call({'text': text});

      if (!mounted) return;
      _input.clear();
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = 'My_Guy failed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }
}
