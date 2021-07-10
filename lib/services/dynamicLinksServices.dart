import 'package:democoin/provider_package/allNotifiers.dart';
import 'package:democoin/utils/Constants.dart';
import 'package:democoin/utils/tools.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DynamicServices {
  Future<String> createDynamicLinks({
    bool short,
  }) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final  user = await auth.currentUser;
    String _linkToShare = "";

    final DynamicLinkParameters dynamicLinkParameters = DynamicLinkParameters(
        uriPrefix: "${Constants.firebase_dynamic_url}",
        link: Uri.parse(
            "${Constants.app_website}/?uid=${user.uid}"),
        androidParameters:
            AndroidParameters(packageName: "${Constants.pakageName}"),
        socialMetaTagParameters: SocialMetaTagParameters(
            title: "The Best ${Constants.coin_name} Paying Faucet App",
            description:
                "You can Earn unlimited ${Constants.coin_name} using this App",
            imageUrl: Uri.parse(
                "${Constants.app_logo_for_dynamiclink}")));

    Uri url;
    if (short == true) {
      final ShortDynamicLink shortDynamicLink =
          await dynamicLinkParameters.buildShortLink();
      url = shortDynamicLink.shortUrl;
      _linkToShare = url.toString();
      print("Short Link ${_linkToShare}");
    } else {
      url = await dynamicLinkParameters.buildUrl();
      _linkToShare = url.toString();
      print("Long Link ${_linkToShare}");
    }

    return _linkToShare;
  }

  Future handleDynamicLinks(BuildContext context) async {
    // STARTUP FROM DYNAMIC LINK LOGIC
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    _handleDeepLink(data, context);

    // INTOFOREGROUND FROM DYNAMIC LIBK LOGIC
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLinkdata) async {
      _handleDeepLink(dynamicLinkdata, context);
    }, onError: (OnLinkErrorException e) async {
      print("Dynamick Link Error $e");
    });
  }

  void _handleDeepLink(PendingDynamicLinkData data, BuildContext context) {
    final Uri deepLink = data?.link;
    print(" Handling The DeepLink");
    if (deepLink != null) {
      print("handle DeepLink In |  deepLink: $deepLink");
      var uid = deepLink.queryParameters['uid'];
      print("handle DeepLink |  Uid: $uid");
      var allNotifier = Provider.of<AllNotifier>(context, listen: false);
      allNotifier.setReferralId(uid);
    }
  }
}
