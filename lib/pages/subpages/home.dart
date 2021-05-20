import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:one_take_pass_remake/api/calendar/calendar.dart';
import 'package:one_take_pass_remake/api/misc.dart';
import 'package:one_take_pass_remake/api/url/localapiurl.dart';
import 'package:one_take_pass_remake/api/userdata/login_request.dart'
    show UserREST, UserTokenLocalStorage;
import 'package:one_take_pass_remake/pages/reusable/indentity_widget.dart';
import 'package:one_take_pass_remake/pages/reusable/instructor_info.dart';
import 'package:one_take_pass_remake/themes.dart';
import 'package:one_take_pass_remake/api/userdata/users.dart';

class OTPHome extends StatelessWidget with IdentityWidget {
  OTPHome(UserREST restData) {
    this.currentIdentity = restData;
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(5),
      child: (roleName == "privateDrivingInstructor")
          ? _IncomingRequest()
          : _FindDriver(),
    );
  }
}

class _FindDriver extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FindDriverUI();
}

class _FindDriverUI extends State<_FindDriver> {
  TextEditingController _controller;
  String _keyword = "";

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: (MediaQuery.of(context).size.width * 2) / 3,
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 1,
                decoration: InputDecoration(labelText: "Instructor's name"),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 3 - 20,
              margin: EdgeInsets.only(top: 12.5),
              child: MaterialButton(
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
                child: Text(
                  "Search",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onPressed: () {
                  _keyword = _controller.text ?? "";
                  _keyword.replaceAll(RegexLibraries.whiteSpaceOnStart, "");
                  setState(() {}); //Trigger new build with keyword
                },
                color: OTPColour.light1,
              ),
            )
          ],
        ),
        Expanded(
            child: Container(
                margin: EdgeInsets.only(top: 20, left: 10, right: 10),
                child: Builder(
                    //Parse keyword to a widget which handling result
                    builder: (context) => _SearchList(keyword: _keyword))))
      ],
    );
  }
}

class _SearchList extends StatelessWidget {
  final String keyword;
  _SearchList({@required this.keyword});

  Future<List<Instructor>> fetchSearch(String keyword) async {
    var dio = Dio();
    dio.options.headers["Content-Type"] = "application/json";
    var resp = await dio
        .post(APISitemap.findInstructor.toString(), data: {"key": keyword});
    //Get result data
    //print(resp.data);
    List<Instructor> placeholder = [];
    resp.data.forEach((ijson) {
      placeholder.add(Instructor.fromJSON(ijson));
    });
    return placeholder;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchSearch(keyword),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            //When fetching data
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          //Fetched data events
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, count) => Container(
                child: MaterialButton(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.person, size: 36),
                      Text(snapshot.data[count].name,
                          style: TextStyle(fontSize: 24))
                    ],
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InstructorInfo(
                                instructor: snapshot.data[count])));
                  },
                ),
              ),
            );
          } else if (snapshot.hasError) {
            //Error
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.xmark_circle,
                    size: 120,
                  ),
                  Text(
                    "No user found",
                    style: TextStyle(fontSize: 24),
                  )
                ],
              ),
            );
          }
          //I don't know what status is it
          return Center();
        });
  }
}

///Instructor exclusive page for accepting or rejecting student to attnd the courses
class _IncomingRequest extends StatefulWidget {
  Future<List<CoursesCalendar>> get orderedCourses async {
    List<CoursesCalendar> buffer = [];
    var dio = Dio();
    dio.options.headers["Content-Type"] = "application/json";
    var resp = await dio.post(APISitemap.courseControl("order").toString(),
        data: jsonEncode(
            {"refresh_token": (await UserTokenLocalStorage.getToken())}));
    (resp.data as List<dynamic>).forEach((jsonObj) {
      buffer.add(CoursesCalendar.fromJson(jsonObj));
    });
    return buffer;
  }

  @override
  State<StatefulWidget> createState() => _IncomingRequestUI();
}

