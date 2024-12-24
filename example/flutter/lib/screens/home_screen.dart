import 'package:flutter/material.dart';

import 'airdrop_share_screen.dart';
import 'bluetooth_share_screen.dart';
import 'manual_share_screen.dart';
import 'nfc_share_screen.dart';
import 'ur_share_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multisig Setup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choose how to exchange information with other participants:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            _buildSharingOption(
              context,
              icon: Icons.copy,
              title: 'Manual Copy/Paste',
              subtitle: 'Manually exchange information between participants',
              screen: const ManualShareScreen(),
            ),
            _buildSharingOption(
              context,
              icon: Icons.qr_code,
              title: 'Camera/UR Code',
              subtitle: 'Exchange using camera and UR codes',
              screen: const URShareScreen(),
            ),
            _buildSharingOption(
              context,
              icon: Icons.nfc,
              title: 'NFC/Tap',
              subtitle: 'Exchange by tapping devices together',
              screen: const NFCShareScreen(),
            ),
            _buildSharingOption(
              context,
              icon: Icons.ios_share,
              title: 'AirDrop',
              subtitle: 'Share using AirDrop on iOS devices',
              screen: const AirDropShareScreen(),
            ),
            _buildSharingOption(
              context,
              icon: Icons.bluetooth,
              title: 'Bluetooth',
              subtitle: 'Exchange using Bluetooth',
              screen: const BluetoothShareScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSharingOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget screen,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
      ),
    );
  }
}
