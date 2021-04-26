import 'dart:convert';
import 'dart:io';

import "package:googleapis_auth/auth_io.dart";
import 'package:googleapis/calendar/v3.dart';
import 'package:one_take_pass_remake/api/misc.dart' show RegexLibraries;
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

///Get event durations
class EventDuration {
  static final String timezone = "GMT+08:00";
  final DateTime datetime;
  EventDateTime _eDT;
  EventDuration({this.datetime}) {
    _eDT = new EventDateTime();
    _eDT.dateTime = datetime;
    _eDT.timeZone = timezone;
  }
  EventDateTime get edt {
    return _eDT;
  }
}

///An factory class that redat to create event object from API
class EventFactory {
  final EventDuration start;
  final EventDuration end;
  final String summary;
  final List<String> attendeesEmails;
  EventFactory({this.summary, this.start, this.end, this.attendeesEmails});

  ///Generate [Event] from Google API
  Event get eventObject {
    Event e = new Event();
    e.summary = summary;
    e.start = start.edt;
    e.end = end.edt;
    //Assign all attendees
    attendeesEmails.forEach((emailAttr) {
      if (RegexLibraries.emailPattern.hasMatch(emailAttr)) {
        EventAttendee ea = EventAttendee();
        ea.email = emailAttr;
        e.attendees.add(ea);
      }
    });
    return e;
  }
}

///Link to Google before using API
class ClientSetup {
  static Future<CalendarApi> apiInit() async {
    try {
      AuthClient ac = await clientViaUserConsent(
          CalendarInit.instance, CalendarInit.scope, (prompt) async {
        if (await canLaunch(prompt)) {
          await launch(prompt);
        } else {
          throw "URL is not worked";
        }
      });

      return CalendarApi(ac);
    } catch (err) {
      throw "Unable to activate Google Calendar";
    }
  }

  static String get calId {
    return "primary";
  }
}

///A class that handling all action
abstract class EventAction {
  bool success = false;

  Future<void> run() {
    ClientSetup.apiInit().then((capi) {
      exec(capi);
    });
  }

  ///Tasks of execution, do not call directly
  ///
  ///Thus, to ensure [isSuccess] value is correct, this method must contain await if doing async tasks
  Future<void> exec(CalendarApi c);

  ///Indicator that confirm is usable
  bool get isSuccess {
    return success;
  }
}
