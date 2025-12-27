import 'package:flutter/material.dart';

import 'package:productivity_program_v1/features/team/presentation/team_panel.dart';
import 'package:productivity_program_v1/features/my_guy/presentation/my_guy_panel.dart';

enum RightTab { team, myGuy }

class RightPane extends StatelessWidget {
  const RightPane({
    super.key,
    required this.uid,
    required this.tab,
  });

  final String uid;
  final RightTab tab;

  @override
  Widget build(BuildContext context) {
    final index = tab == RightTab.team ? 0 : 1;

    return Column(
      children: [
        const Divider(height: 1), // top separator line inside right pane
        Expanded(
          child: IndexedStack(
            index: index,
            children: [
              TeamPanel(uid: uid),
              MyGuyPanel(uid: uid),
            ],
          ),
        ),
      ],
    );
  }
}
