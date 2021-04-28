import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:one_take_pass_remake/api/misc.dart';
import 'package:one_take_pass_remake/api/url/localapiurl.dart';
import 'package:one_take_pass_remake/pages/reusable/instructor_info.dart';
import 'package:one_take_pass_remake/themes.dart';
import 'package:one_take_pass_remake/api/userdata/users.dart';

class OTPHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(5),
      child: _FindDriver(),
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
    var resp =
        await dio.post(APISitemap.findInstructor.toString(), data: {"key": ""});
    //Get result data
    print(resp.data);
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
