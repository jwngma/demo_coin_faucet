class InAppTransactionModel {
  String purchaseID;
  String transactionDate;
  String status;
  String productID;
  bool pendingCompletePurchase;

  InAppTransactionModel(
      {this.purchaseID,
      this.transactionDate,
      this.status,
      this.productID,
      this.pendingCompletePurchase});

  InAppTransactionModel.fromJson(Map<String, dynamic> json) {
    purchaseID = json['purchaseID'];
    transactionDate = json['transactionDate'];
    status = json['status'];
    productID = json['productID'];
    pendingCompletePurchase = json['pendingCompletePurchase'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['purchaseID'] = this.purchaseID;
    data['transactionDate'] = this.transactionDate;
    data['status'] = this.status;
    data['productID'] = this.productID;
    data['pendingCompletePurchase'] = this.pendingCompletePurchase;

    return data;
  }
}
