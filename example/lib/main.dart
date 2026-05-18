import 'package:flutter/material.dart';
import 'package:flutter_ads_lib/flutter_ads_lib.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize with your ad network and IDs
  await AdsManager.instance.initialize(
    const AdsConfig(
      network: AdNetwork.admob,
      appId: 'ca-app-pub-3940256099942544~3347511713', // AdMob test app ID
      bannerAdUnitId: 'ca-app-pub-3940256099942544/6300978111',
      interstitialAdUnitId: 'ca-app-pub-3940256099942544/1033173712',
      rewardedAdUnitId: 'ca-app-pub-3940256099942544/5224354917',
      nativeAdUnitId: 'ca-app-pub-3940256099942544/2247696110',
      appOpenAdUnitId: 'ca-app-pub-3940256099942544/9257395921',
      testMode: true,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ads Example',
      home: const AdsExampleScreen(),
    );
  }
}

class AdsExampleScreen extends StatelessWidget {
  const AdsExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ads Library Example')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner Ad
            const Text('Banner Ad:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const BannerAdWidget(),
            const SizedBox(height: 24),

            // Interstitial
            ElevatedButton(
              onPressed: () async {
                final result = await AdsManager.instance.showInterstitial();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Interstitial: ${result.success ? "shown" : result.errorMessage}')),
                  );
                }
              },
              child: const Text('Show Interstitial'),
            ),
            const SizedBox(height: 12),

            // Rewarded
            ElevatedButton(
              onPressed: () async {
                final result = await AdsManager.instance.showRewarded(
                  onReward: (reward) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Earned ${reward.rewardAmount} ${reward.rewardType}')),
                      );
                    }
                  },
                );
                if (!result.success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Rewarded error: ${result.errorMessage}')),
                  );
                }
              },
              child: const Text('Show Rewarded Ad'),
            ),
            const SizedBox(height: 12),

            // App Open
            ElevatedButton(
              onPressed: () async {
                final result = await AdsManager.instance.showAppOpenAd();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('App Open: ${result.success ? "shown" : result.errorMessage}')),
                  );
                }
              },
              child: const Text('Show App Open Ad'),
            ),
            const SizedBox(height: 24),

            // Native Ad
            const Text('Native Ad:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const NativeAdWidget(height: 300),
          ],
        ),
      ),
    );
  }
}
