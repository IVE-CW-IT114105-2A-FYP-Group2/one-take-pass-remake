import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_take_pass_remake/pages/reusable/chatting.dart';
import 'package:shared_preferences/shared_preferences.dart';

final String contactKeyName = "otp_instructor_contact";

class OTPInbox extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OTPInbox();
}

class _OTPInbox extends State<OTPInbox> {
  Future<List<String>> _chattedInstructorList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(contactKeyName);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
        future: _chattedInstructorList(),
        builder: (context, result) {
          if (result.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [CircularProgressIndicator()],
              ),
            );
          } else if (result.hasData) {
            return ListView.builder(
              itemCount: result.data.length,
              itemBuilder: (context, count) => MaterialButton(
                  padding: EdgeInsets.all(15),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person,
                          size: 48,
                        ),
                        Text(
                          result.data[count],
                          style: TextStyle(fontSize: 16),
                        )
                      ]),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ChatComm(name: result.data[count])));
                  }),
            );
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
                  Padding(
                      padding: EdgeInsets.all(15),
                      child: Text("Reading existed list failed"))
                ],
              ),
            );
          }
        });
  }
}
