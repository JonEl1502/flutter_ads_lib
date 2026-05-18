import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../ads_config.dart';
import '../models/ad_result.dart';
import 'ad_network_adapter.dart';

class AdmobAdapter implements AdNetworkAdapter {
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  AppOpenAd? _appOpenAd;

  bool _interstitialLoaded = false;
  bool _rewardedLoaded = false;
  bool _appOpenLoaded = false;

  @override
  Future<void> initialize(AdsConfig config) async {
    await MobileAds.instance.initialize();
    if (config.testMode) {
      MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: ['YOUR_TEST_DEVICE_ID']),
      );
    }
  }

  @override
  Future<void> dispose() async {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _appOpenAd?.dispose();
    _interstitialAd = null;
    _rewardedAd = null;
    _appOpenAd = null;
    _interstitialLoaded = false;
    _rewardedLoaded = false;
    _appOpenLoaded = false;
  }

  // --- Interstitial ---

  @override
  bool get isInterstitialLoaded => _interstitialLoaded;

  @override
  Future<void> loadInterstitial(String adUnitId) async {
    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialLoaded = true;
        },
        onAdFailedToLoad: (error) {
          _interstitialLoaded = false;
          debugPrint('AdMob interstitial failed to load: ${error.message}');
        },
      ),
    );
  }

  @override
  Future<AdResult> showInterstitial() async {
    if (!_interstitialLoaded || _interstitialAd == null) {
      return AdResult.failure('Interstitial ad not loaded');
    }

    final completer = Completer<AdResult>();

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _interstitialLoaded = false;
        completer.complete(AdResult.success());
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        _interstitialLoaded = false;
        completer.complete(AdResult.failure(error.message));
      },
    );

    await _interstitialAd!.show();
    return completer.future;
  }

  // --- Rewarded ---

  @override
  bool get isRewardedLoaded => _rewardedLoaded;

  @override
  Future<void> loadRewarded(String adUnitId) async {
    await RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedLoaded = true;
        },
        onAdFailedToLoad: (error) {
          _rewardedLoaded = false;
          debugPrint('AdMob rewarded failed to load: ${error.message}');
        },
      ),
    );
  }

  @override
  Future<AdResult> showRewarded() async {
    if (!_rewardedLoaded || _rewardedAd == null) {
      return AdResult.failure('Rewarded ad not loaded');
    }

    final completer = Completer<AdResult>();
    RewardItem? earnedReward;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _rewardedLoaded = false;
        if (earnedReward != null) {
          completer.complete(AdResult.success(
            rewardType: earnedReward!.type,
            rewardAmount: earnedReward!.amount,
          ));
        } else {
          completer.complete(AdResult.failure('User did not earn reward'));
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _rewardedLoaded = false;
        completer.complete(AdResult.failure(error.message));
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        earnedReward = reward;
      },
    );

    return completer.future;
  }

  // --- App Open ---

  @override
  bool get isAppOpenLoaded => _appOpenLoaded;

  @override
  Future<void> loadAppOpen(String adUnitId) async {
    await AppOpenAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _appOpenLoaded = true;
        },
        onAdFailedToLoad: (error) {
          _appOpenLoaded = false;
          debugPrint('AdMob app open failed to load: ${error.message}');
        },
      ),
    );
  }

  @override
  Future<AdResult> showAppOpen() async {
    if (!_appOpenLoaded || _appOpenAd == null) {
      return AdResult.failure('App open ad not loaded');
    }

    final completer = Completer<AdResult>();

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _appOpenAd = null;
        _appOpenLoaded = false;
        completer.complete(AdResult.success());
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _appOpenAd = null;
        _appOpenLoaded = false;
        completer.complete(AdResult.failure(error.message));
      },
    );

    await _appOpenAd!.show();
    return completer.future;
  }

  // --- Banner ---

  @override
  Widget buildBannerAd(String adUnitId, {double? width}) {
    return _AdmobBannerWidget(adUnitId: adUnitId, width: width);
  }

  // --- Native ---

  @override
  Widget buildNativeAd(String adUnitId, {double? height}) {
    return _AdmobNativeWidget(adUnitId: adUnitId, height: height);
  }
}

// --- Helper widgets ---

class _AdmobBannerWidget extends StatefulWidget {
  final String adUnitId;
  final double? width;

  const _AdmobBannerWidget({required this.adUnitId, this.width});

  @override
  State<_AdmobBannerWidget> createState() => _AdmobBannerWidgetState();
}

class _AdmobBannerWidgetState extends State<_AdmobBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('AdMob banner failed to load: ${error.message}');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: widget.width ?? _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

class _AdmobNativeWidget extends StatefulWidget {
  final String adUnitId;
  final double? height;

  const _AdmobNativeWidget({required this.adUnitId, this.height});

  @override
  State<_AdmobNativeWidget> createState() => _AdmobNativeWidgetState();
}

class _AdmobNativeWidgetState extends State<_AdmobNativeWidget> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _nativeAd = NativeAd(
      adUnitId: widget.adUnitId,
      request: const AdRequest(),
      factoryId: 'adFactoryExample',
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('AdMob native failed to load: ${error.message}');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _nativeAd == null) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: widget.height ?? 300,
      child: AdWidget(ad: _nativeAd!),
    );
  }
}

