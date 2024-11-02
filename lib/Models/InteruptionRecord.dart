class InteruptionRecord {
  String? id;
  int? recordID;
  int? processID;
  String? issuedOn;
  String? checkedBy;
  String? interruptionTypeDetails;
  int? intinterruptionID;

  InteruptionRecord(
      {this.id,
      this.recordID,
      this.processID,
      this.issuedOn,
      this.checkedBy,
      this.interruptionTypeDetails,
      this.intinterruptionID});

  InteruptionRecord.fromJson(Map<String, dynamic> json) {
    id = json['$id'];
    recordID = json['RecordID'];
    processID = json['ProcessID'];
    issuedOn = json['IssuedOn'];
    checkedBy = json['CheckedBy'];
    interruptionTypeDetails = json['InterruptionTypeDetails'];
    intinterruptionID = json['IntinterruptionID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['$id'] = this.id;
    data['RecordID'] = this.recordID;
    data['ProcessID'] = this.processID;
    data['IssuedOn'] = this.issuedOn;
    data['CheckedBy'] = this.checkedBy;
    data['InterruptionTypeDetails'] = this.interruptionTypeDetails;
    data['IntinterruptionID'] = this.intinterruptionID;
    return data;
  }
}
