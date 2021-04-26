import 'package:date_time_picker/date_time_picker.dart';
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TableCalendar(
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
          return [];
        },
      ),
      Expanded(
        child: ListView.builder(
            padding: EdgeInsets.all(5),
            itemCount: 3,
            itemBuilder: (context, count) => Container(
                  width: MediaQuery.of(context).size.width,
                  height: 100,
                  margin: EdgeInsets.only(top: 2.5, bottom: 2.5),
                  decoration: BoxDecoration(
                      border:
                          Border.all(color: OTPColour.mainTheme, width: 1.5)),
                )),
      )
    ]);
  }
}

class OTPCalenderEventAdder extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OTPCalenderEventAdder();
}

class _OTPCalenderEventAdder extends State<OTPCalenderEventAdder> {
  Map<String, bool> _selectedDay = {
    "mon": false,
    "tue": false,
    "wed": false,
    "thur": false,
    "fri": false,
    "sat": false,
    "sun": false
  };

  Map<String, DateTime> _eventsMap = {
    //Assume start immediately
    "start": DateTime.now(),
    //Assume the event will be held one hour
    "end": DateTime.now().add(Duration(hours: 1))
  };

  void _assignDayVal(String day, bool newVal) {
    _selectedDay[day] = newVal;
  }

  static bool isSubmit = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
              onPressed: () {
                if (_eventsMap["end"].isBefore(_eventsMap["start"])) {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text("Date setting error"),
                            content: Text(
                                "The end date must be set before the start date"),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      isSubmit = false;
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Text("OK"))
                            ],
                          ));
                } else {
                  Navigator.pop(context);
                }
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
          Container(
            margin: EdgeInsets.only(left: 5, right: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Start date
                Text("From"),
                DateTimePicker(
                  type: DateTimePickerType.dateTime,
                  initialValue: _eventsMap["start"].toString(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(
                      days: (365 * 4))), //Extend 4 years ignore leap day
                  onChanged: (newDT) {
                    setState(() {
                      _eventsMap["start"] = DateTime.parse(newDT);
                    });
                  },
                ),
                Padding(padding: EdgeInsets.only(top: 2.5, bottom: 2.5)),
                //End date
                Text("To"),
                DateTimePicker(
                  type: DateTimePickerType.dateTime,
                  initialValue: _eventsMap["end"].toString(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(
                      days: (365 * 4))), //Extend 4 years ignore leap day
                  onChanged: (newDT) {
                    setState(() {
                      _eventsMap["end"] = DateTime.parse(newDT);
                    });
                  },
                ),
              ],
            ),
          ),
          Divider(),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(child: Text("On every:"), padding: EdgeInsets.all(10)),
            CheckboxListTile(
              value: _selectedDay["mon"],
              onChanged: (n) {
                setState(() {
                  _assignDayVal("mon", n);
                });
              },
              title: Text("Monday"),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              value: _selectedDay["tue"],
              onChanged: (n) {
                setState(() {
                  _assignDayVal("tue", n);
                });
              },
              title: Text("Tuesday"),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              value: _selectedDay["wed"],
              onChanged: (n) {
                setState(() {
                  _assignDayVal("wed", n);
                });
              },
              title: Text("Wednesday"),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              value: _selectedDay["thur"],
              onChanged: (n) {
                setState(() {
                  _assignDayVal("thur", n);
                });
              },
              title: Text("Thursday"),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              value: _selectedDay["fri"],
              onChanged: (n) {
                setState(() {
                  _assignDayVal("fri", n);
                });
              },
              title: Text("Friday"),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              value: _selectedDay["sat"],
              onChanged: (n) {
                setState(() {
                  _assignDayVal("sat", n);
                });
              },
              title: Text("Saturday"),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              value: _selectedDay["sun"],
              onChanged: (n) {
                setState(() {
                  _assignDayVal("sun", n);
                });
              },
              title: Text("Sunday"),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ])
        ]),
      ),
    );
  }
}
