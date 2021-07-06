import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:democoin/models/users.dart';
import 'package:democoin/screens/ReferralPage.dart';
import 'package:democoin/screens/TopUsersPage.dart';
import 'package:democoin/services/UnityAdsServices.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:democoin/provider_package/connectivity_provider.dart';
import 'package:democoin/screens/about_us.dart';
import 'package:democoin/screens/chat_room/chatrooms_page.dart';
import 'package:democoin/screens/help_page.dart';
import 'package:democoin/screens/home_screen.dart';
import 'package:democoin/screens/no_internet.dart';
import 'package:democoin/screens/notification_page.dart';
import 'package:democoin/screens/policy_page.dart';
import 'package:democoin/screens/redeem_page.dart';
import 'package:democoin/services/firebase_auth_services.dart';
import 'package:democoin/services/firestore_services.dart';
import 'package:democoin/utils/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:democoin/widgets/message_dialog_with_ok.dart';
import 'package:package_info/package_info.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'account_page.dart';

class HomePage extends StatefulWidget {
  static const String routeName = "HomePage";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const PLAY_STORE_URL = Constants.app_link;
  final Firestore _db = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  FirestoreServices firestoreServices = FirestoreServices();
  UnityAdsServices unityAdsServices = UnityAdsServices();

  String email = '';

  Future<void> _signOut(BuildContext context) async {
    ProgressDialog progressDialog =
        ProgressDialog(context, isDismissible: false);
    var firebaseAuthServices = FirebaseAuthServices();
    await progressDialog.show();
    try {
      GoogleSignIn _googleSignIn = GoogleSignIn();

      final _firebaseAuth = FirebaseAuth.instance;

      progressDialog.hide();
      if (_googleSignIn != null) {
        print("Google is called");
        await firebaseAuthServices.signOutWhenGoogle();
        progressDialog.hide();
      } else {
        print("Auth is Called");
        await _firebaseAuth.signOut();
        progressDialog.hide();
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    try {
      versionCheck(context);
    } catch (e) {
      print(e);
    }
    Provider.of<ConnectivityProvider>(context, listen: false).startMonitoring();
    UnityAdsServices.init();
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");

        showDialog(
            context: context,
            builder: (context) => CustomDialogWithOk(
                  title: message['notification']['title'],
                  description: message['notification']['body'],
                  primaryButtonText: "Ok",
                  primaryButtonRoute: HomePage.routeName,
                ));
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        _navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        _navigateToItemDetail(message);
      },
    );
    super.initState();
  }

