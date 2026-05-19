import 'package:flutter/widgets.dart';

import '../ads_config.dart';
import '../models/ad_result.dart';
import 'ad_network_adapter.dart';

/// Stub adapter. The Facebook Audience Network plugin
/// (`facebook_audience_network` 1.0.1) is abandoned and breaks modern Android
/// Gradle Plugin builds (`package` attribute in manifest is rejected), so it
/// has been removed from this library's dependencies. Selecting
/// `AdNetwork.facebook` will throw at runtime — switch to `AdNetwork.admob`,
/// `AdNetwork.unity`, or `AdNetwork.applovin` instead.
class FacebookAdapter implements AdNetworkAdapter {
  static const _msg =
      'Facebook Audience Network is not available in this build. '
      'Use AdNetwork.admob, AdNetwork.unity, or AdNetwork.applovin.';

  @override
  Future<void> initialize(AdsConfig config) async =>
      throw UnsupportedError(_msg);

  @override
  Future<void> dispose() async {}

  @override
  bool get isInterstitialLoaded => false;
  @override
  Future<void> loadInterstitial(String adUnitId) async =>
      throw UnsupportedError(_msg);
  @override
  Future<AdResult> showInterstitial() async => throw UnsupportedError(_msg);

  @override
  bool get isRewardedLoaded => false;
  @override
  Future<void> loadRewarded(String adUnitId) async =>
      throw UnsupportedError(_msg);
  @override
  Future<AdResult> showRewarded() async => throw UnsupportedError(_msg);

  @override
  bool get isAppOpenLoaded => false;
  @override
  Future<void> loadAppOpen(String adUnitId) async =>
      throw UnsupportedError(_msg);
  @override
  Future<AdResult> showAppOpen() async => throw UnsupportedError(_msg);

  @override
  Widget buildBannerAd(String adUnitId, {double? width}) =>
      const SizedBox.shrink();

  @override
  Widget buildNativeAd(String adUnitId, {double? height}) =>
      const SizedBox.shrink();
}
