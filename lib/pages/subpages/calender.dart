import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class OTPCalender extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OTPCalender();
}

class _OTPCalender extends State<OTPCalender> {
  //Store selected date (and today's date as default)
  DateTime _selectedDate = DateTime.now(), _focusedDate = DateTime.now();

  //Defile current calender display format
  CalendarFormat _format = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      calendarBuilders: CalendarBuilders(headerTitleBuilder: (context, dt) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dt.year.toString(),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300)),
            Text(DateFormat("MMMM").format(dt),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))
          ],
        );
      }),
      focusedDay: _focusedDate,
      firstDay: DateTime((DateTime.now().year - 3), 1, 1),
      lastDay: DateTime((DateTime.now().year + 3), 12, 31),
      selectedDayPredicate: (date) => isSameDay(_selectedDate, date),
      onDaySelected: (selected, focused) {
        setState(() {
          _selectedDate = selected;
          _focusedDate = focused;
        });
      },
      calendarFormat: _format,
      onPageChanged: (focused) {
        _focusedDate = focused;
      },
      onFormatChanged: (format) {
        setState(() {
          _format = format;
        });
      },
    );
  }
}
