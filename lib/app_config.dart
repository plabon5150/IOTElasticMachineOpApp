var this_year = DateTime.now().year.toString();

class AppConfig {
  static String copyright_text =
      "@ MachineTap " + this_year; //this shows in the splash screen
  static String app_name = "MachineTap"; //this shows in the splash screen

  //Default language config
  static String default_language = "en";
  static String mobile_app_code = "en";
  static bool app_language_rtl = false;

  //configure this
  static const bool HTTPS = true;
  static const DOMAIN_PATH =
      "192.168.1.253"; // directly inside the public folder

  //do not configure these below
  static const String API_ENDPATH = "NaturubWebAPITest";
  static const String PROTOCOL = HTTPS ? "https://" : "http://";
  static const String RAW_BASE_URL = "${PROTOCOL}${DOMAIN_PATH}";
  static const String BASE_URL = "${RAW_BASE_URL}/${API_ENDPATH}";
}
