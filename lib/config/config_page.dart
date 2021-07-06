import 'package:democoin/services/dynamicLinksServices.dart';
import 'package:flutter/material.dart';
import 'package:democoin/screens/address_page.dart';
import 'package:democoin/screens/profile_page.dart';
import 'package:democoin/screens/redeem_page.dart';
import 'package:democoin/screens/splash_screen_page.dart';
import 'package:provider/provider.dart';
import 'package:democoin/screens/account_page.dart';
import 'package:democoin/screens/home_page.dart';
import 'package:democoin/services/firebase_auth_services.dart';
import 'auth_widget_builder.dart';

class ConfigPage extends StatefulWidget {
  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  DynamicServices _dynamicServices = DynamicServices();

  @override
  void initState() {
    super.initState();
    initDynamicLinks();
  }

  void initDynamicLinks() async {
    await _dynamicServices.handleDynamicLinks(context);
  }



  @override
  Widget build(BuildContext context) {
    return Provider<FirebaseAuthServices>(
      create: (_) => FirebaseAuthServices(),
      child: AuthWidgetBuilder(builder: (context, userSnapshot) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              /*     brightness: Brightness.dark,
                primarySwatch: Constants.primarySwatch,
                primaryColor: Constants.primaryAppColor
            */

              primarySwatch: MaterialColor(4280361249, {
                50: Color(0xfff2f2f2),
                100: Color(0xffe6e6e6),
                200: Color(0xffcccccc),
                300: Color(0xffb3b3b3),
                400: Color(0xff999999),
                500: Color(0xff808080),
                600: Color(0xff666666),
                700: Color(0xff4d4d4d),
                800: Color(0xff333333),
                900: Color(0xff191919)
              }),
              brightness: Brightness.dark,
              primaryColor: Color(0xff212121),
              primaryColorBrightness: Brightness.dark,
              primaryColorLight: Color(0xff9e9e9e),
              primaryColorDark: Color(0xff000000),
            ),
            routes: {
              "/home": (context) => HomePage(),
              HomePage.routeName: (context) => HomePage(),
              "/account": (context) => AccountScreen(),
              AccountScreen.routeName: (context) => AccountScreen(),
              RedeemScreen.routeName: (context) => RedeemScreen(),
              ProfilePage.routeName: (context) => ProfilePage(),
              AddressPage.routeName: (context) => AddressPage(),
            },
            home: SplashScreenPage(userSnapshot: userSnapshot)

            //AuthWidget(userSnapshot: userSnapshot),
            );
      }),
    );
  }
}
