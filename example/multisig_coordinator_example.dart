import 'package:bip48/bip48.dart';
import 'package:coinlib/coinlib.dart';
import 'package:multisig_coordinator/multisig_coordinator.dart';

/// Example showing how to use the multisig coordinator.
void main() async {
  // Initialize coinlib.
  await loadCoinlib();

  print('\nExample 1: Using Trezor test vectors for 2-of-3 P2SH multisig');
  print('==========================================================');

  // These are from Trezor's test vectors.
  final trezorXpubs = [
    "xpub6EgGHjcvovyMw8xyoJw9ZRUfjGLS1KUmbjVqMKSNfM6E8hq4EbQ3CpBxfGCPsdxzXtCFuKCxYarzY1TYCG1cmPwq9ep548cM9Ws9rB8V8E8",
    "xpub6EexEtC6c2rN5QCpzrL2nUNGDfxizCi3kM1C2Mk5a6PfQs4H3F72C642M3XbnzycvvtD4U6vzn1nYPpH8VUmiREc2YuXP3EFgN1uLTrVEj4",
    "xpub6F6Tq7sVLDrhuV3SpvsVKrKofF6Hx7oKxWLFkN6dbepuMhuYueKUnQo7E972GJyeRHqPKu44V1C9zBL6KW47GXjuprhbNrPQahWAFKoL2rN",
  ];

  // Define shared parameters matching Trezor test vectors.
  final params = MultisigParams(
    threshold: 2,
    totalCosigners: 3,
    coinType: 0, // Bitcoin mainnet.
    account: 0, // First account.
    scriptType: Bip48ScriptType.p2shMultisig, // P2SH multisig.
  );

  // Create coordinator starting with first xpub.
  final coordinator = MultisigCoordinator.fromXpub(
    accountXpub: trezorXpubs[0],
    params: params,
  );

  print('First cosigner xpub: ${trezorXpubs[0]}');

  // Add other cosigners.
  coordinator.addCosigner(trezorXpubs[1]);
  coordinator.addCosigner(trezorXpubs[2]);

  // Once complete, create the wallet and verify addresses.
  if (coordinator.isComplete()) {
    // Get first receiving and change addresses.
    final addresses =
        coordinator.getVerificationAddresses(indices: [0], isChange: false);
    final changeAddresses =
        coordinator.getVerificationAddresses(indices: [0], isChange: true);

    print('\nFirst receiving address: ${addresses[0]}');
    print('First change address: ${changeAddresses[0]}');
  }

  print('\nExample 2: Using master private key');
  print('================================');

  // Create from test seed.
  final seedHex = "000102030405060708090a0b0c0d0e0f";
  final masterKey = HDPrivateKey.fromSeed(hexToBytes(seedHex));

  // Create coordinator with private key.
  final privKeyCoordinator = MultisigCoordinator(
    localMasterKey: masterKey,
    params: params,
  );

  // Get account xpub to share with others.
  final accountXpub = privKeyCoordinator.getLocalAccountXpub();
  print('Account xpub to share: $accountXpub');

  // Add same cosigner xpubs as before.
  privKeyCoordinator.addCosigner(trezorXpubs[1]);
  privKeyCoordinator.addCosigner(trezorXpubs[2]);

  if (privKeyCoordinator.isComplete()) {
    // Get addresses for verification.
    final addresses = privKeyCoordinator
        .getVerificationAddresses(indices: [0], isChange: false);
    final changeAddresses = privKeyCoordinator
        .getVerificationAddresses(indices: [0], isChange: true);

    print('\nFirst receiving address: ${addresses[0]}');
    print('First change address: ${changeAddresses[0]}');
  }
}
