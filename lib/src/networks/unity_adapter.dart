import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

import '../ads_config.dart';
import '../models/ad_result.dart';
import 'ad_network_adapter.dart';

class UnityAdapter implements AdNetworkAdapter {
  bool _interstitialLoaded = false;
  bool _rewardedLoaded = false;
  String? _interstitialPlacementId;
  String? _rewardedPlacementId;

  @override
  Future<void> initialize(AdsConfig config) async {
    await UnityAds.init(
      gameId: config.appId,
      testMode: config.testMode,
    );
  }

  @override
  Future<void> dispose() async {
    _interstitialLoaded = false;
    _rewardedLoaded = false;
  }

  // --- Interstitial ---

  @override
  bool get isInterstitialLoaded => _interstitialLoaded;

  @override
  Future<void> loadInterstitial(String adUnitId) async {
    _interstitialPlacementId = adUnitId;
    final completer = Completer<void>();
    UnityAds.load(
      placementId: adUnitId,
      onComplete: (placementId) {
        _interstitialLoaded = true;
        if (!completer.isCompleted) completer.complete();
      },
      onFailed: (placementId, error, message) {
        _interstitialLoaded = false;
        debugPrint('Unity interstitial failed to load: $message');
        if (!completer.isCompleted) completer.complete();
      },
    );
    return completer.future;
  }

  @override
  Future<AdResult> showInterstitial() async {
    if (!_interstitialLoaded || _interstitialPlacementId == null) {
      return AdResult.failure('Interstitial ad not loaded');
    }
    final completer = Completer<AdResult>();
    UnityAds.showVideoAd(
      placementId: _interstitialPlacementId!,
      onComplete: (placementId) {
        _interstitialLoaded = false;
        if (!completer.isCompleted) completer.complete(AdResult.success());
      },
      onFailed: (placementId, error, message) {
        _interstitialLoaded = false;
        if (!completer.isCompleted) {
          completer.complete(AdResult.failure(message));
        }
      },
      onSkipped: (placementId) {
        _interstitialLoaded = false;
        if (!completer.isCompleted) completer.complete(AdResult.success());
      },
    );
    return completer.future;
  }

  // --- Rewarded ---

  @override
  bool get isRewardedLoaded => _rewardedLoaded;

  @override
  Future<void> loadRewarded(String adUnitId) async {
    _rewardedPlacementId = adUnitId;
    final completer = Completer<void>();
    UnityAds.load(
      placementId: adUnitId,
      onComplete: (placementId) {
        _rewardedLoaded = true;
        if (!completer.isCompleted) completer.complete();
      },
      onFailed: (placementId, error, message) {
        _rewardedLoaded = false;
        debugPrint('Unity rewarded failed to load: $message');
        if (!completer.isCompleted) completer.complete();
      },
    );
    return completer.future;
  }

  @override
  Future<AdResult> showRewarded() async {
    if (!_rewardedLoaded || _rewardedPlacementId == null) {
      return AdResult.failure('Rewarded ad not loaded');
    }
    final completer = Completer<AdResult>();
    UnityAds.showVideoAd(
      placementId: _rewardedPlacementId!,
      onComplete: (placementId) {
        _rewardedLoaded = false;
        if (!completer.isCompleted) {
          completer.complete(AdResult.success(
            rewardType: 'reward',
            rewardAmount: 1,
          ));
        }
      },
      onFailed: (placementId, error, message) {
        _rewardedLoaded = false;
        if (!completer.isCompleted) {
          completer.complete(AdResult.failure(message));
        }
      },
      onSkipped: (placementId) {
        _rewardedLoaded = false;
        if (!completer.isCompleted) {
          completer.complete(AdResult.failure('User skipped rewarded ad'));
        }
      },
    );
    return completer.future;
  }

  // --- App Open (not supported by Unity) ---

  @override
  bool get isAppOpenLoaded => false;

  @override
  Future<void> loadAppOpen(String adUnitId) async {
    debugPrint('Unity Ads does not support App Open ads');
  }

  @override
  Future<AdResult> showAppOpen() async {
    return AdResult.failure('App Open ads not supported by Unity');
  }

  // --- Banner ---

  @override
  Widget buildBannerAd(String adUnitId, {double? width}) {
    return UnityBannerAd(
      placementId: adUnitId,
      size: BannerSize.standard,
      onLoad: (placementId) {
        debugPrint('Unity banner loaded: $placementId');
      },
      onFailed: (placementId, error, message) {
        debugPrint('Unity banner failed: $message');
      },
    );
  }

  // --- Native (not supported by Unity) ---

  @override
  Widget buildNativeAd(String adUnitId, {double? height}) {
    debugPrint('Unity Ads does not support Native ads');
    return const SizedBox.shrink();
  }
}
