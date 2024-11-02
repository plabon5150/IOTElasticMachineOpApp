class Interruption {
  String? id;
  int? interruptionTypeDetailsID;
  int? interruptionTypeID;
  String? interruptionTypeDetails;
  Null? mcNo;

  Interruption(
      {this.id,
      this.interruptionTypeDetailsID,
      this.interruptionTypeID,
      this.interruptionTypeDetails,
      this.mcNo});

  Interruption.fromJson(Map<String, dynamic> json) {
    id = json['$id'];
    interruptionTypeDetailsID = json['InterruptionTypeDetailsID'];
    interruptionTypeID = json['InterruptionTypeID'];
    interruptionTypeDetails = json['InterruptionTypeDetails'];
    mcNo = json['McNo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['$id'] = this.id;
    data['InterruptionTypeDetailsID'] = this.interruptionTypeDetailsID;
    data['InterruptionTypeID'] = this.interruptionTypeID;
    data['InterruptionTypeDetails'] = this.interruptionTypeDetails;
    data['McNo'] = this.mcNo;
    return data;
  }
}
