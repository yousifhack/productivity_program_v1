import 'package:flutter/material.dart';

import '../utils/breakpoints.dart';

typedef PanelBuilder = Widget Function(BuildContext context);

class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    super.key,
    required this.appBar,
    required this.body,
    this.sidePanel,
    this.fab,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final PanelBuilder? sidePanel;
  final Widget? fab;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final showSidePanel =
            sidePanel != null && width >= AppBreakpoints.medium;

        return Scaffold(
          appBar: appBar,
          body: Row(
            children: [
              Expanded(child: body),
              if (showSidePanel) ...[
                const VerticalDivider(width: 1, color: Colors.white12),
                SizedBox(width: width * 0.28, child: sidePanel!(context)),
              ],
            ],
          ),
          floatingActionButton: fab,
        );
      },
    );
  }
}
