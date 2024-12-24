import 'package:flutter/material.dart';

import '../widgets/multisig_setup_form.dart';

class BluetoothShareScreen extends StatelessWidget {
  const BluetoothShareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Exchange'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const MultisigSetupForm(),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.bluetooth_searching, size: 64),
                          const SizedBox(height: 16),
                          const Text(
                            'Scanning for nearby devices...',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          // Placeholder for device list
                          ListView(
                            shrinkWrap: true,
                            children: const [
                              ListTile(
                                leading: Icon(Icons.bluetooth),
                                title: Text('No devices found'),
                                subtitle:
                                    Text('Make sure Bluetooth is enabled'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Implement Bluetooth scanning
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Scan Again'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
