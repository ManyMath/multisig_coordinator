import 'dart:io';

import 'package:bip48/bip48.dart';
import 'package:coinlib/coinlib.dart';
import 'package:multisig_coordinator/multisig_coordinator.dart';

/// Prompts for user input with the given message.
String prompt(String message) {
  stdout.write('\n$message: ');
  return stdin.readLineSync() ?? '';
}

/// Prompts for yes/no input.
bool promptYesNo(String message) {
  while (true) {
    final response = prompt('$message (y/n)').toLowerCase();
    if (response == 'y' || response == 'yes') return true;
    if (response == 'n' || response == 'no') return false;
    print('Please answer y or n');
  }
}

/// Prompts for a number within a range.
int promptNumber(String message, {required int min, required int max}) {
  while (true) {
    final input = prompt(message);
    try {
      final num = int.parse(input);
      if (num >= min && num <= max) return num;
      print('Please enter a number between $min and $max');
    } catch (_) {
      print('Please enter a valid number');
    }
  }
}

/// Gets multisig parameters from user input.
MultisigParams getMultisigParams() {
  final scriptTypes = {
    1: Bip48ScriptType.p2shMultisig,
    2: Bip48ScriptType.p2shP2wshMultisig,
    3: Bip48ScriptType.p2wshMultisig,
  };

  print('\nScript type options:');
  print('1. Legacy P2SH');
  print('2. Nested SegWit (P2SH-P2WSH)');
  print('3. Native SegWit (P2WSH) - Recommended');

  final scriptChoice = promptNumber(
    'Choose script type (1-3)',
    min: 1,
    max: 3,
  );

  final totalCosigners = promptNumber(
    'Enter total number of cosigners (2-15)',
    min: 2,
    max: 15,
  );

  final threshold = promptNumber(
    'Enter number of required signatures (1-$totalCosigners)',
    min: 1,
    max: totalCosigners,
  );

  final network = promptYesNo('Use testnet?');

  return MultisigParams(
    threshold: threshold,
    totalCosigners: totalCosigners,
    coinType: network ? 1 : 0, // 0=mainnet, 1=testnet
    account: 0,
    scriptType: scriptTypes[scriptChoice]!,
  );
}

Future<void> runTrezorTest() async {
  print('\nRunning Trezor test vector example:');
  print('2-of-3 P2SH multisig, mainnet, account 0');

  // Trezor test vectors.
  //
  // See https://github.com/trezor/trezor-firmware/blob/f10dc86da21734fd7be36bbd269da112747df1f3/tests/device_tests/bitcoin/test_getaddress_show.py#L177.
  final trezorXpubs = [
    "xpub6EgGHjcvovyMw8xyoJw9ZRUfjGLS1KUmbjVqMKSNfM6E8hq4EbQ3CpBxfGCPsdxzXtCFuKCxYarzY1TYCG1cmPwq9ep548cM9Ws9rB8V8E8",
    "xpub6EexEtC6c2rN5QCpzrL2nUNGDfxizCi3kM1C2Mk5a6PfQs4H3F72C642M3XbnzycvvtD4U6vzn1nYPpH8VUmiREc2YuXP3EFgN1uLTrVEj4",
    "xpub6F6Tq7sVLDrhuV3SpvsVKrKofF6Hx7oKxWLFkN6dbepuMhuYueKUnQo7E972GJyeRHqPKu44V1C9zBL6KW47GXjuprhbNrPQahWAFKoL2rN",
  ];

  final params = MultisigParams(
    threshold: 2,
    totalCosigners: 3,
    coinType: 0, // Bitcoin mainnet
    account: 0,
    scriptType: Bip48ScriptType.p2shMultisig,
  );

  final coordinator = MultisigCoordinator.fromXpub(
    accountXpub: trezorXpubs[0],
    params: params,
  );

  print('\nUsing xpubs from test vectors:');
  print('1. ${trezorXpubs[0]}');
  print('2. ${trezorXpubs[1]}');
  print('3. ${trezorXpubs[2]}');

  coordinator.addCosigner(trezorXpubs[1]);
  coordinator.addCosigner(trezorXpubs[2]);

  if (coordinator.isComplete()) {
    print('\nVerification addresses:');

    final receivingAddresses = coordinator.getVerificationAddresses(
      indices: [0],
      isChange: false,
    );
    print('\nFirst receiving address (should match Trezor test):');
    print('Expected: 33TU5DyVi2kFSGQUfmZxNHgPDPqruwdesY');
    print('Derived:  ${receivingAddresses[0]}');
  }
}

Future<void> runInteractive() async {
  print('\nMultisig Wallet Setup');
  print('===================');

  final params = getMultisigParams();

  print('\nDo you have:');
  print('1. A master private key (for signing)');
  print('2. Only an xpub (for verification)');

  final usePrivKey = promptNumber('Choose option (1-2)', min: 1, max: 2) == 1;

  late MultisigCoordinator coordinator;

  if (usePrivKey) {
    print('\nEnter your HD wallet seed as hex (e.g., 000102...):');
    final seedHex = stdin.readLineSync() ?? '';
    try {
      final masterKey = HDPrivateKey.fromSeed(hexToBytes(seedHex));
      coordinator = MultisigCoordinator(
        localMasterKey: masterKey,
        params: params,
      );
    } catch (e) {
      print('Error: Invalid seed format');
      return;
    }
  } else {
    print('\nEnter your xpub:');
    final xpub = stdin.readLineSync() ?? '';
    try {
      coordinator = MultisigCoordinator.fromXpub(
        accountXpub: xpub,
        params: params,
      );
    } catch (e) {
      print('Error: Invalid xpub format');
      return;
    }
  }

  print('\nYour account xpub to share with other cosigners:');
  print(coordinator.getLocalAccountXpub());

  print('\nNow enter the other cosigners\' xpubs:');
  for (var i = 1; i < params.totalCosigners; i++) {
    print('\nEnter cosigner $i xpub:');
    final cosignerXpub = stdin.readLineSync() ?? '';
    try {
      coordinator.addCosigner(cosignerXpub);
    } catch (e) {
      print('Error: Invalid xpub format');
      return;
    }
  }

  if (coordinator.isComplete()) {
    print('\nVerification addresses (share these with other participants):');

    final receivingAddresses = coordinator.getVerificationAddresses(
      indices: [0, 1],
      isChange: false,
    );
    print('\nFirst two receiving addresses:');
    print('1. ${receivingAddresses[0]}');
    print('2. ${receivingAddresses[1]}');

    final changeAddresses = coordinator.getVerificationAddresses(
      indices: [0],
      isChange: true,
    );
    print('\nFirst change address:');
    print('1. ${changeAddresses[0]}');

    print('\nVerify these addresses match what other participants derived!');

    if (usePrivKey) {
      print('\nYour wallet is ready for signing.');
    } else {
      print('\nYour watch-only wallet is ready.');
    }
  }
}

Future<void> main() async {
  // Initialize coinlib.
  await loadCoinlib();

  print('\nMultisig Coordinator Examples');
  print('==========================');
  print('1. Run with Trezor test vectors');
  print('2. Interactive setup');

  final choice = promptNumber('Choose option (1-2)', min: 1, max: 2);

  if (choice == 1) {
    await runTrezorTest();
  } else {
    await runInteractive();
  }
}
