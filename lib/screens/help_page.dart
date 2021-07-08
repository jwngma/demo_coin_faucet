import 'package:democoin/services/UnityAdsServices.dart';
import 'package:democoin/services/firestore_services.dart';
import 'package:democoin/utils/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'home_page.dart';

class HelpPage extends StatefulWidget {
  static const String routeName = "HelpPage";

  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  TextEditingController _subController = TextEditingController();

  TextEditingController _messageController = TextEditingController();


  @override
  void initState() {
    super.initState();
    SystemChannels.textInput.invokeMethod('TextInput.hide');

  }



  showToastt(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) {
          return HomePage();
        }));
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Help "),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _subController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(labelText: "Enter The Subject"),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _messageController,
                    keyboardType: TextInputType.text,
                    decoration:
                        InputDecoration(labelText: "Enter Your Message"),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.red),
                    child: FlatButton(
                      onPressed: () async {
                        if (_subController.text.toString() != null &&
                            _subController.text.toString() != "") {
                          FirestoreServices firestoreServices =
                              FirestoreServices();

                          String name = await firestoreServices.getName();
                          String email = await firestoreServices.getEmail();
                          String uid = await firestoreServices.getCurrentUid();
                          print("Uid-  ${uid}");
                          var emailUrl =
                              '''mailto:${Constants.email}?subject=${_subController.text.toString()}&body=${_messageController.text.toString()}\n\n\n\nName: ${name},\nEmail: ${email},\n Uid:${uid} (Do not remove or edit this value, they are useful to solve your problem)''';
                          var out = Uri.encodeFull(emailUrl);
                          await _launchURL(out);
                        } else {
                          showToastt("Fill the Both Fields");
                        }
                      },
                      child: Text(
                        "Send Message",
                        style: TextStyle(color: Colors.white),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
