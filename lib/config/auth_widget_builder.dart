import 'package:democoin/games/AddTheNumbers.dart';
import 'package:democoin/games/MultiplyTheNumbers.dart';
import 'package:democoin/screens/signup_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:democoin/games/HourlyBonusPage.dart';
import 'package:democoin/games/WeeklyGiveAwayPage.dart';
import 'package:democoin/provider_package/allNotifiers.dart';
import 'package:democoin/provider_package/connectivity_provider.dart';
import 'package:democoin/screens/home_page.dart';
import 'package:provider/provider.dart';
import 'package:democoin/services/firebase_auth_services.dart';
import 'package:democoin/services/firestore_services.dart';


class AuthWidgetBuilder extends StatelessWidget {
  final Widget Function(BuildContext, AsyncSnapshot<User>) builder;

  const AuthWidgetBuilder({Key key, this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Auth Widget Builder");
    final authServices =
        Provider.of<FirebaseAuthServices>(context, listen: false);
    FirestoreServices firestoreServices = FirestoreServices();





    return StreamBuilder<User>(
        stream: authServices.onAuthStateChanged,
        builder: (context, snapshot) {
          final user = snapshot.data;
          if (user != null) {
            return MultiProvider(
              providers: [
                Provider<User>.value(
                  value: user,
                ),
                Provider<FirestoreServices>(
                  create: (_) => FirestoreServices(),
                ),
                Provider<AllNotifier>(
                  create: (_) => AllNotifier(),
                ),
                ChangeNotifierProvider<AllNotifier>(
                  create: (context) => AllNotifier(),
                  child: AddTheNumbers(),
                ),
                ChangeNotifierProvider<AllNotifier>(
                  create: (context) => AllNotifier(),
                  child: SignUpPage(),
                ),
                ChangeNotifierProvider<AllNotifier>(
                  create: (context) => AllNotifier(),
                  child: MultiplyTheNumbers(),
                ),
                ChangeNotifierProvider(
                  create: (context) => ConnectivityProvider(),
                  child: HourlyBonusPage(),
                ),
                ChangeNotifierProvider(
                  create: (context) => ConnectivityProvider(),
                  child: WeeklyGiveAwayPage(),
                ),
                ChangeNotifierProvider(
                  create: (context) => ConnectivityProvider(),
                  child: HomePage(),
                ),
                StreamProvider(
                    create: (BuildContext context) =>
                        firestoreServices.getUserData(user.uid)),
              ],
              child: builder(context, snapshot),
            );
          }
          return builder(context, snapshot);
        });
  }
}
