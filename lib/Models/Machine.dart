class Machine {
  double? Voltage;
  double? Speed;
  double? current;

  Machine({this.Voltage, this.Speed, this.current});

  Machine.fromJson(Map<String, dynamic> json) {
    Voltage = json['Voltage'];
    Speed = json['Speed'];
    current = json['current'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Voltage'] = this.Voltage;
    data['Speed'] = this.Speed;
    data['current'] = this.current;
    return data;
  }
}
