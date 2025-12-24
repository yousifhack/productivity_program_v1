class AppBreakpoints {
  static const double compact = 800;
  static const double medium = 1200;
}

extension BreakpointX on double {
  bool get isCompact => this < AppBreakpoints.compact;
  bool get isMedium =>
      this >= AppBreakpoints.compact && this < AppBreakpoints.medium;
  bool get isExpanded => this >= AppBreakpoints.medium;
}
