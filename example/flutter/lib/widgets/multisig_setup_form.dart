import 'package:bip48/bip48.dart';
import 'package:flutter/material.dart';

class MultisigSetupForm extends StatefulWidget {
  const MultisigSetupForm({super.key});

  @override
  State<MultisigSetupForm> createState() => _MultisigSetupFormState();
}

class _MultisigSetupFormState extends State<MultisigSetupForm> {
  Bip48ScriptType _scriptType = Bip48ScriptType.p2wshMultisig;
  int _totalCosigners = 3;
  int _threshold = 2;
  bool _isTestnet = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Multisig Setup',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Script Type Selection
            DropdownButtonFormField<Bip48ScriptType>(
              value: _scriptType,
              decoration: const InputDecoration(
                labelText: 'Script Type',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: Bip48ScriptType.p2shMultisig,
                  child: Text('Legacy P2SH'),
                ),
                DropdownMenuItem(
                  value: Bip48ScriptType.p2shP2wshMultisig,
                  child: Text('Nested SegWit (P2SH-P2WSH)'),
                ),
                DropdownMenuItem(
                  value: Bip48ScriptType.p2wshMultisig,
                  child: Text('Native SegWit (P2WSH)'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _scriptType = value);
                }
              },
            ),
            const SizedBox(height: 16),
            // Total Cosigners
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Cosigners'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _totalCosigners,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(13, (i) => i + 2)
                            .map((n) => DropdownMenuItem(
                                  value: n,
                                  child: Text('$n cosigners'),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _totalCosigners = value;
                              if (_threshold > value) {
                                _threshold = value;
                              }
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Threshold Selection
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Required Signatures'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _threshold,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(_totalCosigners, (i) => i + 1)
                            .map((n) => DropdownMenuItem(
                                  value: n,
                                  child: Text('$n of $_totalCosigners'),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _threshold = value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Network Selection
            SwitchListTile(
              title: const Text('Use Testnet'),
              value: _isTestnet,
              onChanged: (value) {
                setState(() => _isTestnet = value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
