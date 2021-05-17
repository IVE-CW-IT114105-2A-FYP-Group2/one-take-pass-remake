import 'dart:async';
import 'dart:convert';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart' show DateFormat;
import 'package:intl/date_symbol_data_local.dart';
import 'package:one_take_pass_remake/api/calendar/calendar.dart';
import 'package:one_take_pass_remake/api/url/localapiurl.dart';
import 'package:one_take_pass_remake/api/userdata/login_request.dart';
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
  static final List<String> _availableCarTypes = [
    "Private Car",
    "Goods Vehicle",
    "Bus"
  ];

  final Map<int, bool> _wdMapper = {
    DateTime.monday: false,
    DateTime.tuesday: false,
    DateTime.wednesday: false,
    DateTime.thursday: false,
    DateTime.friday: false,
    DateTime.saturday: false,
    DateTime.sunday: false
  };

  String _currentCarType = _availableCarTypes[0];

  ///Controller for [TextField]
  Map<String, TextEditingController> _controllers;

  ///A mapped object that define start and end
  Map<String, DateTime> _eventsMap = {
    //Assume start immediately
    "start": DateTime.now(),
    //Assume the event will be held one hour
    "end": DateTime.now().add(Duration(hours: 1))
  };

  CoursesCalendar _courseMaker(String title, String carType,
      DateTime startRange, DateTime endRange, Map<int, bool> repeatedWeekdate) {
    TimeRange _dtToRESTJsonFactory(DateTime start, DateTime end) {
      String exporter(DateTime dt) {
        // Default uses en_US which SWAPPED POSITION OF MONTH AND DATE
        String date = DateFormat.yMd('en_GB').format(dt).replaceAll("/", "-");
        String time = DateFormat.Hm('en_GB').format(dt) + ":00";
        return date + " " + time;
      }

      return TimeRange(startTime: exporter(start), endTime: exporter(end));
    }

    List<TimeRange> _coursesTimeFactory(DateTime start, DateTime end) {
      List<TimeRange> coursesTime = [];
      DateTime chdt = start; //Current handle date time
      int rangeInSec() {
        int toSec(DateTime t) =>
            (t.hour * 60 * 60) + (t.minute * 60) + t.second;
        return toSec(end) - toSec(start);
      }

      while (end.isAfter(chdt)) {
        if (repeatedWeekdate[chdt.weekday]) {
          DateTime chdte = chdt.add(Duration(seconds: rangeInSec()));
          coursesTime.add(_dtToRESTJsonFactory(chdt, chdte));
        }
        chdt = chdt.add(Duration(days: 1));
      }

      return coursesTime;
    }

    return CoursesCalendar(
        title, carType, _coursesTimeFactory(startRange, endRange));
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    _controllers = {"summary": TextEditingController()};
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
    List<CheckboxListTile> _weekDayPickers() {
      List<CheckboxListTile> pickers = [];
      _wdMapper.forEach((weekday, isRepeated) {
        pickers.add(CheckboxListTile(
          value: isRepeated,
          onChanged: (bool newVal) {
            setState(() {
              _wdMapper[weekday] = newVal;
            });
          },
          title: Text((<String>() {
            switch (weekday) {
              case DateTime.monday:
                return "Monday";
              case DateTime.tuesday:
                return "Tuesday";
              case DateTime.wednesday:
                return "Wednesday";
              case DateTime.thursday:
                return "Thursday";
              case DateTime.friday:
                return "Friday";
              case DateTime.saturday:
                return "Saturday";
              case DateTime.sunday:
                return "Sunday";
            }
          })()),
        ));
      });
      return pickers;
    }

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
                  Map<String, dynamic> course;
                  try {
                    course = _courseMaker(
                            _controllers["summary"].text,
                            _currentCarType,
                            _eventsMap["start"],
                            _eventsMap["end"],
                            _wdMapper)
                        .toJson;
                  } catch (invalid_set) {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text("Date and time setting error"),
                              content: Text(
                                  "The weekday you did not picked or picked out of the range"),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("OK"))
                              ],
                            ));
                    return;
                  }

                  //Get token before submit
                  UserTokenLocalStorage.getToken().then((token) {
                    course["refresh_token"] = token;
                    return jsonEncode(course);
                  }).then((restCourse) async {
                    var dio = Dio();
                    dio.options.headers["Content-Type"] = "application/json";
                    var resp = await dio.post(
                        APISitemap.courseControl("add").toString(),
                        data: restCourse);
                  }).then((_) {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text("The courses has been created"),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("OK"))
                              ],
                            )).then((_) {
                      //Auto exit
                      Navigator.pop(context);
                    });
                  }).onError((_, __) {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text("Network error"),
                              content: Text("Please try again later"),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("OK"))
                              ],
                            ));
                  });
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
                Divider(),
                Text("Car type"),
                DropdownButton<String>(
                  value: _currentCarType,
                  items: _availableCarTypes
                      .map<DropdownMenuItem<String>>(
                          (String carType) => DropdownMenuItem(
                                child: Text(carType),
                                value: carType,
                              ))
                      .toList(),
                  onChanged: (String carType) {
                    setState(() {
                      _currentCarType = carType;
                    });
                  },
                  isExpanded: true,
                ),
                Divider(),
                Text("On every:"),
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: 200,
                    child: ListView(children: _weekDayPickers()))
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class OTPListExistedCourses extends StatefulWidget {
  Future<List<CoursesCalendar>> get ownerCourses async {
    List<CoursesCalendar> buffer = [];
    var dio = Dio();
  }

  @override
  State<StatefulWidget> createState() => _OTPListExistedCourses();
}

class _OTPListExistedCourses extends State<OTPListExistedCourses> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CoursesCalendar>>(builder: (context, snapshot) {
      return null;
    });
  }
}
