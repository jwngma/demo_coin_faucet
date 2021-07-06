import 'package:auto_size_text/auto_size_text.dart';
import 'package:date_format/date_format.dart';
import 'package:democoin/screens/redeem_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:democoin/models/address_model.dart';
import 'package:democoin/models/users.dart';
import 'package:democoin/screens/home_page.dart';
import 'package:democoin/services/firestore_services.dart';
import 'package:democoin/utils/Constants.dart';
import 'package:democoin/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:democoin/widgets/message_dialog_with_ok.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

class AddressPage extends StatefulWidget {
  static const String routeName = "/AddressPage";

  @override
  _AddressPageState createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _faucetpay_ethController = TextEditingController();
  TextEditingController _coinbase_emailController = TextEditingController();


  ProgressDialog progressDialog;
  FirestoreServices _fireStoreServices = FirestoreServices();
  String faucetpay_eth, coinbase_email, _warning;
  bool isLoginPressed = false;
  AddressModel addressModel;

  @override
  void initState() {
    super.initState();
    _getUserAddress();
  }

  _getUserAddress() async {
    addressModel = await _fireStoreServices.getUserAddress();
    setState(() {
      _faucetpay_ethController.text = addressModel.faucetpay_email;
      _coinbase_emailController.text = addressModel.coinbase_email;
    });
  }

  showToastt(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  updateAddress(BuildContext context, ProgressDialog progressDialog) async {
    progressDialog = new ProgressDialog(context);
    await progressDialog.show();

    AddressModel addressModel = AddressModel(
      faucetpay_email: faucetpay_eth,
      coinbase_email: coinbase_email,
    );
    await _fireStoreServices.updateAddress(context, addressModel).then((val) {
      progressDialog.hide();
      showDialog(
          context: context,
          builder: (context) =>
              CustomDialogWithOk(
                title: "Wallet Address Updated",
                description: "Your Wallet Addresses has been Updated,",
                primaryButtonText: "Ok",
                primaryButtonRoute: RedeemScreen.routeName,
              ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wallet Address"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Save Your ${Constants.coin_name} Wallet Address that you want to use for withdrawall",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: <Widget>[
                  _buildErrorWidget(),
                  Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.always,
                      child: Column(
                        children: _buildWidgets() + _buildButtons(),
                      )),
                ],
              ),
            ),
            Divider(
              height: 10,
              color: Colors.red,
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildButtons() {
    return [
      Container(
        width: MediaQuery
            .of(context)
            .size
            .width * 0.6,
        child: RaisedButton(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            color: Colors.blue,
            child: Text(
              "Save",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontSize: 22),
            ),
            onPressed: () {
              submit(context);
            }),
      ),
    ];
  }

  bool isValid() {
    final form = _formKey.currentState;

    form.save();
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void submit(BuildContext context) async {
    if (isValid()) {
      try {
        updateAddress(context, progressDialog);
      } catch (error) {
        setState(() {
          _warning = error.message;
          isLoginPressed = false;
        });
        print(error);
      }
    } else {
      showToastt("We Accept Only Coinbase Email And Faucetpay Email as address");
    }
  }

  InputDecoration buildSignUpinputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(fontSize: 10),
      fillColor: Colors.white,
      border: new OutlineInputBorder(
        borderRadius: new BorderRadius.circular(10.0),
        borderSide: new BorderSide(),
      ),
      //fillColor: Colors.green
    );
  }

  List<Widget> _buildWidgets() {
    List<Widget> textfields = [];

    textfields.add(Text(
      "Faucetpay  Email Address",
      textAlign: TextAlign.start,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ));
    textfields.add(SizedBox(
      height: 5,
    ));

    textfields.add(TextFormField(
      style: TextStyle(fontSize: 22),
      validator: Emailvalidator.validate,
      controller: _faucetpay_ethController,
      enabled: true,
      decoration:
      buildSignUpinputDecoration("Enter The Faucuetpay Email Address (important)"),
      keyboardType: TextInputType.emailAddress,
      onSaved: (String value) => faucetpay_eth = value,
    ));
    textfields.add(SizedBox(
      height: 5,
    ));
    textfields.add(Divider(
      color: Colors.red,
      height: 5,
    ));
    textfields.add(SizedBox(
      height: 20,
    ));
    textfields.add(Text(
      "Coinbase Email Address",
      textAlign: TextAlign.left,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ));
    textfields.add(SizedBox(
      height: 5,
    ));

    textfields.add(TextFormField(
      style: TextStyle(fontSize: 22),
      validator: Emailvalidator.validate,
      controller: _coinbase_emailController,
      decoration: buildSignUpinputDecoration(
          "Enter The Coinbase Email Address (important)"),
      keyboardType: TextInputType.emailAddress,
      onSaved: (String value) => coinbase_email = value,
    ));
    textfields.add(SizedBox(
      height: 5,
    ));
    textfields.add(Divider(
      color: Colors.red,
      height: 5,
    ));
    textfields.add(SizedBox(
      height: 20,
    ));

    //
    return textfields;
  }

  _buildErrorWidget() {
    if (_warning != null) {
      return Container(
        color: Colors.yellow,
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child:
              IconButton(icon: Icon(Icons.error_outline), onPressed: () {}),
            ),
            Expanded(
              child: AutoSizeText(
                _warning,
                maxLines: 3,
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _warning = null;
                    });
                  }),
            ),
          ],
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
