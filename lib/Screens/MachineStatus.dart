import 'dart:async';
import 'dart:io';
import 'package:d_chart/d_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gpiod/flutter_gpiod.dart';
import 'package:machineautomation/Models/JobModel.dart';
import 'package:machineautomation/Models/MachineDetails.dart';
import 'package:machineautomation/Models/ProductionCal.dart';
import 'package:machineautomation/Models/ProductionDetails.dart';
import 'package:machineautomation/Models/Sensor.dart';
import 'package:machineautomation/my_theme.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../Constants/MachineDate.dart';
import '../Models/Machine.dart';
import '../Models/ProductionData.dart';
import '../Services/HttpService.dart';

class MachineStatus extends StatefulWidget {
  const MachineStatus({super.key});

  @override
  State<MachineStatus> createState() => _MachineStatusState();
}

class _MachineStatusState extends State<MachineStatus>
    with TickerProviderStateMixin {
  ProductionStatus _productionStatus = new ProductionStatus();
  List<ProductionDetails> mList = [];
  List<Map<String, dynamic>> productgyp = [];
  List<Map<String, double>> productDonat = [];
  int _currentItem = 0;
  bool? switchValue;
  late double width;
  late double height;
  late dynamic mapWithBiggestCaseNumber;
  double maxValueProduction = 0.0;
  late AnimationController _controller;
  String _timeString = '00:00:00';
  late String Status;
  Timer? _timer1;
  int _start = 0;
  int _count = 0;
  bool isStart = false;
  late final line8;
  String result = "";
  Sensor _sensorModel = new Sensor();
  MachineDetails _MachineDetails = new MachineDetails();
  Machine _machineModel = new Machine();
  dynamic sensorData = null;
  dynamic machineDate = null;
  List<MachineDetails> _machineDetails = [];
  List<MachineDetails> _options = [];
  ProductionDetails? _productionCal;
  List<MachineDetails> _filteredOptions = [];
  TextEditingController _searchController = TextEditingController();
  late String ipAddress = "";
  late String mcNo = "";
  bool wifi = false;
  TextEditingController ipAddressController = TextEditingController();
  TextEditingController mcController = TextEditingController();
  String _searchQuery = '';
  int _counter = 0;
  Timer? _timerCounter;
  bool Started = false;
  bool Jog = false;
  late Timer _timerP;
  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    super.initState();
    _timerCounter = Timer.periodic(const Duration(seconds: 15), (timer) {
      // _getDataCount();
    });
    Size screenSize = WidgetsBinding.instance.window.physicalSize;
    width = screenSize.width;
    height = screenSize.height;
    getDeviceIp();
    getMachineNo();
    _getProductionDetails();
    _startRepeatedFunctionCall();
  }

  String formatDuration(int minutes) {
    int hours = minutes ~/ 60;
    int remainingMinutes = minutes % 60;
    int seconds = minutes * 60;

    String formattedHours = hours.toString().padLeft(2, '0');
    String formattedMinutes = remainingMinutes.toString().padLeft(2, '0');
    String formattedSeconds = (seconds % 60).toString().padLeft(2, '0');

    return '$formattedHours:$formattedMinutes:$formattedSeconds';
  }

  void _getMachineStop() async {
    HttpService().stopMachine().then((value) {});
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
            MachineData.setIP(ipAddressController.text);
          }
        }
      }
      print('Device IP address not found.');
    } catch (e) {
      print('Error getting IP address: $e');
    }
  }

  void _getProductionDetails() async {
    List<ProductionDetails> productionCal =
        await HttpService().getRealtProductionDetails();
    if (productionCal.isNotEmpty) {
      setState(() {
        _productionCal = productionCal.first;
        mList = productionCal;
        // if (mList[0].allocQty == mList[0].producedQty) {
        //   _getMachineStop();
        // }

        for (final i in mList) {
          var productMap = {
            'domain': i.vcJobNo,
            'measure': i.producedQty,
          };
          var productMapDonat = {
            'Production': ((i.producedQty! * 100) / i.allocQty!),
            'Damage': ((i.totalDamages! * 100) / i.allocQty!),
            'Remaining': 100 -
                (((i.producedQty! * 100) / i.allocQty!) +
                    ((i.totalDamages! * 100) / i.allocQty!))
          };

          productgyp.add(productMap);
          productDonat.add(productMapDonat);
          productgyp.sort((a, b) => a['measure'].compareTo(b['measure']));
          maxValueProduction = productgyp.last['measure'];
        }
      });
    }
  }

  void _startRepeatedFunctionCall() {
    _timerP = Timer.periodic(const Duration(minutes: 1), (timer) {
      _getProductionDetails();
    });
  }

  void startTimer() {
    _timer1 = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _start = _start + 1;
          int hours = _start ~/ 3600;
          int minutes = (_start % 3600) ~/ 60;
          int seconds = _start % 60;
          _timeString =
              '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        });
        _controller.forward();
      } else {
        stopTimer(); // Cancel the timer if the widget is no longer in the tree
      }
    });
  }

  void stopTimer() {
    _timer1?.cancel();
    _controller.stop();
    if (mounted) {
      setState(() {
        _start = 0;
        _timeString = '00:00:00';
      });
    }
  }

  void _getDataCount() async {
    _sensorModel = (await HttpService().getSensorData());

    setState(() {
      sensorData = _sensorModel;
    });
    //Future.delayed(const Duration(seconds: 1)).then((value) => setState(() {}));
  }

  void _getMachineDetails() async {
    _machineDetails = (await HttpService().getProductionMachine());
    setState(() {
      _filteredOptions = _machineDetails;
    });
    //Future.delayed(const Duration(seconds: 1)).then((value) => setState(() {}));
  }

  void _getMachineStart() async {
    Status = (await HttpService().startMachine());
    setState(() {
      //machineDate = _machineModel;
    });
    //Future.delayed(const Duration(seconds: 1)).then((value) => setState(() {}));
  }

  void _getMachineJogStart() async {
    Status = (await HttpService().startJog());
    setState(() {
      //machineDate = _machineModel;
    });
    //Future.delayed(const Duration(seconds: 1)).then((value) => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _timerCounter?.cancel();
    _timer1?.cancel();
    _timerP?.cancel();
    super.dispose();
  }

  // void _getData() async {
  //   HttpService().getRealtProductionDetails().then((value) {
  //     setState(() {
  //       mList = value;

  //       for (final i in mList) {
  //         var productMap = {
  //           'domain': i.vcJobNo,
  //           'measure': i.producedQty,
  //         };
  //         var productMapDonat = {
  //           'Production': ((i.producedQty! * 100) / i.allocQty!),
  //           'Damage': ((i.totalDamages! * 100) / i.allocQty!),
  //           'Remaining': 100 -
  //               (((i.producedQty! * 100) / i.allocQty!) +
  //                   ((i.totalDamages! * 100) / i.allocQty!))
  //         };

  //         productgyp.add(productMap);
  //         productDonat.add(productMapDonat);
  //         productgyp.sort((a, b) => a['measure'].compareTo(b['measure']));
  //         maxValueProduction = productgyp.last['measure'];
  //       }
  //     });
  //   });
  // }

  Map<String, double> dataMap = {"Production": 0, "Damage": 0, "Pending": 0};
  @override
  Widget build(BuildContext context) {
    //Timer.periodic(Duration(), (_) => _getDataCount());
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.blue],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: 20),
              height: height / 1.3,
              width: width / 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [MyTheme.white, MyTheme.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50)),
              ),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                      height: height / 3.5,
                      width: width / 1,
                      child: Row(
                        children: [
                          Expanded(
                            child: PieChart(
                              dataMap: productDonat.isNotEmpty
                                  ? productDonat[_currentItem]
                                  : dataMap,
                              animationDuration:
                                  const Duration(milliseconds: 800),
                              chartLegendSpacing: 25,
                              chartRadius: height / 1,
                              initialAngleInDegree: 0,
                              colorList: const [
                                Colors.blue,
                                Colors.red,
                                Colors.orange
                              ],
                              chartType: ChartType.ring,
                              ringStrokeWidth: 32,
                              centerText: "Status",
                              legendOptions: const LegendOptions(
                                showLegendsInRow: false,
                                legendPosition: LegendPosition.right,
                                showLegends: true,
                                legendShape: BoxShape.circle,
                                legendTextStyle:
                                    TextStyle(fontWeight: FontWeight.bold),
                              ),
                              chartValuesOptions: const ChartValuesOptions(
                                showChartValueBackground: true,
                                showChartValues: true,
                                showChartValuesInPercentage: false,
                                showChartValuesOutside: false,
                                decimalPlaces: 1,
                              ),
                            ),
                          ),
                          Expanded(
                            child: DChartBar(
                              data: [
                                {'id': 'Bar', 'data': productgyp}
                              ],
                              yAxisTitle: 'Job',
                              xAxisTitle: 'Production',
                              measureMin: 100,
                              measureMax: maxValueProduction.round() + 1000,
                              minimumPaddingBetweenLabel: 1,
                              domainLabelPaddingToAxisLine: 5,
                              animate: false,
                              measureAxisTitleFontSize: 11,
                              measureLabelFontSize: 11,
                              domainAxisTitleFontSize: 11,
                              domainLabelFontSize: 11,
                              axisLineTick: 2,
                              axisLinePointTick: 2,
                              axisLinePointWidth: 10,
                              axisLineColor: Colors.green,
                              measureLabelPaddingToAxisLine: 11,
                              verticalDirection: false,
                              barValueFontSize: 11,
                              barColor: (barData, index, id) =>
                                  barData['measure'] >=
                                          maxValueProduction.round()
                                      ? Colors.red.shade900
                                      : Colors.blue.shade700,
                              barValue: (barData, index) =>
                                  '${barData['measure']} Y',
                              showBarValue: true,
                              barValuePosition: BarValuePosition.outside,
                            ),
                          ),
                        ],
                      )),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: PageView.builder(
                        itemCount: mList.length,
                        scrollDirection: Axis.horizontal,
                        physics: const PageScrollPhysics(),
                        itemBuilder: ((context, index) {
                          ProductionDetails productStatusList = mList[index];
                          return VisibilityDetector(
                              key: Key(index.toString()),
                              onVisibilityChanged: (VisibilityInfo info) {
                                if (info.visibleFraction == 1) {
                                  setState(() {
                                    _currentItem = index;
                                    print(_currentItem);
                                  });
                                }
                              },
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Container(
                                      padding: const EdgeInsets.only(top: 10),
                                      height: height / 2.2 - 30,
                                      width: width / 1,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color.fromRGBO(25, 118, 210, 1),
                                            Color.fromRGBO(107, 176, 245, 1)
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(50),
                                            topRight: Radius.circular(50)),
                                      ),
                                      child: Stack(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5, top: 5),
                                                      child: CircleAvatar(
                                                        backgroundColor:
                                                            Colors.cyan[200],
                                                        radius: 25,
                                                        child: const Icon(
                                                          CupertinoIcons
                                                              .briefcase,
                                                          size: 25,
                                                          color: Colors.black,
                                                        ),
                                                      )),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 5, top: 5),
                                                    child: Text(
                                                      _productionCal != null
                                                          ? productStatusList!
                                                              .vcJobNo
                                                              .toString()
                                                          : "Loading...",
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontSize: 25,
                                                          fontFamily:
                                                              'Sans Serif'),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5, top: 5),
                                                      child: CircleAvatar(
                                                        backgroundColor:
                                                            Colors.orange[200],
                                                        radius: 25,
                                                        child: Icon(
                                                          CupertinoIcons
                                                              .speedometer,
                                                          size: 25,
                                                          color: Colors
                                                              .orange[700],
                                                        ),
                                                      )),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 5, top: 5),
                                                    child: Text(
                                                      productStatusList != null
                                                          ? productStatusList!
                                                              .started
                                                              .toString()!
                                                          : "Loading...",
                                                      style: const TextStyle(
                                                          color:
                                                              Colors.cyanAccent,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontSize: 25,
                                                          fontFamily:
                                                              'Sans Serif'),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Container(
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 5,
                                                                top: 5),
                                                        child: CircleAvatar(
                                                          backgroundColor:
                                                              Colors.lime[300],
                                                          radius: 25,
                                                          child: Icon(
                                                            CupertinoIcons
                                                                .cube_box_fill,
                                                            size: 25,
                                                            color: Colors
                                                                .lime[900],
                                                          ),
                                                        )),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5, top: 5),
                                                      child: Text(
                                                        productStatusList !=
                                                                null
                                                            ? '${productStatusList!.productionKG.toString()} KG'
                                                            : "Loading...",
                                                        style: TextStyle(
                                                            color: Colors
                                                                .amber[200],
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            fontSize: 25,
                                                            fontFamily:
                                                                'Sans Serif'),
                                                        textAlign:
                                                            TextAlign.end,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      )),
                                ),
                              ));
                        })),
                  )
                ],
              ),
            )
          ]),
    );
  }

  Widget _buildBody() {
    if (_machineDetails.isEmpty) {
      return const Center(
        child: Text('No options found'),
      );
    }
    return DropdownButtonFormField<MachineDetails>(
        items: _filteredOptions.map((option) {
          return DropdownMenuItem<MachineDetails>(
            value: option,
            child: Text(option.vcMCCode.toString()),
          );
        }).toList(),
        onChanged: (machine) {
          updateMachineData(machine!.vcMCCode.toString());
        },
        decoration: const InputDecoration(
          labelText: 'Machine No',
          border: InputBorder.none,
        ));
  }

  Future<void> updateMachineData(String machineName) async {
    await MachineData.setName(machineName);
    _getProductionDetails();
  }
}

class _SearchDelegate extends SearchDelegate<String> {
  final String _searchQuery;
  final Function(String) _onFilter;

  _SearchDelegate(this._searchQuery, this._onFilter);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    _onFilter(query);
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _onFilter(query);
    return Container();
  }
}
