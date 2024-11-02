import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart';
import 'package:machineautomation/Models/JobModel.dart';
import 'package:machineautomation/Models/Machine.dart';
import 'package:machineautomation/Models/MachineDetails.dart';
import 'package:machineautomation/Models/ProductionCal.dart';
import 'package:machineautomation/Models/ProductionDetails.dart';
import 'package:machineautomation/Models/QcTaskDetail.dart';
import 'package:machineautomation/Models/Sensor.dart';
import '../Constants/MachineDate.dart';
import '../Models/Interruption.dart';
import '../Models/InteruptionRecord.dart';
import '../Models/MachineStatusModel.dart';
import '../Models/ProductionData.dart';
import '../Models/ProductionMachineStatus.dart';
import '../Models/QCCard.dart';
import '../Models/QcDetails.dart';

class HttpService {
  final String postsURL =
      "http://192.168.1.253:44782/NaturubWebAPI/api/Production/GetProductionUsingMC";
  final String commonProUrl =
      "http://192.168.1.253:44782/NaturubWebAPI/api/Production/GetAutoDetailsMachine";
  final String postsURL1 = "http://192.168.12.11:5000/";
  final String MachineUrl = "http://192.168.12.11:5000";
  final String MainApi = "http://192.168.1.253:4422/api/Common";
  final String LocalApi =
      "http://192.168.1.253:44782/NaturubWebAPI/api/Production";
  final String testUrl =
      "http://192.168.1.253:44782/NaturubWebAPI/api/Production/GetJobForPlanning";

