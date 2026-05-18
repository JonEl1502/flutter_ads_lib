import 'package:flutter/widgets.dart';
import '../ads_config.dart';
import '../models/ad_result.dart';

/// Abstract interface that all ad network adapters must implement.
abstract class AdNetworkAdapter {
  /// Initialize the ad SDK with the given config.
  Future<void> initialize(AdsConfig config);

  /// Dispose all loaded ads and release resources.
  Future<void> dispose();

  // --- Interstitial ---
  Future<void> loadInterstitial(String adUnitId);
  Future<AdResult> showInterstitial();
  bool get isInterstitialLoaded;

  // --- Rewarded ---
  Future<void> loadRewarded(String adUnitId);
  Future<AdResult> showRewarded();
  bool get isRewardedLoaded;

  // --- App Open ---
  Future<void> loadAppOpen(String adUnitId);
  Future<AdResult> showAppOpen();
  bool get isAppOpenLoaded;

  // --- Banner ---
  Widget buildBannerAd(String adUnitId, {double? width});

  // --- Native ---
  Widget buildNativeAd(String adUnitId, {double? height});
}
