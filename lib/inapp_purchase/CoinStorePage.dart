import 'dart:async';
import 'dart:io';
import 'package:democoin/models/inAppTransactionModel.dart';
import 'package:democoin/services/firestore_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'SuccesfulPurchase.dart';

const bool kAutoConsume = true;

const String _kConsumableId = 'standard';

const List<String> _kAndroidProductIds = <String>[
  'standard',
  'premium',
  'ultra_premium',
  'isolated',
];
int entry_coin;

class CoinStorePage extends StatefulWidget {
  static const String routeName = "/CoinStorePage";

  @override
  _CoinStorePageState createState() => _CoinStorePageState();
}

class _CoinStorePageState extends State<CoinStorePage> {


  final InAppPurchaseConnection _connection = InAppPurchaseConnection.instance;
  StreamSubscription<List<PurchaseDetails>> _subscription;
  List<String> _notFoundIds = [];
  List<ProductDetails> _products = [];
  FirestoreServices fireStoreServices = FirestoreServices();
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  String _queryProductError;

  @override
  void initState() {
    ProgressDialog progressDialog= ProgressDialog(context, isDismissible: false);
    Stream purchaseUpdated =
        InAppPurchaseConnection.instance.purchaseUpdatedStream;

    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      progressDialog.show();
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      progressDialog.hide();
      _subscription.cancel();
    }, onError: (error) {
      // handle error here.
    });
    initStoreInfo();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    super.initState();
  }

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _connection.isAvailable();

    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = [];
        _notFoundIds = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    ProductDetailsResponse productDetailResponse =
        await _connection.queryProductDetails(_kAndroidProductIds.toSet());
    if (productDetailResponse.error != null) {
      setState(() {
        _queryProductError = productDetailResponse.error.message;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _notFoundIds = productDetailResponse.notFoundIDs;
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _queryProductError = null;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _products.sort((a, b) => a.price.compareTo(b.price));
        _notFoundIds = productDetailResponse.notFoundIDs;
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    final QueryPurchaseDetailsResponse purchaseResponse =
        await _connection.queryPastPurchases();
    if (purchaseResponse.error != null) {
      // handle query past purchase error..
    }
    final List<PurchaseDetails> verifiedPurchases = [];
    for (PurchaseDetails purchase in purchaseResponse.pastPurchases) {
      if (await _verifyPurchase(purchase)) {
        verifiedPurchases.add(purchase);
      }
    }
    setState(() {
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      _notFoundIds = productDetailResponse.notFoundIDs;
      _purchasePending = false;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stack = [];

    if (_queryProductError == null) {
      stack.add(
        ListView(
          children: [
            SizedBox(
              height: 10,
            ),
            _buildConnectionCheckTile(),
            _buildProductList(),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Note- This cannot be used to redeem",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 10,
                ),
              ),
            )
          ],
        ),
      );
    } else {
      stack.add(Center(
        child: Text(_queryProductError),
      ));
    }
    if (_purchasePending) {
      stack.add(
        Stack(
          children: [
            Opacity(
              opacity: 0.3,
              child: const ModalBarrier(dismissible: false, color: Colors.grey),
            ),
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Increase Per Claim"),
      ),
      body: Stack(
        children: stack,
      ),
    );
  }

  Card _buildConnectionCheckTile() {
    if (_loading) {
      return Card(child: ListTile(title: const Text('Trying to connect...')));
    }
    final List<Widget> children = <Widget>[];

    if (!_isAvailable) {
      children.addAll([
        Divider(),
        ListTile(
          title: Text('Not connected',
              style: TextStyle(color: ThemeData.light().errorColor)),
          subtitle: const Text(
              'Unable to connect to the payments processor. Has this app been configured correctly? See the example README for instructions.'),
        ),
      ]);
    }
    return Card(child: Column(children: children));
  }

  Card _buildProductList() {
    if (_loading) {
      return Card(
          child: (ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Fetching products...'))));
    }
    if (!_isAvailable) {
      return Card();
    }
    final ListTile productHeader = ListTile(
        title: Text(
      'Increase Per Claim Bonus And Earn More',
      style: TextStyle(
          fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
      textAlign: TextAlign.center,
    ));
    List<Widget> productList = <Widget>[];
    if (_notFoundIds.isNotEmpty) {
      productList.add(Container(
        child: ListTile(
            title: Text('[${_notFoundIds.join(", ")}] not found',
                style: TextStyle(color: ThemeData.light().errorColor)),
            subtitle: Text(
                'This app needs special configuration to run. Please see example/README.md for instructions.')),
      ));
    }
    productList.addAll(_products.map(
      (ProductDetails productDetails) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black54,
            ),
            child: Column(
              children: [
                SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    productDetails.title,
                    style: TextStyle(fontSize: 15, color: Colors.red),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    productDetails.description.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
                RaisedButton(
                  color: Colors.red,
                  child: Text(productDetails.price),
                  onPressed: () {
                    PurchaseParam purchaseParam = PurchaseParam(
                        productDetails: productDetails,
                        applicationUserName: null,
                        sandboxTesting: false);

              /*      Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                      return CoinStoreDetailsPage(
                        purchaseParam: purchaseParam,
                      );
                    }));
*/
                _connection.buyConsumable(
                              purchaseParam: purchaseParam,
                              autoConsume: kAutoConsume || Platform.isIOS);
                  },
                ),
                SizedBox(height: 10,)
              ],
            ),
          ),
        );
      },
    ));

    return Card(
        child: Column(
            children: <Widget>[
                  productHeader,
                  Divider(
                    color: Colors.white,
                  ),
                  SizedBox(
                    height: 10,
                  )
                ] +
                productList));
  }

  void showPendingUI() {
    setState(() {
      _purchasePending = true;
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
      print('purchaseID :' + inAppTransactionModel.purchaseID); // La// st
      if (purchaseDetails.productID == "standard") {
        fireStoreServices
            .addInAppTransactions(context, inAppTransactionModel, 743
            , 180)
            .then((value) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SuccesfulPurchase(
              amount: 743,
              transactionId: purchaseDetails.purchaseID,
              desc: "You have successfully Paid Rs 743 only",
              done: purchaseDetails.pendingCompletePurchase,
            );
          }));
        });
      } else if (purchaseDetails.productID == "premium") {
        fireStoreServices
            .addInAppTransactions(context, inAppTransactionModel, 1114, 180)
            .then((value) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SuccesfulPurchase(
              amount: 1114,
              transactionId: purchaseDetails.purchaseID,
              desc: "You have siccessfuly added Rs 1114 only",
              done: purchaseDetails.pendingCompletePurchase,
            );
          }));
        });
      } else if (purchaseDetails.productID == "ultra_premium") {
        fireStoreServices
            .addInAppTransactions(context, inAppTransactionModel,  1486, 180)
            .then((value) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SuccesfulPurchase(
              amount: 1486,
              transactionId: purchaseDetails.purchaseID,
              desc: "You have siccessfuly added  Rs 1486 only ",
              done: purchaseDetails.pendingCompletePurchase,
            );
          }));
        });
      }else if (purchaseDetails.productID == "isolated") {
        fireStoreServices
            .addInAppTransactions(context, inAppTransactionModel,   1857, 180)
            .then((value) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SuccesfulPurchase(
              amount: 1857,
              transactionId: purchaseDetails.purchaseID,
              desc: "You have siccessfuly added  Rs 1857 only ",
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
    ProgressDialog progressDialog =
        ProgressDialog(context, isDismissible: false);
    progressDialog.show();
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
            print(" Valid Purchase");
            deliverProduct(purchaseDetails);
          } else {
            print("Invalid Purchase");
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
}
