import "package:googleapis_auth/auth_io.dart";
import 'package:googleapis/calendar/v3.dart';
import 'package:one_take_pass_remake/api/calendar/setup.dart';

///Class that handling event listing
class ListEvents extends EventAction {
  Events _eventsList;

  ListEvents() : super();

  @override
  Future<void> exec(CalendarApi c) async {
    _eventsList = await c.events.list(ClientSetup.calId);
    success = true;
  }

  ///Get current user events list, null if failed
  Events get cues {
    if (isSuccess) {
      return _eventsList;
    }
    return null;
  }
}
