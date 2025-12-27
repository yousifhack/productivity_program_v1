import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/contacts_repository.dart';
import '../../../core/services/chat_repository.dart';
import 'chat_view.dart';

class TeamPanel extends ConsumerStatefulWidget {
  const TeamPanel({super.key, required this.uid});
  final String uid;

  @override
  ConsumerState<TeamPanel> createState() => _TeamPanelState();
}

class _TeamPanelState extends ConsumerState<TeamPanel> {
  String? _activeOtherUid;
  String? _activeOtherName;

  Future<void> _openChat({
    required String otherUid,
    required String otherName,
  }) async {
    await ref.read(chatRepositoryProvider).markRead(
          myUid: widget.uid,
          otherUid: otherUid,
        );

    if (!mounted) return;
    setState(() {
      _activeOtherUid = otherUid;
      _activeOtherName = otherName;
    });
  }

  void _backToContacts() {
    setState(() {
      _activeOtherUid = null;
      _activeOtherName = null;
    });
  }

  Future<void> _addColleagueDialog() async {
    final c = TextEditingController();
    String? error;
    bool busy = false;

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dCtx) {
        return StatefulBuilder(
          builder: (dCtx, setLocal) {
            final insets = MediaQuery.viewInsetsOf(dCtx);

            return AlertDialog(
              title: const Text('Add colleague'),
              content: AnimatedPadding(
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(bottom: insets.bottom),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: c,
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'User ID / invite code',
                          hintText: 'Example: ABCD2345EFGH',
                        ),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) async {
                          // Optional: let Enter trigger add, but only if not busy.
                          if (busy) return;
                        },
                      ),
                      if (error != null) ...[
                        const SizedBox(height: 10),
                        Text(error!, style: const TextStyle(color: Colors.red)),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dCtx),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: busy
                      ? null
                      : () async {
                          final code = c.text.trim();
                          if (code.isEmpty) {
                            setLocal(() => error = 'Enter an ID.');
                            return;
                          }

                          setLocal(() {
                            busy = true;
                            error = null;
                          });

                          try {
                            await ref.read(contactsRepositoryProvider).addByInviteCode(
                                  myUid: widget.uid,
                                  inviteCode: code,
                                );

                            if (!dCtx.mounted) return;
                            Navigator.pop(dCtx);
                          } catch (e) {
                            if (!dCtx.mounted) return;
                            setLocal(() {
                              busy = false;
                              error = e.toString().replaceFirst('StateError: ', '');
                            });
                          }
                        },
                  child: busy
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    c.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_activeOtherUid != null && _activeOtherName != null) {
      return ChatView(
        myUid: widget.uid,
        otherUid: _activeOtherUid!,
        otherName: _activeOtherName!,
        onBack: _backToContacts,
      );
    }

    final contactsStream = ref.read(contactsRepositoryProvider).contactsStream(widget.uid);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            height: 52,
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Team / Chat',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: FilledButton.icon(
                    onPressed: _addColleagueDialog,
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text('Add'),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder(
              stream: contactsStream,
              builder: (context, snap) {
                if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());

                final docs = snap.data!.docs;
                if (docs.isEmpty) {
                  return _EmptyContacts(onAdd: _addColleagueDialog);
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (ctx, i) {
                    final d = docs[i];
                    final data = d.data();
                    final otherUid = d.id;
                    final name = (data['displayName'] ?? 'Colleague').toString();
                    final hasUnread =
                        (data['hasUnread'] == true) || ((data['unreadCount'] ?? 0) as num) > 0;
                    final lastText = (data['lastMessageText'] ?? '').toString();
                    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(initial, style: const TextStyle(fontWeight: FontWeight.w900)),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                            if (hasUnread)
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Icon(Icons.star, size: 18, color: Colors.orange),
                              ),
                          ],
                        ),
                        subtitle: lastText.trim().isEmpty
                            ? const Text('Tap to chat', maxLines: 1, overflow: TextOverflow.ellipsis)
                            : Text(lastText, maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: IconButton(
                          tooltip: 'Chat',
                          icon: const Icon(Icons.chat_bubble_outline),
                          onPressed: () => _openChat(otherUid: otherUid, otherName: name),
                        ),
                        onTap: () => _openChat(otherUid: otherUid, otherName: name),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyContacts extends StatelessWidget {
  const _EmptyContacts({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No colleagues found', style: TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('Add a colleague using their User ID / invite code.'),
              const SizedBox(height: 12),
              SizedBox(
                height: 44,
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Add colleague'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
