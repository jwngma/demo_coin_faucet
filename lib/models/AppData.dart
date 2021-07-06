class AppData {
  int points;
  int nextClaim;
  String name;
  int claimed;
  int earnedByReferral;
  String profile_photo;

  AppData(
      {this.points,
      this.nextClaim,
      this.name,
      this.claimed,
      this.earnedByReferral,
      this.profile_photo});

  AppData.fromJson(Map<String, dynamic> json) {
    points = json['points'];
    nextClaim = json['nextClaim'];
    name = json['name'];
    claimed = json['claimed'];
    earnedByReferral = json['earnedByReferral'];
    profile_photo = json['profile_photo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['points'] = this.points;
    data['nextClaim'] = this.nextClaim;
    data['name'] = this.name;
    data['claimed'] = this.claimed;
    data['earnedByReferral'] = this.earnedByReferral;
    data['profile_photo'] = this.profile_photo;
    return data;
  }
}
