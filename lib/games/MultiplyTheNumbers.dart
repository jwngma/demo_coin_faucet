import 'dart:async';
import 'dart:math';
import 'package:democoin/models/users.dart';
import 'package:democoin/provider_package/allNotifiers.dart';
import 'package:democoin/services/firebase_auth_services.dart';
import 'package:democoin/utils/tools.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:democoin/provider_package/connectivity_provider.dart';
import 'package:democoin/screens/home_page.dart';
import 'package:democoin/screens/no_internet.dart';
import 'package:democoin/services/UnityAdsServices.dart';
import 'package:democoin/services/firestore_services.dart';
import 'package:democoin/utils/Constants.dart';
import 'package:package_info/package_info.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

class MultiplyTheNumbers extends StatefulWidget {
  const MultiplyTheNumbers({
    Key key,
  }) : super(key: key);

  @override
  _MultiplyTheNumbersState createState() => _MultiplyTheNumbersState();
}

class _MultiplyTheNumbersState extends State<MultiplyTheNumbers> {
  FirebaseAuthServices authServices = FirebaseAuthServices();

  TextEditingController _multipliedController = TextEditingController();
  int multipliedNumber = 0;
  int enteredNumber = 0;
  int guessedTimes = 0;
  bool updated = true;
  int timerLeft=-1;

  bool clicked = false;

  @override
  void initState() {
    super.initState();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    checkIfTodaysLeftClick();
    try {
      versionCheck(context);
    } catch (e) {
      print(e);
    }
  }

  checkIfTodaysLeftClick() async {
    var firestoreServices =
        Provider.of<FirestoreServices>(context, listen: false);
    today = await firestoreServices.getToday();

    if (today == DateTime.now().day.toString()) {
      getLastClickedTime();
    }

    setState(() {});
  }

  FirestoreServices firestoreServices = FirestoreServices();

  getLastClickedTime() async {
    generateRandomNunbersAndMultipliedNumber();
  }

  int currentTimeInSeconds() {
    var ms = new DateTime.now().millisecondsSinceEpoch;
    return (ms / 1000).round();
  }


  versionCheck(context) async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    double currentVersion =
        double.parse(info.version.trim().replaceAll(".", ""));

    final RemoteConfig remoteConfig = await RemoteConfig.instance;

