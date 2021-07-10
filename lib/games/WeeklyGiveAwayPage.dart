import 'dart:async';

import 'package:democoin/models/users.dart';
import 'package:democoin/provider_package/allNotifiers.dart';
import 'package:democoin/services/AdmobHelper.dart';
import 'package:democoin/services/UnityAdsServices.dart';
import 'package:democoin/widgets/message_dialog_with_ok.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:democoin/games/GiveAwayResultPage.dart';
import 'package:democoin/models/address_model.dart';
import 'package:democoin/provider_package/connectivity_provider.dart';
import 'package:democoin/screens/home_page.dart';
import 'package:democoin/screens/no_internet.dart';
import 'package:democoin/services/firestore_services.dart';
import 'package:democoin/utils/Constants.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

class WeeklyGiveAwayPage extends StatefulWidget {
  static const String routeName = "/WeeklyGiveAwayPage";

  @override
  _WeeklyGiveAwayPageState createState() => _WeeklyGiveAwayPageState();
}

class _WeeklyGiveAwayPageState extends State<WeeklyGiveAwayPage> {
  var firestoreServices = FirestoreServices();
  AdmobHelper admobHelper = new AdmobHelper();
  var today = "";

  @override
  void initState() {
    super.initState();
    Provider.of<ConnectivityProvider>(context, listen: false).startMonitoring();
    MobileAds.instance.initialize();
    admobHelper.createRewardAd();
  }


  showRewardAds() {
   admobHelper.showRewardAd();
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

  Widget pageUI() {
    var allNotifier = Provider.of<AllNotifier>(context, listen: true);
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
                      title: Text("Weekly GiveAway"),
                      actions: [
                        IconButton(
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (_) {
                              return GiveAwayResultPage();
                            }));
                          },
                          icon: Icon(
                            FontAwesomeIcons.trophy,
                          ),
                          color: Colors.red,
                        ),
                        SizedBox(
                          width: 20,
                        )
                      ],
                    ),
                    body: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: Container(
                                height: 100,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.green),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: CircleAvatar(
                                  radius: 80,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(Constants.weeklyIcon),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Win Weekly Giveaway!! Hurry",
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
                              "* Two Weekly Give Away Events are organised every Month, 1st Event- 1 to 15, and 2nd Event- 16 to 31",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "* Random user Will be selected for the Give Away Every 15th and 31st of the month",
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
                              "* 50 ${Constants.coin_name} will be Given Away",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "* One User Can participate only Once",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "* Tap on the Join button to join for Give Away",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Center(
                              child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.6,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.red),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5))),
                                  child: btnenabled
                                      ? ElevatedButton(
                                          onPressed: () async {
                                            showRewardAds();
                                            ProgressDialog pr= ProgressDialog(context, isDismissible: true);
                                            pr.show();
                                            Timer(Duration(seconds: 5), () {
                                              participateInGiveAway();
                                              setState(() {
                                                pr.hide();
                                              });
                                            });

                                          },
                                          child: Text(
                                            " Join Give Away",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18),
                                          ),
                                        )
                                      : ElevatedButton(
                                          onPressed: () {
                                            showToasts("Please Wait ! We are loading bonus for you. Inform Admin if its does not load after few seconds");
                                          },
                                          child: Text(
                                            " Loading",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18),
                                          ),
                                        )),
                            ),
                            SizedBox(
                              height: 10,
                            ),
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

  Future participateInGiveAway() {
    ProgressDialog pr = ProgressDialog(context, isDismissible: false);

    var firebaseServices =
        Provider.of<FirestoreServices>(context, listen: false);
    pr.show();
    if (DateTime.now().day <= 15) {
      firebaseServices.participate("week_one").then((val) {
        pr.hide();
        showDialog(
            context: context,
            builder: (context) => CustomDialogWithOk(
                  title: "Particiapted Successfully",
                  description:
                      "You have participated in the Weekly Give Away. Result Will be Declared in our Telegram Group",
                  primaryButtonText: "Ok",
                ));
      });
    } else {
      firebaseServices.participate("week_two").then((val) {
        pr.hide();
        showDialog(
            context: context,
            builder: (context) => CustomDialogWithOk(
                  title: "Particiapted Successfully",
                  description:
                      "You have participated in the Weekly Give Away. Result Will be Declared in our Telegram group",
                  primaryButtonText: "Ok",
                ));
      });
    }
  }
}
