import 'package:flutter/material.dart';

class AllNotifier with ChangeNotifier {
  bool _isBannerAdsLoaded;
  int _randomNumberOne;
  int _randomNumberTwo;
  bool _isRewardAdsLoaded;
  String _referredBy = "";

  AllNotifier() {
    _isBannerAdsLoaded = false;
    _isRewardAdsLoaded = false;
    _randomNumberOne = 0;
    _randomNumberTwo = 0;
    _referredBy = "";
  }

  // Banner Ads
  String get referredBy => _referredBy;

  void setReferralId(String uid) {
    _referredBy = uid;
    notifyListeners();
  }

  // Banner Ads
  bool get isBannerAdsLoaded => _isBannerAdsLoaded;

  void setBannerLoaded(bool value) {
    _isBannerAdsLoaded = value;
    notifyListeners();
  }

  // Reward Ads
  bool get isRewardAdsLoaded => _isRewardAdsLoaded;

  void setRewardAdLoaded(bool value) {
    _isRewardAdsLoaded = value;
    notifyListeners();
  }

  // randomNumberOne
  int get randomNumberOne => _randomNumberOne;

  void setRandomNumberOne(int value) {
    _randomNumberOne = value;
    notifyListeners();
  }

  // _randomNumberTwo
  int get randomNumberTwo => _randomNumberTwo;

  void setRandomNumberTwo(int value) {
    _randomNumberTwo = value;
    notifyListeners();
  }
}
