import 'package:auto_size_text/auto_size_text.dart';
import 'package:democoin/services/UnityAdsServices.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:democoin/services/firestore_services.dart';
import 'package:democoin/widgets/message_dialog_with_ok.dart';
import 'package:democoin/widgets/notification_dialog_with_ok.dart';
import 'package:democoin/widgets/showLoading.dart';

import 'home_page.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  Stream stream;
  FirestoreServices fireStoreServices = FirestoreServices();
  bool showLoading = true;
  //



  showInterstitialAds() {
    //
  }
  @override
  void initState() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    //
    fireStoreServices.getNotifications().then((val) {
      setState(() {
        stream = val;
        showLoading = false;
      });
    });

    super.initState();
  }

  showNotificationDialog(String title, String message) {
    showDialog(
        context: context,
        builder: (context) => NotificationDialogWithOk(
          title: title,
          description: message,
          primaryButtonText: "Ok",
        ));
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
          title: Text("Notifications"),
        ),
        backgroundColor: Colors.white,
        body: Stack(
          children: <Widget>[
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            StreamBuilder(
                                stream: stream,
                                builder: (context, snapshots) {
                                  return snapshots.data == null
                                      ? showLoadingDialog()
                                      : ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount:
                                      snapshots.data.docs.length,
                                      shrinkWrap: true,
                                      reverse: true,
                                      itemBuilder: (context, index) {
                                        if (index < 0)
                                          return Text("No Notifications");
                                        return GestureDetector(
                                          onTap: () {
                                            showNotificationDialog(
                                                snapshots
                                                    .data
                                                    .docs[index]
                                                    ["title"],
                                                snapshots
                                                    .data
                                                    .docs[index]
                                                    ["message"]);
                                          },
                                          child: Card(
                                            elevation: 1,
                                            color: Colors.grey,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: ListTile(
                                                leading: CircleAvatar(
                                                  radius: 20,
                                                  child: Icon(
                                                    Icons.announcement,
                                                    size: 15,
                                                  ),
                                                ),
                                                title: AutoSizeText(
                                                  snapshots
                                                      .data
                                                      .docs[index]
                                                      ["title"],
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                      FontWeight.bold),
                                                ),
                                                subtitle: Text(
                                                  snapshots
                                                      .data
                                                      .docs[index]
                                                      ["message"],
                                                  style:
                                                  TextStyle(fontSize: 14),
                                                ),
                                                trailing: Text(
                                                  "${DateFormat.yMd().format(DateTime.parse(snapshots.data.docs[index]['time'].toString()))}",
                                                  style:
                                                  TextStyle(fontSize: 10),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                })
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 100,
                    )
                  ],
                ),
              ),
            ),
            showLoading ? showLoadingDialog() : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
