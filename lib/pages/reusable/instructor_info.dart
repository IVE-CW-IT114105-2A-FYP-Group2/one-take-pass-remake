import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:one_take_pass_remake/api/userdata/users.dart';
import 'package:one_take_pass_remake/pages/reusable/chatting.dart';
import 'package:one_take_pass_remake/pages/subpages/inbox.dart'
    show contactKeyName;
import 'package:one_take_pass_remake/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

///A page about instructor
class InstructorInfo extends StatelessWidget {
  final Instructor instructor;

  InstructorInfo({@required this.instructor});

  ///Append toinbox list when clicked
  Future<void> _addToListInInbox(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> existedChatUser;
    try {
      existedChatUser = prefs.getStringList(contactKeyName);
      if (existedChatUser == null) {
        throw "Need to be initalized";
      }
    } catch (read_fail) {
      existedChatUser = [];
    }
    if (existedChatUser.isNotEmpty) {
      if (existedChatUser.contains(name)) {
        return;
      }
    }
    existedChatUser.add(name);
    await prefs.setStringList(contactKeyName, existedChatUser);
  }

  ///Heading definitions
  Widget _heading(BuildContext context) {
    Widget _img(String url) {
      if (url != "") {
        return CircleAvatar(
          backgroundImage: NetworkImage(url),
          maxRadius: 36,
        );
      }
      return Container(
        child: Icon(
          CupertinoIcons.person,
          size: 48,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _img(""),
        Padding(padding: EdgeInsets.only(right: 10)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              instructor.name,
              style: TextStyle(fontSize: 24),
            ),
            //InstructorRating(context: context, rate: instructor.rating)
          ],
        )
      ],
    );
  }

  ///Show details of instructor
  Widget _details() {
    return Container(
      //color: OTPColour.light2,
      margin: EdgeInsets.only(top: 10, bottom: 5),
      padding: EdgeInsets.all(7.5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(7.5)),
          color: OTPColour.light2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Description: " + instructor.desc,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24)),
          Text("Personality: " + PersonalityGetter(instructor.personality).str,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
          /*Text(
              "Language: " +
                  SpeakingLanguageGetter(instructor.speakingLanguage).str,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300)),*/
          Text("District: " + HKDistrictGetter(instructor.hkDistrict).str,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300)),
          Text("Vehicles: " + instructor.vehicles,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(instructor.name),
      ),
      body: ListView(
        padding: EdgeInsets.only(left: 10, right: 10, top: 10),
        children: [
          _heading(context),
          _details(),
          Divider(color: colourPicker(128, 128, 128, 120)),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width / 1.25,
              height: 50,
              child: MaterialButton(
                color: OTPColour.light1,
                onPressed: () async {
                  await _addToListInInbox(instructor.name);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ChatComm(name: instructor.name)));
                },
                child: Text(
                  "Open chat",
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
