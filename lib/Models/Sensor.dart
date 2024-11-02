class Sensor {
  int? Metal_count;

  Sensor({this.Metal_count});

  Sensor.fromJson(Map<String, dynamic> json) {
    Metal_count = json['Metal_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Metal_count'] = this.Metal_count;
    return data;
  }
}
