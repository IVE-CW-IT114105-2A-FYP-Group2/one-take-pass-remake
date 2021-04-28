import 'dart:async';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/calendar/v3.dart';

import 'package:intl/intl.dart' show DateFormat;
import 'package:one_take_pass_remake/api/calendar/setup.dart';
import 'package:one_take_pass_remake/api/misc.dart' show RegexLibraries;
import 'package:one_take_pass_remake/themes.dart';
import 'package:table_calendar/table_calendar.dart';

class _CApiManager {
  static CalendarApi _capi = null;
  static Future<CalendarApi> get grant async {
    if (_capi == null) {
      _capi = await new GCalAPIHandler().getGranted();
    }
    return _capi;
  }
}

Future<List<Event>> _cuEvents = Future.value(_CApiManager.grant
    .then((capi) => capi.events.list(GCalAPIHandler.calId))
    .then((value) => value.items));

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

  ///All interface about calendar
  Widget calendarInterface(BuildContext context, List<Event> receivedEvents) {
    return StatefulBuilder(
        builder: (context, setState) => Column(children: [
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
                  setState(() {
                    _selectedDate = selected;
                    _focusedDate = focused;
                  });
                },
                calendarFormat: _format,
                onPageChanged: (focused) {
                  setState(() {
                    _focusedDate = focused;
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _format = format;
                  });
                },
                eventLoader: (dt) {
                  try {
                    return receivedEvents.where((eventInfo) {
                      EventDateTime eDT = eventInfo.start;
                      String dateAsStr =
                          DateFormat(DateFormat.YEAR_NUM_MONTH_DAY).format(eDT
                                  .date ??
                              eDT.dateTime); //Pick the date that is not null
                      return dateAsStr ==
                          DateFormat(DateFormat.YEAR_NUM_MONTH_DAY).format(dt);
                    }).toList();
                  } catch (filter_error) {
                    //If caught error as moy be no event found
                    return [];
                  }
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
                              border: Border.all(
                                  color: OTPColour.mainTheme, width: 1.5)),
                        )),
              )
            ]));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Event>>(
        future: _cuEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Getting your calendar..."),
                  CircularProgressIndicator()
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
  Map<String, bool> _selectedDay = {
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

  void insertEvent(CalendarApi capi) {
    List<String> getEmailListStr() {
      List<String> validAddr = [];
      List<String> inputAddr = _controllers["attendees"].text.split(',');
      inputAddr.forEach((a) {
        if (RegexLibraries.emailPattern.hasMatch(a)) {
          validAddr.add(a);
        }
      });
      return validAddr;
    }

    ///Set timezone in Hong Kong
    final String timezone = "GMT+08:00";

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

    //Duration of the single day event
    String startTime = DateFormat.Hm().format(_eventsMap["start"]) + ":00",
        endTime = DateFormat.Hm().format(_eventsMap["end"]) + ":00";
    DateTime cwd = _eventsMap["start"];
    List<String> attendees = getEmailListStr();
    //It's keep insert until the end of the date
    while (cwd.isBefore(_eventsMap["end"])) {
      //When cwd's weekday is assign to repeated
      if (_selectedDay[repeatDayKeyConverter(cwd.weekday)]) {
        Event sDE = new Event();
        EventDateTime timeStart = new EventDateTime();
        EventDateTime timeEnd = new EventDateTime();
        timeStart.dateTime = DateTime.parse(getCWDDate(cwd) + " " + startTime);
        timeStart.timeZone = timezone;
        timeEnd.dateTime = DateTime.parse(getCWDDate(cwd) + " " + endTime);
        timeEnd.timeZone = timezone;
        sDE.start = timeStart;
        sDE.end = timeEnd;
        sDE.summary = _controllers["summary"].text;
        if (attendees[0] != "") {
          //It still gives a empty string if nothing can be split
          attendees.forEach((emailAddr) {
            EventAttendee ea = EventAttendee();
            ea.email = emailAddr;
            sDE.attendees.add(ea);
          });
        }
        try {
          capi.events.insert(sDE, GCalAPIHandler.calId).then((value) {
            if (value.status == "confirmed") {
              print("Event added");
            }
          });
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text("The new event has been created"),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("OK"))
                    ],
                  )).then((_) {
            Navigator.pop(context);
          });
        } catch (insert_failed) {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text("Unable to insert new event"),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("OK"))
                    ],
                  ));
        }
        //if (!await assignSingleEvent(capi, sDE)) {
        //  return false;
        //}
      }
      cwd = cwd.add(Duration(days: 1));
    }
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
                                    Navigator.pop(context);
                                  },
                                  child: Text("OK"))
                            ],
                          ));
                } else {
                  //Insert event handler
                  _CApiManager.grant.then((capi) {
                    insertEvent(capi);
                  });

                  /*InsertEvent(
                          from: _eventsMap["start"],
                          to: _eventsMap["end"],
                          summary: _controllers["summary"].text,
                          repeatDay: _selectedDay,
                          attendees: getEmailListStr())*/

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
            Container(
                margin: EdgeInsets.only(bottom: 5),
                height: 150,
                width: MediaQuery.of(context).size.width,
                child: ListView(children: [
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
                ])),
          ]),
          Divider(),
          Container(
            padding: EdgeInsets.only(left: 5, right: 5),
            margin: EdgeInsets.only(top: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Attendees' email address:"),
                TextField(
                  controller: _controllers["attendees"],
                  decoration: InputDecoration(
                      hintText:
                          "Use ',' to sperate multiple email address if needed",
                      hintStyle: TextStyle(fontSize: 12)),
                  maxLines: 1,
                  minLines: 1,
                  inputFormatters: [
                    FilteringTextInputFormatter.singleLineFormatter
                  ],
                )
              ],
            ),
          )
        ]),
      ),
    );
  }
}
