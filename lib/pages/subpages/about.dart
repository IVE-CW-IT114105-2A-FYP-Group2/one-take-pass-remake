import 'package:flutter/material.dart';
import 'package:one_take_pass_remake/pages/login.dart';
import 'package:one_take_pass_remake/themes.dart';

class OTPAbout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(children: [
      Container(
        width: MediaQuery.of(context).size.width - 10,
        child: MaterialButton(
          color: OTPColour.mainTheme,
          child: Text("Logout",
              style: TextStyle(fontSize: 16, color: Colors.white)),
          onPressed: () {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                      title: Text("Logout"),
                      content: Text("Do you want to logout?"),
                      actions: <Widget>[
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            child: Text(
                              "Yes",
                              style: TextStyle(color: Colors.red),
                            )),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            child: Text("No"))
                      ],
                    )).then((doLogout) {
              //Check returned data that is required logout
              if (doLogout) requireLogin(ModalRoute.of(context), context);
            });
          },
        ),
      )
    ]));
  }
}
