import 'models/ad_network.dart';

/// Configuration for the ads library.
///
/// Pass your app ID and ad unit IDs for the selected network.
class AdsConfig {
  final AdNetwork network;
  final String appId;
  final String? bannerAdUnitId;
  final String? interstitialAdUnitId;
  final String? rewardedAdUnitId;
  final String? nativeAdUnitId;
  final String? appOpenAdUnitId;
  final bool enableConsent;
  final bool testMode;

  const AdsConfig({
    required this.network,
    required this.appId,
    this.bannerAdUnitId,
    this.interstitialAdUnitId,
    this.rewardedAdUnitId,
    this.nativeAdUnitId,
    this.appOpenAdUnitId,
    this.enableConsent = true,
    this.testMode = false,
  });
}
