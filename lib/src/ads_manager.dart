import 'package:flutter/widgets.dart';

import 'ads_config.dart';
import 'consent/consent_manager.dart';
import 'models/ad_network.dart';
import 'models/ad_result.dart';
import 'networks/ad_network_adapter.dart';
import 'networks/admob_adapter.dart';
import 'networks/applovin_adapter.dart';
import 'networks/facebook_adapter.dart';
import 'networks/unity_adapter.dart';

/// Main entry point for the ads library.
///
/// Usage:
/// ```dart
/// await AdsManager.instance.initialize(AdsConfig(...));
/// AdsManager.instance.showInterstitial();
/// ```
class AdsManager {
  static final AdsManager instance = AdsManager._();
  AdsManager._();

  AdsConfig? _config;
  AdNetworkAdapter? _adapter;
  bool _initialized = false;

  bool get isInitialized => _initialized;
  AdsConfig? get config => _config;

  /// Initialize the ads library with the given configuration.
  ///
  /// Call this once in your app's `main()` before `runApp()`.
  Future<void> initialize(AdsConfig config) async {
    if (_initialized) {
      debugPrint('AdsManager already initialized');
      return;
    }

    _config = config;
    _adapter = _createAdapter(config.network);

    await _adapter!.initialize(config);

    // Handle consent if enabled (uses Google UMP)
    if (config.enableConsent) {
      await ConsentManager.instance.requestConsent();
    }

    // Preload fullscreen ads
    await _preloadAds();

    _initialized = true;
    debugPrint('AdsManager initialized with ${config.network.name}');
  }

  /// Dispose all ads and reset the manager.
  Future<void> dispose() async {
    await _adapter?.dispose();
    _adapter = null;
    _config = null;
    _initialized = false;
  }

  // --- Interstitial ---

  /// Whether an interstitial ad is loaded and ready to show.
  bool get isInterstitialReady => _adapter?.isInterstitialLoaded ?? false;

  /// Show a preloaded interstitial ad. Auto-reloads after showing.
  Future<AdResult> showInterstitial() async {
    _ensureInitialized();
    final result = await _adapter!.showInterstitial();
    // Auto-reload
    if (_config?.interstitialAdUnitId != null) {
      _adapter!.loadInterstitial(_config!.interstitialAdUnitId!);
    }
    return result;
  }

  // --- Rewarded ---

  /// Whether a rewarded ad is loaded and ready to show.
  bool get isRewardedReady => _adapter?.isRewardedLoaded ?? false;

  /// Show a preloaded rewarded ad. Returns reward info on success. Auto-reloads.
  ///
  /// ```dart
  /// final result = await AdsManager.instance.showRewarded();
  /// if (result.success) {
  ///   print('Earned ${result.rewardAmount} ${result.rewardType}');
  /// }
  /// ```
  Future<AdResult> showRewarded({void Function(AdResult)? onReward}) async {
    _ensureInitialized();
    final result = await _adapter!.showRewarded();
    if (result.success && onReward != null) {
      onReward(result);
    }
    // Auto-reload
    if (_config?.rewardedAdUnitId != null) {
      _adapter!.loadRewarded(_config!.rewardedAdUnitId!);
    }
    return result;
  }

  // --- App Open ---

  /// Whether an app open ad is loaded and ready to show.
  bool get isAppOpenReady => _adapter?.isAppOpenLoaded ?? false;

  /// Show a preloaded app open ad. Auto-reloads.
  Future<AdResult> showAppOpenAd() async {
    _ensureInitialized();
    final result = await _adapter!.showAppOpen();
    // Auto-reload
    if (_config?.appOpenAdUnitId != null) {
      _adapter!.loadAppOpen(_config!.appOpenAdUnitId!);
    }
    return result;
  }

  // --- Banner ---

  /// Build a banner ad widget. Use this inside your widget tree.
  Widget buildBannerAd({double? width}) {
    _ensureInitialized();
    if (_config?.bannerAdUnitId == null) {
      return const SizedBox.shrink();
    }
    return _adapter!.buildBannerAd(_config!.bannerAdUnitId!, width: width);
  }

  // --- Native ---

  /// Build a native ad widget. Use this inside your widget tree.
  Widget buildNativeAd({double? height}) {
    _ensureInitialized();
    if (_config?.nativeAdUnitId == null) {
      return const SizedBox.shrink();
    }
    return _adapter!.buildNativeAd(_config!.nativeAdUnitId!, height: height);
  }

  // --- Private helpers ---

  AdNetworkAdapter _createAdapter(AdNetwork network) {
    switch (network) {
      case AdNetwork.admob:
        return AdmobAdapter();
      case AdNetwork.facebook:
        return FacebookAdapter();
      case AdNetwork.unity:
        return UnityAdapter();
      case AdNetwork.applovin:
        return ApplovinAdapter();
    }
  }

  Future<void> _preloadAds() async {
    final futures = <Future<void>>[];

    if (_config?.interstitialAdUnitId != null) {
      futures.add(_adapter!.loadInterstitial(_config!.interstitialAdUnitId!));
    }
    if (_config?.rewardedAdUnitId != null) {
      futures.add(_adapter!.loadRewarded(_config!.rewardedAdUnitId!));
    }
    if (_config?.appOpenAdUnitId != null) {
      futures.add(_adapter!.loadAppOpen(_config!.appOpenAdUnitId!));
    }

    await Future.wait(futures);
  }

  void _ensureInitialized() {
    assert(_initialized, 'AdsManager not initialized. Call initialize() first.');
    if (!_initialized) {
      throw StateError('AdsManager not initialized. Call initialize() first.');
    }
  }
}
