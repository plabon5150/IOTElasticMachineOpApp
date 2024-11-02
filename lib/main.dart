import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gpiod/flutter_gpiod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:machineautomation/Constants/MyCustomScrollBehavior.dart';
import 'package:machineautomation/app_config.dart';
import 'package:machineautomation/my_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_value/shared_value.dart';
import 'package:root_access/root_access.dart';

import 'Screens/SplashScreen.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft]);
  runApp(
    MediaQuery(
      data: MediaQueryData.fromWindow(WidgetsBinding.instance.window),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _rootStatus = false;

  Future<void> initRootRequest() async {
    bool rootStatus = await RootAccess.requestRootAccess;
    setState(() {
      _rootStatus = rootStatus;
    });
  }

  @override
  void initState() {
    super.initState();
    //initRootRequest();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final mediaQueryData = MediaQuery.of(context);
    // Access the height and width of the device's screen
    final height = mediaQueryData.size.height;
    final width = mediaQueryData.size.width;
    return MaterialApp(
      title: AppConfig.app_name,
      debugShowCheckedModeBanner: false,
      scrollBehavior: MyCustomScrollBehavior(),
      theme: ThemeData(
        colorScheme: ColorScheme(
          primary: MyTheme.white,
          background: MyTheme.white,
          onBackground: MyTheme.shimmer_base,
          onPrimary: MyTheme.amber,
          onSecondary: MyTheme.accent_color,
          surface: MyTheme.white,
          onSurface: MyTheme.accent_color,
          error: MyTheme.light_grey,
          onError: MyTheme.white,
          secondary: MyTheme.accent_color,
          brightness: Brightness.light,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        //
        // the below code is getting fonts from http
        textTheme: GoogleFonts.publicSansTextTheme(textTheme).copyWith(
          bodyText1: GoogleFonts.publicSans(textStyle: textTheme.bodyText1),
          bodyText2: GoogleFonts.publicSans(
            textStyle: textTheme.bodyText2,
            fontSize: 12,
          ),
        ),
      ),
      home: SplashScreen(height: height, width: width),
      // home: Splash(),
    );
  }
}
