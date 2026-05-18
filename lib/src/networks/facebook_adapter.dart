import 'dart:async';

import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/widgets.dart';

import '../ads_config.dart';
import '../models/ad_result.dart';
import 'ad_network_adapter.dart';

class FacebookAdapter implements AdNetworkAdapter {
  bool _interstitialLoaded = false;
  bool _rewardedLoaded = false;

  Completer<AdResult>? _interstitialShowCompleter;
  Completer<AdResult>? _rewardedShowCompleter;
  bool _rewardedVideoCompleted = false;

  @override
  Future<void> initialize(AdsConfig config) async {
    await FacebookAudienceNetwork.init(
      testingId: config.testMode ? 'YOUR_TEST_DEVICE_HASH' : null,
    );
  }

  @override
  Future<void> dispose() async {
    _interstitialLoaded = false;
    _rewardedLoaded = false;
    FacebookInterstitialAd.destroyInterstitialAd();
    FacebookRewardedVideoAd.destroyRewardedVideoAd();
  }

  // --- Interstitial ---

  @override
  bool get isInterstitialLoaded => _interstitialLoaded;

  @override
  Future<void> loadInterstitial(String adUnitId) async {
    final completer = Completer<void>();
    FacebookInterstitialAd.loadInterstitialAd(
      placementId: adUnitId,
      listener: (result, value) {
        if (result == InterstitialAdResult.LOADED) {
          _interstitialLoaded = true;
          if (!completer.isCompleted) completer.complete();
        } else if (result == InterstitialAdResult.ERROR) {
          _interstitialLoaded = false;
          debugPrint('Facebook interstitial failed to load: $value');
          if (!completer.isCompleted) completer.complete();
        } else if (result == InterstitialAdResult.DISMISSED) {
          _interstitialLoaded = false;
          if (_interstitialShowCompleter != null &&
              !_interstitialShowCompleter!.isCompleted) {
            _interstitialShowCompleter!.complete(AdResult.success());
          }
        }
      },
    );
    return completer.future;
  }

  @override
  Future<AdResult> showInterstitial() async {
    if (!_interstitialLoaded) {
      return AdResult.failure('Interstitial ad not loaded');
    }
    _interstitialShowCompleter = Completer<AdResult>();
    FacebookInterstitialAd.showInterstitialAd();
    return _interstitialShowCompleter!.future;
  }

  // --- Rewarded ---

  @override
  bool get isRewardedLoaded => _rewardedLoaded;

  @override
  Future<void> loadRewarded(String adUnitId) async {
    final completer = Completer<void>();
    _rewardedVideoCompleted = false;

    FacebookRewardedVideoAd.loadRewardedVideoAd(
      placementId: adUnitId,
      listener: (result, value) {
        if (result == RewardedVideoAdResult.LOADED) {
          _rewardedLoaded = true;
          if (!completer.isCompleted) completer.complete();
        } else if (result == RewardedVideoAdResult.ERROR) {
          _rewardedLoaded = false;
          debugPrint('Facebook rewarded failed to load: $value');
          if (!completer.isCompleted) completer.complete();
          if (_rewardedShowCompleter != null &&
              !_rewardedShowCompleter!.isCompleted) {
            _rewardedShowCompleter!.complete(AdResult.failure('$value'));
          }
        } else if (result == RewardedVideoAdResult.VIDEO_COMPLETE) {
          _rewardedVideoCompleted = true;
        } else if (result == RewardedVideoAdResult.VIDEO_CLOSED) {
          _rewardedLoaded = false;
          if (_rewardedShowCompleter != null &&
              !_rewardedShowCompleter!.isCompleted) {
            if (_rewardedVideoCompleted) {
              _rewardedShowCompleter!.complete(AdResult.success(
                rewardType: 'reward',
                rewardAmount: 1,
              ));
            } else {
              _rewardedShowCompleter!
                  .complete(AdResult.failure('User closed before reward'));
            }
          }
        }
      },
    );
    return completer.future;
  }

  @override
  Future<AdResult> showRewarded() async {
    if (!_rewardedLoaded) {
      return AdResult.failure('Rewarded ad not loaded');
    }
    _rewardedShowCompleter = Completer<AdResult>();
    _rewardedVideoCompleted = false;
    FacebookRewardedVideoAd.showRewardedVideoAd();
    return _rewardedShowCompleter!.future;
  }

  // --- App Open (not supported by Facebook) ---

  @override
  bool get isAppOpenLoaded => false;

  @override
  Future<void> loadAppOpen(String adUnitId) async {
    debugPrint('Facebook Audience Network does not support App Open ads');
  }

  @override
  Future<AdResult> showAppOpen() async {
    return AdResult.failure('App Open ads not supported by Facebook');
  }

  // --- Banner ---

  @override
  Widget buildBannerAd(String adUnitId, {double? width}) {
    return FacebookBannerAd(
      placementId: adUnitId,
      bannerSize: BannerSize.STANDARD,
      listener: (result, value) {
        if (result == BannerAdResult.ERROR) {
          debugPrint('Facebook banner error: $value');
        }
      },
    );
  }

  // --- Native ---

  @override
  Widget buildNativeAd(String adUnitId, {double? height}) {
    return FacebookNativeAd(
      placementId: adUnitId,
      adType: NativeAdType.NATIVE_AD,
      height: height ?? 300,
      listener: (result, value) {
        if (result == NativeAdResult.ERROR) {
          debugPrint('Facebook native error: $value');
        }
      },
    );
  }
}
