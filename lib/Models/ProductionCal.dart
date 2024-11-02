class productioncal {
  String? mcNo;
  String? jobNo;
  int? processID;
  double? totalProductionKG;
  int? totalStartTimeMinutes;

  productioncal(
      {this.mcNo,
      this.jobNo,
      this.processID,
      this.totalProductionKG,
      this.totalStartTimeMinutes});

  productioncal.fromJson(Map<String, dynamic> json) {
    mcNo = json['McNo'];
    jobNo = json['JobNo'];
    processID = json['ProcessID'];
    totalProductionKG = json['TotalProductionKG'];
    totalStartTimeMinutes = json['TotalStartTimeMinutes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['McNo'] = this.mcNo;
    data['JobNo'] = this.jobNo;
    data['ProcessID'] = this.processID;
    data['TotalProductionKG'] = this.totalProductionKG;
    data['TotalStartTimeMinutes'] = this.totalStartTimeMinutes;
    return data;
  }
}
