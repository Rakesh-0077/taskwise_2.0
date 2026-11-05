import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_store.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<TaskStore>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(store.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text('${store.userEmail} (${store.userMode})'),
            currentAccountPicture: const CircleAvatar(child: Icon(Icons.person)),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Appearance Theme', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
          RadioListTile<String>(
            title: const Text('System Default'),
            value: 'System',
            groupValue: store.themeModeSetting,
            onChanged: (val) => store.setThemeMode(val!),
          ),
          RadioListTile<String>(
            title: const Text('Light Mode'),
            value: 'Light',
            groupValue: store.themeModeSetting,
            onChanged: (val) => store.setThemeMode(val!),
          ),
          RadioListTile<String>(
            title: const Text('Dark Mode'),
            value: 'Dark',
            groupValue: store.themeModeSetting,
            onChanged: (val) => store.setThemeMode(val!),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Enable Ding Notifications'),
            subtitle: const Text('Get popup reminders for pending tasks'),
            value: store.notificationsEnabled,
            onChanged: (val) => store.setNotificationsEnabled(val),
          ),
          const Divider(),
          ListTile(
            title: const Text('Log Out', style: TextStyle(color: Colors.red)),
            leading: const Icon(Icons.logout, color: Colors.red),
            onTap: () {
              store.logout();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
            },
          ),
        ],
      ),
    );
  }
}