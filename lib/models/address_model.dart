class AddressModel {
  String coinbase_email;
  String faucetpay_email;

  AddressModel({this.coinbase_email, this.faucetpay_email
  });

  AddressModel.fromJson(Map<String, dynamic> json) {
    coinbase_email = json['coinbase_email'];
    faucetpay_email = json['faucetpay_email'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['coinbase_email'] = this.coinbase_email;
    data['faucetpay_email'] = this.faucetpay_email;

    return data;
  }
}
