import 'package:flutter/material.dart';
import 'package:one_take_pass_remake/pages/reusable/chatting.dart';

class OTPInbox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        MaterialButton(
            padding: EdgeInsets.all(15),
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Icon(
                Icons.person,
                size: 48,
              ),
              Text(
                "John Siu",
                style: TextStyle(fontSize: 16),
              )
            ]),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatComm(name: "John Siu")));
            })
      ],
    );
  }
}
