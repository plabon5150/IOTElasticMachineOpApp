import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:cool_ui/cool_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:machineautomation/Constants/MachineDate.dart';
import 'package:machineautomation/my_theme.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:virtual_keyboard_multi_language/virtual_keyboard_multi_language.dart';
import '../Models/Machine.dart';
import '../Services/HttpService.dart';

class QcEntry extends StatefulWidget {
  const QcEntry({super.key});

  @override
  State<QcEntry> createState() => _QcEntryState();
}

class _QcEntryState extends State<QcEntry> {
  Machine _machineModel = new Machine();
  dynamic machineDate = null;
  late Timer timer;
  late double width;
  late double height;
  late String Status;
  late String ipAddress = "";
  late String mcNo = "";
  bool switchValue = false;
  bool ServerOP = false;
  bool wifi = false;
  bool isServerRunning = true;
  String serverStatus = 'Loading...';
  TextEditingController ipAddressController = TextEditingController();
  TextEditingController mcController = TextEditingController();
  @override
  void initState() {
    super.initState();
    //connectToWifi();
    getDeviceIp();
    getMachineNo();
    checkServerStatus();
    //getWifiConnection();
    Size screenSize = WidgetsBinding.instance.window.physicalSize;
    width = screenSize.width;
    height = screenSize.height;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> checkServerStatus() async {
    final String apiUrl = 'http://${ipAddressController.text}:5002/status';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = response.body;
        final decodedData = json.decode(data);
        final status = decodedData['status'];

        setState(() {
          isServerRunning = status == 'active';
        });
      } else {
        setState(() {
          isServerRunning = false;
        });
      }
    } catch (e) {
      setState(() {
        isServerRunning = false;
      });
    }
  }

  Future<String> getWifiConnection() async {
    try {
      var result = await Process.run('/usr/sbin/iwconfig', ['wlan0']);
      if (result.stdout.toString().contains('plabon')) {
        setState(() {
          wifi = true;
        });
      } else {
        setState(() {
          wifi = false;
          Process.run('/usr/sbin/iwconfig',
              ['wlan0', 'essid', 'plabon', 'key', 's:helloworld']);
          Process.run('/usr/sbin/dhclient', ['wlan0']);
        });
      }
      return 'Wifi Connected';
    } catch (e) {
      setState(() {
        wifi = false;
      });
      return 'Error Connecting Wifi: $e';
    }
  }

  Future<void> connectToWifi() async {
    const ssid = 'plabon';
    const password = 'helloworld';
    const config = 'network={\n  ssid="$ssid"\n  psk="$password"\n}\n';
    final tempFile = File('/tmp/wifi-config.conf');
    await tempFile.writeAsString(config);

    const wifiInterface = 'wlan0';

    await Process.run('sudo', [
      'cp',
      '/tmp/wifi-config.conf',
      '/etc/wpa_supplicant/wpa_supplicant.conf',
    ]);

    await Process.run('sudo', ['ifdown', wifiInterface]);
    await Process.run('sudo', ['ifup', wifiInterface]);
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

  Future<void> stopServer() async {
    setState(() {
      ServerOP = true;
    });
    final String serverUrl =
        "http://${ipAddressController.text}:5002/stop-server";

    try {
      final response = await http.post(Uri.parse(serverUrl));

      if (response.statusCode == 200) {
        setState(() {
          isServerRunning = false;
          ServerOP = false;
        });
      } else {
        print("Error stopping server. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception during HTTP request: $e");
    }
  }

  Future<void> startServer() async {
    setState(() {
      ServerOP = true;
    });
    final String serverUrl =
        "http://${ipAddressController.text}:5002/start-server";

    try {
      final response = await http.post(Uri.parse(serverUrl));

      if (response.statusCode == 200) {
        print("Server stopped successfully.");
        setState(() {
          isServerRunning = true;
          ServerOP = false;
        });
      } else {
        print("Error stopping server. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception during HTTP request: $e");
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
            MachineData.setIP(ipAddressController.text);
          }
        }
      }
      print('Device IP address not found.');
    } catch (e) {
      print('Error getting IP address: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ServerOP
          ? const CircularProgressIndicator(color: Colors.blue)
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.5), // Shadow color
                          spreadRadius: 5, // How wide the shadow should be
                          blurRadius:
                              7, // How much the shadow should be blurred
                          offset: const Offset(0, 3), // Offset of the shadow
                        ),
                      ]),
                  height: height / 1.5,
                  width: width / 2.3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text("Machine Configuration",
                          style: TextStyle(fontSize: 24)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CupertinoSwitch(
                            activeColor: Colors.orange,
                            value: isServerRunning,
                            onChanged: (value) {
                              setState(() {
                                if (value) {
                                  startServer();
                                } else {
                                  stopServer();
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            isServerRunning ? 'Machine On' : 'Machine Off',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: switchValue ? Colors.green : Colors.red,
                            ),
                          )
                        ],
                      ),
                      TextField(
                        controller: mcController,
                        decoration: InputDecoration(
                          labelText: 'Machine No',
                          filled: true,
                          fillColor: Colors.grey[200],
                          enabled: false, // Disable the text field
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        readOnly: true,
                        style: const TextStyle(
                          color: Colors.black87,
                        ),
                      ),
                      TextField(
                        controller: ipAddressController,
                        decoration: InputDecoration(
                          labelText: 'IP ADDRESS',
                          filled: true,
                          fillColor: Colors.grey[200],
                          enabled: false, // Disable the text field
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        readOnly: true,
                        style: const TextStyle(
                          color: Colors.black87,
                        ),
                      ),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Firmwire version',
                          filled: true,

                          fillColor: Colors.grey[200],
                          enabled: false, // Disable the text field
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        readOnly: true,
                        style: const TextStyle(
                          color: Colors.black87,
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.5), // Shadow color
                          spreadRadius: 5, // How wide the shadow should be
                          blurRadius:
                              7, // How much the shadow should be blurred
                          offset: const Offset(0, 3), // Offset of the shadow
                        ),
                      ]),
                  height: height / 1.5,
                  width: width / 2.3,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Lottie.asset(
                          'assets/heater.json',
                          width: 250,
                          height: 200,
                          animate: switchValue,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text("Machine Utility Lookup",
                              style: TextStyle(fontSize: 24)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CupertinoSwitch(
                                activeColor: Colors.orange,
                                value: switchValue,
                                onChanged: (value) {
                                  setState(() {
                                    switchValue = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 16.0),
                              Text(
                                switchValue ? 'Heater Start' : 'Heater Off',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      switchValue ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Stop Motion :",
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                " WORKING",
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Inverter :",
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                " WORKING",
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                "Wifi :",
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                wifi ? " CONNECTED" : " NOT CONNECTED",
                                style: const TextStyle(
                                    fontSize: 17,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton(
                              onPressed: () {
                                // Process.run('/usr/sbin/iwconfig', [
                                //   'wlan0',
                                //   'essid',
                                //   'plabon',
                                //   'key',
                                //   's:helloworld'
                                // ]);
                                // Process.run('/usr/sbin/dhclient', ['wlan0']);
                                // setState(() {
                                //   wifi = true;
                                // });
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(15.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.wifi,
                                    size: 30.0,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 10.0),
                                  Text(
                                    'Connect',
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        color: Colors.amber[900]),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
