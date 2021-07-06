import 'package:democoin/utils/Constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:democoin/config/auth_widget.dart';
import 'package:democoin/services/firebase_auth_services.dart';

class SplashScreenPage extends StatefulWidget {
  AsyncSnapshot<User> userSnapshot;

  SplashScreenPage({@required this.userSnapshot});

  @override
  _SplashScreenPageState createState() =>
      _SplashScreenPageState(this.userSnapshot);
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  AsyncSnapshot<User> userSnapshot;

  _SplashScreenPageState(this.userSnapshot);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2)).then((val) {
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return AuthWidget(
            userSnapshot: widget.userSnapshot,
          );
        }));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Container(
              child: Text(
                "${Constants.app_name}",
                style:
                    GoogleFonts.abhayaLibre(color: Colors.white, fontSize: 35),
              ),
            ),
          ),
          SizedBox(
            height: 100,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              CircularProgressIndicator(
                backgroundColor: Colors.white,
                strokeWidth: 5,
              ),
              Padding(padding: const EdgeInsets.only(top: 10)),
              Text(
                "${Constants.app_name} \n For Everyone",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 12),
              )
            ],
          )
        ],
      ),
    );
  }
}
