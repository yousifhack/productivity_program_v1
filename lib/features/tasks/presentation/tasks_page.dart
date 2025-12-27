import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key, required this.uid});
  final String uid;

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  CollectionReference<Map<String, dynamic>> get _groups =>
      FirebaseFirestore.instance.collection('users').doc(widget.uid).collection('taskGroups');

  CollectionReference<Map<String, dynamic>> get _tasks =>
      FirebaseFirestore.instance.collection('users').doc(widget.uid).collection('tasks');

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _safeErr(Object e) {
    final s = e.toString();
    if (s.contains('permission') || s.contains('PERMISSION_DENIED')) {
      return 'Permission denied (Firestore rules).';
    }
    return 'Something went wrong. Please try again.';
  }

  Future<void> _createGroupDialog() async {
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
              title: const Text('Create Task Group'),
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
                        decoration: const InputDecoration(labelText: 'Group name'),
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
                TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Cancel')),
                FilledButton(
                  onPressed: busy
                      ? null
                      : () async {
                          final name = c.text.trim();
                          if (name.isEmpty) {
                            setLocal(() => error = 'Group name required.');
                            return;
                          }

                          setLocal(() {
                            busy = true;
                            error = null;
                          });

                          try {
                            await _groups.add({
                              'name': name,
                              'createdAt': FieldValue.serverTimestamp(),
                            });

                            if (!dCtx.mounted) return;
                            Navigator.pop(dCtx);
                            _snack('Group created');
                          } catch (e) {
                            if (!dCtx.mounted) return;
                            setLocal(() {
                              busy = false;
                              error = _safeErr(e);
                            });
                          }
                        },
                  child: busy
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );

    c.dispose();
  }

  Future<void> _addTaskDialog({String? preselectedGroupId}) async {
    final titleC = TextEditingController();
    final descC = TextEditingController();
    DateTime? due;
    String? groupId = preselectedGroupId;
    String? error;
    bool busy = false;

    // Use MapEntry instead of records/tuples -> no ".data" crashes.
    List<MapEntry<String, String>> groupItems = [];
    try {
      final groupsSnap = await _groups.orderBy('createdAt').get();
      groupItems = groupsSnap.docs
          .map((d) => MapEntry(d.id, (d.data()['name'] ?? '').toString()))
          .where((e) => e.value.trim().isNotEmpty)
          .toList();
    } catch (_) {
      groupItems = [];
    }

    if (!mounted) {
      titleC.dispose();
      descC.dispose();
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dCtx) {
        return StatefulBuilder(
          builder: (dCtx, setLocal) {
            final insets = MediaQuery.viewInsetsOf(dCtx);

            Future<void> openDescription() async {
              final tmp = TextEditingController(text: descC.text);

              final res = await showDialog<String>(
                context: dCtx,
                barrierDismissible: true,
                builder: (dd) {
                  final ddInsets = MediaQuery.viewInsetsOf(dd);
                  return AlertDialog(
                    title: const Text('Description'),
                    content: AnimatedPadding(
                      duration: const Duration(milliseconds: 120),
                      curve: Curves.easeOut,
                      padding: EdgeInsets.only(bottom: ddInsets.bottom),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: TextField(
                          controller: tmp,
                          minLines: 4,
                          maxLines: 10,
                          decoration: const InputDecoration(hintText: 'Write details...'),
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(dd), child: const Text('Cancel')),
                      FilledButton(onPressed: () => Navigator.pop(dd, tmp.text), child: const Text('Save')),
                    ],
                  );
                },
              );

              tmp.dispose();

              if (!dCtx.mounted) return;
              if (res != null) {
                setLocal(() => descC.text = res);
              }
            }

            return AlertDialog(
              title: const Text('Add Task'),
              content: AnimatedPadding(
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(bottom: insets.bottom),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: titleC,
                          autofocus: true,
                          decoration: const InputDecoration(labelText: 'Task title'),
                        ),
                        const SizedBox(height: 10),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.description_outlined),
                            label: Text(descC.text.trim().isEmpty ? 'Add Description' : 'Edit Description'),
                            onPressed: busy ? null : openDescription,
                          ),
                        ),

                        const SizedBox(height: 10),

                        OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today_outlined),
                          label: Text(
                            due == null
                                ? 'Pick date'
                                : '${due!.year}-${due!.month.toString().padLeft(2, '0')}-${due!.day.toString().padLeft(2, '0')}',
                          ),
                          onPressed: busy
                              ? null
                              : () async {
                                  final now = DateTime.now();
                                  final picked = await showDatePicker(
                                    context: dCtx,
                                    firstDate: DateTime(now.year, now.month, now.day),
                                    lastDate: DateTime(now.year + 5),
                                    initialDate: due ?? now,
                                  );
                                  if (!dCtx.mounted) return;
                                  if (picked != null) setLocal(() => due = picked);
                                },
                        ),

                        const SizedBox(height: 10),

                        DropdownButtonFormField<String?>(
                          initialValue: groupId,
                          decoration: const InputDecoration(labelText: 'Add to group (optional)'),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('No group')),
                            ...groupItems.map(
                              (g) => DropdownMenuItem<String?>(
                                value: g.key,
                                child: Text(g.value),
                              ),
                            ),
                          ],
                          onChanged: busy ? null : (v) => setLocal(() => groupId = v),
                        ),

                        if (error != null) ...[
                          const SizedBox(height: 10),
                          Text(error!, style: const TextStyle(color: Colors.red)),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Cancel')),
                FilledButton(
                  onPressed: busy
                      ? null
                      : () async {
                          final title = titleC.text.trim();
                          if (title.isEmpty) {
                            setLocal(() => error = 'Task title required.');
                            return;
                          }

                          setLocal(() {
                            busy = true;
                            error = null;
                          });

                          try {
                            await _tasks.add({
                              'title': title,
                              'description': descC.text.trim(),
                              'dueAt': due == null ? null : Timestamp.fromDate(due!),
                              'groupId': groupId,
                              'createdAt': FieldValue.serverTimestamp(),
                              'updatedAt': FieldValue.serverTimestamp(),
                            });

                            if (!dCtx.mounted) return;
                            Navigator.pop(dCtx);
                            _snack('Task added');
                          } catch (e) {
                            if (!dCtx.mounted) return;
                            setLocal(() {
                              busy = false;
                              error = _safeErr(e);
                            });
                          }
                        },
                  child: busy
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    titleC.dispose();
    descC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupsStream = _groups.orderBy('createdAt').snapshots();
    final tasksStream = _tasks.orderBy('createdAt', descending: true).snapshots();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        children: [
          // Header row with buttons beside "Tasks"
          Row(
            children: [
              const Expanded(
                child: Text('Tasks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              ),
              SizedBox(
                height: 40,
                child: FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Task'),
                  onPressed: () => _addTaskDialog(),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 40,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.create_new_folder_outlined),
                  label: const Text('Group'),
                  onPressed: _createGroupDialog,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // One scrollable grouped body
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: groupsStream,
              builder: (ctx, gSnap) {
                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: tasksStream,
                  builder: (ctx, tSnap) {
                    if (gSnap.hasError) {
                      return Center(child: Text('Groups error: ${_safeErr(gSnap.error!)}'));
                    }
                    if (tSnap.hasError) {
                      return Center(child: Text('Tasks error: ${_safeErr(tSnap.error!)}'));
                    }
                    if (!gSnap.hasData || !tSnap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // groups: List<MapEntry<groupId, data>>
                    final groups = gSnap.data!.docs
                        .map((d) => MapEntry<String, Map<String, dynamic>>(d.id, d.data()))
                        .toList();

                    // tasks: List<MapEntry<taskId, data>>
                    final tasks = tSnap.data!.docs
                        .map((d) => MapEntry<String, Map<String, dynamic>>(d.id, d.data()))
                        .toList();

                    // groupId -> tasks
                    final Map<String, List<MapEntry<String, Map<String, dynamic>>>> byGroup = {};
                    final List<MapEntry<String, Map<String, dynamic>>> ungrouped = [];

                    for (final t in tasks) {
                      final gid = (t.value['groupId'] ?? '').toString().trim();
                      if (gid.isEmpty) {
                        ungrouped.add(t);
                      } else {
                        byGroup.putIfAbsent(gid, () => []).add(t);
                      }
                    }

                    if (groups.isEmpty && tasks.isEmpty) {
                      return const Center(child: Text('No tasks yet.'));
                    }

                    final items = <Widget>[];

                    for (final g in groups) {
                      final name = (g.value['name'] ?? 'Group').toString();
                      final list = byGroup[g.key] ?? const [];

                      items.add(_GroupHeader(
                        title: name,
                        onAddTask: () => _addTaskDialog(preselectedGroupId: g.key),
                      ));

                      if (list.isEmpty) {
                        items.add(const Padding(
                          padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                          child: Text('No tasks in this group yet.'),
                        ));
                      } else {
                        for (final t in list) {
                          final title = (t.value['title'] ?? '').toString();
                          items.add(_TaskTile(title: title));
                        }
                      }

                      items.add(const SizedBox(height: 10));
                    }

                    if (ungrouped.isNotEmpty) {
                      items.add(const _SectionTitle('Ungrouped'));
                      for (final t in ungrouped) {
                        final title = (t.value['title'] ?? '').toString();
                        items.add(_TaskTile(title: title));
                      }
                    }

                    return ListView(
                      padding: const EdgeInsets.only(top: 4),
                      children: items,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.title, required this.onAddTask});
  final String title;
  final VoidCallback onAddTask;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900))),
          IconButton(
            tooltip: 'Add task',
            onPressed: onAddTask,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 10, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800))),
        ],
      ),
    );
  }
}
