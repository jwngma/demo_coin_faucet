import 'package:democoin/services/firestore_services.dart';
import 'package:democoin/utils/Constants.dart';
import 'package:democoin/widgets/message_dialog_with_ok.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

class Webview extends StatefulWidget {
  @override
  _WebviewState createState() => _WebviewState();
}

class _WebviewState extends State<Webview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Webview"),
      ),
      body: Center(
        child: Text(" Now You have to do all those comparing and all here, and When done Sen the user to FinalWebPage(), and then hadle the rest"),
      ),
    );
  }
}

class FinalWebPage extends StatefulWidget {
  @override
  _FinalWebPageState createState() => _FinalWebPageState();
}

class _FinalWebPageState extends State<FinalWebPage> {
  var firestoreServices = FirestoreServices();

  addPoints(int randomRewards, String title, int days, int min, int secs) {
    ProgressDialog progressDialog =
        ProgressDialog(context, isDismissible: false);
    progressDialog.show();
    firestoreServices
        .addPointsForAction(10, title, days, min, secs)
        .then((val) {
      progressDialog.hide();
      setState(() {});
      showDialog(
          context: context,
          builder: (context) => CustomDialogWithOk(
                title: "Free Point Added",
                description:
                    "You Have Claimed Your Free Point for viewing ads Successfully",
                primaryButtonText: "Ok",
              ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(" Final Weburl"),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text(" Claim Point"),
          onPressed: () {
            addPoints(1000, "freeCashTimer", 0, Constants.bonusTimer, 0);

            // after thsis redirect the user to the HomePage();
            // There should no back button here
            // he should ne able to press back anyhow from here
          },
        ),
      ),
    );
  }
}
