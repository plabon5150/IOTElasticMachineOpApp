class ProductionStatus {
  String? vcJobNo;
  double? producedQty;
  double? allocQty;
  int? intSequenceNo;
  double? totalDamages;
  String? vcMCCode;

  ProductionStatus(
      {this.vcJobNo,
      this.producedQty,
      this.allocQty,
      this.intSequenceNo,
      this.totalDamages,
      this.vcMCCode});

  ProductionStatus.fromJson(Map<String, dynamic> json) {
    vcJobNo = json['vcJobNo'];
    producedQty = json['ProducedQty'];
    allocQty = json['AllocQty'];
    intSequenceNo = json['intSequenceNo'];
    totalDamages = json['TotalDamages'];
    vcMCCode = json['vcMCCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['vcJobNo'] = this.vcJobNo;
    data['ProducedQty'] = this.producedQty;
    data['AllocQty'] = this.allocQty;
    data['intSequenceNo'] = this.intSequenceNo;
    data['TotalDamages'] = this.totalDamages;
    data['vcMCCode'] = this.vcMCCode;
    return data;
  }
}
