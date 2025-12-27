import 'package:flutter/material.dart';

import 'my_guy_feed.dart';
import 'team_feed.dart';

class UpdatesPanel extends StatefulWidget {
  const UpdatesPanel({super.key});

  @override
  State<UpdatesPanel> createState() => _UpdatesPanelState();
}

class _UpdatesPanelState extends State<UpdatesPanel> {
  int idx = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // top tabs
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              Expanded(
                child: _TabButton(
                  label: 'My Guy',
                  selected: idx == 0,
                  onTap: () => setState(() => idx = 0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TabButton(
                  label: 'Team',
                  selected: idx == 1,
                  onTap: () => setState(() => idx = 1),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(child: idx == 0 ? const MyGuyFeed() : const TeamFeed()),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 44,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: selected ? cs.primary : cs.surfaceContainerHighest,
          foregroundColor: selected ? cs.onPrimary : cs.onSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onTap,
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}
