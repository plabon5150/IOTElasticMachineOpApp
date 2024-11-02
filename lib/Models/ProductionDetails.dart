class ProductionDetails {
  String id;
  String vcMCCode;
  String vcJobNo;
  double producedQty;
  double allocQty;
  double totalDamages;
  int mcID;
  double productionKG;
  String started;
  String stopMotion;
  double frequency;
  double rpm;
  double totalYards;
  int statusID;
  String statusDetails;
  int interruptionID;
  String color;

  ProductionDetails({
    required this.id,
    required this.vcMCCode,
    required this.vcJobNo,
    required this.producedQty,
    required this.allocQty,
    required this.totalDamages,
    required this.mcID,
    required this.productionKG,
    required this.started,
    required this.stopMotion,
    required this.frequency,
    required this.rpm,
    required this.totalYards,
    required this.statusID,
    required this.statusDetails,
    required this.interruptionID,
    required this.color,
  });

  factory ProductionDetails.fromJson(Map<String, dynamic> json) {
    return ProductionDetails(
      id: json['\$id'],
      vcMCCode: json['vcMCCode'],
      vcJobNo: json['vcJobNo'],
      producedQty: json['ProducedQty'].toDouble(),
      allocQty: json['AllocQty'].toDouble(),
      totalDamages: json['TotalDamages'].toDouble(),
      mcID: json['McID'],
      productionKG: json['ProductionKG'].toDouble(),
      started: json['Started'],
      stopMotion: json['StopMotion'],
      frequency: json['Frequency'].toDouble(),
      rpm: json['RPM'].toDouble(),
      totalYards: json['TotalYards'].toDouble(),
      statusID: json['StatusID'],
      statusDetails: json['StatusDetails'],
      interruptionID: json['InterruptionID'],
      color: json['Color'],
    );
  }
}
