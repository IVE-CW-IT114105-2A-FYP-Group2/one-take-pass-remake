import 'package:flutter/material.dart';
import 'package:one_take_pass_remake/pages/reusable/chatting.dart';
import 'package:shared_preferences/shared_preferences.dart';

final String contentKey = "otp_chat_name";

Future<List<String>> get currentContent async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    return prefs.getStringList(contentKey);
  } catch (err) {
    return [];
  }
}

class OTPInbox extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OTPInbox();
}

class _OTPInbox extends State<OTPInbox> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
        future: currentContent,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data.length,
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
                            snapshot.data[count],
                            style: TextStyle(fontSize: 16),
                          )
                        ]),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ChatComm(name: snapshot.data[count])));
                    }));
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                      "Instructors will be appeared when you found and started chatting")
                ],
              ),
            );
          }
        });
  }
}
