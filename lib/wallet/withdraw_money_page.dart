import 'package:auto_size_text/auto_size_text.dart';
import 'package:democoin/screens/account_page.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:democoin/models/address_model.dart';
import 'package:democoin/screens/address_page.dart';
import 'package:democoin/screens/home_page.dart';
import 'package:democoin/services/firebase_auth_services.dart';
import 'package:democoin/services/firestore_services.dart';
import 'package:democoin/utils/Constants.dart';
import 'package:democoin/widgets/message_dialog_with_ok.dart';
import 'package:democoin/widgets/notification_dialog_with_ok.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

class WithdrawMoney extends StatefulWidget {
  @override
  _WithdrawMoneyState createState() => _WithdrawMoneyState();
}

class _WithdrawMoneyState extends State<WithdrawMoney> {
  int pointsToShow;
  String withdrawal_address = "";
  TextEditingController _withdrawal_addressController = TextEditingController();
  FirebaseAuthServices authServices = FirebaseAuthServices();
  FirestoreServices _fireStoreServices = FirestoreServices();

  int selectedLocation = 0;
  bool walletSelected = false;
  List<String> withdrawalServices = Constants.withdrawalServices;
  String microwallet_eth, coinbase_email, _warning;
  String accountType = "Basic";

  @override
  void initState() {
    super.initState();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    _getPointsToShow();
    getAccountType();
  }

  _getPointsToShow() async {
    var firestoreServices =
        Provider.of<FirestoreServices>(context, listen: false);
    int point = await firestoreServices.getPoints();
    setState(() {
      pointsToShow = point;
    });
  }

  showEmptyWalletDialog(String message) {
    showDialog(
        context: context,
        builder: (context) => CustomDialogWithOk(
              title: "Empty Wallet",
              description: "You  have not added your $message yet.",
              primaryButtonText: "Ok",
              primaryButtonRoute: AddressPage.routeName,
            ));
  }

  getTheWithdrawalAddress(ProgressDialog progressDialog, int value) async {
    switch (value) {
      case 0:
        //Coinbase
        await progressDialog.show();
        await _fireStoreServices.getUserAddress().then((value) {
          progressDialog.hide();

          if (value.coinbase_email == "") {
            setState(() {
              showEmptyWalletDialog("Coinbase Email");
              _withdrawal_addressController.text =
                  "Please Save Your Address First";
            });
            return;
          } else {
            setState(() {
              walletSelected = true;
              _withdrawal_addressController.text = value.coinbase_email;
              withdrawal_address = _withdrawal_addressController.text;
            });
            return;
          }
        });
        break;
      case 1:
        //FaucetPay
        await progressDialog.show();
        await _fireStoreServices.getUserAddress().then((value) {
          progressDialog.hide();

          if (value.faucetpay_email == "") {
            setState(() {
              showEmptyWalletDialog("FaucetPay Email");
              _withdrawal_addressController.text =
                  "Please Save Your Address First";
            });
            return;
          } else {
            setState(() {
              walletSelected = true;
              _withdrawal_addressController.text = value.faucetpay_email;
              withdrawal_address = _withdrawal_addressController.text;
            });
            return;
          }
        });
        break;
    }
  }

