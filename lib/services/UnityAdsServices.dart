/*
import 'dart:io';
import 'package:democoin/provider_package/allNotifiers.dart';
import 'package:democoin/utils/Constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unity_ads_plugin/unity_ads.dart';

class UnityAdsServices {
  static bool release = false;

  static void init() {
    print("Init is called");
    UnityAds.init(
      gameId: AdManager.gameId,
      testMode: true,
      listener: (state, args) => print('Init Listener: $state => $args'),
    );
  }

  showInterstitialAd() {
    UnityAds.showVideoAd(
      placementId: AdManager.interstitialVideoAdPlacementId,
      listener: (state, args) =>
          print('Interstitial Video Listener: $state => $args'),
    );
  }

  showRewardAds() {
    UnityAds.showVideoAd(
      placementId: AdManager.rewardedVideoAdPlacementId,
      listener: (state, args) =>
          print('Rewarded Video Listener: $state => $args'),
    );
  }

  Widget BannerAd() {
    return UnityBannerAd(
      placementId: AdManager.bannerAdPlacementId,
      size: BannerSize.standard,
      listener: (state, args) {
        if (state == BannerAdState.loaded) {
          print(
              " Your Banner is Ready and Loaded, And Notified to AllNotifier");
        }
        print('Banner Listener: $state => $args');
      },
    );
  }
}

class AdManager {
  static String get gameId {
    return Constants.unity_ads_id;
  }

  static String get bannerAdPlacementId {
    return 'Banner_Android';
  }

  static String get interstitialVideoAdPlacementId {
    return 'Interstitial_Android';
  }

  static String get rewardedVideoAdPlacementId {
    return 'Rewarded_Android';
  }
}
*/
