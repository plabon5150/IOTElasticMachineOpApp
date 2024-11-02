class QCCard {
  String? mcNo;
  String? proMachine;
  String? jobNo;
  String? pO;
  String? referenceNo;
  String? itemCode;
  String? sampleDesc;
  String? size;
  String? colorCode;
  String? stretchbilty;
  String? noofBeam;
  String? countofRT;
  double? outputMH;
  String? dateofStart;
  double? ofTap;
  String? qty;
  Null? noofRT;
  double? wPM;
  String? actualQty;
  String? startDate;
  String? endDate;

  QCCard(
      {this.mcNo,
      this.proMachine,
      this.jobNo,
      this.pO,
      this.referenceNo,
      this.itemCode,
      this.sampleDesc,
      this.size,
      this.colorCode,
      this.stretchbilty,
      this.noofBeam,
      this.countofRT,
      this.outputMH,
      this.dateofStart,
      this.ofTap,
      this.qty,
      this.noofRT,
      this.wPM,
      this.actualQty,
      this.startDate,
      this.endDate});

  QCCard.fromJson(Map<String, dynamic> json) {
    mcNo = json['McNo'];
    proMachine = json['ProMachine'];
    jobNo = json['JobNo'];
    pO = json['PO'];
    referenceNo = json['ReferenceNo'];
    itemCode = json['ItemCode'];
    sampleDesc = json['SampleDesc'];
    size = json['Size'];
    colorCode = json['ColorCode'];
    stretchbilty = json['Stretchbilty'];
    noofBeam = json['NoofBeam'];
    countofRT = json['CountofRT'];
    outputMH = json['OutputMH'];
    dateofStart = json['DateofStart'];
    ofTap = json['OfTap'];
    qty = json['Qty'];
    noofRT = json['NoofRT'];
    wPM = json['WPM'];
    actualQty = json['ActualQty'];
    startDate = json['StartDate'];
    endDate = json['EndDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['McNo'] = this.mcNo;
    data['ProMachine'] = this.proMachine;
    data['JobNo'] = this.jobNo;
    data['PO'] = this.pO;
    data['ReferenceNo'] = this.referenceNo;
    data['ItemCode'] = this.itemCode;
    data['SampleDesc'] = this.sampleDesc;
    data['Size'] = this.size;
    data['ColorCode'] = this.colorCode;
    data['Stretchbilty'] = this.stretchbilty;
    data['NoofBeam'] = this.noofBeam;
    data['CountofRT'] = this.countofRT;
    data['OutputMH'] = this.outputMH;
    data['DateofStart'] = this.dateofStart;
    data['OfTap'] = this.ofTap;
    data['Qty'] = this.qty;
    data['NoofRT'] = this.noofRT;
    data['WPM'] = this.wPM;
    data['ActualQty'] = this.actualQty;
    data['StartDate'] = this.startDate;
    data['EndDate'] = this.endDate;
    return data;
  }
}
