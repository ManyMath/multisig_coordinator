import 'dart:typed_data';

import 'package:bip48/bip48.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

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
              items: const [
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

/// A screen demonstrating how to use nfc_manager for reading/writing NFC tags.
class NFCShareScreen extends StatefulWidget {
  const NFCShareScreen({super.key});

  @override
  State<NFCShareScreen> createState() => _NFCShareScreenState();
}

class _NFCShareScreenState extends State<NFCShareScreen> {
  bool _isNfcAvailable = false;
  String _status = 'Checking NFC availability...';
  NfcTag? _detectedTag; // We'll store the most recently discovered tag here.

  @override
  void initState() {
    super.initState();
    _checkNfcAvailability();
  }

  /// Check if NFC is available on this device.
  Future<void> _checkNfcAvailability() async {
    final isAvailable = await NfcManager.instance.isAvailable();
    setState(() {
      _isNfcAvailable = isAvailable;
      _status = isAvailable
          ? 'NFC is available'
          : 'NFC is not available on this device';
    });
  }

  /// Start an NFC session and handle discovered tags with nfc_manager.
  Future<void> _startNfcSession() async {
    if (!_isNfcAvailable) return;

    setState(() => _status = 'Waiting for NFC tag...');

    /// On iOS, the session automatically ends once onDiscovered completes.
    /// On Android, we should call stopSession() when finished.
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          // We have a tag! Save it in state.
          setState(() {
            _detectedTag = tag;
            _status = 'Tag detected!';
          });

          // Check if this tag supports NDEF.
          final ndef = Ndef.from(tag);
          if (ndef == null) {
            setState(() {
              _status = 'Tag is not NDEF compatible.';
            });
            NfcManager.instance.stopSession(errorMessage: 'Not NDEF.');
            return;
          }

          // 1) READ any existing NDEF data.
          final cachedMessage = ndef.cachedMessage;
          if (cachedMessage != null) {
            String readData = '';
            for (var record in cachedMessage.records) {
              // We'll just show type & payload in hex form for demo.
              readData +=
                  'TNF=${record.typeNameFormat}, type=${record.type}, payload=${record.payload}\n';
            }
            setState(() {
              _status = 'Read data:\n$readData';
            });
          } else {
            setState(() => _status = 'Tag has no NDEF message.');
          }

          // 2) Write a simple text record if the tag is writable.
          if (ndef.isWritable) {
            final languageCode = 'en';
            final xpubData = 'xpub...'; // Your xpub would go here.
            final payload = <int>[
              languageCode.length,
              ...languageCode.codeUnits,
              ...xpubData.codeUnits,
            ];

            final textRecord = NdefRecord(
              typeNameFormat: NdefTypeNameFormat.nfcWellknown,
              type: Uint8List.fromList([0x54]), // 'T'
              identifier: Uint8List(0),
              payload: Uint8List.fromList(payload),
            );

            final message = NdefMessage([textRecord]);
            await ndef.write(message);

            setState(() => _status += '\nData written successfully!');
          } else {
            setState(() => _status += '\nTag is not writable.');
          }

          // 3) Done. Stop the NFC session.
          NfcManager.instance.stopSession();
        } catch (e) {
          setState(() => _status = 'Error: $e');
          // For iOS, you can display an error message in the system UI:
          NfcManager.instance.stopSession(errorMessage: 'Failed: $e');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    /// The UI has two main parts:
    /// 1. Your MultisigSetupForm
    /// 2. A card showing NFC status + a button to start scanning
    return Scaffold(
      appBar: AppBar(
        title: const Text('NFC Exchange'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Your real multisig setup form
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
                          Icon(
                            _isNfcAvailable ? Icons.nfc : Icons.nfc_outlined,
                            size: 64,
                            color: _isNfcAvailable ? Colors.blue : Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _status,
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          if (_isNfcAvailable)
                            ElevatedButton.icon(
                              onPressed: _startNfcSession,
                              icon: const Icon(Icons.tap_and_play),
                              label: const Text('Start NFC Session'),
                            ),
                        ],
                      ),
                    ),
                    if (_detectedTag != null) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Last Detected Tag:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        // For Android, you could retrieve the identifier from NfcA, NfcB, etc.
                        // For iOS, the NFC tag info differs. So, we'll just display the raw `tag`.
                        'Tag Data: $_detectedTag',
                      ),
                    ],
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
