import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loyalty_wallet/providers/auth_provider.dart';
import 'package:loyalty_wallet/services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Account'),
            leading: const Icon(Icons.account_circle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to account settings
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Get alerts for expiring cards and offers'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
              // Update notification settings
            },
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: _darkModeEnabled,
            onChanged: (value) {
              setState(() {
                _darkModeEnabled = value;
              });
              // Update theme settings
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('About'),
            leading: const Icon(Icons.info),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Loyalty Wallet',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2023 Everyday Rewards Inc.',
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Sign Out'),
            leading: const Icon(Icons.logout),
            onTap: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
