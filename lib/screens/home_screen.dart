import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:democoin/games/AddTheNumbers.dart';
import 'package:democoin/games/FreeCashPage.dart';
import 'package:democoin/games/HourlyBonusPage.dart';
import 'package:democoin/games/LoadWebviewUrlsPage.dart';
import 'package:democoin/games/MultiplyTheNumbers.dart';
import 'package:democoin/games/WatchVideosPage.dart';
import 'package:democoin/games/WeeklyGiveAwayPage.dart';
import 'package:democoin/models/users.dart';
import 'package:democoin/services/AdmobHelper.dart';
import 'package:democoin/services/firebase_auth_services.dart';
import 'package:democoin/services/firestore_services.dart';
import 'package:democoin/utils/Constants.dart';
import 'package:democoin/utils/tools.dart';
import 'package:democoin/widgets/message_dialog_with_ok.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'AnnouncementPage.dart';
import 'ReferralPage.dart';
import 'account_page.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool showLoading = true;
  FirestoreServices fireStoreServices = FirestoreServices();
  FirebaseAuthServices authServices = FirebaseAuthServices();
  int totalUser = 0;
  var today = "1";
  int timerLeft;
  String lastNotifiedDate;
  bool clicked = false;
  double _scale;
  AnimationController _controller;
  InterstitialAd ad;

  RewardedAd _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  AdmobHelper admobHelper = new AdmobHelper();


  @override
  void initState() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    MobileAds.instance.initialize();
    admobHelper.createRewardAd();
    admobHelper.createInterad();

    checkIfTodaysLeftClick();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 10,
      ),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });
    super.initState();
  }



  showRewardAds() {
    admobHelper.showRewardAd();
  }

  showInterstitialAds(){
    admobHelper.showInterad();
  }

  checkIfTodaysLeftClick() async {
    var firestoreServices = FirestoreServices();
    var nextClaimTime = await firestoreServices.getNextClickTime("nextClaim");
    today = await firestoreServices.getToday();

    if (today != DateTime.now().day.toString()) {
      firestoreServices.addToday().then((value) {
        firestoreServices.addIntervalTimer("nextClaim").then((value) {
          getNextClickTimer();
        });
      });
    } else {
      if (nextClaimTime == null || nextClaimTime == "") {
        firestoreServices.addIntervalTimer("nextClaim").then((value) {
          getNextClickTimer();
        });
      } else {
        getNextClickTimer();
      }
    }

    setState(() {});
  }

  getNextClickTimer() async {
    var nextClaimTime = await fireStoreServices.getNextClickTime("nextClaim");
    var userName = await fireStoreServices.getNextClickTime("name");
    print("Next  Clicked Timer in Db  $nextClaimTime");
    print("Your Name is   ${userName}");

    var currentTime = currentTimeInSeconds();
    print("Current Time  $currentTime");

    timerLeft = nextClaimTime - currentTime;

    print(" The Time Lefty for the next Click - $timerLeft");
    getTotalUsers();
    setState(() {});
  }

  int currentTimeInSeconds() {
    var ms = new DateTime.now().millisecondsSinceEpoch;
    return (ms / 1000).round();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  getTotalUsers() async {
    var firestoreServices =
        Provider.of<FirestoreServices>(context, listen: false);
    int totalUsers = await firestoreServices.getTotalUsers();
    String lastNofied = await firestoreServices.getLastNoticeDate();
    setState(() {
      totalUser = totalUsers;
      lastNotifiedDate = lastNofied;
    });
  }

  addPoints(
    int reward,
    String title,
    int days,
    int min,
    int secs,
    Users userData,
  ) {
    ProgressDialog progressDialog =
        ProgressDialog(context, isDismissible: false);
    progressDialog.show();

    fireStoreServices
        .addPointsForClaim(reward, title, days, min, secs)
        .then((val) {
      progressDialog.hide();
      setState(() {
        timerLeft = Constants.claimTimer * 60;
        clicked = !clicked;
      });
      showDialog(
          context: context,
          builder: (context) => CustomDialogWithOk(
                title: "Rewardded Successfully",
                description:
                    "You Have Claimed Your ${Constants.coin_name} Successfully",
                primaryButtonText: "Ok",
              ));
    });
  }

  bool btnenabled = false;

  @override
  Widget build(BuildContext context) {
    var userData = Provider.of<Users>(context);

    Timer(Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          btnenabled = true;
        });
      }
    });

    _scale = 1 - _controller.value;
    return userData == null
        ? CircularProgressIndicator()
        : Scaffold(
            body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "My Earnings",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${(userData.points * Constants.decimal).toStringAsFixed(0)} ${Constants.symbol}",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    timerLeft == null
                        ? SizedBox(
                            height: 50,
                          )
                        : clicked == true
                            ? Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * 0.4,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.green),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                                child: TweenAnimationBuilder<Duration>(
                                    duration: Duration(
                                        seconds: Constants.claimTimer * 60),
                                    tween: Tween(
                                        begin: Duration(
                                            seconds: Constants.claimTimer * 60),
                                        end: Duration.zero),
                                    onEnd: () {
                                      print('Timer ended');
                                      timerLeft = 0;
                                      setState(() {});
                                    },
                                    builder: (BuildContext context,
                                        Duration value, Widget child) {
                                      final minutes = value.inMinutes;
                                      final seconds = value.inSeconds % 60;
                                      return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5),
                                          child: Text('$minutes m : $seconds s',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 30)));
                                    }),
                              )
                            : SizedBox(),
                    timerLeft == null
                        ? SizedBox()
                        : !clicked
                            ? Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * 0.7,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.green),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                                child: clicked
                                    ? TweenAnimationBuilder<Duration>(
                                        duration: Duration(
                                            seconds: Constants.claimTimer * 60),
                                        tween: Tween(
                                            begin: Duration(
                                                seconds:
                                                    Constants.claimTimer * 60),
                                            end: Duration.zero),
                                        onEnd: () {
                                          print('Timer ended');
                                          timerLeft = 0;
                                          setState(() {});
                                        },
                                        builder: (BuildContext context,
                                            Duration value, Widget child) {
                                          final minutes = value.inMinutes;
                                          final seconds = value.inSeconds % 60;
                                          return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5),
                                              child: Text(
                                                  '$minutes m : $seconds s',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 30)));
                                        })
                                    : TweenAnimationBuilder<Duration>(
                                        duration: Duration(
                                            seconds:
                                                timerLeft <= 0 ? 1 : timerLeft),
                                        tween: Tween(
                                            begin: Duration(
                                                seconds: timerLeft <= 0
                                                    ? 1
                                                    : timerLeft),
                                            end: Duration.zero),
                                        onEnd: () {
                                          print('Timer ended');
                                          timerLeft = 0;
                                          setState(() {});
                                        },
                                        builder: (BuildContext context,
                                            Duration value, Widget child) {
                                          final minutes = value.inMinutes;
                                          final seconds = value.inSeconds % 60;
                                          return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5),
                                              child: timerLeft <= 0
                                                  ? Text('Ready To Claim',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 30))
                                                  : Text(
                                                      '$minutes m : $seconds s',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 30)));
                                        }),
                              )
                            : SizedBox(),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: 150.0,
                      height: 150.0,
                      decoration: new BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: GestureDetector(
                          /*               onTap: _ontap,*/
                          onTapDown: _tapDown,
                          onTapUp: _tapUp,
                          child: Transform.scale(
                            scale: _scale,
                            child: _animatedButton(userData),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Important Announcements",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                lastNotifiedDate == null
                                    ? SizedBox()
                                    : AutoSizeText(
                                        "Last Notified at: ${DateFormat.yMd().format(DateTime.parse(lastNotifiedDate))}",
                                        style: TextStyle(
                                            fontSize: 10, color: Colors.grey),
                                      ),
                              ],
                            ),
                            FlatButton(
                              color: Colors.red,
                              onPressed: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (_) {
                                  return AnnouncementPage();
                                }));
                              },
                              child: Text(
                                "Read",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 80,
                      decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(100)),
                                      color: Colors.indigo),
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundImage: NetworkImage(
                                        "${userData.profile_photo}"),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  // "${name}",
                                  "${userData.name != null || userData.name != "" ? userData.name : ""}",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            FlatButton(
                              color: Colors.red,
                              onPressed: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (_) {
                                  return AccountScreen();
                                }));
                              },
                              child: Text(
                                "upgrade",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 90,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              showInterstitialAds();
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (_) {
                                return HourlyBonusPage();
                              }));
                            },
                            child: Container(
                              height: 85,
                              width: MediaQuery.of(context).size.width * 0.46,
                              decoration: BoxDecoration(
                                  color: Colors.indigo,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Text(
                                          "Hourly Bonus",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 20,
                                              letterSpacing: 1.2,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: AutoSizeText(
                                          "${(Constants.bonus_reward * Constants.decimal).toStringAsFixed(0)} ${Constants.symbol}",
                                          maxLines: 1,
                                          style: TextStyle(
                                              letterSpacing: 1.2,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              showInterstitialAds();
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (_) {
                                return WatchVideosPage();
                              }));
                            },
                            child: Container(
                              height: 85,
                              width: MediaQuery.of(context).size.width * 0.46,
                              decoration: BoxDecoration(
                                  color: Colors.indigo,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Text(
                                          "Watch Videos",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 20,
                                              letterSpacing: 1.2,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: AutoSizeText(
                                          "${(Constants.bonus_reward * Constants.decimal).toStringAsFixed(0)} ${Constants.symbol}",
                                          maxLines: 1,
                                          style: TextStyle(
                                              letterSpacing: 1.2,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 90,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              showInterstitialAds();
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (_) {
                                return AddTheNumbers();
                              }));
                            },
                            child: Container(
                              height: 85,
                              width: MediaQuery.of(context).size.width * 0.46,
                              decoration: BoxDecoration(
                                  color: Colors.indigo,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Text(
                                          "Sum",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 20,
                                              letterSpacing: 1.2,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: AutoSizeText(
                                          "${(Constants.bonus_reward * Constants.decimal).toStringAsFixed(0)} ${Constants.symbol}",
                                          maxLines: 1,
                                          style: TextStyle(
                                              letterSpacing: 1.2,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              showInterstitialAds();
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (_) {
                                return MultiplyTheNumbers();
                              }));
                            },
                            child: Container(
                              height: 85,
                              width: MediaQuery.of(context).size.width * 0.46,
                              decoration: BoxDecoration(
                                  color: Colors.indigo,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Text(
                                          "Multiply",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 20,
                                              letterSpacing: 1.2,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: AutoSizeText(
                                          "${(Constants.bonus_reward * Constants.decimal).toStringAsFixed(0)} ${Constants.symbol}",
                                          maxLines: 1,
                                          style: TextStyle(
                                              letterSpacing: 1.2,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 90,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              showInterstitialAds();
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (_) {
                                return WeeklyGiveAwayPage();
                              }));
                            },
                            child: Container(
                              height: 85,
                              width: MediaQuery.of(context).size.width * 0.46,
                              decoration: BoxDecoration(
                                  color: Colors.indigo,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Text(
                                          "Weekly GiveAway",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 15,
                                              letterSpacing: 1.2,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: AutoSizeText(
                                          "50 ${Constants.symbol}",
                                          maxLines: 1,
                                          style: TextStyle(
                                              letterSpacing: 1.2,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              showInterstitialAds();
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (_) {
                                return FreeCashPage();
                              }));
                            },
                            child: Container(
                              height: 85,
                              width: MediaQuery.of(context).size.width * 0.46,
                              decoration: BoxDecoration(
                                  color: Colors.indigo,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Text(
                                          "Free Cash",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 20,
                                              letterSpacing: 1.2,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: AutoSizeText(
                                          "${(Constants.bonus_reward * Constants.decimal).toStringAsFixed(0)} ${Constants.symbol}",
                                          maxLines: 1,
                                          style: TextStyle(
                                              letterSpacing: 1.2,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 90,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              showInterstitialAds();
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (_) {
                                return WeeklyGiveAwayPage();
                              }));
                            },
                            child: Container(
                              height: 85,
                              width: MediaQuery.of(context).size.width * 0.46,
                              decoration: BoxDecoration(
                                  color: Colors.indigo,
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(left: 10),
                                        child: Text(
                                          "Nothing Just",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 15,
                                              letterSpacing: 1.2,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(left: 10),
                                        child: AutoSizeText(
                                          "50 ${Constants.symbol}",
                                          maxLines: 1,
                                          style: TextStyle(
                                              letterSpacing: 1.2,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              showInterstitialAds();
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (_) {
                                return LoadWebiewburlsPage();
                              }));
                            },
                            child: Container(
                              height: 85,
                              width: MediaQuery.of(context).size.width * 0.46,
                              decoration: BoxDecoration(
                                  color: Colors.indigo,
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(left: 10),
                                        child: Text(
                                          "Webview",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 20,
                                              letterSpacing: 1.2,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(left: 10),
                                        child: AutoSizeText(
                                          "${(Constants.bonus_reward * Constants.decimal).toStringAsFixed(0)} ${Constants.symbol}",
                                          maxLines: 1,
                                          style: TextStyle(
                                              letterSpacing: 1.2,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Join Chat (Important)",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            FlatButton(
                              color: Colors.red,
                              onPressed: () {
                                _launchTelegram(Constants.telegram_group_link);
                              },
                              child: Text(
                                "Telegram",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 90,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 85,
                            width: MediaQuery.of(context).size.width * 0.46,
                            decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10),
                                      child: Text(
                                        "Claimed",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 20,
                                            letterSpacing: 1.2,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10),
                                      child: AutoSizeText(
                                        "${(userData.claimed * Constants.decimal).toStringAsFixed(0)}",
                                        maxLines: 1,
                                        style: TextStyle(
                                            letterSpacing: 1.2,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.touch_app))
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              showInterstitialAds();
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (_) {
                                return ReferralPage();
                              }));
                            },
                            child: Container(
                              height: 85,
                              width: MediaQuery.of(context).size.width * 0.46,
                              decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Text(
                                          "Referral",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 20,
                                              letterSpacing: 1.2,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: AutoSizeText(
                                          "${(userData.earnedByReferral * Constants.decimal).toStringAsFixed(0)}",
                                          maxLines: 1,
                                          style: TextStyle(
                                              letterSpacing: 1.2,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(builder: (_) {
                                          return ReferralPage();
                                        }));
                                      },
                                      icon: Icon(Icons.person_add))
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total Users",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                "${totalUser} Users",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ),
            ),
          ));
  }

  Widget _animatedButton(
    Users userData,
  ) {
    return btnenabled
        ? timerLeft == null
            ? Container(
                height: 120,
                width: 180,
                decoration: BoxDecoration(
                    //borderRadius: BorderRadius.circular(100.0),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x80000000),
                        blurRadius: 12.0,
                        offset: Offset(0.0, 5.0),
                      ),
                    ],
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xff33ccff),
                        Color(0xffff99cc),
                      ],
                    )),
                child: Center(
                  child: Text(
                    'Wait',
                    style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
              )
            : timerLeft <= 0
                ? GestureDetector(
                    onTap: () {
                      if (userData.clicks_left <= 0) {
                        return Tools.showToasts(
                            "You can Claim only 250 times aday");
                      }

                      showRewardAds();
                      addPoints(Constants.claim_reward, "nextClaim", 0,
                          Constants.claimTimer, 0, userData);
                    },
                    child: Container(
                      height: 120,
                      width: 180,
                      decoration: BoxDecoration(
                          //borderRadius: BorderRadius.circular(100.0),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x80000000),
                              blurRadius: 12.0,
                              offset: Offset(0.0, 5.0),
                            ),
                          ],
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xff33ccff),
                              Color(0xffff99cc),
                            ],
                          )),
                      child: Center(
                        child: Text(
                          '${Constants.claim_coin}',
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: () {
                      showToasts("Your Next Claim will be Ready shortly");
                    },
                    child: Container(
                      height: 120,
                      width: 180,
                      decoration: BoxDecoration(
                          //borderRadius: BorderRadius.circular(100.0),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x80000000),
                              blurRadius: 12.0,
                              offset: Offset(0.0, 5.0),
                            ),
                          ],
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xff33ccff),
                              Color(0xffff99cc),
                            ],
                          )),
                      child: Center(
                        child: Text(
                          'Wait',
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                    ),
                  )
        : Container(
            height: 120,
            width: 180,
            decoration: BoxDecoration(
                //borderRadius: BorderRadius.circular(100.0),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x80000000),
                    blurRadius: 12.0,
                    offset: Offset(0.0, 5.0),
                  ),
                ],
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xff33ccff),
                    Color(0xffff99cc),
                  ],
                )),
            child: Center(
              child: Text(
                'Wait',
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
          );
  }

  void _tapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _tapUp(TapUpDetails details) {
    _controller.reverse();
  }

  _launchTelegram(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      showToasts("You Do not hyave Telegram Installed");
      throw 'Could not launch $url';
    }
  }

  showToasts(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
