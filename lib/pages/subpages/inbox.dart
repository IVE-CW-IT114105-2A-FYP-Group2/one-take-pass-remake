import 'package:flutter/material.dart';
import 'package:one_take_pass_remake/pages/reusable/chatting.dart';

class OTPInbox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        MaterialButton(
            child: Text("Sample"),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatComm(name: "Sample")));
            })
      ],
    );
  }
}