  showToasts(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    ProgressDialog progressDialog =
        ProgressDialog(context, isDismissible: false);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                height: 100,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Center(
                                child: Text(
                              "Available Points:",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            )),
                            SizedBox(
                              width: 10,
                            ),
                            Center(
                              child: Text(
                                pointsToShow == null
                                    ? "0"
                                    : "${(pointsToShow * Constants.decimal).toStringAsFixed(8)}",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            )
                          ],
                        ),
                      ),
                      Text(
                        pointsToShow == null
                            ? "Wait For Few Seconds To get loaded"
                            : "Loaded",
                        style: TextStyle(color: Colors.white, fontSize: 8),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Flexible(
                      child: AutoSizeText(
                        "Note- Add Your Withdrawal Address, before withdrawal",
                        maxLines: 2,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return AddressPage();
                        }));
                      },
                      child: Container(
                        color: Colors.red,
                        child: Text("Here"),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  color: Colors.grey[700],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      AutoSizeText(
                        "Select the Wallet service",
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15),
                      ),
                      Container(
                        color: Colors.grey[600],
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: PopupMenuButton(
                            color: Colors.grey,
                            child: Row(
                              children: <Widget>[
                                Text(
                                  withdrawalServices[selectedLocation],
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                  size: 30,
                                )
                              ],
                            ),
                            onSelected: (int value) {
                              setState(() {
                                selectedLocation = value;
                                getTheWithdrawalAddress(progressDialog, value);
                              });
                            },
                            itemBuilder: (BuildContext context) {
                              return <PopupMenuItem<int>>[
                                PopupMenuItem(
                                  child: Text(
                                    withdrawalServices[0],
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15),
                                  ),
                                  value: 0,
                                ),
                                PopupMenuItem(
                                  child: Text(
                                    withdrawalServices[1],
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15),
                                  ),
                                  value: 1,
                                ),
                              ];
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                    child: TextFormField(
                  style: TextStyle(fontSize: 14),
                  controller: _withdrawal_addressController,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: "Wallet Address",
                    labelStyle: TextStyle(fontSize: 15),
                    fillColor: Colors.white,
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                      borderSide: new BorderSide(),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  onSaved: (String value) => withdrawal_address = value,
                )),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blue),
                  child: FlatButton(
                    onPressed: () async {
                      ProgressDialog pr =
                          ProgressDialog(context, isDismissible: false);

                      int points = await _fireStoreServices.getPoints();

                      int clicks = await _fireStoreServices
                          .getClicks(await authServices.getCurrentUser());

                      if (withdrawalServices[selectedLocation] == false) {
                        return showToasts("Select Your Wallet Email First");
                      }
                      if (withdrawal_address == "") {
                        return showToasts("Please Add Your Address First");
                      }
                      double pointToWithdraw = double.parse(
                          (points * Constants.decimal).toStringAsFixed(8));

                      if (pointToWithdraw >= 50) {
                        pr.show();
                        addWithdrawRequestOld(
                                withdrawalServices[selectedLocation],
                                points,
                                withdrawal_address,
                                clicks,
                                accountType)
                            .then((value) {
                          pr.hide();
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => NotificationDialogWithOk(
                                    title: "Withdrawal request",
                                    description:
                                        "Your withdrawal will be processed within 72 Hours, till then You can Share our App with others or Review us in playstore, It will help us to run smoothly. ",
                                    primaryButtonText: "Ok",
                                    primaryButtonRoute: HomePage.routeName,
                                  ));
                        });
                      } else {
                        showToasts(
                            "You have Low ${Constants.coin_name} in your wallet, Min Withdraw limit is 50 ${Constants.coin_name}");
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Withdraw",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Note- 1 ${Constants.symbol} = 1 ${Constants.coin_name}",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Note- ${Constants.app_name} will increase the value of  per Claim very soon",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Note- You have a ${accountType}",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Note-${Constants.approval_time} ",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "${Constants.withdraw_note}",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: Colors.red),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  showDialogCantWithdrawToday(
    String title,
    String desc,
  ) {
    showDialog(
        context: context,
        builder: (context) => NotificationDialogWithOk(
              title: title,
              description: desc,
              primaryButtonText: "Ok",
              primaryButtonRoute: AccountScreen.routeName,
            ));
  }

  Future addWithdrawRequestOld(String method, int points, String wallet_address,
      int clicks, String accountType) async {
    _fireStoreServices.addWithdrawRequest(context,
        withdrawalServices[selectedLocation], points, wallet_address, clicks);
  }

  getAccountType() async {
    accountType = await _fireStoreServices.getAccountType();
  }
/*  Future addWithdrawRequest(String method, int points, String wallet_address,
      int clicks, String accountType) async {
    print(" Add Withdraw Request");
    print("Account Type- ${accountType}");
    switch (accountType) {
      case "Basic":
        print(" One");
        if (DateTime.now().day == 15 || DateTime.now().day == 16) {
          print(" Two");
          _fireStoreServices
              .addWithdrawRequest(
                  context,
                  withdrawalServices[selected_location],
                  points,
                  wallet_address,
                  clicks)
              .then((val) {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => NotificationDialogWithOk(
                      title: "Withdrawal request",
                      description:
                          "Your withdrawal will be processed within 72 Hours, till then You can Share our App with others or Review us in playstore, It will help us to run smoothly. ",
                      primaryButtonText: "Ok",
                      primaryButtonRoute: HomePage.routeName,
                    ));
          });
        } else {
          print(" Three");

          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => NotificationDialogWithOk(
                    title: "Cannot Withdraw Today",
                    description:
                        "Your withdrawal will be processed within 72 Hours, till then You can Share our App with others or Review us in playstore, It will help us to run smoothly. ",
                    primaryButtonText: "Ok",
                    primaryButtonRoute: HomePage.routeName,
                  ));
*/ /*          showDialogCantWithdrawToday("Cannot Withdraw Today",
              "Users with Basic Plan are allowed to withdraw only on 15th - 17th of every month. Upgrade Your Account to withdraw Every day");*/ /*
        }

        break;

      case "Standard":
        {
          if (DateTime.now().day == 15 ||
              DateTime.now().day == 16 ||
              DateTime.now().day == 28 ||
              DateTime.now().day == 29) {
            _fireStoreServices
                .addWithdrawRequest(
                    context,
                    withdrawalServices[selected_location],
                    points,
                    wallet_address,
                    clicks)
                .then((val) {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => NotificationDialogWithOk(
                        title: "Withdrawal request",
                        description:
                            "Your withdrawal will be processed within 72 Hours, till then You can Share our App with others or Review us in playstore, It will help us to run smoothly",
                        primaryButtonText: "Ok",
                        primaryButtonRoute: HomePage.routeName,
                      ));
            });
          } else {
            showDialogCantWithdrawToday("Cannot Withdraw Today",
                "Users with Standard Plan are allowd to withdraw only on 15th - 16th and 28th - 29th of every month. Upgrade Your Account to withdraw Every day");
          }
        }
        break;

      case "Premium":
        {
          String currentDay = await _fireStoreServices
              .getCurrentDay()
              .then((value) => value.dayOfTheWeek);

          if (currentDay == "Sunday") {
            _fireStoreServices
                .addWithdrawRequest(
                    context,
                    withdrawalServices[selected_location],
                    points,
                    wallet_address,
                    clicks)
                .then((val) {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => NotificationDialogWithOk(
                        title: "Withdrawal request",
                        description:
                            "Your withdrawal will be processed within 72 Hours, till then You can Share our App with others or Review us in playstore, It will help us to run smoothly",
                        primaryButtonText: "Ok",
                        primaryButtonRoute: HomePage.routeName,
                      ));
            });
          } else {
            showDialogCantWithdrawToday("Cannot Withdraw Today",
                "Users with Standard Plan are allowd to withdraw only on Sunday of every month. Upgrade Your Account to withdraw Every day");
          }
        }
        break;

      case "Ultra premium":
        {
          _fireStoreServices
              .addWithdrawRequest(
                  context,
                  withdrawalServices[selected_location],
                  points,
                  wallet_address,
                  clicks)
              .then((val) {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => NotificationDialogWithOk(
                      title: "Withdrawal request",
                      description:
                          "Your withdrawal will be processed within 72 Hours, till then You can Share our App with others or Review us in playstore, It will help us to run smoothly",
                      primaryButtonText: "Ok",
                      primaryButtonRoute: HomePage.routeName,
                    ));
          });
        }
        break;

      default:
        {
          print("Invalid choice");
        }
        break;
    }
  }*/

}