  showInterstitialAds() {
    unityAdsServices.showInterstitialAd();
  }

/*  getEmailAddress() async {
    email = await firestoreServices.getEmail();
    setState(() {});
    print("Email ${email}");
  }*/

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  //PRIVATE METHOD TO HANDLE NAVIGATION TO SPECIFIC PAGE
  void _navigateToItemDetail(Map<String, dynamic> message) {
    final MessageBean item = _itemForMessage(message);
    // Clear away dialogs
    Navigator.popUntil(context, (Route<dynamic> route) => route is PageRoute);

    if (item.itemId != "1") {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) {
        return HomePage();
      }));
    }

    if (!item.route.isCurrent) {
      Navigator.push(context, item.route);
    }
  }

  versionCheck(context) async {
    //Get Current installed version of app
    final PackageInfo info = await PackageInfo.fromPlatform();
    double currentVersion =
        double.parse(info.version.trim().replaceAll(".", ""));

    //Get Latest version info from firebase config
    final RemoteConfig remoteConfig = await RemoteConfig.instance;

    try {
      // Using default duration to force fetching from remote server.
      await remoteConfig.fetch(expiration: const Duration(seconds: 0));
      await remoteConfig.activateFetched();
      remoteConfig.getString('force_update_current_version');
      double newVersion = double.parse(remoteConfig
          .getString('force_update_current_version')
          .trim()
          .replaceAll(".", ""));
      if (newVersion > currentVersion) {
        _showVersionDialog(context);
      }
    } on FetchThrottledException catch (exception) {
      // Fetch throttled.
      print(exception);
    } catch (exception) {
      print('Unable to fetch remote config. Cached or default values will be '
          'used');
    }
  }

  _showVersionDialog(context) async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = "New Update Available";
        String message =
            "There is a newer version of app available, They have added some more interesting faeatures. please update it now.";
        String btnLabel = "Update Now";
        return Platform.isIOS
            ? new CupertinoAlertDialog(
                title: Text(title),
                content: Text(message),
                actions: <Widget>[
                  FlatButton(
                    child: Text(btnLabel),
                    onPressed: () => _launchURL(PLAY_STORE_URL),
                  ),
                ],
              )
            : new AlertDialog(
                title: Text(title),
                content: Text(message),
                actions: <Widget>[
                  FlatButton(
                    child: Text(btnLabel),
                    onPressed: () => _launchURL(PLAY_STORE_URL),
                  ),
                ],
              );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showRatingDialog() {
    // We use the built in showDialog function to show our Rating Dialog
    showDialog(
        context: context,
        barrierDismissible: true, // set to false if you want to force a rating
        builder: (context) {
          return RatingDialog(
            icon: Image.asset(
              Constants.app_logo,
              fit: BoxFit.contain,
              height: 50,
            ),
            // set your own image/icon widget
            title: " Rating Dialog",
            description:
                "Tap a star to set your rating. Add more description here if you want.",
            submitButton: "SUBMIT",
            alternativeButton: "Contact us instead?",
            // optional
            positiveComment: "We are so happy to hear :)",
            // optional
            negativeComment: "We're sad to hear :(",
            // optional
            accentColor: Colors.red,
            // optional
            onSubmitPressed: (int rating) {
              print("onSubmitPressed: rating = $rating");
              _launchURL(Constants.app_link);
            },
            onAlternativePressed: () {
              print("onAlternativePressed: do something");
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return HelpPage();
              }));
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
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
                    appBar: AppBar(
                      elevation: 0,
                      title: Text(Constants.app_name),
                      actions: <Widget>[
                        IconButton(
                            icon: Icon(
                              Icons.chat,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return ChatRoomsPage();
                              }));
                            }),
                        IconButton(
                            icon: Icon(
                              Icons.notifications,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return NotificationPage();
                              }));
                            }),
                        SizedBox(
                          width: 10,
                        )
                      ],
                    ),
                    // body: FaceBookAds(),
                    body: HomeScreen(),
                    drawer: Drawer(
                      child: ListView(
                        children: <Widget>[
                          UserAccountsDrawerHeader(
                            accountName: Text(
                              Constants.app_name,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            accountEmail: Text(
                              "${userData!=null ?userData.email:""}",
                              style: TextStyle(
                                  fontSize: 15, color: Colors.greenAccent),
                            ),
                            currentAccountPicture: new CircleAvatar(
                              child: CircleAvatar(
                                backgroundImage: AssetImage(Constants.app_logo),
                                backgroundColor: Colors.white,
                              ),
                            ),
                          ),
                          ListTile(
                            title: Text("Home"),
                            leading: Icon(Icons.home),
                            onTap: () {
                              showInterstitialAds();
                              Navigator.of(context).pop();
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return HomePage();
                              }));
                            },
                          ),
                          Divider(
                            height: 1,
                            color: Colors.white,
                          ),
                          ListTile(
                            title: Text("Top 50 Users"),
                            leading: Icon(Icons.vertical_align_top),
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return TopUsersPage();
                              }));
                            },
                          ),
                          Divider(
                            height: 1,
                            color: Colors.white,
                          ),
                          ListTile(
                            title: Text("Redeem"),
                            leading: Icon(Icons.account_balance_wallet),
                            onTap: () {
                              showInterstitialAds();
                              Navigator.of(context).pop();

                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return RedeemScreen();
                              }));
                            },
                          ),
                          Divider(
                            height: 1,
                            color: Colors.white,
                          ),
                          ListTile(
                            title: Text("Policies"),
                            leading: Icon(Icons.security),
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return PolicyPage();
                              }));
                            },
                          ),
                          Divider(
                            height: 1,
                            color: Colors.white,
                          ),
                          ListTile(
                            title: Text("Help"),
                            leading: Icon(Icons.help),
                            onTap: () {
                              Navigator.of(context).pop();
                              showInterstitialAds();
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return HelpPage();
                              }));
                            },
                          ),
                          Divider(
                            height: 1,
                            color: Colors.white,
                          ),
                          ListTile(
                            title: Text("Youtube Channel"),
                            leading: Icon(Icons.help),
                            onTap: () {
                              Navigator.of(context).pop();

                              _launchURL(
                                  "https://www.youtube.com/channel/UCdzz6KsxA_vHqJyI4fCxF-A");
                            },
                          ),
                          Divider(
                            height: 1,
                            color: Colors.white,
                          ),
                          ListTile(
                            title: Text("Rate The App"),
                            leading: Icon(Icons.star),
                            onTap: () {
                              Navigator.of(context).pop();
                              _showRatingDialog();
                            },
                          ),
                          Divider(
                            height: 1,
                            color: Colors.white,
                          ),
                          ListTile(
                            title: Text("Share App"),
                            leading: Icon(Icons.share),
                            onTap: () {
                              Navigator.of(context).pop();
                              showInterstitialAds();
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                    return ReferralPage();
                                  }));
                            },
                          ),
                          Divider(
                            height: 1,
                            color: Colors.white,
                          ),
                          ListTile(
                            title: Text("About us"),
                            leading: Icon(Icons.info),
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return AboutUsScreen();
                              }));
                            },
                          ),
                          Divider(
                            height: 1,
                            color: Colors.white,
                          ),
                          ListTile(
                            title: Text("Logout"),
                            leading: Icon(FontAwesomeIcons.signOutAlt),
                            onTap: () {
                              Navigator.of(context).pop();
                              _signOut(context);
                            },
                          ),
                          Divider(
                            height: 1,
                            color: Colors.white,
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

final Map<String, MessageBean> _items = <String, MessageBean>{};

MessageBean _itemForMessage(Map<String, dynamic> message) {
  //If the message['data'] is non-null, we will return its value, else return map message object
  final dynamic data = message['data'] ?? message;
  final String itemId = data['id'];
  final MessageBean item = _items.putIfAbsent(
      itemId, () => MessageBean(itemId: itemId))
    ..status = data['status'];
  return item;
}

//Model class to represent the message return by FCM
class MessageBean {
  MessageBean({this.itemId});

  final String itemId;

  StreamController<MessageBean> _controller =
      StreamController<MessageBean>.broadcast();

  Stream<MessageBean> get onChanged => _controller.stream;

  String _status;

  String get status => _status;

  set status(String value) {
    _status = value;
    _controller.add(this);
  }

  static final Map<String, Route<void>> routes = <String, Route<void>>{};

  Route<void> get route {
    final String routeName = '/detail/$itemId';
    return routes.putIfAbsent(
      routeName,
      () => MaterialPageRoute<void>(
        settings: RouteSettings(name: routeName),
        builder: (BuildContext context) => DetailPage(itemId),
      ),
    );
  }
}

//Detail UI screen that will display the content of the message return from FCM
class DetailPage extends StatefulWidget {
  DetailPage(this.itemId);

  final String itemId;

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  MessageBean _item;
  StreamSubscription<MessageBean> _subscription;

  @override
  void initState() {
    super.initState();
    _item = _items[widget.itemId];
    _subscription = _item.onChanged.listen((MessageBean item) {
      if (!mounted) {
        _subscription.cancel();
      } else {
        setState(() {
          _item = item;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _item.itemId == "1" ? Text("Payment Approved") : Text(""),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Container(
            height: 100,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.all(Radius.circular(10))),
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
          Center(
              child: Text(
            "${_item.status}",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          )),
        ],
      ),
    );
  }

  _launchTelegram(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      showToasts("You Cannot Open it");
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
