import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:democoin/utils/Constants.dart';

class NoInternet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 200,
              width: 200,
              margin: EdgeInsets.fromLTRB(0, 0, 0, 25),
              child: Lottie.asset(
                Constants.no_internet,
                repeat: true,
                reverse: true,
                animate: true,
              ),
            ),
            Text(
              "No Internet Connection",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                "You are not connected to the internet. Make sure Wi-Fi is on or Mobile data is on, Airplane Mode is Off and try again.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, letterSpacing: 1.2),
              ),
            )
          ],
        ),
      ),
    );
  }
}
