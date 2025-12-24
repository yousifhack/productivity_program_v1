import 'dart:async';
import 'package:flutter/material.dart';

class TimerChip extends StatefulWidget {
  const TimerChip({
    super.key,
    required this.label,
    required this.target,
    this.positiveColor = Colors.green,
    this.negativeColor = Colors.red,
  });

  final String label;
  final DateTime target;
  final Color positiveColor;
  final Color negativeColor;

  @override
  State<TimerChip> createState() => _TimerChipState();
}

class _TimerChipState extends State<TimerChip> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final diff = widget.target.difference(now);
    final isNegative = diff.isNegative;
    final duration = diff.abs();

    final text =
        '${isNegative ? '-' : ''}${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';

    final color = isNegative ? widget.negativeColor : widget.positiveColor;

    return Chip(
      backgroundColor: color.withValues(alpha: 0.18),
      side: BorderSide(
        color: color.withValues(alpha: 0.6),
      ),
      label: Text(
        '${widget.label}: $text',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
