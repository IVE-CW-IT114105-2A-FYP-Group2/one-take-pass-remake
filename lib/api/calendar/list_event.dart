import "package:googleapis_auth/auth_io.dart";
import 'package:googleapis/calendar/v3.dart';
import 'package:one_take_pass_remake/api/calendar/setup.dart';

///List current user's calendar
class ListEvents extends GCalAPIHandler {
  @override
  Future<List<Event>> task(CalendarApi capi) async {
    Events events = await capi.events.list(GCalAPIHandler.calId);
    return events.items;
  }
}
