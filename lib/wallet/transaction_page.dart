import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:democoin/utils/Constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:democoin/services/firestore_services.dart';
import 'package:democoin/widgets/shimmer_widget.dart';
import 'package:shimmer/shimmer.dart';

class TransactionsPage extends StatefulWidget {
  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  Stream stream;
  FirestoreServices fireStoreServices = FirestoreServices();
  bool showLoading = true;

  bool _loadingProducts = true;
  List<DocumentSnapshot> _listEvents = [];

  @override
  void initState() {
    getEvents();
    super.initState();
  }

  getEvents() {
    fireStoreServices.getTransactionss().then((val) {
      _listEvents = val;
      setState(() {
        if(mounted){
          _loadingProducts = false;
        }

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                  : _listEvents.length == 0
                                  ? Center(
                                child: Container(
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: <Widget>[
                                        SizedBox(
                                          height: 100,
                                        ),
                                        Text(
                                          "You have not done any Withdrawal or Your \nwithdrawal are not approved yet",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.green),
                                        ),
                                        SizedBox(
                                          height: 30,
                                        ),
                                      ],
                                    )),
                              )
                                  : ListView.builder(
                                  itemCount: _listEvents.length,
                                  physics:
                                  NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    //

                                    return Card(
                                      elevation: 1,
                                      color: Colors.grey,
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          radius: 20,
                                          child: Text("${index}"),
                                        ),
                                        title: AutoSizeText(
                                          "${_listEvents[index].get("title")}",
                                          maxLines: 2,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight:
                                              FontWeight.bold),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              //"Points- ${_listEvents[index].get("points")}",
                                              "Points- ${(_listEvents[index].get("points")* Constants.decimal).toStringAsFixed(8)} ${Constants.coin_name}",
                                              style: TextStyle(
                                                  fontSize: 14),
                                            ),
                                            Text(
                                              // "Status- ${_listEvents[index].get("type")}",
                                              "Status- ${_listEvents[index].get("status")}",
                                              style: TextStyle(
                                                  fontSize: 14),
                                            ),
                                          ],
                                        ),
                                        trailing: Text(
                                          // "${DateFormat.yMd().format(DateTime.parse(_listEvents[index].get('time').toString()))}",
                                          "${DateFormat.yMd().format(DateTime.parse(_listEvents[index].get('date').toString()))}",
                                          style:
                                          TextStyle(fontSize: 10),
                                        ),
                                      ),
                                    );
                                  })),
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
        ],
      ),
    );
  }
}
