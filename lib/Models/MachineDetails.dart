class MachineDetails {
  String? vcMCCode;
  int? intMCID;

  MachineDetails({this.vcMCCode, this.intMCID});
  @override
  bool operator ==(other) {
    return other is MachineDetails && other.intMCID == intMCID;
  }

  @override
  int get hashCode => intMCID.hashCode;

  MachineDetails.fromJson(Map<String, dynamic> json) {
    vcMCCode = json['vcMCCode'];
    intMCID = json['intMCID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['vcMCCode'] = this.vcMCCode;
    data['intMCID'] = this.intMCID;
    return data;
  }
}
