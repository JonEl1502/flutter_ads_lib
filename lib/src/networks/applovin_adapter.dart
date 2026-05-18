import 'dart:async';

import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/widgets.dart';

import '../ads_config.dart';
import '../models/ad_result.dart';
import 'ad_network_adapter.dart';

class ApplovinAdapter implements AdNetworkAdapter {
  bool _interstitialLoaded = false;
  bool _rewardedLoaded = false;
  bool _appOpenLoaded = false;
  String? _interstitialAdUnitId;
  String? _rewardedAdUnitId;
  String? _appOpenAdUnitId;

  @override
  Future<void> initialize(AdsConfig config) async {
    await AppLovinMAX.initialize(config.appId);

    // Set up listeners
    AppLovinMAX.setInterstitialListener(InterstitialListener(
      onAdLoadedCallback: (ad) => _interstitialLoaded = true,
      onAdLoadFailedCallback: (adUnitId, error) {
        _interstitialLoaded = false;
        debugPrint('AppLovin interstitial failed: ${error.message}');
      },
      onAdDisplayedCallback: (ad) {},
      onAdDisplayFailedCallback: (ad, error) => _interstitialLoaded = false,
      onAdClickedCallback: (ad) {},
      onAdHiddenCallback: (ad) => _interstitialLoaded = false,
    ));

    AppLovinMAX.setRewardedAdListener(RewardedAdListener(
      onAdLoadedCallback: (ad) => _rewardedLoaded = true,
      onAdLoadFailedCallback: (adUnitId, error) {
        _rewardedLoaded = false;
        debugPrint('AppLovin rewarded failed: ${error.message}');
      },
      onAdDisplayedCallback: (ad) {},
      onAdDisplayFailedCallback: (ad, error) => _rewardedLoaded = false,
      onAdClickedCallback: (ad) {},
      onAdHiddenCallback: (ad) => _rewardedLoaded = false,
      onAdReceivedRewardCallback: (ad, reward) {},
    ));

    AppLovinMAX.setAppOpenAdListener(AppOpenAdListener(
      onAdLoadedCallback: (ad) => _appOpenLoaded = true,
      onAdLoadFailedCallback: (adUnitId, error) {
        _appOpenLoaded = false;
        debugPrint('AppLovin app open failed: ${error.message}');
      },
      onAdDisplayedCallback: (ad) {},
      onAdDisplayFailedCallback: (ad, error) => _appOpenLoaded = false,
      onAdClickedCallback: (ad) {},
      onAdHiddenCallback: (ad) => _appOpenLoaded = false,
    ));
  }

  @override
  Future<void> dispose() async {
    _interstitialLoaded = false;
    _rewardedLoaded = false;
    _appOpenLoaded = false;
  }

  // --- Interstitial ---

  @override
  bool get isInterstitialLoaded => _interstitialLoaded;

  @override
  Future<void> loadInterstitial(String adUnitId) async {
    _interstitialAdUnitId = adUnitId;
    AppLovinMAX.loadInterstitial(adUnitId);
  }

  @override
  Future<AdResult> showInterstitial() async {
    if (_interstitialAdUnitId == null) {
      return AdResult.failure('Interstitial ad unit not set');
    }
    final isReady =
        await AppLovinMAX.isInterstitialReady(_interstitialAdUnitId!) ?? false;
    if (!isReady) {
      return AdResult.failure('Interstitial ad not loaded');
    }
    AppLovinMAX.showInterstitial(_interstitialAdUnitId!);
    _interstitialLoaded = false;
    return AdResult.success();
  }

  // --- Rewarded ---

  @override
  bool get isRewardedLoaded => _rewardedLoaded;

  @override
  Future<void> loadRewarded(String adUnitId) async {
    _rewardedAdUnitId = adUnitId;
    AppLovinMAX.loadRewardedAd(adUnitId);
  }

  @override
  Future<AdResult> showRewarded() async {
    if (_rewardedAdUnitId == null) {
      return AdResult.failure('Rewarded ad unit not set');
    }
    final isReady =
        await AppLovinMAX.isRewardedAdReady(_rewardedAdUnitId!) ?? false;
    if (!isReady) {
      return AdResult.failure('Rewarded ad not loaded');
    }
    AppLovinMAX.showRewardedAd(_rewardedAdUnitId!);
    _rewardedLoaded = false;
    return AdResult.success(rewardType: 'reward', rewardAmount: 1);
  }

  // --- App Open ---

  @override
  bool get isAppOpenLoaded => _appOpenLoaded;

  @override
  Future<void> loadAppOpen(String adUnitId) async {
    _appOpenAdUnitId = adUnitId;
    AppLovinMAX.loadAppOpenAd(adUnitId);
  }

  @override
  Future<AdResult> showAppOpen() async {
    if (_appOpenAdUnitId == null) {
      return AdResult.failure('App open ad unit not set');
    }
    final isReady =
        await AppLovinMAX.isAppOpenAdReady(_appOpenAdUnitId!) ?? false;
    if (!isReady) {
      return AdResult.failure('App open ad not loaded');
    }
    AppLovinMAX.showAppOpenAd(_appOpenAdUnitId!);
    _appOpenLoaded = false;
    return AdResult.success();
  }

  // --- Banner ---

  @override
  Widget buildBannerAd(String adUnitId, {double? width}) {
    return MaxAdView(
      adUnitId: adUnitId,
      adFormat: AdFormat.banner,
      listener: AdViewAdListener(
        onAdLoadedCallback: (ad) {},
        onAdLoadFailedCallback: (adUnitId, error) {
          debugPrint('AppLovin banner failed: ${error.message}');
        },
        onAdClickedCallback: (ad) {},
        onAdExpandedCallback: (ad) {},
        onAdCollapsedCallback: (ad) {},
      ),
    );
  }

  // --- Native ---

  @override
  Widget buildNativeAd(String adUnitId, {double? height}) {
    return SizedBox(
      height: height ?? 300,
      child: MaxNativeAdView(
        adUnitId: adUnitId,
        listener: NativeAdListener(
          onAdLoadedCallback: (ad) {},
          onAdLoadFailedCallback: (adUnitId, error) {
            debugPrint('AppLovin native failed: ${error.message}');
          },
          onAdClickedCallback: (ad) {},
        ),
        child: const SizedBox.shrink(),
      ),
    );
  }
}
