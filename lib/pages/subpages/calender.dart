import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';

class OTPCalender extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OTPCalender();
}

class _OTPCalender extends State<OTPCalender> {
  @override
  Widget build(BuildContext context) {
    return TableCalendar(
        focusedDay: DateTime.now(),
        firstDay: DateTime(2021, 1, 1),
        lastDay: DateTime(2030, 12, 31));
  }
}
