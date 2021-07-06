import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:democoin/utils/Constants.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:share/share.dart';

class ReferUsersCustomDialog extends StatelessWidget {
  final String title, description, primaryButtonText, sharetext;
  final int referralPrize;

  static const double padding = 20.0;
  final primaryColor = const Color(0xFF75A2EA);
  final grayColor = const Color(0xFF939393);

  const ReferUsersCustomDialog({
    @required this.title,
    @required this.description,
    @required this.primaryButtonText,
    @required this.sharetext, this.referralPrize,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(padding)),
      child: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black,
                      blurRadius: 10,
                      offset: const Offset(0.0, 10))
                ]),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 24,
                  ),
                  AutoSizeText(
                    title,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: primaryColor, fontSize: 25),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: sharetext == ""
                          ? ""
                          : 'Your Invitation Link for ${Constants.coin_name} Faucet App \n\n',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                      children: <TextSpan>[
                        TextSpan(
                          text: description,
                          recognizer: TapGestureRecognizer()..onTap = () {},
                          style: TextStyle(
                              color: Colors.lightBlue,
                              fontSize: sharetext == "" ? 22 : null,
                              decoration: sharetext == ""
                                  ? null
                                  : TextDecoration.underline),
                        ),
                        TextSpan(
                          text: sharetext == ""
                              ? ""
                              : '\n\nYou will be rewarded ${referralPrize}% of Withdrawal amount per successful referral joining throught this link',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  RaisedButton(
                      color: primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      child: AutoSizeText(
                        primaryButtonText,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w200),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();

                        if (sharetext != "") {
                          Share.share(
                            sharetext,
                          );
                        }
                      }),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
