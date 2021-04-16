import 'dart:io';

import "package:googleapis_auth/auth_io.dart";
import 'package:googleapis/calendar/v3.dart';

const _scopes = const [CalendarApi.calendarScope];

class CalendarInit {
  ClientId _cert;
  void run() {
    if (Platform.isAndroid) {
      _cert = new ClientId(
          "732279302674-895l9voaromdbc17meacn8qqdhqdahj2.apps.googleusercontent.com",
          "");
    }
  }
}
