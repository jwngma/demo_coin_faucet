import 'package:democoin/games/Webview.dart';
import 'package:democoin/screens/home_page.dart';
import 'package:democoin/services/AdmobHelper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:democoin/services/UnityAdsServices.dart';
import 'package:democoin/services/firebase_auth_services.dart';
import 'package:democoin/services/firestore_services.dart';
import 'package:democoin/utils/Constants.dart';
import 'package:democoin/widgets/shimmer_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shimmer/shimmer.dart';

class LoadWebiewburlsPage extends StatefulWidget {
  @override
  _LoadWebiewburlsPageState createState() => _LoadWebiewburlsPageState();
}

class _LoadWebiewburlsPageState extends State<LoadWebiewburlsPage> {
  FirestoreServices fireStoreServices = FirestoreServices();
  FirebaseAuthServices authServices = FirebaseAuthServices();
  String currentUid = "";

  bool _loadingProducts = true;
  List<DocumentSnapshot> _listShortLinks = [];

  @override
  void initState() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    super.initState();
    getShorturls();
  }

  getShorturls() {
    fireStoreServices.getWebviewUrls().then((val) {
      _listShortLinks = val;
      print(_listShortLinks.length);
      if (mounted) {
        setState(() {
          _loadingProducts = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
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
            title: Text("Top 100 users"),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                      child: _loadingProducts == true
                          ? Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Container(
                                child: Container(
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.black,
                                    highlightColor: Colors.white,
                                    enabled: true,
                                    child: ShimmerWidget(),
                                  ),
                                ),
                              ),
                            )
                          : _listShortLinks.length == 0
                              ? Center(
                                  child: Container(
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Image.asset(
                                        Constants.weeklyIcon,
                                        height: 100,
                                        width: 100,
                                      ),
                                      SizedBox(
                                        height: 30,
                                      ),
                                      Text(
                                        "No Urls",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.green),
                                      ),
                                      SizedBox(
                                        height: 30,
                                      ),
                                    ],
                                  )),
                                )
                              : ListView.builder(
                                  itemCount: _listShortLinks.length,
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: (){
                                       Navigator.of(context).push(MaterialPageRoute(builder: (_){
                                         return Webview();
                                       }));
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10),
                                                child: CircleAvatar(
                                                  radius: 20,
                                                  child: Text("${index + 1}"),
                                                ),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.8,
                                                child: ListTile(
                                                  title: Text(
                                                    "${(_listShortLinks[index].get("shortLink"))}" +
                                                        "  ${Constants.coin_name}",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black54),
                                                  ),
                                                  subtitle: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 5),
                                                    child: Text(
                                                      "${(_listShortLinks[index].get("longLink"))}" +
                                                          "  ${Constants.coin_name}",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.black54),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  })),
                ],
              ),
            ),
          )),
    );
  }

  showToastt(String message) {
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
