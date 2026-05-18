import 'package:flutter/widgets.dart';

import '../ads_manager.dart';

/// Drop-in banner ad widget.
///
/// ```dart
/// BannerAdWidget()
/// BannerAdWidget(width: 320)
/// ```
class BannerAdWidget extends StatelessWidget {
  final double? width;

  const BannerAdWidget({super.key, this.width});

  @override
  Widget build(BuildContext context) {
    return AdsManager.instance.buildBannerAd(width: width);
  }
}
