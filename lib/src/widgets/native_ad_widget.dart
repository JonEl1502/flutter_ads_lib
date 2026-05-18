import 'package:flutter/widgets.dart';

import '../ads_manager.dart';

/// Drop-in native ad widget.
///
/// ```dart
/// NativeAdWidget()
/// NativeAdWidget(height: 350)
/// ```
class NativeAdWidget extends StatelessWidget {
  final double? height;

  const NativeAdWidget({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    return AdsManager.instance.buildNativeAd(height: height);
  }
}
