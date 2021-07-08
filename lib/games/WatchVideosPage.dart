import 'dart:async';

import 'package:democoin/models/users.dart';
import 'package:democoin/provider_package/allNotifiers.dart';
import 'package:democoin/provider_package/connectivity_provider.dart';
import 'package:democoin/screens/home_page.dart';
import 'package:democoin/screens/no_internet.dart';
import 'package:democoin/services/UnityAdsServices.dart';
import 'package:democoin/services/firestore_services.dart';
import 'package:democoin/utils/Constants.dart';
import 'package:democoin/utils/tools.dart';
import 'package:democoin/widgets/message_dialog_with_ok.dart';
import 'package:democoin/widgets/showLoading.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';


class WatchVideosPage extends StatefulWidget {
  static const String routeName = "/WatchVideosPage";

  @override
  _WatchVideosPageState createState() => _WatchVideosPageState();
}

class _WatchVideosPageState extends State<WatchVideosPage> {
  var firestoreServices = FirestoreServices();

  var randomReward = Constants.video_reward;
  int clicks_left = 0;
  bool clicked = false;
  int timerLeft=-1;

  @override
  void initState() {
    super.initState();
    Provider.of<ConnectivityProvider>(context, listen: false).startMonitoring();



  }


  int currentTimeInSeconds() {
    var ms = new DateTime.now().millisecondsSinceEpoch;
    return (ms / 1000).round();

  }
  bool btnenabled = false;

  @override
  Widget build(BuildContext context) {
    Timer(Duration(seconds: 5), () {
      setState(() {
        btnenabled = true;
      });
    });
    return pageUI();
  }

  addPoints(int randomRewards, String title, int days, int min, int secs) {
    ProgressDialog progressDialog =
        ProgressDialog(context, isDismissible: false);
    progressDialog.show();
    firestoreServices
        .addPointsForAction(randomReward, title, days, min, secs)
        .then((val) {
      progressDialog.hide();
      setState(() {
        timerLeft = Constants.bonusTimer * 60;
        clicked = true;
      });
      showDialog(
          context: context,
          builder: (context) => CustomDialogWithOk(
                title: "Daily Bonus Added",
                description: "You Have Claimed Your Bonus Successfully",
                primaryButtonText: "Ok",
              ));
    });
  }

