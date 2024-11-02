import 'dart:ffi';

class QcDetails {
  String? id;
  String? mcNo;
  String? mobileNO;
  String? emailID;
  String? name;
  double? qMSpeed;

  QcDetails({this.id, this.mcNo, this.mobileNO, this.emailID, this.name});

  QcDetails.fromJson(Map<String, dynamic> json) {
    id = json['$id'];
    mcNo = json['McNo'];
    mobileNO = json['MobileNO'];
    emailID = json['EmailID'];
    name = json['Name'];
    qMSpeed = json['QMSpeed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['$id'] = this.id;
    data['McNo'] = this.mcNo;
    data['MobileNO'] = this.mobileNO;
    data['EmailID'] = this.emailID;
    data['Name'] = this.name;
    data['QMSpeed'] = this.qMSpeed;
    return data;
  }
}
