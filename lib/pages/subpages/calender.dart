import 'dart:async';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart' show DateFormat;
import 'package:one_take_pass_remake/main.dart' show routeObserver;
import 'package:one_take_pass_remake/themes.dart';
import 'package:table_calendar/table_calendar.dart';

class OTPCalender extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OTPCalender();
}

class _OTPCalender extends State<OTPCalender> with RouteAware {
  //Store selected date (and today's date as default)
  DateTime _selectedDate = DateTime.now(), _focusedDate = DateTime.now();

  //Defile current calender display format
  CalendarFormat _format = CalendarFormat.month;

  //List<Event> _pickedEvent = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    setState(() {});
  }

  ///Show empty string if [dt] is null
  ///
  ///That because some event don't store in dateTime in Google Calendar
  String _timeDisplayHandler(DateTime dt) {
    try {
      return DateFormat("Hm").format(dt);
    } catch (null_datetime) {
      return "";
    }
  }

  ///All interface about calendar
  Widget calendarInterface(BuildContext context, List<dynamic> receivedEvents) {
    return StatefulBuilder(
        builder: (context, setInnerState) => Column(children: [
              TableCalendar(
                calendarBuilders:
                    CalendarBuilders(headerTitleBuilder: (context, dt) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dt.year.toString(),
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w300)),
                      Text(DateFormat("MMMM").format(dt),
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700))
                    ],
                  );
                }),
                focusedDay: _focusedDate,
                firstDay: DateTime((DateTime.now().year - 3), 1, 1),
                lastDay: DateTime((DateTime.now().year + 3), 12, 31),
                selectedDayPredicate: (date) => isSameDay(_selectedDate, date),
                onDaySelected: (selected, focused) {
                  setInnerState(() {
                    _selectedDate = selected;
                    _focusedDate = focused;
                    //_pickedEvent = eventGetterByDay(selected);
                  });
                },
                calendarFormat: _format,
                onPageChanged: (focused) {
                  _focusedDate = focused;
                },
                onFormatChanged: (format) {
                  setInnerState(() {
                    _format = format;
                  });
                },
                eventLoader: (dt) {
                  return []; //eventGetterByDay(dt);
                },
              ),
              Expanded(
                child: ListView.builder(
                    padding: EdgeInsets.all(5),
                    itemCount: 3, //_pickedEvent.length,
                    itemBuilder: (context, count) => GestureDetector(
                        onTap: () async {
                          //When click the event, open in google calendar
                          /*if (await canLaunch(_pickedEvent[count].htmlLink)) {
                            await launch(_pickedEvent[count].htmlLink);
                          }*/
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 100,
                          margin: EdgeInsets.only(top: 2.5, bottom: 2.5),
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: OTPColour.mainTheme, width: 1.5)),
                          /*child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (DateFormat("MMMM d").format(_pickedEvent[count]
                                            .start
                                            .date ??
                                        _pickedEvent[count].start.dateTime) +
                                    "\t\t\t\t" +
                                    _timeDisplayHandler(
                                        _pickedEvent[count].start.dateTime) +
                                    " - " +
                                    _timeDisplayHandler(
                                        _pickedEvent[count].end.dateTime)),
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w300),
                              ),
                              Text(
                                _pickedEvent[count].summary,
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),*/
                        ))),
              )
            ]));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
        future: Future.delayed(Duration(seconds: 1), () => []),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Getting your calendar..."),
                  Padding(
                    child: CircularProgressIndicator(),
                    padding: EdgeInsets.all(30),
                  )
                ],
              ),
            );
          } else {
            if (snapshot.hasData) {
              //print(snapshot.data);
              return calendarInterface(context, snapshot.data);
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Unable to get your calendar"),
                    Icon(
                      CupertinoIcons.xmark_circle,
                      size: 120,
                    )
                  ],
                ),
              );
            }
          }
        });
  }
}

class OTPCalenderEventAdder extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OTPCalenderEventAdder();
}

///An interface that add a event to Google Calendar
class _OTPCalenderEventAdder extends State<OTPCalenderEventAdder> {
  ///Selected which day will repeated
  final Map<String, bool> _selectedDay = {
    "mon": false,
    "tue": false,
    "wed": false,
    "thur": false,
    "fri": false,
    "sat": false,
    "sun": false
  };

  ///Controller for [TextField]
  Map<String, TextEditingController> _controllers;

  ///A mapped object that define start and end
  Map<String, DateTime> _eventsMap = {
    //Assume start immediately
    "start": DateTime.now(),
    //Assume the event will be held one hour
    "end": DateTime.now().add(Duration(hours: 1))
  };

  ///A lazy way to assign [_selectedDay] to define repeated day
  void _assignDayVal(String day, bool newVal) {
    _selectedDay[day] = newVal;
  }

  ///Convert Map's key to DateTime's enum ints
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

  ///Uses for unified date format
  String getCWDDate(DateTime c) {
    return DateFormat("yyyy-MM-dd").format(c);
  }

  @override
  void initState() {
    super.initState();
    _controllers = {
      "summary": TextEditingController(),
      "attendees": TextEditingController()
    };
  }

  @override
  void dispose() {
    _controllers.forEach((_, value) {
      value.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Widget sets
    final List<CheckboxListTile> _weekDays = <CheckboxListTile>[
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
      )
    ];
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
              onPressed: () {
                if (_eventsMap["end"].isBefore(_eventsMap["start"])) {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text("Date and time setting error"),
                            content: Text(
                                "The end date and time should not before start date and time"),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("OK"))
                            ],
                          ));
                } else {
                  //Insert event handler

                }
              },
              child: Text(
                "Create",
                style: TextStyle(color: OTPColour.dark1),
              ))
        ],
        title: Text("Create new courses"),
        centerTitle: true,
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: ListView(children: [
          Container(
            margin: EdgeInsets.only(left: 5, right: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Title"),
                TextField(
                  controller: _controllers["summary"],
                  inputFormatters: [
                    FilteringTextInputFormatter.singleLineFormatter
                  ],
                  maxLength: 255,
                  maxLines: 1,
                  minLines: 1,
                ),
                Divider(),
                //Start date
                Text("From"),
                DateTimePicker(
                  type: DateTimePickerType.dateTimeSeparate,
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
                  type: DateTimePickerType.dateTimeSeparate,
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
            Container(child: Column(children: _weekDays)),
          ]),
        ]),
      ),
    );
  }
}
