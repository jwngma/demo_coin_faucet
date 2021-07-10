import 'package:cloud_firestore/cloud_firestore.dart';
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
  FirestoreServices firestoreServices = FirestoreServices();

  Users users = Users();

  User _userFromFirebase( user) {
    return user == null ? null : User(uid: user.uid);
  }

  Stream<User> get onAuthStateChanged {
    return _firebaseAuth.authStateChanges().map(_userFromFirebase);
  }


  Future<User> signInAnonymously() async {
    final authResult = await _firebaseAuth.signInAnonymously();
    return _userFromFirebase(authResult.user);
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }
  Future<UserCredential> signInWithGoogle() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final UserCredential user = await _firebaseAuth.signInWithCredential(credential);
    return user;
  }


  Future<bool> authenticateUser(UserCredential firebaseUser) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constants.Users)
        .where("email", isEqualTo: firebaseUser.user.email)
        .get();

    List<DocumentSnapshot> docs = querySnapshot.docs;

    print("Doc Length (Email check  ${docs.length}");

    return docs.length > 0 ? false : true;
  }

  Future<void> addToDb(UserCredential currentuser) async {
    String username = Tools.getUsername(currentuser.user.email);
    print(username);
    var firebaseMessageing = FirebaseMessaging.instance;

    String token = await firebaseMessageing.getToken();
    String country = "india";//await firestoreServices.getCountryForSignup().then((value) => value.country);
    print(" Your id Token -${token}");
    users = Users(
        uid: currentuser.user.uid,
        email: currentuser.user.email,
        name: currentuser.user.displayName,
        activePlan: "Basic",
        points: 0,
        idToken: token,
        clicks: 0,
        count: 0,
        clicks_left: 10,
        watchVideoTimer: 0,
        freeCashTimer: 0,
        hourlyTimer: 0,
        sumTimer: 0,
        multiplyTimer: 0,
        referredBy: false,
        nextClaim: 0,
        today: "1",
        claimed: 0,
        premiumTill: 1,
        referralId: "",
        earnedByReferral: 0,
        createdOn: DateTime.now().toIso8601String(),
        lastLogin: DateTime.now().toIso8601String(),
        country: country,
        profile_photo: currentuser.user.photoURL);

    var userMap = Map<String, dynamic>();
    userMap['users'] = FieldValue.increment(1);
    var userWelcomeNotificationMap = Map<String, dynamic>();
    userWelcomeNotificationMap['title'] = "Welcome ${users.name}";
    userWelcomeNotificationMap['message'] =
        "Congratulations ${users.name} on Creating Account at ${Constants.app_name} App. You Just joined a ${Constants.app_name} , the community for ${Constants.coin_name} Faucets. Now Claim your ${Constants.coin_name} and enjoy the App .";
    userWelcomeNotificationMap['time'] =
        DateTime.now().add(Duration(minutes: 5)).toIso8601String();

    await FirebaseFirestore.instance
        .collection(Constants.Users)
        .doc(currentuser.user.uid)
        .set(users.toMap(users))
        .then((value) async {
      await FirebaseFirestore.instance
          .collection(Constants.generalInformations)
          .doc("total")
          .update(userMap)
          .then((value) async {
        await FirebaseFirestore.instance
            .collection(Constants.Users)
            .doc(currentuser.user.uid)
            .collection(Constants.notifications)
            .doc()
            .set(userWelcomeNotificationMap);
      });
    });
  }

  Future<void> updateIdToken(UserCredential currentuser) async {
    String email = Tools.getUsername(currentuser.user.email);
    print(email);

    var firebaseMessageing = FirebaseMessaging.instance;

    String token = await firebaseMessageing.getToken();
    print(" The New id Token -${token}");
    var map = Map<String, dynamic>();
    map['idToken'] = token;
    map['today'] = DateTime.now().day.toString();
    map['lastLogin'] = DateTime.now().toIso8601String();

   await FirebaseFirestore.instance
        .collection(Constants.Users)
        .doc(currentuser.user.uid)
        .update(map);
  }

  Future<void> UpdateUserProfile(Users users) async {
    var map = Map<String, dynamic>();
    map["name"] = users.name;
    map["email"] = users.email;
    await FirebaseFirestore.instance
        .collection(Constants.Users)
        .doc(users.uid)
        .update(map);
  }

  Future signOutWhenGoogle() async {
    print("Logout Called");
    await _googleSignIn.disconnect();
    await _googleSignIn.signOut();
    return await _firebaseAuth.signOut();
  }
}
