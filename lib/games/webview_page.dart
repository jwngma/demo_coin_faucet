import 'dart:async';

import 'package:democoin/utils/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:democoin/widgets/navigation_controls.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewPage extends StatefulWidget {
  final String faucetUrl;

  const WebviewPage({Key key, @required this.faucetUrl}) : super(key: key);

  @override
  _WebviewPageState createState() => _WebviewPageState(this.faucetUrl);
}

class _WebviewPageState extends State<WebviewPage> {
  final String faucetUrl;

  _WebviewPageState(this.faucetUrl);

  final globalKey = GlobalKey<ScaffoldState>();

  String _title = "${Constants.app_name}";

  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  String url = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    url = widget.faucetUrl;
  }



  @override
  void dispose() {
    super.dispose();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: globalKey,
      appBar: AppBar(
        title: Text(_title),
        actions: <Widget>[
          NavigationControls(_controller.future),
        ],
      ),
      body: _buildWebView(),
    );
  }

  Widget _buildWebView() {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            Flexible(
              child: WebView(
                javascriptMode: JavascriptMode.unrestricted,
                initialUrl: url,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller.complete(webViewController);
                },
                navigationDelegate: (request) {
                  return _buildNavigationDecision(request);
                },
                javascriptChannels: <JavascriptChannel>[
                  _createTopBarJsChannel(),
                ].toSet(),
                onPageFinished: (url) {
                  _showPageTitle();
                  setState(() {
                    isLoading= false;
                  });
                },
              ),
            ),
          ],
        ),
        isLoading ? Center( child: CircularProgressIndicator(),)
            : SizedBox.shrink(),
      ],
    );
  }

  NavigationDecision _buildNavigationDecision(NavigationRequest request) {
    if (!request.url.startsWith(url)) {
      globalKey.currentState.showSnackBar(
        SnackBar(
          content: Text(
            'We have just stopped Popup Ads',
            style: TextStyle(fontSize: 20),
          ),
        ),
      );
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  void _showPageTitle() {
    _controller.future.then((webViewController) {
      webViewController.evaluateJavascript('''
        inputs = document.querySelectorAll("input[type=text]");
        TopBarJsChannel.postMessage(document.title);
         inputs.forEach(function(inp) {
            let finalInput = inp;
            finalInput.addEventListener("focus", function() {
                console.log('focus');
                input = finalInput;
                InputValue.postMessage('');
                Focus.postMessage('focus');
           }); ''');
    });
  }

  JavascriptChannel _createTopBarJsChannel() {
    return JavascriptChannel(
      name: 'TopBarJsChannel',
      onMessageReceived: (JavascriptMessage message) {
        String newTitle = message.message;

        if (newTitle.contains('-')) {
          newTitle = newTitle.substring(0, newTitle.indexOf('-')).trim();
        }

        setState(() {
          _title = newTitle;
        });
      },
    );
  }
}
