import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:democoin/models/AccountData.dart';
import 'package:democoin/models/AppData.dart';
import 'package:democoin/models/CurrentDay.dart';
import 'package:democoin/models/inAppTransactionModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:democoin/models/Country.dart';
import 'package:democoin/models/address_model.dart';
import 'package:democoin/models/appStatus.dart';
import 'package:democoin/models/users.dart';
import 'package:democoin/utils/Constants.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class FirestoreServices {
  FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  // getting Notifications
  getNotifications() async {
    final FirebaseUser user = await auth.currentUser();
    return await _db
        .collection(Constants.Users)
        .doc(user.uid)
        .collection(Constants.notifications)
        .orderBy("time", descending: false)
        .snapshots();
  }

  // getting Notifications
  getAnnouncements() async {
    return await _db
        .collection(Constants.announcements)
        .orderBy("time", descending: false)
        .snapshots();
  }

  // getting Group Message
  getGroupMessage() async {
    return await _db
        .collection(Constants.groupChatName)
        .orderBy("time", descending: true)
        .limit(20)
        .snapshots();
  }

  Future getToday() async {
    print("Get tODAY  is called");
    final FirebaseUser user = await auth.currentUser();
    return await _db
        .collection(Constants.Users)
        .doc(user.uid)
        .get()
          .then((DocumentSnapshot) => DocumentSnapshot.get("today"));
        //.then((DocumentSnapshot) => DocumentSnapshot.data['today']);
  }

  Future<AddressModel> getUpdatedValues() async {
    final FirebaseUser user = await auth.currentUser();
    return await _db.collection(Constants.Users).doc(user.uid).get().then(
             (DocumentSnapshot) => AddressModel.fromJson(DocumentSnapshot.data()));
        //(DocumentSnapshot) => AddressModel.fromJson(DocumentSnapshot.data));
  }

  Future<AppData> getAppData() async {
    final FirebaseUser user = await auth.currentUser();
    return await _db
        .collection(Constants.Users)
        .doc(user.uid)
        .get()
        .then((DocumentSnapshot) => AppData.fromJson(DocumentSnapshot.data()));
  }

  Future<AccountData> getAccountData() async {
    final FirebaseUser user = await auth.currentUser();
    return await _db.collection(Constants.Users).doc(user.uid).get().then(
        (DocumentSnapshot) => AccountData.fromJson(DocumentSnapshot.data()));
  }

  Future addToday() async {
    final FirebaseUser user = await auth.currentUser();
    var map = Map<String, dynamic>();
    map['clicks_left'] = 250;
    map['today'] = DateTime.now().day.toString();
    await _db.collection(Constants.Users).doc(user.uid).update(map);
  }

  Future addIntervalTimer(String timerTitle) async {
    final FirebaseUser user = await auth.currentUser();
    var map = Map<String, dynamic>();
    map['${timerTitle}'] = DateTime.now().day;
    await _db.collection(Constants.Users).doc(user.uid).update(map);
  }

  // add group messge
  Future<void> addGroupMessage(
    String message,
    String name,
  ) async {
    final FirebaseUser user = await auth.currentUser();
    var groupMap = Map<String, dynamic>();
    groupMap['message'] = message;
    groupMap['time'] = DateTime.now().toIso8601String();
    groupMap['name'] = name;
    groupMap['uid'] = user.uid;
    await _db.collection(Constants.groupChatName).doc().set(groupMap);
  }

  Future<List<DocumentSnapshot>> getTransactionss() async {
    final FirebaseUser user = await auth.currentUser();
    List<DocumentSnapshot> _list = [];
    Query query = _db
        .collection(Constants.Users)
        .doc(user.uid)
        .collection(Constants.transactions)
        .orderBy("date", descending: false);
    QuerySnapshot querySnapshot = await query.get();
    _list = querySnapshot.docs;

    return _list;
  }

  Future getPoints() async {
    final FirebaseUser user = await auth.currentUser();
    print("Get Points is called");
    return await _db
        .collection(Constants.Users)
        .doc(user.uid)
        .get()
        .then((DocumentSnapshot) => DocumentSnapshot.get('points'));
  }

  Future getTotalUsers() async {
    print("Get TOTAL USERS is called");
    return await _db
        .collection(Constants.generalInformations)
        .doc("total")
        .get()
        .then((DocumentSnapshot) => DocumentSnapshot.get('users'));
  }

  Future getLastNoticeDate() async {
    print("Get The last Notified date  is called");
    return await _db
        .collection(Constants.generalInformations)
        .doc("lastUpdated")
        .get()
        .then((DocumentSnapshot) => DocumentSnapshot.get("lastNotificeDate"));
  }

  Future getClicks(FirebaseUser currentUser) async {
    final FirebaseUser user = await auth.currentUser();
    print("Get Clicks is called");
    return await _db
        .collection(Constants.Users)
        .doc(user.uid)
        .get()
        .then((DocumentSnapshot) => DocumentSnapshot.get("clicks"));
  }

  Future getName() async {
    final FirebaseUser user = await auth.currentUser();
    return await _db
        .collection(Constants.Users)
        .doc(user.uid)
        .get()
        .then((DocumentSnapshot) => DocumentSnapshot.get('name'));
  }

  Future getCurrentUid() async {
    final FirebaseUser user = await auth.currentUser();
    return await user.uid.toString();
  }

  Future getAccountType() async {
    final FirebaseUser user = await auth.currentUser();
    return await _db
        .collection(Constants.Users)
        .doc(user.uid)
        .get()
        .then((DocumentSnapshot) => DocumentSnapshot.get('activePlan'));
  }

  Future getCountry() async {
    final FirebaseUser user = await auth.currentUser();
    return await _db
        .collection(Constants.Users)
        .doc(user.uid)
        .get()
        .then((DocumentSnapshot) => DocumentSnapshot.get('country'));
  }

  Future getCoinbaseEmail() async {
    final FirebaseUser user = await auth.currentUser();
    return await _db
        .collection(Constants.Users)
        .doc(user.uid)
        .get()
        .then((DocumentSnapshot) => DocumentSnapshot.get('coinbase_email'));
  }

  Future<Users> getUserprofile() async {
    final FirebaseUser user = await auth.currentUser();
    return await _db
        .collection(Constants.Users)
        .doc(user.uid)
        .get()
        .then((DocumentSnapshot) => Users.fromMap(DocumentSnapshot.data()));
  }

  Future<AppStatus> getAppStatus() async {
    return await _db
        .collection(Constants.appStatus)
        .doc("app_status")
        .get()
        .then((DocumentSnapshot) => AppStatus.fromMap(DocumentSnapshot.data()));
  }

  Future<AddressModel> getUserAddress() async {
    final FirebaseUser user = await auth.currentUser();
    return await _db.collection(Constants.Users).doc(user.uid).get().then(
        (DocumentSnapshot) => AddressModel.fromJson(DocumentSnapshot.data()));
  }

  Future addPoints(int points) async {
    final FirebaseUser user = await auth.currentUser();
    var map = Map<String, dynamic>();
    map['points'] = points;
    await _db.collection(Constants.Users).doc(user.uid).update({
      "points": FieldValue.increment(points),
      "clicks": FieldValue.increment(1),
      "clicks_left": FieldValue.increment(-1),
    });
  }

  Future addPointsForAction(
      int points, String title, int hrs, int min, int sec) async {
    final FirebaseUser user = await auth.currentUser();
    var map = Map<String, dynamic>();
    map['points'] = points;
    await _db.collection(Constants.Users).doc(user.uid).update({
      "points": FieldValue.increment(points),
      "clicks": FieldValue.increment(1),
      "clicks_left": FieldValue.increment(-1),
    }).then((value) async {
      var nextClaimMap = Map<String, dynamic>();
      nextClaimMap['${title}'] = (DateTime.now()
                  .add(Duration(hours: hrs, minutes: min, seconds: sec))
                  .millisecondsSinceEpoch /
              1000)
          .round();
      await _db
          .collection(Constants.Users)
          .doc(user.uid)
          .update(nextClaimMap);
    });
  }

  Future addPointsForClaim(
      int points, String title, int hrs, int min, int sec) async {
    final FirebaseUser user = await auth.currentUser();
    var map = Map<String, dynamic>();
    map['points'] = points;
    await _db.collection(Constants.Users).doc(user.uid).update({
      "points": FieldValue.increment(points),
      "clicks": FieldValue.increment(1),
      "clicks_left": FieldValue.increment(-1),
    }).then((value) async {
      var nextClaimMap = Map<String, dynamic>();
      nextClaimMap['${title}'] = (DateTime.now()
                  .add(Duration(hours: hrs, minutes: min, seconds: sec))
                  .millisecondsSinceEpoch /
              1000)
          .round();
      await _db
          .collection(Constants.Users)
          .doc(user.uid)
          .update(nextClaimMap);
    });
  }

  //Withdraw
  Future<void> addWithdrawRequest(BuildContext context, String method,
      int points, String wallet_address, int clicks) async {
    //update to user Database
    final FirebaseUser user = await auth.currentUser();
    // String uid = await Constants.prefs.getString(Constants.uid);
    await _db.collection(Constants.Users).doc(user.uid).update({
      "points": 0,
      "clicks": 0,
    }).then((val) async {
      //save the transactions in Withdraw Request
      var withdrawMap = Map<String, dynamic>();
      withdrawMap["points"] = points;
      withdrawMap["date"] = DateTime.now().toIso8601String();
      withdrawMap["method"] = method;
      withdrawMap["status"] = "pending";
      withdrawMap["wallet_address"] = wallet_address;
      withdrawMap["uid"] = user.uid;
      withdrawMap["title"] = "Withdrawal to ${method.toLowerCase()}";
      withdrawMap["clicks"] = clicks;
      withdrawMap["version"] = Constants.release_version_code;
      String docId = user.uid + "${DateTime.now().toIso8601String()}";
      await _db
          .collection("WithdrawRequest")
          .doc(docId)
          .set(withdrawMap)
          .then((value) async {
        await _db
            .collection(Constants.Users)
            .doc(user.uid)
            .collection("transactions")
            .doc(docId)
            .set(withdrawMap)
            .then((val) {
          print("Withdraw Request have been added");
        });
      }).catchError((error) {
        _showError(context);
      });
      ;
    });
  }

  //Update Profile
  Future<void> updateUserProfile(BuildContext context, Users users) async {
    //update to user Database
    final FirebaseUser user = await auth.currentUser();
    //  String uid = await Constants.prefs.getString(Constants.uid);
    var userMap = Map<String, dynamic>();
    userMap['name'] = users.name;
    userMap['country'] = users.country;

    await _db
        .collection(Constants.Users)
        .doc(user.uid)
        .update(userMap)
        .then((val) {
      print("User profile Updated");
    }).catchError((error) {
      _showError(context);
    });
    ;
  }

  //Update Profile
  Future<void> updateAddress(
      BuildContext context, AddressModel addressModel) async {
    //update Adrress to user Database
    final FirebaseUser user = await auth.currentUser();
    //   String uid = await Constants.prefs.getString(Constants.uid);
    var addressMap = Map<String, dynamic>();
    addressMap['faucetpay_email'] = addressModel.faucetpay_email;
    addressMap['coinbase_email'] = addressModel.coinbase_email;

    await _db
        .collection(Constants.Users)
        .doc(user.uid)
        .update(addressMap)
        .then((val) {
      print("User Address Updated");
    }).catchError((error) {
      _showError(context);
    });
    ;
  }

  Future<void> participate(String week) async {
    final FirebaseUser user = await auth.currentUser();
    var eventExist = await _db
        .collection(Constants.weeklyEvent)
        .doc(
            "${DateTime.now().year.toString()}_${DateTime.now().month.toString()}_${week}")
        .get();

    if (eventExist.exists) {
      await _db
          .collection(Constants.weeklyEvent)
          .doc(
              "${DateTime.now().year.toString()}_${DateTime.now().month.toString()}_${week}")
          .update({
        "participants": FieldValue.arrayUnion([user.uid])
      });
    } else {
      await _db
          .collection(Constants.weeklyEvent)
          .doc(
              "${DateTime.now().year.toString()}_${DateTime.now().month.toString()}_${week}")
          .set({
        "participants": FieldValue.arrayUnion([user.uid])
      });
    }
  }

  Future<String> getEmail() async {
    final FirebaseUser user = await auth.currentUser();
    return await _db
        .collection(Constants.Users)
        .doc(user.uid)
        .get()
        .then((DocumentSnapshot) => DocumentSnapshot.get('email'));
  }

  Future<Country> getCountryForSignup() async {
    String url = "http://ip-api.com/json";
    var response = await http.get(
      url,
    );
    var jsonResponse = json.decode(response.body);
    return Country.fromJson(jsonResponse);
  }

  Future<CurrentDay> getCurrentDay() async {
    String url = "http://worldclockapi.com/api/json/est/now";
    var response = await http.get(
      url,
    );
    var jsonResponse = json.decode(response.body);
    return CurrentDay.fromJson(jsonResponse);
  }

  Future getNextClickTime(String timerTitle) async {
    print("Get Last Clicked Time is called");
    final FirebaseUser user = await auth.currentUser();
    return await _db
        .collection(Constants.Users)
        .doc(user.uid)
        .get()
        .then((DocumentSnapshot) => DocumentSnapshot.get('${timerTitle}'));
  }

  Future<List<DocumentSnapshot>> getTopUsers() async {
    List<DocumentSnapshot> _list = [];
    Query query = _db
        .collection(Constants.Users)
        .orderBy("points", descending: true)
        .limit(50);
    QuerySnapshot querySnapshot = await query.get();
    _list = querySnapshot.docs;

    return _list;
  }

  Future getUserId() async {
    return await auth.currentUser();
  }

  Stream<Users> getUserData(String uid) {
    return _db
        .collection(Constants.Users)
        .doc(uid)
        .snapshots()
        .map((event) => Users.fromMap(event.data()));
  }

  Future<bool> addInAppTransactions(BuildContext context,
      InAppTransactionModel inAppTransactionModel, int amount, int days) async {
    final FirebaseUser user = await auth.currentUser();
    //update to user Database
    int amounts = int.parse("${amount.toString()}");

    //save the transactions record for the user
    var transMap = Map<String, dynamic>();
    transMap["purchaseID"] = inAppTransactionModel.purchaseID;
    transMap["status"] = inAppTransactionModel.status;
    transMap["amount"] = amounts;
    transMap["transactionDate"] = inAppTransactionModel.transactionDate;
    transMap["productID"] = inAppTransactionModel.productID;
    transMap["pendingCompletePurchase"] =
        inAppTransactionModel.pendingCompletePurchase;

    var purchasedMap = Map<String, dynamic>();
    purchasedMap["activePlan"] =
        toBeginningOfSentenceCase(inAppTransactionModel.productID.toString());
    purchasedMap["premiumTill"] =
        (DateTime.now().add(Duration(days: days)).millisecondsSinceEpoch / 1000)
            .round();

    var notificationMap = Map<String, dynamic>();
    notificationMap['title'] = "Per Claim Value Increased";
    notificationMap['message'] =
        "You have successfully increased your per claim value, you will be rewarded as mentioned in the Product description for the next siz months";
    notificationMap['time'] =
        DateTime.now().add(Duration(minutes: 3)).toIso8601String();

    await _db
        .collection(Constants.Users)
        .doc(user.uid)
        .collection("transactions")
        .doc(inAppTransactionModel.purchaseID)
        .set(transMap)
        .then((value) async {
      await _db
          .collection(Constants.Users)
          .doc(user.uid)
          .update(purchasedMap)
          .then((value) async {
        await _db
            .collection(Constants.Users)
            .doc(user.uid)
            .collection(Constants.notifications)
            .doc()
            .set(notificationMap);
      }).then((value) {
        return true;
      });
    }).catchError((error) {
      _showError(context);
    });
  }


  Future setReferralLink(String refLink) async {
    final FirebaseUser user = await auth.currentUser();
    var referalMap = Map<String, dynamic>();
    referalMap['referralId'] = refLink;
    await _db
        .collection(Constants.Users)
        .doc(user.uid)
        .update(referalMap);
  }

}

_showDoneMessage(
  BuildContext context,
) {
  Fluttertoast.showToast(
      msg: "You have Paticipated Successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}

_showError(BuildContext context, [Error error]) {
  Fluttertoast.showToast(
      msg: "Error Occured, Please Try Again",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}
