import 'package:flutter/material.dart';

import '../widgets/multisig_setup_form.dart';

class ManualShareScreen extends StatelessWidget {
  const ManualShareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Setup'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const MultisigSetupForm(),
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Account xPub:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    // TODO: Show xpub and copy button
                    Text('xpub...'),
                    SizedBox(height: 16),
                    Text(
                      'Cosigner xPubs:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    // TODO: Add text fields for entering cosigner xpubs
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Enter cosigner xpub',
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
