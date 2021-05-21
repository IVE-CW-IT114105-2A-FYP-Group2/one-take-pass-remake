import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:one_take_pass_remake/api/calendar/calendar.dart';
import 'package:one_take_pass_remake/themes.dart';

class CourseEventPage extends StatelessWidget {
  final bool isStudent;
  final PersonalCourseEvent event;

  CourseEventPage({@required this.event, this.isStudent = false});

  Container _infoContainer(List<Widget> infoWidget) {
    return Container(
      margin: EdgeInsets.only(top: 5, bottom: 5),
      padding: EdgeInsets.all(7.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(3)),
        color: OTPColour.light2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: infoWidget,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> view = <Widget>[
      _infoContainer([
        Text("Date:",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500)),
        Text(
          DateFormat("EEEE, d MMMM yyyy")
              .format(event.range.parsedToDateTime["start"]),
          style: TextStyle(fontSize: 18),
        )
      ]),
      _infoContainer([
        Text("Time:",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500)),
        Text(
          (DateFormat.Hm().format(event.range.parsedToDateTime["start"]) +
              " - " +
              DateFormat.Hm().format(event.range.parsedToDateTime["stop"])),
          style: TextStyle(fontSize: 18),
        )
      ]),
      _infoContainer([
        Text((isStudent ? "Instructor" : "Student") + "'s phone number:",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
        Text(
          isStudent ? event.insPhono : event.stdPhono,
          style: TextStyle(fontSize: 18),
        )
      ])
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
        centerTitle: true,
      ),
      body: Container(
        margin: EdgeInsets.all(5),
        child: ListView(children: view),
      ),
    );
  }
}
