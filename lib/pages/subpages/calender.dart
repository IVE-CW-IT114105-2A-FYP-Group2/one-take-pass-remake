import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import 'package:one_take_pass_remake/themes.dart';
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
      eventLoader: (dt) {
        if (dt.weekday == DateTime.monday) {
          return ["Driving lesson"];
        }
        return [];
      },
    );
  }
}

class OTPCalenderEventAdder extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OTPCalenderEventAdder();
}

class DaySelect {
  bool selected = false;
  String day;
  DaySelect(String day) {
    this.day = day;
  }
}

class _OTPCalenderEventAdder extends State<OTPCalenderEventAdder> {
  CheckboxListTile _cbxFactory(DaySelect ds) {
    return CheckboxListTile(
      value: ds.selected,
      onChanged: (bool nv) {
        setState(() {
          ds.selected = nv;
        });
      },
      title: Text(ds.day),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Create",
                style: TextStyle(color: OTPColour.dark1),
              ))
        ],
        title: Text("Create new event"),
        centerTitle: true,
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: Column(children: [
          InputDatePickerFormField(
            firstDate: DateTime(2020, 1, 1),
            lastDate: DateTime(2030, 12, 31),
            fieldLabelText: "Start date",
          ),
          InputDatePickerFormField(
            firstDate: DateTime(2020, 1, 1),
            lastDate: DateTime(2030, 12, 31),
            fieldLabelText: "End date",
          ),
          Divider(),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("On every:"),
            _cbxFactory(DaySelect("Mon")),
            _cbxFactory(DaySelect("Tue")),
            _cbxFactory(DaySelect("Wen")),
            _cbxFactory(DaySelect("Thur")),
            _cbxFactory(DaySelect("Fri")),
            _cbxFactory(DaySelect("Sat")),
            _cbxFactory(DaySelect("Sun")),
          ])
        ]),
      ),
    );
  }
}
