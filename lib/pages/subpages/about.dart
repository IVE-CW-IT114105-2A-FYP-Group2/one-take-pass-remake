import 'package:flutter/material.dart';
import 'package:one_take_pass_remake/api/userdata/login_request.dart';
import 'package:one_take_pass_remake/pages/login.dart';
import 'package:one_take_pass_remake/pages/reusable/link_google.dart';
import 'package:one_take_pass_remake/themes.dart';

class OTPAbout extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OTPAbout();
}

class _OTPAbout extends State<OTPAbout> {
  _GoogleLink _gl = new _GoogleLink();
  bool _status = true;
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(children: [
      Padding(padding: EdgeInsets.only(top: 10)),
      Container(
        width: MediaQuery.of(context).size.width - 10,
        child: MaterialButton(
          padding: EdgeInsets.all(10),
          color: Colors.blue,
          child: Text((_status ? "Unlink" : "Link") + " to Google",
              style: TextStyle(fontSize: 16, color: Colors.white)),
          onPressed: () {
            if (!_status) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LinkGoogleNotify()));
            }
            _status = !_status;
            setState(() {});
          },
        ),
      ),
      Padding(padding: EdgeInsets.only(top: 5)),
      Container(
        width: MediaQuery.of(context).size.width - 10,
        child: MaterialButton(
          padding: EdgeInsets.all(10),
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
              if (doLogout) {
                UserLocalStorage.clearUser().then((_) {
                  requireLogin(ModalRoute.of(context), context);
                });
              }
            });
          },
        ),
      )
    ]));
  }
}

class _GoogleLink {
  bool _islinked = false;
  bool get status {
    return _islinked;
  }
}
