import 'package:flutter/material.dart';
import 'tasks_page.dart';

class TasksPanel extends StatelessWidget {
  const TasksPanel({super.key, required this.uid});
  final String uid;

  @override
  Widget build(BuildContext context) {
    return TasksPage(uid: uid);
  }
}
