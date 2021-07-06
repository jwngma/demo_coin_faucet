import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:democoin/provider_package/allNotifiers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:democoin/models/users.dart';
import 'package:democoin/services/firestore_services.dart';
import 'package:democoin/utils/Constants.dart';
import 'package:democoin/utils/tools.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
class User {
  final String uid;

  const User({@required this.uid});
}

class FirebaseAuthServices {
  final _firebaseAuth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  static final Firestore firestore = Firestore.instance;
  FirestoreServices firestoreServices = FirestoreServices();

  Users users = Users();

  User _userFromFirebase(FirebaseUser user) {
    return user == null ? null : User(uid: user.uid);
  }

  Stream<User> get onAuthStateChanged {
    return _firebaseAuth.onAuthStateChanged.map(_userFromFirebase);
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser currentUser;
    currentUser = await _firebaseAuth.currentUser();

    return currentUser;
  }

  Future<User> signInAnonymously() async {
    final authResult = await _firebaseAuth.signInAnonymously();
    return _userFromFirebase(authResult.user);
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

// create with gmail
  Future<FirebaseUser> signInWithGoogle() async {
    print("Login With Google");

    GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
    if (googleSignInAccount != null) {
      print("Login With Google is not null");
      GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential authCredential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);
      print(authCredential.toString());

      FirebaseUser user =
          (await _firebaseAuth.signInWithCredential(authCredential)).user;

      return user;
    } else {
      return null;
    }
  }

  Future<bool> authenticateUser(FirebaseUser firebaseUser) async {
    QuerySnapshot querySnapshot = await firestore
        .collection(Constants.Users)
        .where("email", isEqualTo: firebaseUser.email)
        .getDocuments();

    List<DocumentSnapshot> docs = querySnapshot.documents;

    print("Doc Length(Email check");

    return docs.length > 0 ? false : true;
  }

  Future<void> addToDb(
      FirebaseUser currentuser) async {
    String username = Tools.getUsername(currentuser.email);
    print(username);
    var firebaseMessageing = FirebaseMessaging();

    String token = await firebaseMessageing.getToken();
    String country = await firestoreServices
        .getCountryForSignup()
        .then((value) => value.country);
    print(" Your id Token -${token}");
    users = Users(
        uid: currentuser.uid,
        email: currentuser.email,
        name: currentuser.displayName,
        activePlan: "Basic",
        points: 0,
        idToken: token,
        clicks: 0,
        count: 0,
        watchVideoTimer: 0,
        freeCashTimer: 0,
        hourlyTimer: 0,
        sumTimer: 0,
        multiplyTimer: 0,
        referredBy: false,
        claimed: 0,
        premiumTill: 1,
        referralId: "",
        earnedByReferral: 0,
        createdOn: DateTime.now().toIso8601String(),
        lastLogin: DateTime.now().toIso8601String(),
        country: country,
        profile_photo: currentuser.photoUrl);

    var userMap = Map<String, dynamic>();
    userMap['users'] = FieldValue.increment(1);
    var userWelcomeNotificationMap = Map<String, dynamic>();
    userWelcomeNotificationMap['title'] = "Welcome ${users.name}";
    userWelcomeNotificationMap['message'] =
        "Congratulations ${users.name} on Creating Account at ${Constants.app_name} App. You Just joined a ${Constants.app_name} , the community for ${Constants.coin_name} Faucets. Now Claim your ${Constants.coin_name} and enjoy the App .";
    userWelcomeNotificationMap['time'] =
        DateTime.now().add(Duration(minutes: 5)).toIso8601String();

    await firestore
        .collection(Constants.Users)
        .document(currentuser.uid)
        .setData(users.toMap(users))
        .then((value) async {
      await firestore
          .collection(Constants.generalInformations)
          .document("total")
          .updateData(userMap)
          .then((value) async {
        await firestore
            .collection(Constants.Users)
            .document(currentuser.uid)
            .collection(Constants.notifications)
            .document()
            .setData(userWelcomeNotificationMap);
      });
    });
  }

  Future<void> updateIdToken(FirebaseUser currentuser) async {
    String email = Tools.getUsername(currentuser.email);
    print(email);

    var firebaseMessageing = FirebaseMessaging();

    String token = await firebaseMessageing.getToken();
    print(" The New id Token -${token}");
    var map = Map<String, dynamic>();
    map['idToken'] = token;
    map['today'] = DateTime.now().day.toString();
    map['lastLogin'] = DateTime.now().toIso8601String();

    firestore
        .collection(Constants.Users)
        .document(currentuser.uid)
        .updateData(map);
    ;
  }

  Future<void> UpdateUserProfile(Users users) async {
    var map = Map<String, dynamic>();
    map["name"] = users.name;
    map["email"] = users.email;
    await firestore
        .collection(Constants.Users)
        .document(users.uid)
        .updateData(map);
  }

  Future signOutWhenGoogle() async {
    print("Logout Called");
    await _googleSignIn.disconnect();
    await _googleSignIn.signOut();
    return await _firebaseAuth.signOut();
  }
}