class _IncomingRequestUI extends State<_IncomingRequest> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CoursesCalendar>>(
      future: widget.orderedCourses,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (snapshot.hasData) {
            return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(children: [
                  Padding(
                    child: Text(
                      "Incoming request from students",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    padding: EdgeInsets.only(bottom: 5),
                  ),
                  Expanded(
                      child: ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, count) => GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => _CourseDetail(
                                            courses: snapshot.data[count])));
                              },
                              child: Container(
                                  alignment: Alignment.centerLeft,
                                  height: 80,
                                  width: MediaQuery.of(context).size.width,
                                  decoration:
                                      BoxDecoration(color: OTPColour.light2),
                                  margin: EdgeInsets.all(2.5),
                                  padding: EdgeInsets.all(5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        snapshot.data[count].title,
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      Text("Durations:"),
                                      Text((<String>() {
                                        var start = snapshot.data[count]
                                                .courseTime.first.startTime,
                                            end = snapshot.data[count]
                                                .courseTime.last.endTime;
                                        return start + " - " + end;
                                      }()))
                                    ],
                                  ))))),
                  Container(
                      margin: EdgeInsets.all(10),
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      child: MaterialButton(
                        onPressed: () {
                          setState(() {});
                        },
                        child: Text("Reload"),
                        color: OTPColour.light2,
                      ))
                ]));
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.xmark_circle,
                    size: 120,
                  ),
                  Text(
                    "Sorry, we can't fetch incoming request",
                    style: TextStyle(fontSize: 24),
                  ),
                  Container(
                      margin: EdgeInsets.all(10),
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      child: MaterialButton(
                        onPressed: () {
                          setState(() {});
                        },
                        color: OTPColour.light2,
                        child: Text("Reload"),
                      ))
                ],
              ),
            );
          }
        }
      },
    );
  }
}

class _CourseDetail extends StatelessWidget {
  ///Contain courses
  final CoursesCalendar courses;

  _CourseDetail({@required this.courses});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Request detail"),
        centerTitle: true,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        margin: EdgeInsets.all(5),
        child: Column(
          children: [
            Expanded(
                child: ListView(
              children: [
                Text(
                  "Course title",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                Text(courses.title, style: TextStyle(fontSize: 18)),
                Divider(indent: 5),
                Text(
                  "Vehicle type",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                Text(courses.vehicleType, style: TextStyle(fontSize: 18)),
                Divider(indent: 5),
                Text(
                  "Timetable",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 300,
                  child: ListView.builder(
                      itemCount: courses.courseTime.length,
                      itemBuilder: (context, count) {
                        var dtObj = courses.courseTime[count].parsedToDateTime;
                        String getDate(DateTime dt) {
                          return dt.year.toString() +
                              "-" +
                              dt.month.toString() +
                              "-" +
                              dt.day.toString();
                        }

                        String getTime(DateTime dt) {
                          return ((dt.hour < 10) ? "0" : "") +
                              dt.hour.toString() +
                              ":" +
                              ((dt.minute < 10) ? "0" : "") +
                              dt.minute.toString();
                        }

                        return Container(
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          alignment: Alignment.center,
                          margin: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 2, color: OTPColour.dark1)),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Date: " + getDate(dtObj["start"]),
                                  style: TextStyle(fontSize: 16),
                                ),
                                Padding(
                                    padding:
                                        EdgeInsets.only(left: 10, right: 10)),
                                Text(
                                  "Time: " +
                                      getTime(dtObj["start"]) +
                                      " - " +
                                      getTime(dtObj["stop"]),
                                  style: TextStyle(fontSize: 16),
                                )
                              ]),
                        );
                      }),
                )
              ],
            )),
            Container(
                width: MediaQuery.of(context).size.width,
                height: 40,
                margin: EdgeInsets.all(5),
                child: MaterialButton(
                  color: OTPColour.light2,
                  child: Text("Accept this course request"),
                  onPressed: () {},
                ))
          ],
        ),
      ),
    );
  }
}
