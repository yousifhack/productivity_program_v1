import 'package:flutter/material.dart';

class TabletShell extends StatefulWidget {
  const TabletShell({
    super.key,
    required this.header,
    required this.left,
    required this.right,
  });

  final Widget header;
  final Widget left;
  final Widget right;

  @override
  State<TabletShell> createState() => _TabletShellState();
}

class _TabletShellState extends State<TabletShell> {
  bool rightOpen = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.header,
        Expanded(
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              final rightWidth = rightOpen ? (w * 0.38).clamp(280.0, 520.0) : 56.0;

              return Row(
                children: [
                  Expanded(child: widget.left),

                  Container(
                    width: rightWidth,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      border: Border(left: BorderSide(color: Colors.black.withValues(alpha: 0.12))),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 56,
                          child: Row(
                            children: [
                              const SizedBox(width: 8),
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    // FLIPS correctly:
                                    rightOpen ? Icons.chevron_right : Icons.chevron_left,
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    size: 26,
                                  ),
                                  onPressed: () => setState(() => rightOpen = !rightOpen),
                                ),
                              ),
                              if (rightOpen) const SizedBox(width: 10),
                              if (rightOpen)
                                const Expanded(
                                  child: Text(
                                    'Right Panel',
                                    style: TextStyle(fontWeight: FontWeight.w900),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: rightOpen
                              ? widget.right
                              : const Center(child: Icon(Icons.chat_bubble_outline)),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
