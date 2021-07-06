import 'package:democoin/models/users.dart';
import 'package:democoin/services/UnityAdsServices.dart';
import 'package:democoin/services/dynamicLinksServices.dart';
import 'package:democoin/services/firestore_services.dart';
import 'package:democoin/utils/Constants.dart';
import 'package:democoin/widgets/ReferUsersCustomDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import 'home_page.dart';

class ReferralPage extends StatefulWidget {
  static const String routeName = "/accountScreen";

  @override
  _ReferralPageState createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  UnityAdsServices unityAdsServices = UnityAdsServices();

  @override
  void initState() {
    super.initState();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    UnityAdsServices.init();
  }

  showInterstitialAds() {
    unityAdsServices.showInterstitialAd();
  }

  @override
  Widget build(BuildContext context) {
    var userData = Provider.of<Users>(context);
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) {
          return HomePage();
        }));
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Refer And Earn"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Refer Your Friends",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "On Every Successfull Withdrawal of your referred friend, you will receive ${Constants.referal_reward}% of his withdrawal amount",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            height: 150,
                            width: MediaQuery.of(context).size.width * 0.8,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                color: Colors.indigo),
                            child: Image.asset(Constants.ref_icon)),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Your Referral Link-",
                          textAlign: TextAlign.center,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: Colors.indigo),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: userData.referralId == "" ||
                                    userData.referralId == null
                                ? Text("Not Generated")
                                : Text(
                                    "${userData.referralId}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.normal,
                                        fontStyle: FontStyle.italic),
                                  ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        userData.referralId == "" || userData.referralId == null
                            ? RaisedButton(
                                color: Colors.red,
                                onPressed: () async {
                                  generateReferralLink();
                                },
                                child: Text("Generate Referral Link"))
                            : RaisedButton.icon(
                                icon: Icon(Icons.share),
                                color: Colors.red,
                                onPressed: () {
                                  var textToShare =
                                      "Inviting you to join ${Constants.coin_name} Faucet App. \n\nYou can earn Unlimited ${Constants.coin_name} from this App. \n\nDownload From Play store. Link- ${userData.referralId} \n\nJoin us Now";
                                  Share.share(textToShare);
                                },
                                label: Text("Invite and Earn")),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("My Referal Earnings"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                          onPressed: () {}, icon: Icon(Icons.refresh)),
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage(Constants.empty_icon),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Nothing to show here",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  generateReferralLink() async {
    DynamicServices _dynamicServices = DynamicServices();
    FirestoreServices fireStoreServices = FirestoreServices();
    ProgressDialog progressDialog =
        ProgressDialog(context, isDismissible: true);
    await progressDialog.show();

    _dynamicServices
        .createDynamicLinks(
      short: true,
    )
        .then((val) async {
      String linkToShare = val;
      print(" Link to Share= ${linkToShare}");
      fireStoreServices.setReferralLink(linkToShare).then((val) {
        progressDialog.hide();
        showDialog(
            context: context,
            builder: (context) => ReferUsersCustomDialog(
                  referralPrize: 10,
                  title: "Share With Your Friends",
                  description: " $linkToShare",
                  primaryButtonText: "Invite And Earn",
                  sharetext:
                      "Inviting you to join ${Constants.coin_name} Faucet App.\n\n You can earn Unlimited ${Constants.coin_name} from this App. \n\nDownload From Play store . Link- ${linkToShare} \n\nJoin us Now",
                ));
      });
    });
  }
}
