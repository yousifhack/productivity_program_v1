import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:productivity_program_v1/core/widgets/tablet_shell.dart';
import 'package:productivity_program_v1/features/tasks/presentation/tasks_page.dart';
import 'package:productivity_program_v1/features/home/presentation/right_pane.dart';

class HomeShellPage extends StatefulWidget {
  const HomeShellPage({super.key});

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  RightTab _tab = RightTab.team;

  late Timer _clockTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Update time once per minute (lightweight)
    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    final displayName = (user?.displayName ?? '').trim();

    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }

    final nameRaw = displayName.isNotEmpty ? displayName : (user?.email ?? 'User');
    final name = _fitName(nameRaw);

    return Scaffold(
      drawer: _AppDrawer(
        uid: uid,
        displayName: nameRaw,
      ),
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 10,
        title: Row(
          children: [
            Builder(
              builder: (ctx) => IconButton(
                tooltip: 'Menu',
                icon: const Icon(Icons.account_circle),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Center(
              child: Text(
                _hhmm(_now),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _TopTabs(
              value: _tab,
              onChanged: (t) => setState(() => _tab = t),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.black.withValues(alpha: 0.12),
          ),
        ),
      ),
      body: TabletShell(
        // Header already in AppBar, so we pass an empty header space.
        header: const SizedBox.shrink(),
        left: TasksPage(uid: uid),
        right: RightPane(uid: uid, tab: _tab),
      ),
    );
  }

  static String _hhmm(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // Requested: show only short name (max 15 chars),
  // and make it visually compact if long.
  static String _fitName(String input) {
    final s = input.trim();
    if (s.isEmpty) return 'User';
    if (s.length <= 15) return s;
    return '${s.substring(0, 13)}..';
  }
}

class _TopTabs extends StatelessWidget {
  const _TopTabs({required this.value, required this.onChanged});
  final RightTab value;
  final ValueChanged<RightTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<RightTab>(
      segments: const [
        ButtonSegment(value: RightTab.team, label: Text('Team'), icon: Icon(Icons.groups_2_outlined)),
        ButtonSegment(value: RightTab.myGuy, label: Text('My_Guy'), icon: Icon(Icons.smart_toy_outlined)),
      ],
      selected: {value},
      onSelectionChanged: (set) {
        if (set.isEmpty) return;
        onChanged(set.first);
      },
      showSelectedIcon: false,
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        minimumSize: WidgetStateProperty.all(const Size(0, 40)),
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({
    required this.uid,
    required this.displayName,
  });

  final String uid;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: Text(
                displayName.trim().isEmpty ? 'User' : displayName.trim(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text('User ID: $uid'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder – we will add dark/light, username editing, 15-digit invite ID, etc.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.black.withValues(alpha: 0.12)),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Settings coming next:\n'
          '- Dark/Light\n'
          '- Username\n'
          '- Invite/User ID\n',
        ),
      ),
    );
  }
}

