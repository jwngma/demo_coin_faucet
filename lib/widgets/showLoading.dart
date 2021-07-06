import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Widget showLoadingDialog() {
  return Center(
    child: Container(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: Container(
            height: 200,
            width: 170,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 30,),
                SpinKitRing(
                  color: Colors.red,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Please Wait...",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red, fontSize: 18),
                )
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
