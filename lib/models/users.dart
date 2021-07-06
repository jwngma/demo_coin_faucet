class Users {
  String uid;
  String name="";
  String country;
  int points;
  String email;
  String profile_photo;
  int clicks;
  int clicks_left;
  int count;
  int watchVideoTimer;
  String idToken;
  int claimed;
  int earnedByReferral;
  String createdOn;
  String lastLogin;
  int hourlyTimer;
  int sumTimer;
  int premiumTill;
  int freeCashTimer;
  int multiplyTimer;
  bool referredBy;
  String referralId;
  String activePlan;

  Users(
      {this.uid,
      this.name,
      this.country,
      this.idToken,
      this.count,
      this.premiumTill,
      this.watchVideoTimer,
      this.freeCashTimer,
      this.email,
      this.points,
      this.clicks,
      this.clicks_left,
      this.profile_photo,
      this.claimed,
        this.earnedByReferral,
      this.createdOn,
      this.lastLogin,
      this.hourlyTimer,
      this.sumTimer,
      this.multiplyTimer,
      this.referredBy,
      this.referralId,
      this.activePlan,


      });

  Map toMap(Users users) {
    var data = Map<String, dynamic>();
    data['uid'] = users.uid;
    data['name'] = users.name;
    data['country'] = users.country;
    data['email'] = users.email;
    data['watchVideoTimer'] = users.watchVideoTimer;
    data['freeCashTimer'] = users.freeCashTimer;
    data['count'] = users.count;
    data['idToken'] = users.idToken;
    data['premiumTill'] = users.premiumTill;
    data['points'] = users.points;
    data['clicks'] = users.clicks;
    data['clicks_left'] = users.clicks_left;
    data['profile_photo'] = users.profile_photo;
    data['claimed'] = users.claimed;
    data['earnedByReferral'] = users.earnedByReferral;
    data['createdOn'] = users.createdOn;
    data['lastLogin'] = users.lastLogin;
    data['hourlyTimer'] = users.hourlyTimer;
    data['sumTimer'] = users.sumTimer;
    data['multiplyTimer'] = users.multiplyTimer;
    data['referredBy'] = users.referredBy;
    data['referralId'] = users.referralId;
    data['activePlan'] = users.activePlan;

    return data;
  }

  Users.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData['uid'];
    this.name = mapData['name'];
    this.country = mapData['country'];
    this.email = mapData['email'];
    this.freeCashTimer = mapData['freeCashTimer'];
    this.idToken = mapData['idToken'];
    this.count = mapData['count'];
    this.premiumTill = mapData['premiumTill'];
    this.watchVideoTimer = mapData['watchVideoTimer'];
    this.points = mapData['points'];
    this.clicks = mapData['clicks'];
    this.clicks_left = mapData['clicks_left'];
    this.profile_photo = mapData['profile_photo'];
    this.claimed = mapData['claimed'];
    this.earnedByReferral = mapData['earnedByReferral'];
    this.createdOn = mapData['createdOn'];
    this.lastLogin = mapData['lastLogin'];
    this.hourlyTimer = mapData['hourlyTimer'];
    this.sumTimer = mapData['sumTimer'];
    this.multiplyTimer = mapData['multiplyTimer'];
    this.referredBy = mapData['referredBy'];
    this.referralId = mapData['referralId'];

    this.activePlan = mapData['activePlan'];
  }
}
