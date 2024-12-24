import 'package:bip48/bip48.dart';
import 'package:coinlib/coinlib.dart';
import 'package:multisig_coordinator/multisig_coordinator.dart';
import 'package:test/test.dart';

void main() {
  group('MultisigCoordinator Tests', () {
    late List<String> trezorXpubs;
    late MultisigParams params;

    setUpAll(() async {
      await loadCoinlib();

      // Trezor test vectors.
      //
      // See https://github.com/trezor/trezor-firmware/blob/f10dc86da21734fd7be36bbd269da112747df1f3/tests/device_tests/bitcoin/test_getaddress_show.py#L177.
      trezorXpubs = [
        "xpub6EgGHjcvovyMw8xyoJw9ZRUfjGLS1KUmbjVqMKSNfM6E8hq4EbQ3CpBxfGCPsdxzXtCFuKCxYarzY1TYCG1cmPwq9ep548cM9Ws9rB8V8E8",
        "xpub6EexEtC6c2rN5QCpzrL2nUNGDfxizCi3kM1C2Mk5a6PfQs4H3F72C642M3XbnzycvvtD4U6vzn1nYPpH8VUmiREc2YuXP3EFgN1uLTrVEj4",
        "xpub6F6Tq7sVLDrhuV3SpvsVKrKofF6Hx7oKxWLFkN6dbepuMhuYueKUnQo7E972GJyeRHqPKu44V1C9zBL6KW47GXjuprhbNrPQahWAFKoL2rN",
      ];

      params = MultisigParams(
        threshold: 2,
        totalCosigners: 3,
        coinType: 0,
        account: 0,
        scriptType: Bip48ScriptType.p2shMultisig,
      );
    });

    group('Constructor Tests', () {
      test('Create from master key', () {
        final seedHex = "000102030405060708090a0b0c0d0e0f";
        final masterKey = HDPrivateKey.fromSeed(hexToBytes(seedHex));

        final coordinator = MultisigCoordinator(
          localMasterKey: masterKey,
          params: params,
        );

        expect(coordinator.isComplete(), false);
      });

      test('Create from xpub', () {
        final coordinator = MultisigCoordinator.fromXpub(
          accountXpub: trezorXpubs[0],
          params: params,
        );

        expect(coordinator.isComplete(), false);
        expect(coordinator.getLocalAccountXpub(), trezorXpubs[0]);
      });

      test('Invalid parameters throw ArgumentError', () {
        final invalidParams = MultisigParams(
          threshold: 4, // Invalid: more than total
          totalCosigners: 3,
          coinType: 0,
          account: 0,
          scriptType: Bip48ScriptType.p2shMultisig,
        );

        expect(
          () => MultisigCoordinator.fromXpub(
            accountXpub: trezorXpubs[0],
            params: invalidParams,
          ),
          throwsArgumentError,
        );
      });
    });

    group('Cosigner Management Tests', () {
      late MultisigCoordinator coordinator;

      setUp(() {
        coordinator = MultisigCoordinator.fromXpub(
          accountXpub: trezorXpubs[0],
          params: params,
        );
      });

      test('Add cosigners incrementally', () {
        expect(coordinator.isComplete(), false);

        coordinator.addCosigner(trezorXpubs[1]);
        expect(coordinator.isComplete(), false);

        coordinator.addCosigner(trezorXpubs[2]);
        expect(coordinator.isComplete(), true);
      });

      test('Cannot add more than N-1 cosigners', () {
        coordinator.addCosigner(trezorXpubs[1]);
        coordinator.addCosigner(trezorXpubs[2]);

        expect(
          () => coordinator.addCosigner("xpub...extra"),
          throwsStateError,
        );
      });
    });

    group('Address Derivation Tests', () {
      test('Derive addresses matches Trezor test vector', () {
        final coordinator = MultisigCoordinator.fromXpub(
          accountXpub: trezorXpubs[0],
          params: params,
        );

        coordinator.addCosigner(trezorXpubs[1]);
        coordinator.addCosigner(trezorXpubs[2]);

        final addresses = coordinator.getVerificationAddresses(
          indices: [0],
          isChange: false,
        );

        // This is the known good address from Trezor's test vectors.
        expect(addresses[0], "33TU5DyVi2kFSGQUfmZxNHgPDPqruwdesY");
      });

      test('Incomplete coordinator cannot derive addresses', () {
        final coordinator = MultisigCoordinator.fromXpub(
          accountXpub: trezorXpubs[0],
          params: params,
        );

        // Only add one cosigner
        coordinator.addCosigner(trezorXpubs[1]);

        expect(
          () => coordinator.getVerificationAddresses(
            indices: [0],
            isChange: false,
          ),
          throwsStateError,
        );
      });
    });

    group('Address Verification Tests', () {
      test('Verify matching addresses returns true', () {
        final coordinator = MultisigCoordinator.fromXpub(
          accountXpub: trezorXpubs[0],
          params: params,
        );

        coordinator.addCosigner(trezorXpubs[1]);
        coordinator.addCosigner(trezorXpubs[2]);

        final addresses = coordinator.getVerificationAddresses(
          indices: [0, 1],
          isChange: false,
        );

        expect(
          coordinator.verifyAddresses(
            addresses,
            indices: [0, 1],
            isChange: false,
          ),
          true,
        );
      });

      test('Verify mismatched addresses returns false', () {
        final coordinator = MultisigCoordinator.fromXpub(
          accountXpub: trezorXpubs[0],
          params: params,
        );

        coordinator.addCosigner(trezorXpubs[1]);
        coordinator.addCosigner(trezorXpubs[2]);

        expect(
          coordinator.verifyAddresses(
            ["wrongaddress1", "wrongaddress2"],
            indices: [0, 1],
            isChange: false,
          ),
          false,
        );
      });

      test('Verify addresses fails when incomplete', () {
        final coordinator = MultisigCoordinator.fromXpub(
          accountXpub: trezorXpubs[0],
          params: params,
        );

        // Only add one cosigner
        coordinator.addCosigner(trezorXpubs[1]);

        expect(
          coordinator.verifyAddresses(
            ["someaddress"],
            indices: [0],
            isChange: false,
          ),
          false,
        );
      });
    });
  });
}
