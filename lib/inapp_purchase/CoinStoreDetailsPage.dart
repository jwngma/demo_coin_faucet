import 'dart:async';
import 'dart:io';
import 'package:democoin/models/inAppTransactionModel.dart';
import 'package:democoin/services/firestore_services.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'SuccesfulPurchase.dart';

const bool kAutoConsume = true;
const String _kConsumableId = 'no_ads_seven_days';

class CoinStoreDetailsPage extends StatefulWidget {
  final PurchaseParam purchaseParam;

  const CoinStoreDetailsPage({Key key, this.purchaseParam}) : super(key: key);

  @override
  _CoinStoreDetailspageState createState() => _CoinStoreDetailspageState();
}

class _CoinStoreDetailspageState extends State<CoinStoreDetailsPage> {
  final InAppPurchaseConnection _connection = InAppPurchaseConnection.instance;
  FirestoreServices fireStoreServices = FirestoreServices();
  StreamSubscription<List<PurchaseDetails>> _subscription;

  @override
  void initState() {
    Stream purchaseUpdated =
        InAppPurchaseConnection.instance.purchaseUpdatedStream;

    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.purchaseParam.productDetails.title}"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Benifits of Removing Ads", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
            SizedBox(height: 10,),
            Text("${widget.purchaseParam.productDetails.description}", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, ),),
            SizedBox(height: 10,),
            ElevatedButton(
              onPressed: () {
                ProgressDialog progressDialog =
                    ProgressDialog(context, isDismissible: false);
                progressDialog.show();
                _connection
                    .buyConsumable(
                        purchaseParam: widget.purchaseParam,
                        autoConsume: kAutoConsume || Platform.isIOS)
                    .then((value) {
                  progressDialog.hide();
                });
              },
              child: Text("Remove Now ${widget.purchaseParam.productDetails.price}"),
            ),
          ],
        ),
      ),
    );
  }

  bool _purchasePending = false;

  void showPendingUI() {
    setState(() {
      _purchasePending = true;
    });
  }

  void handleError(IAPError error) {
    setState(() {
      _purchasePending = false;
    });
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    print('From _verifyPurchase, Status: ' + purchaseDetails.status.toString());
    print("From _verifyPurchase ,The Product purchase status is :" +
        purchaseDetails.status.toString());
    print("From _verifyPurchase ,The Product purchase Transactiondate is :" +
        purchaseDetails.transactionDate.toString());
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    print(
        '_handleInvalidPurchase Status :' + purchaseDetails.status.toString());
    print('_handleInvalidPurchase ' + purchaseDetails.purchaseID);
    print('_handleInvalidPurchase ' + purchaseDetails.transactionDate);
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    print('_listenToPurchaseUpdated ');
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          handleError(purchaseDetails.error);
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            deliverProduct(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        if (Platform.isAndroid) {
          if (!kAutoConsume && purchaseDetails.productID == _kConsumableId) {
            await InAppPurchaseConnection.instance
                .consumePurchase(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchaseConnection.instance
              .completePurchase(purchaseDetails);
        }
      }
    });
  }

  void deliverProduct(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.status.toString() == "PurchaseStatus.purchased") {
      InAppTransactionModel inAppTransactionModel = InAppTransactionModel(
        purchaseID: purchaseDetails.purchaseID,
        transactionDate: purchaseDetails.transactionDate,
        status: purchaseDetails.status.toString(),
        productID: purchaseDetails.productID,
        pendingCompletePurchase: purchaseDetails.pendingCompletePurchase,
      );

      print('status :' + inAppTransactionModel.status); // La
      print('transactionDate :' + inAppTransactionModel.transactionDate); // La
      print('purchaseID :' + inAppTransactionModel.purchaseID); // La//
      // st
      if (purchaseDetails.productID == "no_ads_one_day") {
        fireStoreServices
            .addInAppTransactions(context, inAppTransactionModel, 150, 2)
            .then((value) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SuccesfulPurchase(
              amount: 150,
              transactionId: purchaseDetails.purchaseID,
              desc: "You have siccessfuly added 150 coins",
              done: purchaseDetails.pendingCompletePurchase,
            );
          }));
        });
      } else if (purchaseDetails.productID == "no_ads_seven_days") {
        fireStoreServices
            .addInAppTransactions(context, inAppTransactionModel, 500, 7)
            .then((value) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SuccesfulPurchase(
              amount: 500,
              transactionId: purchaseDetails.purchaseID,
              desc: "You have siccessfuly added 500 coins",
              done: purchaseDetails.pendingCompletePurchase,
            );
          }));
        });
      } else if (purchaseDetails.productID == "no_ads_fourteen_days") {
        fireStoreServices
            .addInAppTransactions(context, inAppTransactionModel, 720, 14)
            .then((value) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SuccesfulPurchase(
              amount: 720,
              transactionId: purchaseDetails.purchaseID,
              desc: "You have siccessfuly added 720 coins",
              done: purchaseDetails.pendingCompletePurchase,
            );
          }));
        });
      } else if (purchaseDetails.productID == "no_ads_twentyfive_days") {
        fireStoreServices
            .addInAppTransactions(context, inAppTransactionModel, 1080, 25)
            .then((value) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SuccesfulPurchase(
              amount: 1080,
              transactionId: purchaseDetails.purchaseID,
              desc: "You have siccessfuly added 1080 coins",
              done: purchaseDetails.pendingCompletePurchase,
            );
          }));
        });
      } else {
        print(
            "The Purchase Product detail is : product: ${purchaseDetails.productID} Status: ${purchaseDetails.status.toString()} Transaction date ${purchaseDetails.transactionDate}");
      }
    }
  }
}