    try {
      await remoteConfig.fetch(expiration: const Duration(seconds: 0));
      await remoteConfig.activateFetched();
      remoteConfig.getString('force_update_current_version');
      double newVersion = double.parse(remoteConfig
          .getString('force_update_current_version')
          .trim()
          .replaceAll(".", ""));
      if (newVersion <= currentVersion) {
        setState(() {
          updated = true;
          print("You are using the  Updated Vesrion App");
        });
      } else {
        setState(() {
          updated = false;
        });
        print("You are using the  Old Vesrion App");
      }
    } on FetchThrottledException catch (exception) {
      print(exception);
    } catch (exception) {
      print(
          'Unable to fetch remote config. Cached or default values will be used');
    }
  }

  var today = "";

  @override
  void dispose() {
    super.dispose();
  }

  int _randomNumberForMultiplication() {
    var rand = new Random();
    return rand.nextInt(9);
  }

  int generateMultipliedNumber(int randomNumberOne, int randomNumberTwo) {
    int mNum = 0;
    mNum = randomNumberOne * randomNumberTwo;
    return mNum;
  }

  generateRandomNunbersAndMultipliedNumber() {
    var allNotifier = Provider.of<AllNotifier>(context, listen: false);
    int randomNumberOne = _randomNumberForMultiplication();
    allNotifier.setRandomNumberOne(randomNumberOne);


    int randomNumberTwo = _randomNumberForMultiplication();
    allNotifier.setRandomNumberTwo(randomNumberTwo);
    multipliedNumber =
        generateMultipliedNumber(randomNumberOne, randomNumberTwo);
  }


  validateTheGuessedNumber() {
    enteredNumber = int.parse(_multipliedController.text.toString());
    var firestoreServices =
        Provider.of<FirestoreServices>(context, listen: false);
    guessedTimes++;
    var randomReward = _generateRandomReward();
    if (enteredNumber == multipliedNumber) {
      print("Correct");
      _multipliedController.clear();
      firestoreServices
          .addPointsForAction(
              randomReward, "multiplyTimer", 0, Constants.bonusTimer, 0)
          .then((val) {
        setState(() {
          timerLeft = Constants.bonusTimer * 60;
          clicked = true;
        });
        showToastWithMessage(
            "You have been  Reward ${(randomReward* Constants.decimal).toStringAsFixed(4)} ${Constants.symbol}");
      }).then((val) {
        generateRandomNunbersAndMultipliedNumber();
      });
    } else {
      print("Incorrect");

      showToastWithMessage("Your Answer is not Correct,");
    }
  }

  int _generateRandomReward() {
    var rand = new Random();
    return Constants.bonus_reward;
  }

  showToastWithMessage(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  GlobalKey<ScaffoldState> scaffoldState = GlobalKey();

  void showSnackBar(String content) {
    scaffoldState.currentState.showSnackBar(SnackBar(
      content: Text(content),
      duration: Duration(milliseconds: 1500),
    ));
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
                    key: scaffoldState,
                    appBar: AppBar(
                      title: Text("Multiply The Numbers"),
                    ),
                    body:
                        SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 20,
                          ),
                     clicked == true
                                  ? Container(
                                      height: 50,
                                      width: MediaQuery.of(context).size.width *
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
                                          }),
                                    )
                                  : SizedBox(),
                   !clicked
                                  ? Container(
                                      height: 50,
                                      width: MediaQuery.of(context).size.width *
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
                                                  Duration value,
                                                  Widget child) {
                                                final minutes = value.inMinutes;
                                                final seconds =
                                                    value.inSeconds % 60;
                                                return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 5),
                                                    child: Text(
                                                        '$minutes m : $seconds s',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 30)));
                                              })
                                          : TweenAnimationBuilder<Duration>(
                                              duration: Duration(
                                                  seconds: userData.multiplyTimer - currentTimeInSeconds() <= 0
                                                      ? 1
                                                      : userData.multiplyTimer - currentTimeInSeconds()),
                                              tween: Tween(
                                                  begin: Duration(
                                                      seconds: userData.multiplyTimer - currentTimeInSeconds() <= 0
                                                          ? 1
                                                          : userData.multiplyTimer - currentTimeInSeconds()),
                                                  end: Duration.zero),
                                              onEnd: () {
                                                print('Timer ended');
                                                timerLeft = 0;
                                                setState(() {});
                                              },
                                              builder: (BuildContext context,
                                                  Duration value,
                                                  Widget child) {
                                                final minutes = value.inMinutes;
                                                final seconds =
                                                    value.inSeconds % 60;
                                                return Padding(
                                                    padding:
                                                        const EdgeInsets
                                                                .symmetric(
                                                            vertical: 5),
                                                    child: userData.multiplyTimer - currentTimeInSeconds() <=
                                                            0
                                                        ? Text(
                                                            'Ready',
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
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 30)));
                                              }),
                                    )
                                  : SizedBox(),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
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
                                  child: Consumer<AllNotifier>(
                                    builder: (_, data, child) {
                                      return Text(
                                        "My Earning: ${(userData.points * Constants.decimal).toStringAsFixed(8)} ${Constants.symbol}",
                                        style: GoogleFonts.abhayaLibre(
                                            fontSize: 22,
                                            color: Colors.white,
                                            fontStyle: FontStyle.normal,
                                            fontWeight: FontWeight.bold),
                                      );
                                    },
                                  ),
                                ))),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                                child: Text(
                              " Multiply The Two Numbers",
                              textAlign: TextAlign.center,
                            )),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Consumer<AllNotifier>(builder: (_, data, child) {
                                return Container(
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      border: Border.all(color: Colors.blue),
                                      borderRadius: BorderRadius.circular(3)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 10),
                                    child: Text(
                                      "${data.randomNumberOne}",
                                      style: TextStyle(fontSize: 25),
                                    ),
                                  ),
                                );
                              }),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                "*",
                                style: TextStyle(fontSize: 22),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Consumer<AllNotifier>(builder: (_, data, child) {
                                return Container(
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      border: Border.all(color: Colors.blue),
                                      borderRadius: BorderRadius.circular(3)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 10),
                                    child: Text(
                                      "${data.randomNumberTwo}",
                                      style: TextStyle(fontSize: 25),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              height: 60,
                              child: TextFormField(
                                style: TextStyle(fontSize: 22),
                                controller: _multipliedController,
                                decoration: InputDecoration(
                                  labelText: "Enter The Multiplication ",
                                  fillColor: Colors.white,
                                  border: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(30.0),
                                    borderSide: new BorderSide(),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                onSaved: (String value) =>
                                    enteredNumber = int.parse(value),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),

                          SizedBox(
                            height: 10,
                          ),
                          userData.multiplyTimer-currentTimeInSeconds() <= 0
                                  ? Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.6,
                                      height: 50,
                                      decoration: BoxDecoration(
                                          border: Border.all(color: Colors.red),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5))),
                                      child:
                                          btnenabled
                                              ? ElevatedButton(
                                                  onPressed: () {
                                                    print(
                                                        "Guest Count $guessedTimes");

                                                    if (!updated) {

                                                      return showToastWithMessage(
                                                          "Please Update The App To The Latest Version");
                                                    }
                                                    if (_multipliedController
                                                        .text.isEmpty) {
                                                      return showToastWithMessage(
                                                          "Multiply The Two Numbers");
                                                    }

                                                    if(userData.clicks_left<=0){
                                                      return Tools.showToasts(
                                                          "You can Claim only 250 times aday");
                                                    }


                                                    ProgressDialog pr= ProgressDialog(context, isDismissible: true);
                                                    pr.show();
                                                    Timer(Duration(seconds: 5), () {
                                                      validateTheGuessedNumber();
                                                      setState(() {
                                                        pr.hide();
                                                      });
                                                    });


                                                  },
                                                  child: Text(
                                                    " Verify",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18),
                                                  ),
                                                )
                                              : ElevatedButton(
                                                  onPressed: () {
                                                    showToastWithMessage(
                                                        " Please Wait ! We are loading bonus for you. Inform Admin if its does not load after few seconds");
                                                  },
                                                  child: Text(
                                                    " Loading",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18),
                                                  ),
                                                ))
                                  : ElevatedButton(

                                      onPressed: (){

                                      },
                                      child: Text("Collected")),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "You will be rewarded upto ${(Constants.bonus_reward * Constants.decimal).toStringAsFixed(8)} ${Constants.coin_name} for the Correct Answer",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 10),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : WillPopScope(
                  onWillPop: () {
                    return showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Confirm Exit"),
                            content: Text(
                                "Are you sure you want to exit? Instead You Can Switch your network On and use The App"),
                            actions: <Widget>[
                              FlatButton(
                                child: Text("YES"),
                                onPressed: () {
                                  SystemNavigator.pop();
                                },
                              ),
                              FlatButton(
                                child: Text("NO"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          );
                        });
                  },
                  child: NoInternet());
        }
        return Container(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
