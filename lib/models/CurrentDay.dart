class CurrentDay {
  String id;
  String currentDateTime;
  String utcOffset;
  bool isDayLightSavingsTime;
  String dayOfTheWeek;
  String timeZoneName;
  int currentFileTime;
  String ordinalDate;
  Null serviceResponse;

  CurrentDay(
      {this.id,
        this.currentDateTime,
        this.utcOffset,
        this.isDayLightSavingsTime,
        this.dayOfTheWeek,
        this.timeZoneName,
        this.currentFileTime,
        this.ordinalDate,
        this.serviceResponse});

  CurrentDay.fromJson(Map<String, dynamic> json) {
    id = json['$id'];
    currentDateTime = json['currentDateTime'];
    utcOffset = json['utcOffset'];
    isDayLightSavingsTime = json['isDayLightSavingsTime'];
    dayOfTheWeek = json['dayOfTheWeek'];
    timeZoneName = json['timeZoneName'];
    currentFileTime = json['currentFileTime'];
    ordinalDate = json['ordinalDate'];
    serviceResponse = json['serviceResponse'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['$id'] = this.id;
    data['currentDateTime'] = this.currentDateTime;
    data['utcOffset'] = this.utcOffset;
    data['isDayLightSavingsTime'] = this.isDayLightSavingsTime;
    data['dayOfTheWeek'] = this.dayOfTheWeek;
    data['timeZoneName'] = this.timeZoneName;
    data['currentFileTime'] = this.currentFileTime;
    data['ordinalDate'] = this.ordinalDate;
    data['serviceResponse'] = this.serviceResponse;
    return data;
  }
}
