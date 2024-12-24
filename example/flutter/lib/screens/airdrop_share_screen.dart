import 'package:flutter/material.dart';

import '../widgets/multisig_setup_form.dart';

class AirDropShareScreen extends StatelessWidget {
  const AirDropShareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AirDrop Exchange'),
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
                          const Icon(Icons.ios_share, size: 64),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Implement AirDrop sharing
                            },
                            icon: const Icon(Icons.share),
                            label: const Text('Share via AirDrop'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Note: AirDrop is only available on iOS devices',
                      style: TextStyle(fontStyle: FontStyle.italic),
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
