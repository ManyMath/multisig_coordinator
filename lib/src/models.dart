import 'package:bip48/bip48.dart';

/// Represents the parameters needed to create a shared multisig account.
class MultisigParams {
  /// Number of required signatures (M in M-of-N).
  final int threshold;

  /// Total number of participants (N in M-of-N).
  final int totalCosigners;

  /// BIP44 coin type (e.g., 0 for Bitcoin mainnet).
  final int coinType;

  /// BIP44/48 account index.
  final int account;

  /// BIP48 script type (e.g., p2sh, p2wsh).
  final Bip48ScriptType scriptType;

  /// Creates a new set of multisig parameters.
  const MultisigParams({
    required this.threshold,
    required this.totalCosigners,
    required this.coinType,
    required this.account,
    required this.scriptType,
  });

  /// Validates the parameters for consistency.
  ///
  /// Returns true if all parameters are valid:
  /// - threshold > 0
  /// - threshold <= totalCosigners
  /// - account >= 0
  /// - coinType >= 0
  bool isValid() {
    return threshold > 0 &&
        threshold <= totalCosigners &&
        account >= 0 &&
        coinType >= 0;
  }
}

/// Represents a participant in the multisig setup process.
class CosignerInfo {
  /// The cosigner's BIP48 account-level extended public key.
  final String accountXpub;

  /// Position in the sorted set of cosigners (0-based).
  final int index;

  /// Creates info about a cosigner participant.
  const CosignerInfo({
    required this.accountXpub,
    required this.index,
  });
}
