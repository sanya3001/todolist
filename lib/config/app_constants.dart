class AppConstants {
  static const String APP_CONFIG_ORGANIC = 'app_config_organic';

  static const Map<String, dynamic> defaultAppConfigJson = {
    "app": {
      "name": "All Apps",
      "buildNumber": 1,
      "requiredMinimumBuildNumber": 0,
      "recommendedMinimumBuildNumber": 0,
      "appBundleId": "com.nexowa.todolist",
      "dynamicLinkUrl": "https://nexowaexample.page.link",
      "shareText": "Download the app now {link}",
      "showCopyReviewButton": true,
      "reviewRewardValue": 50,
      "showReviewDialog": true
    },
    "ads": {
      "selectedAdNetwork": "google",
      "openWebInAd": [
        "rewarded",
        "interstitial"
      ],
      "preferredBrowser": "chromeCustomTabs",
      "webAdsAlgo": "pro",
      "webAdsConfig": [
        {
          "url": "https://nexowa.com/",
          "weightage": 50,
          "maxClicks": 500
        }
      ],
      "noAfterInterstitialShown": 0,
      "isShowInHouseAd": true,
      "inHouseAdsBaseUrl": "https://customads.vercel.app/api",
      // "autoPreload": [
      //   "appOpen",
      //   "native",
      //   "interstitial",
      //   "rewarded"
      // ],
      "reloadNativeAd": {
        "onBack": false,
        "onClick": false,
        "onAppResume": false
      },
      "nativePreloadCount": 5,
      "rewardedAdTimeout": 20,
      "interstitialAdTimeout": 15,
      "appOpenAdTimeout": {
        "firstTime": 20,
        "regularTime": 12
      },
      "adUnitIds": {
        "appOpen": "ca-app-pub-3940256099942544/9257395921",
        "banner": "ca-app-pub-3940256099942544/6300978111",
        "collapsibleBanner": "ca-app-pub-3940256099942544/2014213617",
        "adaptiveBanner": "ca-app-pub-3940256099942544/9214589741",
        "interstitial": "ca-app-pub-3940256099942544/1033173712",
        "rewarded": "ca-app-pub-3940256099942544/5224354917",
        "rewardedInterstitial": "ca-app-pub-3940256099942544/5354046379",
        "native": "ca-app-pub-3940256099942544/2247696110"
      },

      "actionAdConfig": {
        "add_todo_click": {
          "adType": "rewarded"
        },
        "on_add_click": {
          "adType": "interstitial"
        },

      },
      "screenAdsConfig": {
        "todo_scr_view": {
          "adType": "nativeAd",
          "size": "small",
          "layoutType": 1
        },
        "native_medium_ad_scr_view": {
          "adType": "nativeAd",
          "size": "medium",
          "layoutType": 1
        },
        "native_full_screen_ad_scr_view": {
          "adType": "nativeAd",
          "size": "large",
          "layoutType": 2
        },
        "static_native_small_ad_scr_view": {
          "adType": "inHouseAd",
          "size": "small",
          "layoutType": 3
        },
        "static_native_medium_ad_scr_view": {
          "adType": "inHouseAd",
          "size": "medium",
          "layoutType": 3
        },
        "static_full_screen_ad_scr_view": {
          "adType": "inHouseAd",
          "size": "large",
          "layoutType": 3
        },
        "banner_small_ad_scr_view": {
          "adType": "bannerAd",
          "size": "small",
          "layoutType": 1
        },
        "banner_medium_ad_scr_view": {
          "adType": "bannerAd",
          "size": "medium",
          "layoutType": 1
        },
        "collapsible_native_ad_scr_view": {
          "adType": "nativeAd",
          "size": "collapsible",
          "layoutType": "1/5"
        },
        "no_ad_scr_view": {
          "adType": "none",
          "size": "medium",
          "layoutType": 1
        }
      }
    },
    "rewards": {
      "dailyRewardMaxDays": 30,
      "dailyRewardAmounts": [10, 20, 30]
    },
    "social": [
      {
        "name": "Youtube",
        "logo":
        "https://play-lh.googleusercontent.com/6am0i3walYwNLc08QOOhRJttQENNGkhlKajXSERf3JnPVRQczIyxw2w3DxeMRTOSdsY=s48-rw",
        "link": "https://www.youtube.com/",
        "reward": 25
      }
    ],
    "crossPromotionApps": [
      {
        "name": "Super Puzzle Game",
        "logo": "https://cdn.example.com/puzzle-logo.png",
        "appLink":
        "https://play.google.com/store/apps/details?id=com.nexowa.puzzle",
        "rewardValue": 25
      }
    ],
    "userConfig": {
      "xyz": [77]
    }
  };
}