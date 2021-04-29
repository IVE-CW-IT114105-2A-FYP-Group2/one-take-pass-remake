import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:one_take_pass_remake/api/userdata/login_request.dart';
import 'package:one_take_pass_remake/pages/index.dart' show UserIdentify;
import 'package:one_take_pass_remake/pages/login.dart';
//import 'package:one_take_pass_remake/pages/reusable/link_google.dart';
import 'package:one_take_pass_remake/themes.dart';

class OTPAbout extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OTPAbout();
}

///Get current username from server, [UserIdentify] just verify is user existed
Future<String> get _currentUsername async {
  return (await UserAPIHandler.getUserRest(
          await UserTokenLocalStorage.getToken()))
      .fullName;
}

class _OTPAbout extends State<OTPAbout> {
  //_GoogleLink _gl = new _GoogleLink();
  //bool _status = true;
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(children: [
      Padding(padding: EdgeInsets.only(top: 10)),
      /*Container(
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
      Padding(padding: EdgeInsets.only(top: 5)),*/
      Expanded(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              size: 120,
            ),
            FutureBuilder<String>(
              future: _currentUsername,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    snapshot.data,
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w300),
                  );
                } else {
                  //Return nothing if failed
                  return Text("",
                      style:
                          TextStyle(fontSize: 36, fontWeight: FontWeight.w300));
                }
              },
            )
          ],
        ),
      )),
      Container(
        width: MediaQuery.of(context).size.width - 10,
        child: MaterialButton(
          padding: EdgeInsets.all(10),
          color: OTPColour.mainTheme,
          child: Text("Edit profile",
              style: TextStyle(fontSize: 16, color: Colors.white)),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => EditProfile()));
          },
        ),
      ),
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
                UserTokenLocalStorage.clearToken().then((_) {
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

/*class _GoogleLink {
  bool _islinked = false;
  bool get status {
    return _islinked;
  }
}*/

class EditProfile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EditProfile();
}

class _EditProfile extends State<EditProfile> {
  TextEditingController _nameController;
  Map<String, bool> _genderRadio = {"M": false, "F": false};

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  Widget optionUI(UserREST receivedInfo) {
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10, top: 5),
      child: ListView(
        children: [
          TextField(
            decoration: InputDecoration(labelText: "Name"),
          ),
          Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Gender",
                style: TextStyle(fontSize: 24),
              ),
              RadioListTile(
                value: true,
                groupValue: "gender",
                onChanged: (_) {},
                title: Text("Male"),
                selected: true,
              ),
              RadioListTile(
                value: false,
                groupValue: "gender",
                onChanged: (_) {},
                title: Text("Feale"),
              )
            ],
          ),
          Divider(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Save",
                  style: TextStyle(color: OTPColour.dark1),
                ))
          ],
        ),
        body: FutureBuilder<UserREST>(
          future: (<UserREST>() async {
            return await UserAPIHandler.getUserRest(
                await UserTokenLocalStorage.getToken());
          })(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return optionUI(snapshot.data);
            } else {
              return Center(
                child: Column(
                  children: [
                    Icon(CupertinoIcons.xmark_circle, size: 120),
                    Text(
                      "We can not get your data right now,\ntry again later",
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              );
            }
          },
        ));
  }
}
