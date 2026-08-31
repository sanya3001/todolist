import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nexowa_core/models/ad_unit_id_model.dart';
import 'package:nexowa_core/nexowa_core.dart';
import 'package:nexowa_core/models/custom_ad_options.dart';
import 'package:todolist/firebase_options.dart';

import 'app_constants.dart';
// import 'constants/app_constants.dart';
// import 'main.dart';

final sl = GetIt.instance;

Future<void> init() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NexowaCore.instance.initializeFutureData(
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
    defaultAppConfigJson: AppConstants.defaultAppConfigJson,
    appName: 'Flutter Demo',
    appIcon: 'assets/icons/icon.png',
    packageName: 'com.nexowa.todolist',
  );

  final CustomAdOptions customAdOptions = CustomAdOptions(
    containerBackgroundColor: Colors.white12,
    containerPadding: const EdgeInsets.all(10),
    titleTextStyle: TextStyle(
      height: 1,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
    descriptionTextStyle: TextStyle(
      color: Colors.black,
      height: 1,
    ),
    buttonStyle: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(Colors.grey),
      fixedSize: WidgetStateProperty.all(const Size(0, 51)),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textStyle: WidgetStateProperty.all(
        TextStyle(
          height: 1,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    mainContainerDecoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey)),
    adBadgeStyle: AdBadgeStyle(
      color: Colors.grey,
      padding: const EdgeInsets.all(2),
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    ),
    starRatingStyle: const StarRatingStyle(
      fillColor: Colors.grey,
      unfillColor: Colors.grey,
    ),
  );

  NexowaCore.instance.init(
    isAdsShow: () async {
      return true;
    },
    testIds: [
      "8810dd1f-146f-4393-a264-4a7243d9b2e1"
    ],
    minimumFetchInterval: const Duration(seconds: 10),
    customOptions: customAdOptions,
    organicConfigName: AppConstants.APP_CONFIG_ORGANIC,
    marketingConfigName: 'app_config_marketing',
    // adUnitIds: AdUnitIds(
    //   banner: 'ca-app-pub-3940256099942544/2934735716',
    //   rewarded: 'ca-app-pub-3940256099942544/5224354917',
    //   interstitial: 'ca-app-pub-3940256099942544/1033173712',
    //   rewardedInterstitial: 'ca-app-pub-3940256099942544/5354046379',
    //   native: 'ca-app-pub-3940256099942544/2247696110',
    //   appOpen: 'ca-app-pub-3940256099942544/9257395921',
    //   collapsibleBanner: 'ca-app-pub-3940256099942544/2014213617',
    //   adaptiveBanner: 'ca-app-pub-3940256099942544/9214589741',
    // ),
    adUnitIds: AdUnitIds.androidTestIds,
    adsLoadingDialogTheme: const AdsLoadingDialogTheme(
      indicatorColors: [Colors.cyan, Colors.purple],
      indicatorShape: Indicator.ballGridBeat,
      backgroundColor: Colors.grey,
      message: 'Loading...',
      messageTextColor: Colors.black
    ),
  );
}
