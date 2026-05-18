/// A unified Flutter ads library supporting multiple ad networks.
///
/// Quick start:
/// ```dart
/// import 'package:flutter_ads_lib/flutter_ads_lib.dart';
///
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await AdsManager.instance.initialize(
///     AdsConfig(
///       network: AdNetwork.admob,
///       appId: 'ca-app-pub-xxxxxxxxxxxxx~yyyyyyyyyy',
///       bannerAdUnitId: 'ca-app-pub-xxx/banner',
///       interstitialAdUnitId: 'ca-app-pub-xxx/interstitial',
///       rewardedAdUnitId: 'ca-app-pub-xxx/rewarded',
///     ),
///   );
///   runApp(MyApp());
/// }
/// ```
library;

// Config
export 'src/ads_config.dart';

// Manager
export 'src/ads_manager.dart';

// Models
export 'src/models/ad_network.dart';
export 'src/models/ad_result.dart';

// Consent
export 'src/consent/consent_manager.dart';

// Widgets
export 'src/widgets/banner_ad_widget.dart';
export 'src/widgets/native_ad_widget.dart';
