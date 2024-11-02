import 'dart:async';
import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:machineautomation/Constants/MachineDate.dart';
import 'package:machineautomation/Screens/HomeScreen.dart';
import 'package:machineautomation/my_theme.dart';

class SplashScreen extends StatefulWidget {
  final double height;
  final double width;
  const SplashScreen({super.key, required this.height, required this.width});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  TextEditingController ipAddressController = TextEditingController();
  late String ipAddress = "";
  late String mcNo = "";
  bool wifi = false;
  TextEditingController mcController = TextEditingController();
  @override
  void initState() {
    getDeviceIp();
    getMachineNo();
    Timer(const Duration(seconds: 20), () {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const MyHome()));
    });
    super.initState();
  }

  Future<String> getMachineNo() async {
    try {
      final file = File('/home/config.txt');
      final lines = await file.readAsLines();

      for (var line in lines) {
        if (line.startsWith('machineNo=')) {
          final parts = line.split('=');
          if (parts.length > 1) {
            print('MC NO: ${parts[1]}');
            mcNo = parts[1];
            mcController.text = mcNo.trim();
            MachineData.setName(mcController.text);
            MachineData.setName("CR081");
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
            print('Raw IP Address: ${parts[1]}');
            final ipAddress = parts[1];
            ipAddressController.text = ipAddress;
            MachineData.setIP(ipAddressController.text);
            MachineData.setIP("192.168.12.16");
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
    return Scaffold(
        backgroundColor: const Color(0xFF5583F3),
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Container(
              width: widget.width,
              height: widget.height * 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [MyTheme.white, MyTheme.accent_color],
                  stops: const [0, 1],
                  begin: const AlignmentDirectional(0, -1),
                  end: const AlignmentDirectional(0, 1),
                ),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Lottie.asset(
                        'assets/splashscreen.json',
                        width: 280,
                        height: 350,
                        fit: BoxFit.cover,
                        animate: true,
                        repeat: true,
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 30.0),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const SizedBox(
                                width: 150,
                                child: Text(
                                  'TRANSFORMING',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                width: 170,
                                height: 50,
                                child: DefaultTextStyle(
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Horizon',
                                  ),
                                  child: AnimatedTextKit(
                                    repeatForever: true,
                                    animatedTexts: [
                                      RotateAnimatedText('NATURUB'),
                                      RotateAnimatedText('INDUSTRY'),
                                      RotateAnimatedText('PRODUCTION'),
                                    ],
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => const MyHome()));
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Machine Firmware V 1.0.0',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: MyTheme.white,
                            ),
                          ),
                          Text(
                            'NATURUB IT(BANGLADESH)',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: MyTheme.white,
                            ),
                          ),
                          Text(
                            'Xenon©',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: MyTheme.white,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
