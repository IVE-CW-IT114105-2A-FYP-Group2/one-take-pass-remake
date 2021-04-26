import "package:googleapis_auth/auth_io.dart";
import 'package:googleapis/calendar/v3.dart';
import 'package:one_take_pass_remake/api/calendar/setup.dart';

///Insert event into calendar
class InsertEvent extends EventAction {
  final EventFactory eventsInfos;
  InsertEvent({this.eventsInfos}) : super();
  @override
  Future<void> exec(CalendarApi c) async {
    await c.events
        .insert(eventsInfos.eventObject, ClientSetup.calId)
        .then((event) {
      success = (event.status == "confirmed");
    });
  }
}
