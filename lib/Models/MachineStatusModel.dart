class MachineStatusModel {
  String? id;
  int? statusID;
  String? statusDetails;

  MachineStatusModel({this.id, this.statusID, this.statusDetails});

  MachineStatusModel.fromJson(Map<String, dynamic> json) {
    id = json['$id'];
    statusID = json['StatusID'];
    statusDetails = json['StatusDetails'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['$id'] = this.id;
    data['StatusID'] = this.statusID;
    data['StatusDetails'] = this.statusDetails;
    return data;
  }
}
