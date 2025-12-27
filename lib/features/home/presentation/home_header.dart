import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum LeftTab { tasks, tools }
enum RightTab { team, myGuy }

class HomeHeader extends StatefulWidget {
  const HomeHeader({
    super.key,
    required this.displayName,
    required this.leftTab,
    required this.onLeftTabChanged,
    required this.rightTab,
    required this.onRightTabChanged,
    required this.onOpenDrawer,
  });

  final String displayName;
  final LeftTab leftTab;
  final ValueChanged<LeftTab> onLeftTabChanged;

  final RightTab rightTab;
  final ValueChanged<RightTab> onRightTabChanged;

  final VoidCallback onOpenDrawer;

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  late Timer _timer;
  String _time = '';

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final now = DateTime.now();
    final t = DateFormat('HH:mm').format(now);
    if (t != _time && mounted) setState(() => _time = t);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Display name rules you asked:
  // - Allow up to 15 chars max stored, but UI shows compact
  // - Show only first 10 chars of first name, add ".." if trimmed
  String _uiName(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return 'User';
    final first = s.split(RegExp(r'\s+')).first; // first token only
    final shown = first.length > 10 ? '${first.substring(0, 10)}..' : first;
    return shown.length > 15 ? '${shown.substring(0, 15)}..' : shown;
  }

  @override
  Widget build(BuildContext context) {
    final name = _uiName(widget.displayName);
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return SafeArea(
      bottom: false,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            // LEFT: profile + name + Tasks/Tools
            InkWell(
              onTap: widget.onOpenDrawer,
              borderRadius: BorderRadius.circular(20),
              child: Row(
                children: [
                  CircleAvatar(radius: 18, child: Text(initial, style: const TextStyle(fontWeight: FontWeight.w900))),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 140),
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            SegmentedButton<LeftTab>(
              segments: const [
                ButtonSegment(value: LeftTab.tasks, label: Text('Tasks')),
                ButtonSegment(value: LeftTab.tools, label: Text('Tools')),
              ],
              selected: {widget.leftTab},
              showSelectedIcon: false,
              onSelectionChanged: (s) {
                if (s.isEmpty) return;
                widget.onLeftTabChanged(s.first);
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                minimumSize: WidgetStateProperty.all(const Size(0, 40)),
              ),
            ),

            // CENTER: dynamic island space (do not remove)
            const Expanded(child: SizedBox()),

            // RIGHT: Team/My_Guy + Clock
            SegmentedButton<RightTab>(
              segments: const [
                ButtonSegment(value: RightTab.team, label: Text('Team'), icon: Icon(Icons.groups_2_outlined)),
                ButtonSegment(value: RightTab.myGuy, label: Text('My_Guy'), icon: Icon(Icons.smart_toy_outlined)),
              ],
              selected: {widget.rightTab},
              showSelectedIcon: false,
              onSelectionChanged: (s) {
                if (s.isEmpty) return;
                widget.onRightTabChanged(s.first);
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                minimumSize: WidgetStateProperty.all(const Size(0, 40)),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _time,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
