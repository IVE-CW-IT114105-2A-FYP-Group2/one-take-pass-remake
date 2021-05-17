import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:one_take_pass_remake/api/url/localapiurl.dart';
import 'package:one_take_pass_remake/api/userdata/login_request.dart';
import 'package:one_take_pass_remake/pages/reusable/chatting.dart';
import 'package:shared_preferences/shared_preferences.dart';

final String contentKey = "otp_chat_name";

Future<List<Map<String, dynamic>>> get currentContent async {
  var dio = Dio();
  dio.options.headers["Content-Type"] = "application/json";
  var resp = await dio.post(APISitemap.chatControl("get_contact").toString(),
      data: jsonEncode(
          {"refresh_token": (await UserTokenLocalStorage.getToken())}));
  return resp.data;
}

class OTPInbox extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OTPInbox();
}

class _OTPInbox extends State<OTPInbox> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
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
                            snapshot.data[count]["name"],
                            style: TextStyle(fontSize: 16),
                          )
                        ]),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatComm(
                                  pickedRESTResult: snapshot.data[count])));
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
