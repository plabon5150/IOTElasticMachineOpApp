import 'dart:async';
import 'dart:ui';
import 'package:card_slider/card_slider.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flip_card/flip_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:machineautomation/Models/JobModel.dart';
import 'package:machineautomation/Models/ProductionData.dart';
import 'package:machineautomation/Models/QcTaskDetail.dart';
import 'package:machineautomation/Screens/HomeScreen.dart';
import 'package:machineautomation/Services/HttpService.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:virtual_keyboard_multi_language/virtual_keyboard_multi_language.dart';
import '../Constants/MachineDate.dart';
import '../Models/Interruption.dart';
import '../Models/InteruptionRecord.dart';
import '../Models/MachineStatusModel.dart';
import '../Models/ProductionMachineStatus.dart';
import '../Models/QCCard.dart';
import '../Models/QcDetails.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  final _navigatorKey = GlobalKey<NavigatorState>();
  NavigatorState get _navigator => _navigatorKey.currentState!;
  AnimationController? _animationController;
  AnimationController? _animationControllerQc;
  Animation<double>? _fillAnimation;
  Animation<double>? _fillAnimationQc;
  int count = 0;
  int countQc = 0;
  bool tpS = false;
  bool wyarn = false;
  bool desgin = false;
  bool ospeed = false;
  bool qcPeriod = false;
  bool damage = false;
  bool isPlaying = false;
  int activeStep = 0;
  int activeStep2 = 0;
  int reachedStep = 0;
  int upperBound = 5;
  int statusButton = 1;
  int oparationStep = 0;
  bool machineStatusSave = false;
  bool interupptionRecordLoad = false;
  String text = "STATUS UPDATE";
  String inTupText = "INTERRUPTION UPDATE";
  String remarks = "";
  String QcRemarkstext = "";
  double QtyM = 0.00;
  double WPM = 0.00;
  int noOfTape = 0;
  double mSpeed = 0.00;
  double produceQty = 0.00;
  bool isInterrption = true;
  bool isStatusEnabled = true;
  bool loadingDate = false;
  String selectedValue = "";
  String planningJobs = "";
  Interruption? selectedInterruption;
  List<Interruption> _interruptionDetails = [];
  List<ProductionMachineStatus> _machineStatus = [];
  List<ProductionMachineStatus> _machineProceessStatus = [];
  QcDetails? _qcDetails;
  List<QCCard>? _qcCardDetails;
  QcDetails? _opDetails;
  MachineStatusModel? _selectedMachineStatus;
  List<MachineStatusModel> _machineStatusDetails = [];
  List<InteruptionRecord> _interruptionRecord = [];
  List<JobModel> listJobs = [];
  List<DataRow> dataTableRows = [];
  List<ProductionMachineStatus> selectedJobs = [];
  String jobNo = "";
  Set<int> selectedRecordIds = {};
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _textEditingControllerQc =
      TextEditingController();
  final TextEditingController _produceQtyController = TextEditingController();
  final SearchController _filter = SearchController();
  final TextEditingController _textEditingControllerNoOfTape =
      TextEditingController();
  final TextEditingController _textEditingTime = TextEditingController();
  final CountDownController _controllerTimer = CountDownController();
  final CountDownController _controllerTimerQc = CountDownController();
  int _secondsRemaining = 0;
  int _secondsRemainingQc = 0;
  late Timer _timer;
  late Timer _timerQc;
  late Timer _timeDetailsGet;
  late Timer? _timerDec;
  String selectedJobNo = "";
  List<String?> jobNos = [];
  List<Color> valuesDataColors = [
    Colors.purple,
    Colors.green,
    Colors.orange,
    Colors.yellow,
    Colors.pink,
    Colors.red,
    Colors.cyan
  ];

  @override
  void initState() {
    super.initState();

    _resetTimer();
    HttpService().getProductionJobs().then((value) {
      setState(() {
        listJobs = value;
        print(listJobs);
      });
    });
    setState(() {
      loadingDate = true;
    });
    _getInterrutionDetails();
    _handleGetProcessWiseStatus();
    _startRepeatedFunctionCall();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    );
    _animationControllerQc = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    );
    _fillAnimation = _animationController!.drive(
      Tween<double>(
        begin: 0.0,
        end: 1.0,
      ),
    );
    _fillAnimationQc = _animationControllerQc!.drive(
      Tween<double>(
        begin: 0.0,
        end: 1.0,
      ),
    );
    _animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {
          _animationController!.reset();
        });
      }
    });
    _animationControllerQc!.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {
          _animationControllerQc!.reset();
        });
      }
    });
  }

  void _onKeyPressed(VirtualKeyboardKey key) {
    setState(() {
      mSpeed = double.parse(_textEditingController.text);
    });
  }

  void _onKeyPressedPlan(VirtualKeyboardKey key) {
    setState(() {
      produceQty = double.parse(_produceQtyController.text);
    });
  }

  void addDataToTable(String jobNo, double QtyM, double WPM, int noOfTape,
      double mSpeed, int rowIndex) {
    // Check if jobNo already exists in the table
    bool jobNoExists = dataTableRows.any((dataRow) =>
        dataRow.cells.isNotEmpty &&
        dataRow.cells[0].child is Text &&
        (dataRow.cells[0].child as Text).data == jobNo);

    if (jobNoExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('JobNo $jobNo already Entered.'),
        ),
      );
    } else {
      // JobNo doesn't exist, so add a new row
      DataRow newRow = DataRow(cells: [
        DataCell(Text(jobNo)),
        DataCell(Text(QtyM.toString())),
        DataCell(Text(WPM.toString())),
        DataCell(Text(noOfTape.toString())),
        DataCell(Text(mSpeed.toString())),
        DataCell(
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // Call a method to delete the row
              deleteRow(rowIndex);
            },
          ),
        ),
      ]);
      dataTableRows.add(newRow);

      // Clear the values
      QtyM = 0.00;
      WPM = 0.00;
      noOfTape = 0;
      mSpeed = 0.00;
      setState(() {});
    }
  }

  void _startTimer(int seconds, context) {
    HttpService().startMachine().then((value) {});
    _secondsRemaining = seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
        Navigator.of(context).pop();
        _oparatorDetails();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  void _startTimerQc(int seconds, context) {
    HttpService().startMachine().then((value) {});
    _secondsRemainingQc = seconds;
    _timerQc = Timer.periodic(const Duration(seconds: 1), (timerQC) {
      if (_secondsRemainingQc == 0) {
        timerQC.cancel();
        Navigator.of(context).pop();
        _QcDetails();
      } else {
        setState(() {
          _secondsRemainingQc--;
        });
      }
    });
  }

  void _onKeyPressedTimer(VirtualKeyboardKey key) {
    setState(() {
      _secondsRemaining = int.parse(_textEditingTime.text);
    });
  }

  void _onKeyPressedQc(VirtualKeyboardKey key) {
    setState(() {
      QtyM = double.parse(_textEditingController.text);
      WPM = double.parse(_textEditingControllerQc.text);
      noOfTape = int.parse(_textEditingControllerNoOfTape.text);
    });
  }

  void _saveMachinePlan() {
    if (selectedJobs.isNotEmpty && produceQty != 0.00) {
      HttpService().saveMachineJobPlan(selectedJobs).then((value) {
        setState(() {
          _machineStatus = value;
          saveProcessID(_machineStatus[0].processID);
          _handleGetProcessWiseStatus();
        });
      });
    }
  }

  void _startRepeatedFunctionCall() {
    _timeDetailsGet = Timer.periodic(const Duration(seconds: 25), (timer) {
      _handleGetProcessWiseStatus(); // Call your function here
    });
  }

  void _setMachineSpeedBoot(double speed) async {
    await HttpService().setMachineSpeed(speed * 10).then((value) async {
      await HttpService().setMachineSpeed(speed * 10).then((value) async {});
    });
  }

  void _showCountdownPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: const Text('Machine Running time'),
          content: Center(
            child: CircularCountDownTimer(
              duration: _secondsRemaining * 60,
              initialDuration: 0,
              controller: _controllerTimer,
              width: MediaQuery.of(context).size.width / 2.5,
              height: MediaQuery.of(context).size.height / 2.5,
              ringColor: Colors.grey[300]!,
              ringGradient: null,
              fillColor: Colors.purpleAccent[100]!,
              fillGradient: null,
              backgroundColor: Colors.purple[500],
              backgroundGradient: null,
              strokeWidth: 20.0,
              strokeCap: StrokeCap.round,
              textStyle: const TextStyle(
                  fontSize: 40.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
              textFormat: CountdownTextFormat.S,
              isReverse: false,
              isReverseAnimation: false,
              isTimerTextShown: true,
              autoStart: false,
            ),
          ),
          actions: [
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        30), // Adjust the radius as needed
                  ),
                ),
              ),
              child: const Text("Run",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24, // Adjust the font size as needed
                    fontWeight: FontWeight.bold,
                  )),
              onPressed: () {
                _controllerTimer.start();
                _startTimer(_secondsRemaining * 60, context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showCountdownPopupQc(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: const Text('Machine Running time'),
          content: Center(
            child: CircularCountDownTimer(
              duration: 60,
              initialDuration: 0,
              controller: _controllerTimerQc,
              width: MediaQuery.of(context).size.width / 2.5,
              height: MediaQuery.of(context).size.height / 2.5,
              ringColor: Colors.grey[300]!,
              ringGradient: null,
              fillColor: Colors.purpleAccent[100]!,
              fillGradient: null,
              backgroundColor: Colors.purple[500],
              backgroundGradient: null,
              strokeWidth: 20.0,
              strokeCap: StrokeCap.round,
              textStyle: const TextStyle(
                  fontSize: 40.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
              textFormat: CountdownTextFormat.S,
              isReverse: false,
              isReverseAnimation: false,
              isTimerTextShown: true,
              autoStart: false,
            ),
          ),
          actions: [
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        30), // Adjust the radius as needed
                  ),
                ),
              ),
              child: const Text("Run",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24, // Adjust the font size as needed
                    fontWeight: FontWeight.bold,
                  )),
              onPressed: () {
                _controllerTimerQc.start();
                _startTimerQc(60, context);
              },
            ),
          ],
        );
      },
    );
  }

  void _handleQcPeriodTest() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text("Qc Record"),
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Container(
                  width: 350,
                  height: 250,
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          "QC PERIODIC CHECK",
                          style: TextStyle(
                              color: Colors.cyanAccent[900],
                              fontFamily: 'Pacifico',
                              fontSize: 35,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: damage,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      damage = value!;
                                    });
                                  },
                                ),
                                const SizedBox(
                                    width:
                                        8.0), // Adjust the spacing between checkbox and text
                                Flexible(
                                  child: Text(
                                    'DAMAGE',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.red[900],
                                        fontWeight: FontWeight.bold,
                                        decoration: tpS
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  value: damage,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      damage = value!;
                                    });
                                  },
                                ),
                                const SizedBox(
                                    width:
                                        8.0), // Adjust the spacing between checkbox and text
                                Flexible(
                                  child: Text(
                                    'OUTPUT',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.orange[900],
                                        fontWeight: FontWeight.bold,
                                        decoration: tpS
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              child: TextField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(25.7),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(25.7),
                                  ),
                                  labelText: 'Remarks',

                                  labelStyle:
                                      const TextStyle(color: Colors.pink),
                                  fillColor:
                                      Colors.grey[300], // Set background color
                                  filled: true,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  )),
                );
              }));
        });
  }

  void _handleUpdateTaskOparator() {
    HttpService()
        .updateOperatorTaskDetails(
            tpS,
            wyarn,
            desgin,
            ospeed,
            remarks,
            int.parse(_textEditingTime.text.toString()) * 60,
            double.parse(_textEditingController.text.toString()))
        .then((returnValue) {
      MotionToast.success(
        title: const Text("Update sucessfully"),
        description: const Text("Oparator data recorded"),
      ).show(context);
      setState(() {});
    }).catchError((error) {
      // Handle any errors that occur during the API call
      print(error);
    });
  }

  void _handleQcTaskOparator() async {
    List<QcTaskDetail> taskDetails = [];

    for (DataRow row in dataTableRows) {
      String jobNo = row.cells[0].child
          .toString()
          .substring(6, row.cells[0].child.toString().length - 2);
      double qtyM = double.parse(row.cells[1].child
          .toString()
          .substring(6, row.cells[1].child.toString().length - 2));
      double wPM = double.parse(row.cells[2].child
          .toString()
          .substring(6, row.cells[2].child.toString().length - 2));
      int noOfTape = int.parse(row.cells[3].child
          .toString()
          .substring(6, row.cells[3].child.toString().length - 2));
      double mSpeed = double.parse(row.cells[4].child
          .toString()
          .substring(6, row.cells[4].child.toString().length - 2));
      String user = await MachineData.getUserID();
      int id = await MachineData.getProcessID();
      String name = await MachineData.getName();
      // Create a QcTaskDetail object and add it to the list
      taskDetails.add(QcTaskDetail(
          jobNo: jobNo,
          qtym: qtyM,
          wPM: wPM,
          noOfTape: noOfTape,
          mSpeed: mSpeed,
          enterBy: int.parse(user),
          processID: id,
          mcNo: name));
    }
    HttpService().updateQcTaskDetails(taskDetails).then((returnValue) {
      MotionToast.success(
        title: const Text("Update sucessfully"),
        description: const Text("Qc data recorded"),
      ).show(context);
      setState(() {
        taskDetails.clear();
      });
    }).catchError((error) {
      // Handle any errors that occur during the API call
      print(error);
    });
  }

  void saveProcessID(dynamic processID) async {
    await MachineData.setProcessID(processID);
  }

  void _handleGetInterruptionRecord() async {
    await HttpService().getInterruptionRecord().then((value) {
      setState(() {
        _interruptionRecord = value;
        List<Map<String, dynamic>> selectedRecords = [];
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Interruption Record"),
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return DataTable(
                    columnSpacing: 8.0,
                    border: TableBorder.all(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.amber,
                      style: BorderStyle.solid,
                    ),
                    headingRowColor:
                        MaterialStateColor.resolveWith((states) => Colors.blue),
                    headingTextStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    columns: const [
                      DataColumn(label: Text('Record')),
                      DataColumn(label: Text('Issued On')),
                      DataColumn(label: Text('Issued By')),
                      DataColumn(label: Text('Interruption')),
                      DataColumn(label: Text('E ID')),
                    ],
                    rows: _interruptionRecord.map((record) {
                      bool isSelected = selectedRecords.any(
                        (selectedRecord) =>
                            selectedRecord['recordID'] == record.recordID,
                      );
                      return DataRow(
                        selected: isSelected,
                        onSelectChanged: (value) {
                          setState(() {
                            if (value != null && value) {
                              selectedRecords.add({
                                'recordID': record.recordID!,
                                'intinterruptionID': record.intinterruptionID,
                              });
                            } else {
                              selectedRecords.removeWhere((selectedRecord) =>
                                  selectedRecord['recordID'] ==
                                  record.recordID);
                            }
                          });
                        },
                        cells: [
                          DataCell(Text(record.recordID.toString())),
                          DataCell(Text(record.issuedOn!)),
                          DataCell(Text(record.checkedBy!.trim())),
                          DataCell(Text(record.interruptionTypeDetails!)),
                          DataCell(Text(record.intinterruptionID.toString())),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
              actions: [
                TextButton(
                  style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.blue)),
                  child: const Text("Reporting",
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    for (Map<String, dynamic> selectedRecord
                        in selectedRecords) {
                      int recordID = selectedRecord['recordID'];
                      int intinterruptionID =
                          selectedRecord['intinterruptionID'];

                      _handleSubmitIntupption(recordID, intinterruptionID, () {
                        _handleGetProcessWiseStatus();
                        Navigator.of(context).pop(); // Close the AlertDialog
                      });
                      print(
                          'Selected Record ID: $recordID, Interruption ID: $intinterruptionID');
                    }
                  },
                ),
              ],
            );
          },
        );
      });
    });
  }

  void deleteRow(int rowIndex) {
    setState(() {
      dataTableRows.removeAt(rowIndex);
    });
  }

  void _handleGetJobRecord() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Qc Details Record"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DataTable(
                columnSpacing: 8.0,
                border: TableBorder.all(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.amber,
                  style: BorderStyle.solid,
                ),
                headingRowColor:
                    MaterialStateColor.resolveWith((states) => Colors.blue),
                headingTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                columns: const [
                  DataColumn(label: Text('Job No')),
                  DataColumn(label: Text('WPM(1 Min)')),
                  DataColumn(label: Text('WPM(1 Mtr)')),
                  DataColumn(label: Text('Tape No')),
                  DataColumn(label: Text('Frequency')),
                  DataColumn(label: Text('Delete')),
                ],
                rows: dataTableRows,
              );
            },
          ),
          actions: [],
        );
      },
    );
  }

  void _handleSubmitInterruption(int interrptionID) async {
    await HttpService().saveInterruptionStatus(1, interrptionID).then((value) {
      setState(() {
        _machineStatus = value;
        saveProcessID(_machineStatus[0].processID);
        _handleGetProcessWiseStatus();
      });
    });
  }

  void _handleSubmitStatus() async {
    if (_machineProceessStatus.length != 0) {
      String jobs = selectedJobs.join(', ');
      await HttpService().saveMachineStatus(2, jobs, produceQty).then((value) {
        setState(() {
          _machineStatus = value;
          saveProcessID(_machineStatus[0].processID);
          _handleGetProcessWiseStatus();
          _getMachineStop();
        });
      });
    } else {
      int status = await MachineData.getStatusID();
      String jobs = selectedJobs.join(', ');
      if (status == 2) {
        _handleJobPlan();
      } else {
        if (status == 4 || status == 10) {
          HttpService().startMachine().then((value) {});
        } else {
          _getMachineStop();
        }
        await HttpService()
            .saveMachineStatus(1, jobs, produceQty)
            .then((value) {
          setState(() {
            _machineStatus = value;
            saveProcessID(_machineStatus[0].processID);
            _handleGetProcessWiseStatus();
          });
        });
      }
    }
  }

  void _handleGetProcessWiseStatus() async {
    try {
      List<ProductionMachineStatus> value =
          await HttpService().getProcessWiseMachineStatus();

      setState(() {
        if (value.isNotEmpty) {
          _machineProceessStatus = value;
          MachineData.setStatusID(_machineProceessStatus[0].statusID);
          // if (_machineProceessStatus[0].statusID == 5 ||
          //     _machineProceessStatus[0].statusID == 7 ||
          //     _machineProceessStatus[0].statusID == 8) {
          //   HttpService().heatoffMachine().then((value) {});
          // }
          // if (_machineProceessStatus[0].statusID == 4 ||
          //     _machineProceessStatus[0].statusID == 10) {
          //   HttpService().heatonMachine().then((value) {});
          // }
        } else {
          _machineProceessStatus = [];
        }
      });
      _getMcStatus();
    } catch (e) {
      print('Error in _handleGetProcessWiseStatus: $e');
    }
  }

  void _handleSubmitIntupption(
      int recordID, int interruptionID, void Function() closeDialog) {
    HttpService()
        .updateInterruptionRecord(recordID, interruptionID)
        .then((returnValue) {
      _handleGetInterruptionRecord();
      closeDialog(); // Call the closeDialog callback to close the AlertDialog
    }).catchError((error) {
      // Handle any errors that occur during the API call
      print(error);
    });
  }

  void _getInterrutionDetails() async {
    List<Interruption> interruptionDetails =
        await HttpService().getInterruption();
    setState(() {
      _interruptionDetails = interruptionDetails;
      if (_interruptionDetails.isNotEmpty) {
        selectedInterruption = _interruptionDetails.first;
      }
      _getQcDetails();
    });
  }

  void _getQcDetails() async {
    List<QcDetails> qctionDetails = await HttpService().getQcDetails();
    if (qctionDetails.isNotEmpty) {
      setState(() {
        _qcDetails = qctionDetails.first;
        _setMachineSpeedBoot(_qcDetails!.qMSpeed!);
        _getOPDetails();
      });
    } else {
      _getOPDetails();
    }
  }

  void _getMcStatus() async {
    List<MachineStatusModel> machineStatusDetails =
        await HttpService().getMachineStatusDetails();
    setState(() {
      _machineStatusDetails = machineStatusDetails;
      _selectedMachineStatus = _machineStatusDetails.first;
      loadingDate = false;
      _getQcCardDetails();
    });
  }

  void _getQcCardDetails() async {
    setState(() {
      loadingDate = true;
    });
    List<QCCard> qcCardDetails1 = await HttpService().getQcCardDetails();
    setState(() {
      _qcCardDetails = qcCardDetails1;
      jobNos = _qcCardDetails!
          .map((job) => job.jobNo)
          .where((jobNo) => jobNo != null) // Filter out null values
          .map((jobNo) => jobNo!) // Unwrap non-null values
          .toSet() // Convert to a Set to remove duplicates
          .toList();
      loadingDate = false;
    });
  }

  void _getOPDetails() async {
    List<QcDetails> opDetails = await HttpService().getOparatorDetails();
    if (opDetails.isNotEmpty) {
      setState(() {
        _opDetails = opDetails.first;
      });
    }
    _getMcStatus();
  }

  void _handleJobPlan() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Produce Plan"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                width: 350,
                height: 350,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 350,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: selectedJobs.map((job) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width:
                                        150, // Set a fixed width for each item.
                                    child: Text(job.jobNo.toString(),
                                        style: const TextStyle(fontSize: 14)),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.cancel),
                                    onPressed: () {
                                      setState(() {
                                        selectedJobs.remove(job);
                                      });
                                    },
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      DropdownSearch<String>(
                        popupProps: PopupProps.dialog(
                            showSelectedItems: true,
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                                controller: _filter,
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) => VirtualKeyboard(
                                      type: VirtualKeyboardType.Numeric,
                                      textController: _filter,
                                      onKeyPress: _onKeyPressed,
                                    ),
                                  );
                                })),
                        items: listJobs.map((item) => item.vcJobNo).toList(),
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            labelText: "Job No",
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            planningJobs = value!;
                            //selectedJobs.add(value!);
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelText: 'Produce Quantity (Yds)',
                        ),
                        controller: _produceQtyController,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => VirtualKeyboard(
                              type: VirtualKeyboardType.Numeric,
                              textController: _produceQtyController,
                              onKeyPress: _onKeyPressedPlan,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.orange),
                              padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 24),
                              ),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      30), // Adjust the radius as needed
                                ),
                              ),
                            ),
                            child: const Text(
                              "Add",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24, // Adjust the font size as needed
                                fontWeight: FontWeight.bold, // Optional
                              ),
                            ),
                            onPressed: () async {
                              String user = await MachineData.getUserID();
                              String name = await MachineData.getName();
                              ProductionMachineStatus jobData =
                                  ProductionMachineStatus(
                                      jobNo: planningJobs,
                                      produceQty: produceQty,
                                      statusID: 2,
                                      onClickStatus: 1,
                                      userID: int.parse(user),
                                      mcNo: name);
                              selectedJobs.add(jobData);
                              _produceQtyController.clear();
                              Navigator.of(context).pop();
                              _handleJobPlan();
                            },
                          ),
                          TextButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.blue),
                              padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 24),
                              ),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      30), // Adjust the radius as needed
                                ),
                              ),
                            ),
                            child: const Text(
                              "Save",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24, // Adjust the font size as needed
                                fontWeight: FontWeight.bold, // Optional
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _saveMachinePlan();
                            },
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _handleButtonClick() {
    _textEditingController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                width: 350,
                height: 250,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          "SPEED SET",
                          style: TextStyle(
                            color: Colors.orange,
                            fontFamily: 'Pacifico',
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(25.7),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(25.7),
                          ),
                          labelText: 'Speed ',
                          labelStyle: const TextStyle(color: Colors.pinkAccent),
                          fillColor: Colors.grey[300],
                          filled: true,
                        ),
                        controller: _textEditingController,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => VirtualKeyboard(
                              type: VirtualKeyboardType.Numeric,
                              textController: _textEditingController,
                              onKeyPress: _onKeyPressed,
                            ),
                          );
                        },
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(25.7),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(25.7),
                              ),
                              labelText: 'Timer(Sec) ',
                              labelStyle:
                                  const TextStyle(color: Colors.pinkAccent),
                              fillColor: Colors.grey[300],
                              filled: true,
                            ),
                            controller: _textEditingTime,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => VirtualKeyboard(
                                  type: VirtualKeyboardType.Numeric,
                                  textController: _textEditingTime,
                                  onKeyPress: _onKeyPressedTimer,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.blue),
                              padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 24),
                              ),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      30), // Adjust the radius as needed
                                ),
                              ),
                            ),
                            child: const Text(
                              "Start",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24, // Adjust the font size as needed
                                fontWeight: FontWeight.bold, // Optional
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _setMachineSpeed(mSpeed);
                              _showCountdownPopup(context);
                            },
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _handleButtonQc() {
    _textEditingController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                width: 350,
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          "SPEED SET",
                          style: TextStyle(
                            color: Colors.orange,
                            fontFamily: 'Pacifico',
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(25.7),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(25.7),
                          ),
                          labelText: 'Speed ',
                          labelStyle: const TextStyle(color: Colors.pinkAccent),
                          fillColor: Colors.grey[300],
                          filled: true,
                        ),
                        controller: _textEditingController,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => VirtualKeyboard(
                              type: VirtualKeyboardType.Numeric,
                              textController: _textEditingController,
                              onKeyPress: _onKeyPressed,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blue),
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 24),
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  30), // Adjust the radius as needed
                            ),
                          ),
                        ),
                        child: const Text(
                          "Start",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24, // Adjust the font size as needed
                            fontWeight: FontWeight.bold, // Optional
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _setMachineSpeed(mSpeed);
                          _showCountdownPopupQc(context);
                        },
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _oparatorDetails() async {
    HttpService().stopMachine().then((value) {});
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                width: 350,
                height: 350,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        "OPARATOR CHECK",
                        style: TextStyle(
                            color: Colors.orange,
                            fontFamily: 'Pacifico',
                            fontSize: 35,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: tpS,
                              onChanged: (bool? value) {
                                setState(() {
                                  tpS = value!;
                                });
                              },
                            ),
                            Flexible(
                              child: Text(
                                'TAPE SETTING',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.lightGreen[800],
                                    fontWeight: FontWeight.bold,
                                    decoration: tpS
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: wyarn,
                              onChanged: (bool? value) {
                                setState(() {
                                  wyarn = value!;
                                });
                              },
                            ),
                            Flexible(
                              child: Text(
                                'WRAP & WEFT YARN',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.purpleAccent[700],
                                    fontWeight: FontWeight.bold,
                                    decoration: wyarn
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: desgin,
                              onChanged: (bool? value) {
                                setState(() {
                                  desgin = value!;
                                });
                              },
                            ),
                            Flexible(
                              child: Text(
                                'DESIGN AND SIZE',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.indigoAccent[700],
                                    fontWeight: FontWeight.bold,
                                    decoration: desgin
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: ospeed,
                              onChanged: (bool? value) {
                                setState(() {
                                  ospeed = value!;
                                });
                              },
                            ),
                            Flexible(
                              child: Text(
                                'OUTPUT SPEED',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.cyan[700],
                                    fontWeight: FontWeight.bold,
                                    decoration: ospeed
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              );
            })),
            actions: [
              SizedBox(
                width: 200,
                height: 50,
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            30), // Adjust the radius as needed
                      ),
                    ),
                  ),
                  child: const Text(
                    "Update",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24, // Adjust the font size as needed
                      fontWeight: FontWeight.bold, // Optional
                    ),
                  ),
                  onPressed: () {
                    _handleUpdateTaskOparator();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          );
        });
  }

  void _QcDetails() async {
    _textEditingController.clear();
    HttpService().stopMachine().then((value) {});
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                width: 350,
                height: 450,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          "QC DETAILS ENTRY",
                          style: TextStyle(
                            color: Colors.orange,
                            fontFamily: 'Pacifico',
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Column(children: [
                        DropdownSearch<String>(
                          popupProps: PopupProps.dialog(
                              showSelectedItems: true,
                              showSearchBox: true,
                              searchFieldProps: TextFieldProps(
                                  controller: _filter,
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) => VirtualKeyboard(
                                        type: VirtualKeyboardType.Numeric,
                                        textController: _filter,
                                        onKeyPress: _onKeyPressed,
                                      ),
                                    );
                                  })),
                          items: _qcCardDetails!
                              .map((item) => item.jobNo.toString())
                              .toList(),
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              labelText: "Job No",
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              jobNo = value!;
                            });
                          },
                        )
                      ]),
                      Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(25.7),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(25.7),
                            ),
                            labelText: 'Meter(60 s)',
                            labelStyle:
                                const TextStyle(color: Colors.pinkAccent),
                            fillColor: Colors.grey[300],
                            filled: true,
                          ),
                          controller: _textEditingController,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => VirtualKeyboard(
                                type: VirtualKeyboardType.Numeric,
                                textController: _textEditingController,
                                onKeyPress: _onKeyPressedQc,
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(25.7),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(25.7),
                            ),
                            labelText: 'Weight(Meter)',
                            labelStyle:
                                const TextStyle(color: Colors.pinkAccent),
                            fillColor: Colors.grey[300],
                            filled: true,
                          ),
                          controller: _textEditingControllerQc,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => VirtualKeyboard(
                                type: VirtualKeyboardType.Numeric,
                                textController: _textEditingControllerQc,
                                onKeyPress: _onKeyPressedQc,
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(25.7),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(25.7),
                            ),
                            labelText: 'No Of Tape',
                            labelStyle:
                                const TextStyle(color: Colors.pinkAccent),
                            fillColor: Colors.grey[300],
                            filled: true,
                          ),
                          controller: _textEditingControllerNoOfTape,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => VirtualKeyboard(
                                type: VirtualKeyboardType.Numeric,
                                textController: _textEditingControllerNoOfTape,
                                onKeyPress: _onKeyPressedQc,
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(25.7),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(25.7),
                            ),
                            labelText: 'Remarks',
                            labelStyle: const TextStyle(color: Colors.pink),
                            fillColor: Colors.grey[300],
                            filled: true,
                          ),
                          onChanged: (value) {
                            QcRemarkstext = value;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.orange),
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        30), // Adjust the radius as needed
                  ),
                ),
              ),
              child: const Text(
                "Details",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24, // Adjust the font size as needed
                  fontWeight: FontWeight.bold, // Optional
                ),
              ),
              onPressed: () {
                _handleGetJobRecord();
              },
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.purple),
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        30), // Adjust the radius as needed
                  ),
                ),
              ),
              child: const Text(
                "Add",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24, // Adjust the font size as needed
                  fontWeight: FontWeight.bold, // Optional
                ),
              ),
              onPressed: () {
                addDataToTable(
                    jobNo, QtyM, WPM, noOfTape, mSpeed, dataTableRows.length);
              },
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        30), // Adjust the radius as needed
                  ),
                ),
              ),
              child: const Text(
                "Save",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24, // Adjust the font size as needed
                  fontWeight: FontWeight.bold, // Optional
                ),
              ),
              onPressed: () {
                _handleQcTaskOparator();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _setMachineSpeed(double speed) async {
    await HttpService().setMachineSpeed(speed * 10).then((value) async {
      await HttpService().setMachineSpeed(speed * 10).then((value) async {});
    });
  }

  void _setMachineSpeedForTest(double speed) async {
    await HttpService().setMachineSpeed(speed * 10).then((value) async {
      _getMachineStartForTest();
    });
  }

  void _getMachineStartForTest() async {
    await HttpService().startMachine().then((value) async {
      setState(() {
        count = 0;
      });
      Future.delayed(const Duration(seconds: 60), () {
        HttpService().stopMachine().then((value) {
          setState(() {
            count = 0;
          });
        });
      });
    });
  }

  void _getMachineStop() async {
    HttpService().stopMachine().then((value) {});
  }

  void _resetTimer() {
    _timerDec = Timer.periodic(const Duration(minutes: 120), (timer) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MyHome()));
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _timerQc.cancel();
    _timerDec?.cancel();
    _timeDetailsGet.cancel();
    _animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> valuesWidget = [];
    if (_qcCardDetails != null) {
      for (int i = 0; i < _qcCardDetails!.length; i++) {
        valuesWidget.add(
          Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: valuesDataColors[i],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 30,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.0, color: Colors.white),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Align(
                              alignment: Alignment.center,
                              child: Text(
                                'REFERENCE :',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'SourceSansPro',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              )),
                        ),
                        Container(
                          width: 150,
                          height: 30,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.0, color: Colors.white),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12)),
                          child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                _qcCardDetails == null
                                    ? ""
                                    : _qcCardDetails![i]
                                        .referenceNo
                                        .toString()
                                        .trim(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'SourceSansPro',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              )),
                        )
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 30,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.0, color: Colors.white),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Align(
                              alignment: Alignment.center,
                              child: Text(
                                'SIZE :',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'SourceSansPro',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              )),
                        ),
                        Container(
                          width: 150,
                          height: 30,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.0, color: Colors.white),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12)),
                          child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                _qcCardDetails == null
                                    ? ""
                                    : _qcCardDetails![i].size.toString().trim(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'SourceSansPro',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              )),
                        )
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 30,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.0, color: Colors.white),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Align(
                              alignment: Alignment.center,
                              child: Text(
                                'STRETCH :',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'SourceSansPro',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              )),
                        ),
                        Container(
                          width: 150,
                          height: 30,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.0, color: Colors.white),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12)),
                          child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                _qcCardDetails == null
                                    ? ""
                                    : _qcCardDetails![i]
                                        .stretchbilty
                                        .toString()
                                        .trim(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'SourceSansPro',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              )),
                        )
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 30,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.0, color: Colors.white),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Wrap Yarn :',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'SourceSansPro',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              )),
                        ),
                        Container(
                          width: 150,
                          height: 30,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.0, color: Colors.white),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12)),
                          child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                _qcCardDetails == null
                                    ? ""
                                    : _qcCardDetails![i]
                                        .sampleDesc
                                        .toString()
                                        .trim(),
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontFamily: 'SourceSansPro',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              )),
                        )
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 30,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.0, color: Colors.white),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Weft Yarn :',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'SourceSansPro',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              )),
                        ),
                        Container(
                          width: 150,
                          height: 30,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.0, color: Colors.white),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12)),
                          child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                _qcCardDetails == null
                                    ? ""
                                    : _qcCardDetails![i]
                                        .sampleDesc
                                        .toString()
                                        .trim(),
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontFamily: 'SourceSansPro',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              )),
                        )
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 30,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.0, color: Colors.white),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Beem :',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'SourceSansPro',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              )),
                        ),
                        Container(
                          width: 150,
                          height: 30,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.0, color: Colors.white),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12)),
                          child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                _qcCardDetails == null
                                    ? ""
                                    : _qcCardDetails![i]
                                        .noofBeam
                                        .toString()
                                        .trim(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'SourceSansPro',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              )),
                        )
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 30,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.0, color: Colors.white),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Align(
                              alignment: Alignment.center,
                              child: Text(
                                'RPM :',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'SourceSansPro',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              )),
                        ),
                        Container(
                          height: 30,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.0, color: Colors.white),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Align(
                              alignment: Alignment.center,
                              child: Text(
                                "",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'SourceSansPro',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              )),
                        ),
                        Container(
                          height: 30,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.0, color: Colors.white),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Align(
                              alignment: Alignment.center,
                              child: Text(
                                'C.P.S :',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'SourceSansPro',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              )),
                        ),
                        Container(
                          height: 30,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.0, color: Colors.white),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Align(
                              alignment: Alignment.center,
                              child: Text(
                                '30',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'SourceSansPro',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              )),
                        )
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 30,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.0, color: Colors.white),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Align(
                              alignment: Alignment.center,
                              child: Text(
                                'OUTPUT :',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'SourceSansPro',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              )),
                        ),
                        Container(
                          height: 30,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.0, color: Colors.white),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12)),
                          child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                _qcCardDetails == null
                                    ? ""
                                    : _qcCardDetails![i]
                                        .outputMH
                                        .toString()
                                        .trim(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'SourceSansPro',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              )),
                        ),
                        Container(
                          height: 30,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.0, color: Colors.white),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Align(
                              alignment: Alignment.center,
                              child: Text(
                                'A  12',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'SourceSansPro',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              )),
                        )
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 30,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.0, color: Colors.white),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Align(
                              alignment: Alignment.center,
                              child: Text(
                                'W.P.M :',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'SourceSansPro',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              )),
                        ),
                        Container(
                          height: 30,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.0, color: Colors.white),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12)),
                          child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                _qcCardDetails == null
                                    ? ""
                                    : _qcCardDetails![i].wPM.toString().trim(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'SourceSansPro',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              )),
                        ),
                        Container(
                          height: 30,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.0, color: Colors.white),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Align(
                              alignment: Alignment.center,
                              child: Text(
                                'B  23.61',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'SourceSansPro',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              )),
                        )
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 30,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.0, color: Colors.white),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Tapes :',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'SourceSansPro',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              )),
                        ),
                        Container(
                          height: 30,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.0, color: Colors.white),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12)),
                          child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                _qcCardDetails == null
                                    ? ""
                                    : _qcCardDetails![i]
                                        .ofTap
                                        .toString()
                                        .trim(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'SourceSansPro',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              )),
                        ),
                        Container(
                          height: 30,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.0, color: Colors.white),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Align(
                              alignment: Alignment.center,
                              child: Text(
                                'A  8',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'SourceSansPro',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              )),
                        )
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 30,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.0, color: Colors.white),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Start:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'SourceSansPro',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              )),
                        ),
                        Container(
                          height: 30,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.0, color: Colors.white),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12)),
                          child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                _qcCardDetails == null
                                    ? ""
                                    : DateFormat('yyyy-MM-dd').format(
                                        DateTime.parse(_qcCardDetails![i]
                                            .startDate
                                            .toString()
                                            .trim())),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'SourceSansPro',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              )),
                        ),
                        Container(
                          height: 30,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.0, color: Colors.white),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Align(
                              alignment: Alignment.center,
                              child: Text(
                                'End:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'SourceSansPro',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              )),
                        ),
                        Container(
                          height: 30,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.0, color: Colors.white),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12)),
                          child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                _qcCardDetails == null
                                    ? ""
                                    : DateFormat('yyyy-MM-dd').format(
                                        DateTime.parse(_qcCardDetails![i]
                                            .endDate
                                            .toString()
                                            .trim())),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'SourceSansPro',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              )),
                        ),
                      ])
                ],
              )),
        );
      }
    }
    return loadingDate
        ? const AlertDialog(
            content:
                Center(child: CircularProgressIndicator(color: Colors.amber)),
          )
        : ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            }),
            child: Center(
                child: GestureDetector(
                    supportedDevices: <PointerDeviceKind>{
                  PointerDeviceKind.touch
                },
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: FlipCard(
                              fill: Fill
                                  .fillBack, // Fill the back side of the card to make in the same size as the front.
                              direction: FlipDirection.HORIZONTAL, // default
                              side: CardSide
                                  .FRONT, // The side to initially display.

                              front: SizedBox(
                                  height: 400,
                                  width: 300,
                                  child: CardSlider(
                                    cards: valuesWidget,
                                    bottomOffset: .0008,
                                    cardHeight: 450,
                                    cardWidth: 300,
                                  )),
                              back: Container(
                                height: 400,
                                width: 300,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xff4caf50),
                                        Color(0xff2196f3)
                                      ],
                                      stops: [0, 1],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    )),
                                child: Center(
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        _machineProceessStatus.isNotEmpty &&
                                                _machineProceessStatus[0]
                                                        .statusID ==
                                                    3
                                            ? GestureDetector(
                                                onTap: _handleButtonClick,
                                                child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5),
                                                      height: 80,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(25.0),
                                                        gradient:
                                                            const LinearGradient(
                                                          colors: [
                                                            Color(0xff00bcd4),
                                                            Color(0xff673ab7)
                                                          ],
                                                          stops: [0, 1],
                                                          begin: Alignment
                                                              .centerRight,
                                                          end: Alignment
                                                              .centerLeft,
                                                        ),
                                                        border: Border.all(
                                                          color: Colors
                                                              .transparent,
                                                          width: 3.0,
                                                        ),
                                                      ),
                                                      child: Stack(
                                                        children: [
                                                          AnimatedBuilder(
                                                            animation:
                                                                _fillAnimation!,
                                                            builder:
                                                                (BuildContext
                                                                        context,
                                                                    Widget?
                                                                        child) {
                                                              final double
                                                                  fillValue =
                                                                  _fillAnimation!
                                                                      .value;

                                                              return ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            25.0), // Match the button container radius
                                                                child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  widthFactor:
                                                                      fillValue,
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              25.0), // Match the button container radius
                                                                      gradient:
                                                                          const LinearGradient(
                                                                        colors: [
                                                                          Colors
                                                                              .orange,
                                                                          Colors
                                                                              .yellow
                                                                        ],
                                                                        begin: Alignment
                                                                            .centerLeft,
                                                                        end: Alignment
                                                                            .centerRight,
                                                                        tileMode:
                                                                            TileMode.clamp,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                          Center(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      const Icon(
                                                                        Icons
                                                                            .add_moderator_rounded,
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            204,
                                                                            245,
                                                                            157),
                                                                        size:
                                                                            30,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            3,
                                                                      ),
                                                                      Text(
                                                                        count ==
                                                                                0
                                                                            ? 'OPARATOR TEST'
                                                                            : '$count seconds',
                                                                        style:
                                                                            TextStyle(
                                                                          color: _fillAnimation?.value == 1.0
                                                                              ? Colors.white
                                                                              : Colors.white,
                                                                          fontSize:
                                                                              18,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      )
                                                                    ]),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )),
                                              )
                                            : Container(),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: _machineProceessStatus
                                                      .isNotEmpty &&
                                                  _machineProceessStatus[0]
                                                          .statusID ==
                                                      3
                                              ? Container(
                                                  padding:
                                                      const EdgeInsets.all(5),
                                                  height: 80,
                                                  decoration: BoxDecoration(
                                                    gradient:
                                                        const LinearGradient(
                                                      colors: [
                                                        Color.fromARGB(
                                                            255, 181, 195, 74),
                                                        Color.fromARGB(
                                                            255, 7, 255, 65)
                                                      ],
                                                      stops: [0, 1],
                                                      begin: Alignment.topRight,
                                                      end: Alignment.bottomLeft,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0),
                                                    border: Border.all(
                                                      color: Colors.transparent,
                                                      width: 3.0,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          _setMachineSpeedForTest(
                                                              30);
                                                          setState(() {
                                                            isPlaying =
                                                                true; // Update the flag when play is clicked
                                                          });
                                                        },
                                                        child: Icon(
                                                          isPlaying
                                                              ? Icons
                                                                  .pause_circle
                                                              : Icons
                                                                  .play_circle, // Toggle between play and pause icon
                                                          color: const Color
                                                              .fromARGB(
                                                              207, 13, 0, 198),
                                                          size: 60,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 20,
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          _getMachineStop();
                                                          setState(() {
                                                            isPlaying =
                                                                false; // Update the flag when stop is clicked
                                                          });
                                                        },
                                                        child: const Icon(
                                                          Icons.stop_circle,
                                                          color: Color.fromARGB(
                                                              255, 177, 0, 0),
                                                          size: 60,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : null,
                                        ),
                                        _machineProceessStatus.isNotEmpty &&
                                                _machineProceessStatus[0]
                                                        .statusID ==
                                                    3
                                            ? GestureDetector(
                                                onTap: _handleButtonQc,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    height: 80,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25.0),
                                                      gradient:
                                                          const LinearGradient(
                                                        colors: [
                                                          Color(0xffcddc39),
                                                          Color(0xff00bcd4)
                                                        ],
                                                        stops: [0, 1],
                                                        begin:
                                                            Alignment.topRight,
                                                        end: Alignment
                                                            .bottomLeft,
                                                      ),
                                                      border: Border.all(
                                                        color:
                                                            Colors.transparent,
                                                        width: 3.0,
                                                      ),
                                                    ),
                                                    child: Stack(
                                                      children: [
                                                        AnimatedBuilder(
                                                          animation:
                                                              _fillAnimationQc!,
                                                          builder: (BuildContext
                                                                  context,
                                                              Widget? child) {
                                                            final double
                                                                fillValueQc =
                                                                _fillAnimationQc!
                                                                    .value;
                                                            return ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          25.0), // Match the button container radius
                                                              child: Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                widthFactor:
                                                                    fillValueQc,
                                                                child:
                                                                    Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            25.0), // Match the button container radius
                                                                    gradient:
                                                                        const LinearGradient(
                                                                      colors: [
                                                                        Colors
                                                                            .orangeAccent,
                                                                        Colors
                                                                            .pinkAccent
                                                                      ],
                                                                      begin: Alignment
                                                                          .centerLeft,
                                                                      end: Alignment
                                                                          .centerRight,
                                                                      tileMode:
                                                                          TileMode
                                                                              .clamp,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                        Center(
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              const Icon(
                                                                  Icons
                                                                      .workspace_premium_rounded,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          228,
                                                                          3,
                                                                          37),
                                                                  size: 30),
                                                              const SizedBox(
                                                                width: 3,
                                                              ),
                                                              Text(
                                                                countQc == 0
                                                                    ? 'QC TEST'
                                                                    : '$countQc seconds',
                                                                style:
                                                                    TextStyle(
                                                                  color: _fillAnimationQc
                                                                              ?.value ==
                                                                          1.0
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .white,
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                        GestureDetector(
                                          onTap: _handleQcPeriodTest,
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Container(
                                              padding: const EdgeInsets.all(5),
                                              height: 80,
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xff8bc34a),
                                                    Color(0xffffc107)
                                                  ],
                                                  stops: [0, 1],
                                                  begin: Alignment.topRight,
                                                  end: Alignment.bottomLeft,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                                border: Border.all(
                                                  color: Colors.transparent,
                                                  width: 3.0,
                                                ),
                                              ),
                                              child: const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.timelapse_rounded,
                                                      color: Color.fromARGB(
                                                          255, 165, 3, 194),
                                                      size: 30),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    'QC PERIODIC ENTRY',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: FlipCard(
                                fill: Fill
                                    .fillBack, // Fill the back side of the card to make in the same size as the front.
                                direction: FlipDirection.HORIZONTAL, // default
                                side: CardSide
                                    .FRONT, // The side to initially display.

                                front: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xff9c27b0),
                                        Color(0xff00bcd4)
                                      ],
                                      stops: [0, 1],
                                      begin: Alignment.bottomRight,
                                      end: Alignment.topLeft,
                                    ),
                                  ),
                                  height: 400,
                                  width: 300,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      EasyStepper(
                                        lineType: LineType.dotted,
                                        activeStep:
                                            _machineProceessStatus.isEmpty
                                                ? 0
                                                : _machineProceessStatus[0]
                                                        .statusID!
                                                        .toInt() -
                                                    1,
                                        direction: Axis.vertical,
                                        unreachedStepIconColor: Colors.white,
                                        unreachedStepBorderColor:
                                            Colors.black54,
                                        activeStepBackgroundColor: Colors.green,
                                        finishedStepBackgroundColor: Colors.red,
                                        unreachedStepBackgroundColor:
                                            const Color.fromARGB(
                                                255, 4, 152, 193),
                                        unreachedStepTextColor:
                                            const Color.fromARGB(
                                                255, 223, 239, 203),
                                        showTitle: true,
                                        showStepBorder: true,
                                        onStepReached: (index) =>
                                            setState(() => activeStep = index),
                                        steps: const [
                                          EasyStep(
                                            icon: Icon(FontAwesomeIcons.ideal),
                                            title: 'Ideal',
                                            activeIcon:
                                                Icon(CupertinoIcons.arrow_up),
                                            lineText: 'Ideal',
                                          ),
                                          EasyStep(
                                            icon: Icon(
                                                FontAwesomeIcons.checkDouble),
                                            title: 'Health Checked',
                                            activeIcon:
                                                Icon(CupertinoIcons.heart),
                                            lineText: 'Health Checked',
                                          ),
                                          EasyStep(
                                            icon: Icon(Icons.settings),
                                            activeIcon: Icon(Icons.settings),
                                            title: 'Tape Setting',
                                          ),
                                          EasyStep(
                                            icon: Icon(Icons.start),
                                            activeIcon: Icon(Icons.start),
                                            title: 'Started',
                                          ),
                                          EasyStep(
                                            icon: Icon(Icons.stop),
                                            activeIcon: Icon(Icons.stop),
                                            title: 'Stop',
                                          ),
                                          EasyStep(
                                            icon: Icon(Icons
                                                .wifi_protected_setup_outlined),
                                            activeIcon: Icon(Icons
                                                .wifi_protected_setup_outlined),
                                            title: 'Interruption',
                                          ),
                                          EasyStep(
                                            icon: Icon(
                                                Icons.thumb_up_off_alt_sharp),
                                            activeIcon: Icon(
                                                Icons.thumb_up_off_alt_sharp),
                                            title: 'Finish',
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 200,
                                        height: 400,
                                        child:
                                            Image.asset("assets/elastic.png"),
                                      )
                                    ],
                                  ),
                                ),
                                back: Container(
                                  height: 400,
                                  width: 300,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xff00bcd4),
                                        Color(0xff9c27b0)
                                      ],
                                      stops: [0, 1],
                                      begin: Alignment.bottomRight,
                                      end: Alignment.topLeft,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: ShaderMask(
                                          blendMode: BlendMode.srcATop,
                                          shaderCallback: (Rect bounds) {
                                            return const LinearGradient(
                                              colors: [
                                                Color(0xD483EA66),
                                                Color(0xFF45C605)
                                              ],
                                              stops: [0, 1],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ).createShader(bounds);
                                          },
                                          child: const Text(
                                            'MACHINE STATUS',
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 24.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: DropdownButtonFormField<
                                              MachineStatusModel>(
                                            value: _machineProceessStatus
                                                    .isEmpty
                                                ? _machineStatusDetails.first
                                                : _machineStatusDetails.firstWhere(
                                                    (status) =>
                                                        status.statusID ==
                                                        _machineProceessStatus[
                                                                0]
                                                            .statusID,
                                                    orElse: () =>
                                                        _machineStatusDetails
                                                            .first),
                                            items: _machineStatusDetails.map(
                                                (MachineStatusModel
                                                    interruption) {
                                              return DropdownMenuItem<
                                                  MachineStatusModel>(
                                                value: interruption,
                                                child: Text(interruption
                                                        .statusDetails ??
                                                    ''),
                                              );
                                            }).toList(),
                                            onChanged: _machineProceessStatus
                                                    .isNotEmpty
                                                ? null
                                                : (MachineStatusModel?
                                                    newValue) {
                                                    setState(() {
                                                      _selectedMachineStatus =
                                                          newValue;
                                                      MachineData.setStatusID(
                                                          _selectedMachineStatus!
                                                              .statusID);
                                                    });
                                                  },
                                            isExpanded: true,
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: _machineProceessStatus.isEmpty ||
                                                _machineProceessStatus
                                                        .isNotEmpty &&
                                                    _machineProceessStatus[0]
                                                            .interruptionID ==
                                                        0
                                            ? Container(
                                                width: 200.0,
                                                height: 50.0,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25.0),
                                                  gradient: isStatusEnabled
                                                      ? const LinearGradient(
                                                          colors: [
                                                            Color(0xFF667EEA),
                                                            Color(0xFF64B6FF)
                                                          ],
                                                          begin: Alignment
                                                              .centerLeft,
                                                          end: Alignment
                                                              .centerRight,
                                                        )
                                                      : const LinearGradient(
                                                          colors: [
                                                            Colors.grey,
                                                            Colors.grey
                                                          ],
                                                          begin: Alignment
                                                              .centerLeft,
                                                          end: Alignment
                                                              .centerRight,
                                                        ),
                                                ),
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0),
                                                    onTap: () {
                                                      _handleSubmitStatus();
                                                    },
                                                    child: Center(
                                                      child: Text(
                                                        _machineProceessStatus
                                                                .isEmpty
                                                            ? text
                                                            : "CHECK OUT",
                                                        style: TextStyle(
                                                          color: isStatusEnabled
                                                              ? Colors.white
                                                              : Colors.grey
                                                                  .shade700,
                                                          fontSize: 18.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : null,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: ShaderMask(
                                          blendMode: BlendMode.srcATop,
                                          shaderCallback: (Rect bounds) {
                                            return const LinearGradient(
                                              colors: [
                                                Color(0xffe91e63),
                                                Color(0xffffeb3b)
                                              ],
                                              stops: [0, 1],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ).createShader(bounds);
                                          },
                                          child: const Text(
                                            'INTERRUPTION',
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 24.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: DropdownButtonFormField<
                                              Interruption>(
                                            value: _machineProceessStatus
                                                    .isEmpty
                                                ? _interruptionDetails.first
                                                : _interruptionDetails.firstWhere(
                                                    (status) =>
                                                        status
                                                            .interruptionTypeDetailsID ==
                                                        _machineProceessStatus[
                                                                0]
                                                            .interruptionID,
                                                    orElse: () =>
                                                        _interruptionDetails
                                                            .first),
                                            items: _interruptionDetails.map(
                                                (Interruption interruption) {
                                              return DropdownMenuItem<
                                                  Interruption>(
                                                value: interruption,
                                                child: Text(
                                                  interruption
                                                          .interruptionTypeDetails ??
                                                      '',
                                                ),
                                              );
                                            }).toList(),
                                            onChanged:
                                                (Interruption? newValue) {
                                              setState(() {
                                                selectedInterruption = newValue;
                                              });
                                            },
                                            isExpanded: true,
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: _machineProceessStatus
                                                    .isNotEmpty &&
                                                _machineProceessStatus[0]
                                                        .interruptionID ==
                                                    0
                                            ? null
                                            : Container(
                                                width: 250.0,
                                                height: 50.0,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25.0),
                                                  gradient: isInterrption
                                                      ? const LinearGradient(
                                                          colors: [
                                                            Color(0xD483EA66),
                                                            Color(0xFF45C605)
                                                          ],
                                                          begin: Alignment
                                                              .centerLeft,
                                                          end: Alignment
                                                              .centerRight,
                                                        )
                                                      : const LinearGradient(
                                                          colors: [
                                                            Colors.grey,
                                                            Colors.grey
                                                          ],
                                                          begin: Alignment
                                                              .centerLeft,
                                                          end: Alignment
                                                              .centerRight,
                                                        ),
                                                ),
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0),
                                                    onTap: () {
                                                      if (_machineProceessStatus
                                                          .isEmpty) {
                                                        _handleSubmitInterruption(
                                                            selectedInterruption!
                                                                .interruptionTypeDetailsID!
                                                                .toInt());
                                                      } else {
                                                        _handleGetInterruptionRecord();
                                                      }
                                                    },
                                                    child: Center(
                                                      child: Text(
                                                        _machineProceessStatus
                                                                .isEmpty
                                                            ? inTupText
                                                            : "MAINTAINING UPDATE",
                                                        style: TextStyle(
                                                          color:
                                                              _machineProceessStatus
                                                                      .isEmpty
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .white,
                                                          fontSize: 18.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                          Padding(
                            padding: const EdgeInsets.only(right: 20, left: 20),
                            child: FlipCard(
                              fill: Fill
                                  .fillBack, // Fill the back side of the card to make in the same size as the front.
                              direction: FlipDirection.HORIZONTAL, // default
                              side: CardSide
                                  .FRONT, // The side to initially display.

                              front: Container(
                                height: 400,
                                width: 300,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [
                                    Colors.orangeAccent,
                                    Colors.cyan
                                  ]),
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.orange,
                                ),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      const CircleAvatar(
                                        radius: 70,
                                        backgroundImage: NetworkImage(
                                            "https://cdn.pixabay.com/photo/2020/07/01/12/58/icon-5359553_960_720.png"),
                                      ),
                                      ShaderMask(
                                        blendMode: BlendMode.srcATop,
                                        shaderCallback: (Rect bounds) {
                                          return const LinearGradient(
                                            colors: [
                                              Color(0xff9c27b0),
                                              Color(0xffe91e63)
                                            ],
                                            stops: [0, 1],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ).createShader(bounds);
                                        },
                                        child: Text(
                                          _opDetails == null
                                              ? ""
                                              : _opDetails!.name
                                                  .toString()
                                                  .trim(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Pacifico',
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        'OPARATOR', //cause you cute Devang
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'SourceSansPro',
                                          fontSize: 26,
                                          letterSpacing: 1,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 20),
                                        margin: const EdgeInsets.fromLTRB(
                                            20, 20, 20, 10),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.white,
                                            ),
                                            // color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Row(
                                          children: <Widget>[
                                            const Icon(
                                              Icons.phone,
                                              size: 25,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              _opDetails == null
                                                  ? ""
                                                  : _opDetails!.mobileNO
                                                      .toString()
                                                      .trim(),
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontFamily: 'SourceSansPro',
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            18, 10, 0, 10),
                                        margin: const EdgeInsets.fromLTRB(
                                            20, 0, 20, 10),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.white,
                                            ),
                                            // color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Row(
                                          children: <Widget>[
                                            const Icon(
                                              Icons.mail_outline,
                                              size: 25,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              _opDetails == null
                                                  ? ""
                                                  : _opDetails!.emailID
                                                      .toString()
                                                      .trim(),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'SourceSansPro',
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ]),
                              ),
                              back: Container(
                                height: 400,
                                width: 300,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [
                                    Colors.pinkAccent,
                                    Colors.purpleAccent
                                  ]),
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.orange,
                                ),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      const CircleAvatar(
                                        radius: 70,
                                        backgroundImage: NetworkImage(
                                            "https://cdn.pixabay.com/photo/2020/07/01/12/58/icon-5359553_960_720.png"),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.fromLTRB(
                                            0, 12, 0, 7),
                                        child: ShaderMask(
                                          blendMode: BlendMode.srcATop,
                                          shaderCallback: (Rect bounds) {
                                            return const LinearGradient(
                                              colors: [
                                                Color(0xffffeb3b),
                                                Color(0xff00bcd4)
                                              ],
                                              stops: [0, 1],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ).createShader(bounds);
                                          },
                                          child: Text(
                                            _qcDetails == null
                                                ? ""
                                                : _qcDetails!.name
                                                    .toString()
                                                    .trim(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Pacifico',
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        'QUALITY CHECKER', //cause you cute Devang
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'SourceSansPro',
                                          fontSize: 26,
                                          letterSpacing: 1,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 20),
                                        margin: const EdgeInsets.fromLTRB(
                                            20, 20, 20, 10),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.white,
                                            ),
                                            // color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Row(
                                          children: <Widget>[
                                            const Icon(
                                              Icons.phone,
                                              size: 25,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              _qcDetails == null
                                                  ? ""
                                                  : _qcDetails!.mobileNO
                                                      .toString()
                                                      .trim(),
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontFamily: 'SourceSansPro',
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            18, 10, 0, 10),
                                        margin: const EdgeInsets.fromLTRB(
                                            20, 0, 20, 10),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.white,
                                            ),
                                            // color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Row(
                                          children: <Widget>[
                                            const Icon(
                                              Icons.mail_outline,
                                              size: 25,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              _qcDetails == null
                                                  ? ""
                                                  : _qcDetails!.emailID
                                                      .toString()
                                                      .trim(),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'SourceSansPro',
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ]),
                              ),
                            ),
                          )
                          // SizedBox(
                          //   height: 480,
                          //   width: 300,
                          //   child: CardSlider(
                          //     cards: valuesWidget,
                          //     bottomOffset: .0003,
                          //   ),
                          // )
                        ],
                      ),
                    ))),
          );
  }
}
