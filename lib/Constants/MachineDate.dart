import 'package:shared_preferences/shared_preferences.dart';

class MachineData {
  static final String _machineNo = 'name';
  static final String _processID = 'ProcessID';
  static final String _statusID = 'StatusID';
  static final String _jobNo = 'JobNo';
  static final String _userID = 'UserID';
  static final String _ip = 'ip';

  static Future<String> getName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_machineNo) ?? '';
  }

  static Future<void> setName(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_machineNo, name);
  }

  static Future<String> getIP() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_ip) ?? '';
  }

  static Future<void> setIP(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ip, name);
  }

  static Future<void> setProcessID(dynamic ProcessID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_processID, ProcessID);
  }

  static Future<int> getProcessID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_processID) ?? 8;
  }

  static Future<void> setStatusID(dynamic StatusID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_statusID, StatusID);
  }

  static Future<int> getStatusID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_statusID) ?? 0;
  }

  static Future<void> setJobNo(dynamic JobNo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_jobNo, JobNo);
  }

  static Future<String> getJobNo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_jobNo) ?? "";
  }

  static Future<void> setUserID(dynamic UserID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userID, UserID);
  }

  static Future<String> getUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userID) ?? "";
  }
}
