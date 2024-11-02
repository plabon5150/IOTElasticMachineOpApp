import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:machineautomation/Constants/MachineDate.dart';
import 'package:machineautomation/Models/ProductionData.dart';
import 'package:machineautomation/Screens/LoginScreen.dart';
import 'package:machineautomation/Screens/MachineStatus.dart';
import 'package:machineautomation/Screens/QcNav.dart';
import 'package:machineautomation/Services/HttpService.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  bool isLoading = false;
  late double width;
  late double height;
  late String ipAddress = "";
  late String mcNo = "";
  bool switchValue = false;
  TextEditingController ipAddressController = TextEditingController();
  TextEditingController mcController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _getProcess();
    getDeviceIp();
    getMachineNo();
    getWifiConnection();
    Size screenSize = WidgetsBinding.instance.window.physicalSize;
    width = screenSize.width;
    height = screenSize.height;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<String> getWifiConnection() async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        Process.run('iwconfig wlan0 essid plabon key s:helloworld', []);
        Process.run('dhclient wlan0', []);
      }

      return 'Wifi Connected';
    } catch (e) {
      return 'Error Connecting Wifi: $e';
    }
  }

  Future<String> _getProcess() async {
    List<ProductionStatus> listProcess = await HttpService().getProcessID();

    MachineData.setProcessID(listProcess[0].intSequenceNo);
    return 'ID Saved.ID IS: ${listProcess[0].intSequenceNo}';
  }

  Future<String> getMachineNo() async {
    try {
      final file = File('/home/config.txt');
      final lines = await file.readAsLines();

      for (var line in lines) {
        if (line.startsWith('machineNo=')) {
          final parts = line.split('=');
          if (parts.length > 1) {
            mcNo = parts[1];
            mcController.text = mcNo.trim();
            MachineData.setName(mcController.text);
          }
        }
      }

      return 'IP address not found in /etc/dhcpcd.conf';
    } catch (e) {
      return 'Error getting IP address: $e';
    }
  }

  Future<void> getDeviceIp() async {
    try {
      final file = File('/etc/dhcpcd.conf');
      final lines = await file.readAsLines();
      for (var line in lines) {
        if (line.startsWith('static ip_address=')) {
          final parts = line.split('=');
          if (parts.length > 1) {
            final ipAddress = parts[1];
            ipAddressController.text = ipAddress;
            MachineData.setIP(ipAddressController.text.trim());
          }
        }
      }
      print('Device IP address not found.');
    } catch (e) {
      print('Error getting IP address: $e');
    }
  }

  Future<void> handleQcEntryTap() async {
    if (isLoading) {
      return; // Return if loading is already in progress
    }

    setState(() {
      isLoading = true; // Show the loading indicator
    });

    try {
      final response = await get(Uri.parse(
          'http://${ipAddressController.text.trim()}:5000/read_rfid'));
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        String text = responseData['text'].trim();
        MachineData.setUserID(text);
        MachineData.setIP(ipAddressController.text.trim());
        if (text.isNotEmpty) {
          setState(() {
            _currentIndex = 2; // Navigate to QcEntry
          });
        }
      }
    } catch (error) {
      // Handle any errors during the fetch
      print('Error fetching RFID data: $error');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false; // Hide the loading indicator
        });
      }
    }
  }

  int _currentIndex = 0;
  final List _children = [MachineStatus(), QcEntry(), Login()];

  bool canChangeIndex(int newIndex) {
    return !isLoading;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Color.fromRGBO(107, 176, 245, 1),
        items: <Widget>[
          Icon(Icons.add, size: 30),
          Icon(Icons.list, size: 30),
          Icon(Icons.compare_arrows, size: 30),
        ],
        letIndexChange: canChangeIndex,
        onTap: (index) {
          // setState(() {
          //   _currentIndex = index;
          // });
          if (isLoading) {
            return;
          }
          if (index == 2) {
            handleQcEntryTap();
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
      body: isLoading
          ? AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: Container(
                width: 350,
                height: 350,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.warning,
                            size: 50,
                            color: Colors.red,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'CARD MANDATORY',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Lottie.asset(
                        'assets/nfc.json',
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                        animate: true,
                        repeat: true,
                      ),
                    ],
                  ),
                ),
              ),
            )
          : _children[_currentIndex],
    );
  }
}