  Future<List<ProductionStatus>> getProductionData() async {
    String name = await MachineData.getName();
    final url = Uri.parse(postsURL);
    final headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {"vcMCCode": name};
    String jsonBody = json.encode(body);
    final encoding = Encoding.getByName('utf-8');

    Response response = await post(
      url,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );

    if (response.statusCode == 200) {
      return (json.decode(response.body) as List) // <-- added mapping
          .map((entry) => ProductionStatus.fromJson(entry))
          .toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<ProductionDetails>> getRealtProductionDetails() async {
    String name = await MachineData.getName();
    final url = Uri.parse(commonProUrl);
    final headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {"vcMCCode": name};
    String jsonBody = json.encode(body);
    final encoding = Encoding.getByName('utf-8');

    Response response = await post(
      url,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );

    if (response.statusCode == 200) {
      try {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((entry) => ProductionDetails.fromJson(entry))
            .toList();
      } catch (e) {
        print('Error decoding JSON: $e');
        print('Response body: ${response.body}');
        throw Exception('Failed to parse data');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<MachineDetails>> getProductionMachine() async {
    final url = Uri.parse("$MainApi/GetProductionMachine");
    final response = await get(url);

    if (response.statusCode == 200) {
      return (json.decode(response.body) as List) // <-- added mapping
          .map((entry) => MachineDetails.fromJson(entry))
          .toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<JobModel>> getProductionJobs() async {
    final url = Uri.parse(testUrl);
    final response = await get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return (json.decode(response.body) as List) // <-- added mapping
          .map((entry) => JobModel.fromJson(entry))
          .toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<QcDetails>> getQcDetails() async {
    String name = await MachineData.getName();
    final url = Uri.parse("$LocalApi/GetQCDetails");
    final headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {"McNo": name};
    String jsonBody = json.encode(body);
    //final encoding = Encoding.getByName('utf-8');
    Response response = await post(
      url,
      headers: headers,
      body: jsonBody,
      //encoding: encoding,
    );

    if (response.statusCode == 200) {
      return (json.decode(response.body) as List) // <-- added mapping
          .map((entry) => QcDetails.fromJson(entry))
          .toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<QcDetails>> getOparatorDetails() async {
    String name = await MachineData.getName();
    final url = Uri.parse("$LocalApi/GetOperatorDetails");
    final headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {"McNo": name};
    String jsonBody = json.encode(body);
    final encoding = Encoding.getByName('utf-8');
    Response response = await post(
      url,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );

    if (response.statusCode == 200) {
      return (json.decode(response.body) as List) // <-- added mapping
          .map((entry) => QcDetails.fromJson(entry))
          .toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<Interruption>> getInterruption() async {
    final url = Uri.parse("$LocalApi/GetInterruptionTypeDetails");
    final response = await get(url);

    if (response.statusCode == 200 &&
        response.body != null &&
        response.body.isNotEmpty) {
      final decodedData = json.decode(response.body);

      if (decodedData is List) {
        return decodedData
            .map((entry) => Interruption.fromJson(entry))
            .toList();
      }
    }

    return [];
  }

  Future<List<MachineStatusModel>> getMachineStatusDetails() async {
    String name = await MachineData.getName();
    final url = Uri.parse("$LocalApi/GetMachineStatusDetails");

    final headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {"McNo": name};
    String jsonBody = json.encode(body);
    final encoding = Encoding.getByName('utf-8');

    Response response = await post(
      url,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      return (json.decode(response.body) as List)
          .map((entry) => MachineStatusModel.fromJson(entry))
          .toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<Sensor> getSensorData() async {
    final url = Uri.parse("$MachineUrl/Metal_count");
    final response = await get(url);

    if (response.statusCode == 200) {
      return Sensor.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<String> startMachine() async {
    String ip = await MachineData.getIP();
    final url = Uri.parse("http://$ip:5000/start");
    final response = await get(url);
    if (response.statusCode == 200) {
      return "Machine Started";
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<String> oneMinMachine() async {
    String ip = await MachineData.getIP();
    final url = Uri.parse("http://$ip:5000/minCalled");
    final response = await get(url);
    if (response.statusCode == 200) {
      return "Machine Started for one min";
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<String> startJog() async {
    String ip = await MachineData.getIP();
    final url = Uri.parse("http://$ip:5000/jog");
    final headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {"direction": 1};
    String jsonBody = json.encode(body);
    final encoding = Encoding.getByName('utf-8');

    Response response = await post(
      url,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );

    if (response.statusCode == 200) {
      return "Machine Jog Started";
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<String> stopMachine() async {
    String ip = await MachineData.getIP();
    final url = Uri.parse("http://$ip:5000/stop");
    final response = await get(url);

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      return "Machine Stop";
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<String> heatonMachine() async {
    String ip = await MachineData.getIP();
    final url = Uri.parse("http://$ip:5000/heaton");
    final response = await get(url);

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      return "Machine Stop";
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<String> heatoffMachine() async {
    String ip = await MachineData.getIP();
    final url = Uri.parse("http://$ip:5000/heatoff");
    final response = await get(url);

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      return "Machine Stop";
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<Machine> statusMachine() async {
    String ip = await MachineData.getIP();
    final url = Uri.parse("http://$ip:5000/all_data");
    final response = await get(url);
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      return Machine.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<Machine> setMachineSpeed(speed) async {
    String ip = await MachineData.getIP();
    final url = Uri.parse("http://$ip:5000/speed");
    final headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {"speed": speed};
    String jsonBody = json.encode(body);
    final encoding = Encoding.getByName('utf-8');

    Response response = await post(
      url,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );

    if (response.statusCode == 200) {
      String ip = await MachineData.getIP();
      final url = Uri.parse("http://$ip:5000/all_data");
      final response = await get(url);

      if (response.statusCode == 200) {
        return Machine.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load data');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<ProductionMachineStatus>> saveMachineStatus(
      int onClickStatus, String jobNo, double produceQty) async {
    String name = await MachineData.getName();
    int id = await MachineData.getProcessID();
    int status = await MachineData.getStatusID();
    String user = await MachineData.getUserID();
    //String jobNo = await MachineData.getJobNo();
    final url = Uri.parse("$LocalApi/UpdateProductionMachine");
    final headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {
      "McNo": name,
      "UserID": int.parse(user),
      "OnClickStatus": onClickStatus,
      "ProcessID": id,
      "StatusID": status,
      "JobNo": jobNo,
      "ProduceQty": produceQty
    };
    String jsonBody = json.encode(body);
    final encoding = Encoding.getByName('utf-8');

    Response response = await post(
      url,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      return (json.decode(response.body) as List)
          .map((entry) => ProductionMachineStatus.fromJson(entry))
          .toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<ProductionMachineStatus>> saveMachineJobPlan(
      List<ProductionMachineStatus> listJobPlan) async {
    final url = Uri.parse("$LocalApi/PlanningJobDetails");
    final headers = {'Content-Type': 'application/json'};
    List<Map<String, dynamic>> jobDetailsJson =
        listJobPlan.map((task) => task.toJson()).toList();
    String jsonBody = json.encode(jobDetailsJson);
    final encoding = Encoding.getByName('utf-8');

    Response response = await post(
      url,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse is List) {
        return jsonResponse
            .map((entry) => ProductionMachineStatus.fromJson(entry))
            .toList();
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      throw Exception('Failed to make the API request');
    }
  }

  Future<List<ProductionMachineStatus>> saveInterruptionStatus(
    int OnClickStatus,
    int InterruptionID,
  ) async {
    String name = await MachineData.getName();
    int id = await MachineData.getProcessID();
    String user = await MachineData.getUserID();
    String jobNo = await MachineData.getJobNo();
    final url = Uri.parse("$LocalApi/UpdateProductionMachine");
    final headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {
      "McNo": name,
      "UserID": int.parse(user),
      "OnClickStatus": OnClickStatus,
      "ProcessID": id,
      "StatusID": 5,
      "JobNo": jobNo,
      "InterruptionID": InterruptionID
    };
    String jsonBody = json.encode(body);
    final encoding = Encoding.getByName('utf-8');

    Response response = await post(
      url,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      return (json.decode(response.body) as List)
          .map((entry) => ProductionMachineStatus.fromJson(entry))
          .toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<ProductionMachineStatus>> getProcessWiseMachineStatus() async {
    String name = await MachineData.getName();
    final url = Uri.parse("$LocalApi/GetMachineStatus");
    final headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {
      "McNo": name,
    };
    String jsonBody = json.encode(body);
    final encoding = Encoding.getByName('utf-8');

    Response response = await post(
      url,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );

    if (response.statusCode == 200 && response.body != "[]") {
      return (json.decode(response.body) as List)
          .map((entry) => ProductionMachineStatus.fromJson(entry))
          .toList();
    } else {
      return [];
    }
  }

  Future<List<QCCard>> getQcCardDetails() async {
    String job = await MachineData.getJobNo();
    String name = await MachineData.getName();
    final url = Uri.parse("$LocalApi/GetQCCardDetails");
    final headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {"JobNo": job, "McNo": name};
    String jsonBody = json.encode(body);
    final encoding = Encoding.getByName('utf-8');

    Response response = await post(
      url,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );

    if (response.statusCode == 200 && response.body != "[]") {
      return (json.decode(response.body) as List)
          .map((entry) => QCCard.fromJson(entry))
          .toList();
    } else {
      return [];
    }
  }

  Future<List<productioncal>> getProductionDetails() async {
    String name = await MachineData.getName();
    final url = Uri.parse("$LocalApi/GetTotalProductionKGByMachineID");
    final headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {"McNo": name};
    String jsonBody = json.encode(body);
    final encoding = Encoding.getByName('utf-8');

    Response response = await post(
      url,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );

    if (response.statusCode == 200 && response.body != "[]") {
      return (json.decode(response.body) as List)
          .map((entry) => productioncal.fromJson(entry))
          .toList();
    } else {
      return [];
    }
  }

  Future<List<ProductionStatus>> getProcessID() async {
    String name = await MachineData.getName();
    final url = Uri.parse("$LocalApi/GetSeqUsingMCNo");
    final headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {
      "vcMCCode": name,
    };
    String jsonBody = json.encode(body);
    final encoding = Encoding.getByName('utf-8');

    Response response = await post(
      url,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      return (json.decode(response.body) as List)
          .map((entry) => ProductionStatus.fromJson(entry))
          .toList();
    } else {
      return [];
    }
  }

  Future<List<InteruptionRecord>> getInterruptionRecord() async {
    String name = await MachineData.getName();
    final url = Uri.parse("$LocalApi/GetInterruptionRecord");
    final headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {
      "McNo": name,
    };
    String jsonBody = json.encode(body);
    final encoding = Encoding.getByName('utf-8');

    Response response = await post(
      url,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      return (json.decode(response.body) as List)
          .map((entry) => InteruptionRecord.fromJson(entry))
          .toList();
    } else {
      return [];
    }
  }

  Future<String> updateInterruptionRecord(
      int recordID, int interruptionID) async {
    final url = Uri.parse("$LocalApi/UpdateCheckInCheckOut");
    final headers = {'Content-Type': 'application/json'};
    String user = await MachineData.getUserID();
    Map<String, dynamic> body = {
      "RecordID": recordID,
      "InterruptionID": interruptionID,
      "UserID": user
    };
    String jsonBody = json.encode(body);
    final encoding = Encoding.getByName('utf-8');

    Response response = await post(
      url,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );

    if (response.statusCode == 200) {
      return "Record Updated";
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<String> updateOperatorTaskDetails(
      bool tapeSetting,
      bool yarn,
      bool design,
      bool speed,
      String remark,
      int secondsRemaining,
      double mSpeed) async {
    int id = await MachineData.getProcessID();
    String user = await MachineData.getUserID();
    final url = Uri.parse("$LocalApi/UpdateOperatorDetails");
    final headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {
      "ProcessID": id,
      "EnterBy": int.parse(user),
      "TapeSetting": tapeSetting,
      "Yarn": yarn,
      "Design": design,
      "Speed": speed,
      "MSpeed": mSpeed,
      "Duration": secondsRemaining,
      "Remark": remark
    };
    String jsonBody = json.encode(body);
    final encoding = Encoding.getByName('utf-8');

    Response response = await post(
      url,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );

    if (response.statusCode == 200) {
      return "Record Updated";
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<String> updateQcTaskDetails(List<QcTaskDetail> taskDetails) async {
    final url = Uri.parse("$LocalApi/UpdateQCDetails");
    final headers = {'Content-Type': 'application/json'};
    List<Map<String, dynamic>> taskDetailsJson =
        taskDetails.map((task) => task.toJson()).toList();
    String jsonBody = json.encode(taskDetailsJson);
    final encoding = Encoding.getByName('utf-8');

    Response response = await post(
      url,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );

    if (response.statusCode == 200) {
      return "Record Updated";
    } else {
      throw Exception('Failed to load data');
    }
  }
}
