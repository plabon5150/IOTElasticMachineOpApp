class QcTaskDetail {
  final String jobNo; // Represents the job number
  final double qtym; // Represents the quantity in meters
  final double wPM; // Represents the work per minute
  final int noOfTape; // Represents the number of tape
  final double mSpeed; // Represents the machine speed
  final int enterBy;
  final int processID;
  final String mcNo;
  QcTaskDetail(
      {required this.jobNo,
      required this.qtym,
      required this.wPM,
      required this.noOfTape,
      required this.mSpeed,
      required this.enterBy,
      required this.processID,
      required this.mcNo});

  // You can add a factory constructor to convert from JSON if needed
  factory QcTaskDetail.fromJson(Map<String, dynamic> json) {
    return QcTaskDetail(
        jobNo: json['jobNo'],
        qtym: json['qtym'],
        wPM: json['wPM'],
        noOfTape: json['noOfTape'],
        mSpeed: json['mSpeed'],
        enterBy: json['enterBy'],
        processID: json['processID'],
        mcNo: json['vcMCCode']);
  }

  // You can add a method to convert to JSON if needed
  Map<String, dynamic> toJson() {
    return {
      'JobNo': jobNo,
      'Qtym': qtym,
      'WPM': wPM,
      'QTape': noOfTape,
      'MSpeed': mSpeed,
      'EnterBy': enterBy,
      'ProcessID': processID,
      'vcMCCode': mcNo
    };
  }
}
