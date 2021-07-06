class AccountData {
  String profile_photo;
  String name;
  String email;
  String activePlan;
  String createdOn;
  String lastLogin;

  AccountData(
      {this.activePlan,
      this.email,
      this.name,
      this.createdOn,
      this.lastLogin,
      this.profile_photo});

  AccountData.fromJson(Map<String, dynamic> json) {
    profile_photo = json['profile_photo'];
    name = json['name'];
    email = json['email'];
    activePlan = json['activePlan'];
    createdOn = json['createdOn'];
    lastLogin = json['lastLogin'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['profile_photo'] = this.profile_photo;
    data['name'] = this.name;
    data['email'] = this.email;
    data['activePlan'] = this.activePlan;
    data['createdOn'] = this.createdOn;
    data['lastLogin'] = this.lastLogin;

    return data;
  }
}
