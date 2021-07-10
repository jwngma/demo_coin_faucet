import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:democoin/provider_package/allNotifiers.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:democoin/screens/policy_page.dart';
import 'package:democoin/services/firebase_auth_services.dart';
import 'package:democoin/services/firestore_services.dart';
import 'package:democoin/utils/Constants.dart';
import 'package:democoin/widgets/showLoading.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  FirestoreServices firestoreServices = FirestoreServices();
  bool isLoginPressed = false;

  _SignUpPageState();

  @override
  void initState() {
    super.initState();
    //getInValidCountries();
  }

  var listInValidCountries = [];

  getInValidCountries() async {
    final RemoteConfig remoteConfig = await RemoteConfig.instance;
    RemoteConfigSettings settings = new RemoteConfigSettings();
    remoteConfig.setConfigSettings(settings);
    try {
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
          fetchTimeout: Duration(seconds: 0)
      ));
      await remoteConfig.activate();
      var countries = remoteConfig.getString('invalidCountries');
      var a = '${countries}';
      listInValidCountries = json.decode(a);
    } on PlatformException catch (exception) {
      print(exception);
    } catch (exception) {
      print(
          'Unable To Fetch The Value OF invalidCountries  Of ${Constants.coin_name}');
    }
  }

  final _formKey = GlobalKey<FormState>();
  String _email, _password, _name, _warning;
  bool terms_accepted = false;

  bool isValid() {
    final form = _formKey.currentState;

    form.save();
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }


  performLogin(FirebaseAuthServices auth) {
    setState(() {
      isLoginPressed = true;
    });
    auth.signInWithGoogle().then((user) {
      if (user != null) {
        autheticateUser(user, auth);
      } else {
        setState(() {
          isLoginPressed = false;
        });
        _warning = "We have Encountered an Error. Please Try Again";
        print("Error Occured During Loin");
      }
    });
  }


  autheticateUser(UserCredential user, FirebaseAuthServices auth) {
    if (user != null) {
     auth.authenticateUser(user).then((isNewUser) {
        isLoginPressed = false;
        print("User is ${isNewUser.toString()}");
        if (isNewUser) {
          auth.addToDb(user).then((value) {
            print("New User ! Welcome to the App. User is Added to the Database");
          });
        } else {
          auth.updateIdToken(user).then((value) {
            print("Old User ! Welcome Back to the App. User Token is Updated to the Database");
          });
        }
      });
    } else {
      setState(() {
        isLoginPressed = false;
      });
    }
  }

  bool isPresent(String countryName) {
    showToast("Checking");
    var countries = listInValidCountries.toList();
    for (int i in countries) {
      showToast(countries[i]);
    }
    return countries.contains(countryName);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF75A2EA);
    final _height = MediaQuery.of(context).size.height;
    final _width = MediaQuery.of(context).size.width;
    //bool isLoginPressed = true;
    return WillPopScope(
      onWillPop: () {
        return showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Confirm Exit"),
                content: Text("Are you sure you want to exit?"),
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
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Container(
              height: _height,
              width: _width,
              color: Colors.black,
              child: SafeArea(
                  child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      _buildErrorWidget(),
                      SizedBox(
                        height: _height * 0.05,
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: CircleAvatar(
                            radius: 100,
                            child: Image.asset(
                              Constants.app_logo,
                              height: MediaQuery.of(context).size.height * 0.2,
                            ),
                          ),
                        ),
                      ),
                      buildHeadingAutoSizeText(),
                      SizedBox(
                        height: _height * 0.1,
                      ),
                      Text(
                        "Welcome to ${Constants.app_name}, you are on the right place to earn ${Constants.coin_name} easily.",
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: _height * 0.05,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Checkbox(
                              value: terms_accepted,
                              onChanged: (bool value) {
                                setState(() {
                                  terms_accepted = value;
                                });
                              }),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return PolicyPage();
                                  }));
                                },
                                child: RichText(
                                  text: TextSpan(
                                    text: '',
                                    style: TextStyle(color: Colors.red),
                                    /*defining default style is optional */
                                    children: <TextSpan>[
                                      TextSpan(
                                          text:
                                              ' I have read, understood and agree',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.lightGreenAccent)),
                                      TextSpan(
                                          text: ' \n to the  ',
                                          style: TextStyle(
                                              color: Colors.lightGreenAccent)),
                                      TextSpan(
                                        text: 'Terms of use.',
                                        style: TextStyle(
                                            color: Colors.red,
                                            decoration:
                                                TextDecoration.underline),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: _height * 0.1,
                      ),
                      Visibility(
                        visible: true,
                        child: GoogleSignInButton(onPressed: () async {
                          if (terms_accepted) {
                            final auth = FirebaseAuthServices();
                                performLogin(auth);

                          } else {
                            showToast("Accept the Terms And Conditions");
                          }
                        }),
                      ),
                      SizedBox(
                        height: _height * 0.05,
                      )
                    ],
                  ),
                ),
              )),
            ),
            isLoginPressed ? showLoadingDialog() : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  AutoSizeText buildHeadingAutoSizeText() {
    String header_text = "${Constants.app_name}";

    return AutoSizeText(
      header_text,
      maxLines: 1,
      style: TextStyle(fontSize: 40, color: Colors.white),
    );
  }

  showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  _buildErrorWidget() {
    if (_warning != null) {
      return Container(
        color: Colors.yellow,
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child:
                  IconButton(icon: Icon(Icons.error_outline), onPressed: () {}),
            ),
            Expanded(
              child: AutoSizeText(
                _warning,
                maxLines: 3,
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _warning = null;
                    });
                  }),
            ),
          ],
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
