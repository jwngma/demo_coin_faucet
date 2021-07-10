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

import 'home_page.dart';

class TopUsersPage extends StatefulWidget {
  @override
  _TopUsersPageState createState() => _TopUsersPageState();
}

class _TopUsersPageState extends State<TopUsersPage> {
  FirestoreServices fireStoreServices = FirestoreServices();
  FirebaseAuthServices authServices = FirebaseAuthServices();
  String currentUid = "";

  bool _loadingProducts = true;
  List<DocumentSnapshot> _listUsers = [];
  AdmobHelper admobHelper = new AdmobHelper();

  showInterstitialAds() {
admobHelper.showInterad();
  }

  @override
  void initState() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    super.initState();
    getCurrentUserId();
    getTop100Users();
    MobileAds.instance.initialize();
    admobHelper.createInterad();
  }

  getCurrentUserId() async {
    currentUid = await fireStoreServices.getCurrentUid();
  }

  getTop100Users() {
    fireStoreServices.getTopUsers().then((val) {
      _listUsers = val;
      print(_listUsers.length);
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
        showInterstitialAds();
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
                          : _listUsers.length == 0
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
                                        "No Users yet",
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
                                  itemCount: _listUsers.length,
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color:
                                              _listUsers[index].get("uid") ==
                                                      currentUid
                                                  ? Colors.red
                                                  : Colors.grey,
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
                                                trailing: Container(
                                                  height: 45,
                                                  width: 45,
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.white),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  100)),
                                                      color: Colors.indigo),
                                                  child: CircleAvatar(
                                                    radius: 50,
                                                    backgroundImage: NetworkImage(
                                                        "${_listUsers[index].get("profile_photo")}"),
                                                  ),
                                                ),
                                                title: Text.rich(TextSpan(
                                                    text: _listUsers[index]
                                                        .get("name"),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    children: [
                                                      TextSpan(
                                                          text:
                                                              " (${_listUsers[index].get("country")})",
                                                          style: TextStyle(
                                                              fontSize: 8, color: Colors.black54))
                                                    ]))
                                                ,
                                                subtitle: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5),
                                                  child: Text(
                                                    "${(_listUsers[index].get("points") * Constants.decimal).toStringAsFixed(0)}" +
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
