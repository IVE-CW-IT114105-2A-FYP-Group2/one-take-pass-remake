import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:one_take_pass_remake/themes.dart';

@Deprecated('This should be integrated when needed')
class LinkGoogleNotify extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("This service requires to link to Google",
                style: TextStyle(fontSize: 24), textAlign: TextAlign.center),
            Padding(
              padding: EdgeInsets.only(top: 25),
            ),
            Icon(Icons.login_rounded, size: 120),
            Padding(
              padding: EdgeInsets.only(top: 100),
            ),
            _actionButton(context, "Link to Google", () {}, Colors.blue),
            _actionButton(context, "Do it later", () {
              Navigator.pop(context);
            }, OTPColour.light2),
          ],
        ),
      ),
    );
  }
}

Container _actionButton(
    BuildContext context, String btnTxt, Function onPress, Color colour,
    [Color txtColour = Colors.white]) {
  final double _clickBtnH = 60;
  return Container(
    margin: EdgeInsets.only(top: 10, bottom: 10),
    width: MediaQuery.of(context).size.width - 10,
    height: _clickBtnH,
    child: MaterialButton(
      color: colour,
      child: Text(btnTxt,
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.w400, color: txtColour)),
      onPressed: onPress,
    ),
  );
}
