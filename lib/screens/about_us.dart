import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:democoin/services/UnityAdsServices.dart';
import 'package:democoin/services/firestore_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:democoin/utils/Constants.dart';
import 'package:url_launcher/url_launcher.dart';

import 'home_page.dart';

class AboutUsScreen extends StatefulWidget {
  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {


  @override
  void initState() {
    super.initState();
    SystemChannels.textInput.invokeMethod('TextInput.hide');

  }


  @override
  Widget build(BuildContext context) {
    _launchURL(String url) async {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
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

    _launchTelegram(String url) async {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        showToasts("You Do not hyave Telegram Installed");
        throw 'Could not launch $url';
      }
    }

    Widget socialActions(context) => FittedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: Icon(FontAwesomeIcons.telegram),
                onPressed: () async {
                  await _launchTelegram(Constants.telegram_group_link);
                },
              ),
              IconButton(
                icon: Icon(FontAwesomeIcons.envelope),
                onPressed: () async {
                  FirestoreServices firestoreServices = FirestoreServices();

                  String name = await firestoreServices.getName();
                  String email = await firestoreServices.getEmail();
                  String uid = await firestoreServices.getCurrentUid();
                  print("Uid-  ${uid}");
                  var emailUrl =
                      '''mailto:${Constants.email}?subject=Support Needed For ${Constants.app_name}&body=\n\n\n\n\n\n\n\n\n\n\n\n\n\nName: ${name},\nEmail: ${email},\n Uid:${uid} (Do not remove or edit this value, they are useful to solve your problem)''';
                  var out = Uri.encodeFull(emailUrl);
                  await _launchURL(out);
                },
              ),
            ],
          ),
        );

    return WillPopScope(
      onWillPop: () {

        Navigator.of(context).push(MaterialPageRoute(builder: (_) {
          return HomePage();
        }));
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("About Us"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10,
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
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AutoSizeText(
                  "${Constants.app_name} App",
                  maxLines: 2,
                  style: TextStyle(
                      fontSize: 22,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  Constants.desc_about_app,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  Constants.contact_us,
                  textAlign: TextAlign.center,
                ),
              ),
              socialActions(context),
              SizedBox(
                height: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