  Widget pageUI() {

    var userData = Provider.of<Users>(context);
    return Consumer<ConnectivityProvider>(
      builder: (consumerContext, model, child) {
        if (model.isOnline != null) {
          return model.isOnline
              ? WillPopScope(
                  onWillPop: () {
                    return showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              "Confirm Exit",
                              textAlign: TextAlign.center,
                            ),
                            content: Text("Are you sure you want to Go back?"),
                            actions: <Widget>[
                              FlatButton(
                                color: Colors.red,
                                child: Text("YES"),
                                onPressed: () {

                                  Navigator.of(context)
                                      .push(MaterialPageRoute(builder: (_) {
                                    return HomePage();
                                  }));
                                },
                              ),
                              FlatButton(
                                color: Colors.blue,
                                child: Text("NO"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          );
                        });
                  },
                  child: Scaffold(
                    appBar: AppBar(
                      title: Text("Watch Video"),
                    ),
                    body: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                           clicked == true
                                    ? Container(
                                        height: 50,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.4,
                                        decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.green),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5))),
                                        child: TweenAnimationBuilder<Duration>(
                                            duration: Duration(
                                                seconds:
                                                    Constants.bonusTimer * 60),
                                            tween: Tween(
                                                begin: Duration(
                                                    seconds:
                                                        Constants.bonusTimer *
                                                            60),
                                                end: Duration.zero),
                                            onEnd: () {
                                              print('Timer ended');
                                              timerLeft = 0;
                                              setState(() {});
                                            },
                                            builder: (BuildContext context,
                                                Duration value, Widget child) {
                                              final minutes = value.inMinutes;
                                              final seconds =
                                                  value.inSeconds % 60;
                                              return Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 5),
                                                  child: Text(
                                                      '$minutes m : $seconds s',
                                                      textAlign: TextAlign
                                                          .center,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 30)));
                                            }),
                                      )
                                    : SizedBox(),
                        !clicked
                                    ? Container(
                                        height: 50,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.4,
                                        decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.green),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5))),
                                        child: clicked
                                            ? TweenAnimationBuilder<Duration>(
                                                duration: Duration(
                                                    seconds:
                                                        Constants.bonusTimer *
                                                            60),
                                                tween: Tween(
                                                    begin: Duration(
                                                        seconds: Constants
                                                                .bonusTimer *
                                                            60),
                                                    end: Duration.zero),
                                                onEnd: () {
                                                  print('Timer ended');
                                                  timerLeft = 0;
                                                  setState(() {});
                                                },
                                                builder: (BuildContext context,
                                                    Duration value,
                                                    Widget child) {
                                                  final minutes =
                                                      value.inMinutes;
                                                  final seconds =
                                                      value.inSeconds % 60;
                                                  return Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 5),
                                                      child: Text(
                                                          '$minutes m : $seconds s',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 30)));
                                                })
                                            : TweenAnimationBuilder<Duration>(
                                                duration: Duration(
                                                    seconds: userData.watchVideoTimer - currentTimeInSeconds()  <= 0
                                                        ? 1
                                                        : userData.watchVideoTimer - currentTimeInSeconds() ),
                                                tween: Tween(
                                                    begin: Duration(
                                                        seconds: userData.watchVideoTimer - currentTimeInSeconds()  <= 0
                                                            ? 1
                                                            : userData.watchVideoTimer - currentTimeInSeconds() ),
                                                    end: Duration.zero),
                                                onEnd: () {
                                                  print('Timer ended');
                                                  timerLeft = 0;
                                                  setState(() {});
                                                },
                                                builder: (BuildContext context,
                                                    Duration value,
                                                    Widget child) {
                                                  final minutes =
                                                      value.inMinutes;
                                                  final seconds =
                                                      value.inSeconds % 60;
                                                  return Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                              vertical: 5),
                                                      child: userData.watchVideoTimer - currentTimeInSeconds()  <= 0
                                                          ? Text('Ready',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 30))
                                                          : Text(
                                                              '$minutes m : $seconds s',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      30)));
                                                }),
                                      )
                                    : SizedBox(),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Center(
                                      child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                    ),
                                    child: Text(
                                      "My Earning: ${(userData.points * Constants.decimal).toStringAsFixed(8)} ${Constants.symbol}",
                                      style: GoogleFonts.abhayaLibre(
                                          fontSize: 22,
                                          color: Colors.white,
                                          fontStyle: FontStyle.normal,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ))),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: 100,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.green),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: CircleAvatar(
                                radius: 80,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset(
                                    Constants.free_cash,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Congratulation! \nYou have Won ${randomReward * Constants.decimal} ${Constants.coin_name}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                              "* Open Watch Video every 3 min  and Win upto ${(Constants.bonus_reward * Constants.decimal).toStringAsFixed(8)} ${Constants.coin_name} ",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              Constants.tap_collect_button,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 15,
                                  letterSpacing: 1.5,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            userData.watchVideoTimer - currentTimeInSeconds() <= 0
                                    ? Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.6,
                                        height: 50,
                                        decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.red),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5))),
                                        child: btnenabled
                                            ? ElevatedButton(
                                                onPressed: () {



                                                  if(userData.clicks_left<=0){
                                                    return Tools.showToasts(
                                                        "You can Claim only 250 times aday");
                                                  }

                                                  ProgressDialog pr= ProgressDialog(context, isDismissible: true);
                                                  pr.show();
                                                  Timer(Duration(seconds: 5), () {
                                                    addPoints(
                                                        randomReward,
                                                        "watchVideoTimer",
                                                        0,
                                                        Constants.bonusTimer,
                                                        0);
                                                    setState(() {
                                                      pr.hide();
                                                    });
                                                  });


                                                },
                                                child: Text(
                                                  " Collect Bonus",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18),
                                                ),
                                              )
                                            : ElevatedButton(
                                                onPressed: () {
                                                  showToasts(
                                                      "Please Wait ! We are loading bonus for you. Inform Admin if its does not load after few seconds");
                                                },
                                                child: Text(
                                                  " Loading",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18),
                                                ),
                                              ))
                                    : ElevatedButton(
                                        onPressed: null,
                                        child: Text("Collected")),
                            SizedBox(
                              height: 10,
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : NoInternet();
        }
        return Container(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  showToasts(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
