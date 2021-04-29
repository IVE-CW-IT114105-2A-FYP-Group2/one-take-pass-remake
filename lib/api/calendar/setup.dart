import 'dart:io';

import "package:googleapis_auth/auth_io.dart";
import 'package:googleapis/calendar/v3.dart';
import 'package:url_launcher/url_launcher.dart';

///Initalize the google calendar apis
class CalendarInit {
  ClientId _cert;
  void run() {
    if (Platform.isAndroid) {
      _cert = new ClientId(
          "732279302674-895l9voaromdbc17meacn8qqdhqdahj2.apps.googleusercontent.com",
          "");
    }
  }

  ///Instance get API
  static ClientId get instance {
    CalendarInit init = new CalendarInit();
    init.run();
    return init._cert;
  }

  ///Get scope
  static List<String> get scope {
    return [CalendarApi.calendarScope];
  }
}

///Google calendar API handler
class GCalAPIHandler {
  static final String calId = "primary";
  Future<CalendarApi> getGranted() async {
    try {
      return new CalendarApi(await clientViaUserConsent(
          CalendarInit.instance, CalendarInit.scope, prompt));
    } catch (gapierr) {
      return null;
    }
  }

  ///Assign auth by [gauthurl]
  void prompt(String gauthurl) async {
    if (await canLaunch(gauthurl)) {
      await launch(gauthurl);
    } else {
      throw "Launch Google API URL failed";
    }
  }
}
