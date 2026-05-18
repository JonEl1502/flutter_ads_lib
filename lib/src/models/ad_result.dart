/// Result returned from ad events.
class AdResult {
  final bool success;
  final String? errorMessage;
  final String? rewardType;
  final num? rewardAmount;

  const AdResult({
    required this.success,
    this.errorMessage,
    this.rewardType,
    this.rewardAmount,
  });

  factory AdResult.success({String? rewardType, num? rewardAmount}) {
    return AdResult(
      success: true,
      rewardType: rewardType,
      rewardAmount: rewardAmount,
    );
  }

  factory AdResult.failure(String errorMessage) {
    return AdResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}
