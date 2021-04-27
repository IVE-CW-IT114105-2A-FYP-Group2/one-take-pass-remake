import 'package:googleapis/calendar/v3.dart';
import 'package:one_take_pass_remake/api/calendar/setup.dart';
import 'package:intl/intl.dart';

///Insert new event
class InsertEvent extends GCalAPIHandler {
  static final String timezone = "GMT+08:00";
  final DateTime from;
  final DateTime to;
  final String summary;
  final Map<String, bool> repeatDay;
  final List<String> attendees;
  InsertEvent(
      {this.summary, this.from, this.to, this.repeatDay, this.attendees});

  String repeatDayKeyConverter(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return "mon";
      case DateTime.tuesday:
        return "tue";
      case DateTime.wednesday:
        return "wed";
      case DateTime.thursday:
        return "thur";
      case DateTime.friday:
        return "fri";
      case DateTime.saturday:
        return "sat";
      case DateTime.sunday:
        return "sun";
      default:
        throw "Invalid day";
    }
  }

  @override
  Future<bool> task(CalendarApi capi) async {
    String getCWDDate(DateTime c) {
      return DateFormat("yyyy-MM-dd").format(c);
    }

    //Duration of the single day event
    String startTime = DateFormat.Hm().format(from) + ":00",
        endTime = DateFormat.Hm().format(to) + ":00";
    DateTime cwd = from;
    while (cwd.isBefore(to)) {
      //When cwd's weekday is assign to repeated
      if (repeatDay[repeatDayKeyConverter(cwd.weekday)]) {
        Event sDE = new Event();
        EventDateTime timeStart = new EventDateTime();
        EventDateTime timeEnd = new EventDateTime();
        timeStart.dateTime = DateTime.parse(getCWDDate(cwd) + " " + startTime);
        timeStart.timeZone = timezone;
        timeEnd.dateTime = DateTime.parse(getCWDDate(cwd) + " " + endTime);
        timeEnd.timeZone = timezone;
        sDE.start = timeStart;
        sDE.end = timeEnd;
        sDE.summary = summary;
        if (attendees.length != 0) {
          attendees.forEach((emailAddr) {
            EventAttendee ea = EventAttendee();
            ea.email = emailAddr;
            sDE.attendees.add(ea);
          });
        }
        if (!await assignSingleEvent(capi, sDE)) {
          return false;
        }
      }
      cwd = cwd.add(Duration(days: 1));
    }
    return true;
  }

  ///Insert event day by day
  Future<bool> assignSingleEvent(CalendarApi capi, Event cwde) async {
    Event event = await capi.events.insert(cwde, GCalAPIHandler.calId);
    return event.status == "confirmed"; //Check is added
  }
}
