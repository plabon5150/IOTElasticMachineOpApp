class ProductionMachineStatus {
  String? id;
  int? mcID;
  String? mcNo;
  int? userID;
  int? operatedBy;
  String? operatedOn;
  int? statusID;
  int? onClickStatus;
  int? interruptionID;
  String? jobNo;
  int? processID;
  double? produceQty;

  ProductionMachineStatus(
      {this.id,
      this.mcID,
      this.mcNo,
      this.userID,
      this.operatedBy,
      this.operatedOn,
      this.statusID,
      this.onClickStatus,
      this.interruptionID,
      this.jobNo,
      this.processID,
      this.produceQty});

  ProductionMachineStatus.fromJson(Map<String, dynamic> json) {
    id = json['$id'];
    mcID = json['McID'];
    mcNo = json['McNo'];
    userID = json['UserID'];
    operatedBy = json['OperatedBy'];
    operatedOn = json['OperatedOn'];
    statusID = json['StatusID'];
    onClickStatus = json['OnClickStatus'];
    interruptionID = json['InterruptionID'];
    jobNo = json['JobNo'];
    processID = json['ProcessID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['$id'] = this.id;
    data['McID'] = this.mcID;
    data['McNo'] = this.mcNo;
    data['UserID'] = this.userID;
    data['OperatedBy'] = this.operatedBy;
    data['OperatedOn'] = this.operatedOn;
    data['StatusID'] = this.statusID;
    data['OnClickStatus'] = this.onClickStatus;
    data['JobNo'] = this.jobNo;
    data['ProcessID'] = this.processID;
    data['ProduceQty'] = this.produceQty;
    return data;
  }
}
