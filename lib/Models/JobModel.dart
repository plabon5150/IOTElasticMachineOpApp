class JobModel {
  final String vcJobNo;
  final int intJobID;

  JobModel({
    required this.vcJobNo,
    required this.intJobID,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      vcJobNo: json['vcJobNo'],
      intJobID: json['intJobID'],
    );
  }
}
