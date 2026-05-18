# flutter_ads_lib

A unified Flutter ads library supporting **AdMob**, **Facebook Audience Network**, **Unity Ads**, and **AppLovin MAX** with a simple plug-and-play API.

Just pass your app ID and ad unit IDs — the library handles initialization, loading, showing, consent, and lifecycle management for all ad formats.

## Features

- **4 ad networks**: AdMob, Facebook Audience Network, Unity Ads, AppLovin MAX
- **5 ad formats**: Banner, Interstitial, Rewarded, Native, App Open
- **Auto-preloading**: Fullscreen ads load on init and reload after each show
- **GDPR consent**: Built-in Google UMP consent management
- **Adapter pattern**: Swap networks without changing app code
- **Cross-platform**: Android & iOS

## Installation

Add the dependency in your app's `pubspec.yaml`:

```yaml
dependencies:
  flutter_ads_lib:
    path: ../android_ads_lib
```

Or via git:

```yaml
dependencies:
  flutter_ads_lib:
    git:
      url: https://github.com/your-org/flutter_ads_lib.git
```

Then run:

```bash
flutter pub get
```

## Quick Start

### 1. Initialize

Call once in `main()` before `runApp()`:

```dart
import 'package:flutter_ads_lib/flutter_ads_lib.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AdsManager.instance.initialize(
    const AdsConfig(
      network: AdNetwork.admob, // or .facebook, .unity, .applovin
      appId: 'ca-app-pub-xxxxxxxxxxxxx~yyyyyyyyyy',
      bannerAdUnitId: 'ca-app-pub-xxx/banner',
      interstitialAdUnitId: 'ca-app-pub-xxx/interstitial',
      rewardedAdUnitId: 'ca-app-pub-xxx/rewarded',
      nativeAdUnitId: 'ca-app-pub-xxx/native',
      appOpenAdUnitId: 'ca-app-pub-xxx/appopen',
      testMode: true, // set to false in production
    ),
  );

  runApp(MyApp());
}
```

### 2. Show Ads

#### Banner Ad

Drop the widget anywhere in your widget tree:

```dart
const BannerAdWidget()

// With custom width
BannerAdWidget(width: 320)
```

#### Interstitial Ad

```dart
final result = await AdsManager.instance.showInterstitial();
if (result.success) {
  print('Interstitial shown');
} else {
  print('Error: ${result.errorMessage}');
}
```

#### Rewarded Ad

```dart
final result = await AdsManager.instance.showRewarded(
  onReward: (reward) {
    print('Earned ${reward.rewardAmount} ${reward.rewardType}');
  },
);
```

#### App Open Ad

```dart
final result = await AdsManager.instance.showAppOpenAd();
```

#### Native Ad

```dart
const NativeAdWidget()

// With custom height
NativeAdWidget(height: 350)
```

### 3. Check Ad Readiness

```dart
if (AdsManager.instance.isInterstitialReady) {
  AdsManager.instance.showInterstitial();
}

if (AdsManager.instance.isRewardedReady) {
  AdsManager.instance.showRewarded();
}

if (AdsManager.instance.isAppOpenReady) {
  AdsManager.instance.showAppOpenAd();
}
```

## Switching Ad Networks

Just change the `network` and IDs — the API stays the same:

```dart
// AdMob
AdsConfig(
  network: AdNetwork.admob,
  appId: 'ca-app-pub-xxx~yyy',
  interstitialAdUnitId: 'ca-app-pub-xxx/interstitial',
  ...
)

// Unity Ads
AdsConfig(
  network: AdNetwork.unity,
  appId: '1234567',  // Unity Game ID
  interstitialAdUnitId: 'Interstitial_Android',
  rewardedAdUnitId: 'Rewarded_Android',
  ...
)

// AppLovin MAX
AdsConfig(
  network: AdNetwork.applovin,
  appId: 'YOUR_APPLOVIN_SDK_KEY',
  interstitialAdUnitId: 'YOUR_INTERSTITIAL_AD_UNIT_ID',
  ...
)

// Facebook Audience Network
AdsConfig(
  network: AdNetwork.facebook,
  appId: 'YOUR_FACEBOOK_APP_ID',
  bannerAdUnitId: 'YOUR_PLACEMENT_ID',
  ...
)
```

## Ad Format Support by Network

| Format | AdMob | Facebook | Unity | AppLovin |
|---|---|---|---|---|
| Banner | Yes | Yes | Yes | Yes |
| Interstitial | Yes | Yes | Yes | Yes |
| Rewarded | Yes | Yes | Yes | Yes |
| Native | Yes | Yes | No | Yes |
| App Open | Yes | No | No | Yes |

## Configuration Options

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `network` | `AdNetwork` | Yes | — | Ad network to use |
| `appId` | `String` | Yes | — | App ID / SDK key for the network |
| `bannerAdUnitId` | `String?` | No | `null` | Banner ad unit ID |
| `interstitialAdUnitId` | `String?` | No | `null` | Interstitial ad unit ID |
| `rewardedAdUnitId` | `String?` | No | `null` | Rewarded ad unit ID |
| `nativeAdUnitId` | `String?` | No | `null` | Native ad unit ID |
| `appOpenAdUnitId` | `String?` | No | `null` | App open ad unit ID |
| `enableConsent` | `bool` | No | `true` | Enable GDPR consent (Google UMP) |
| `testMode` | `bool` | No | `false` | Enable test ads |

## Platform Setup

### Android

Add your AdMob app ID to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
  <application>
    <meta-data
      android:name="com.google.android.gms.ads.APPLICATION_ID"
      android:value="ca-app-pub-xxxxxxxxxxxxx~yyyyyyyyyy"/>
  </application>
</manifest>
```

### iOS

Add your AdMob app ID to `ios/Runner/Info.plist`:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-xxxxxxxxxxxxx~yyyyyyyyyy</string>
```

## Cleanup

Dispose when no longer needed:

```dart
await AdsManager.instance.dispose();
```

## License

MIT
