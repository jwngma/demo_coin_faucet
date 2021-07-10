
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:democoin/screens/home_page.dart';
import 'package:democoin/screens/signup_page.dart';
import 'package:democoin/services/firebase_auth_services.dart';

class AuthWidget extends StatelessWidget {
  final AsyncSnapshot<User> userSnapshot;

   AuthWidget({Key key, @required this.userSnapshot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(userSnapshot.connectionState.toString());
    if (userSnapshot.connectionState == ConnectionState.active) {
      return userSnapshot.hasData ? HomePage() : SignUpPage();
    }
    return Scaffold(
        body: Center(
      child: CircularProgressIndicator(),
    ));
  }
}
