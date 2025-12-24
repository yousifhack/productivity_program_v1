import 'package:flutter/material.dart';

import '../../../core/utils/constants.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: AppConstants.pagePadding,
        child: ListView(
          children: const [
            ListTile(
              title: Text('Lock Mode'),
              subtitle: Text('Kiosk-style lock with PIN (coming soon)'),
            ),
            ListTile(
              title: Text('Keep Screen Awake'),
              subtitle: Text('Enabled while plugged in'),
            ),
          ],
        ),
      ),
    );
  }
}
