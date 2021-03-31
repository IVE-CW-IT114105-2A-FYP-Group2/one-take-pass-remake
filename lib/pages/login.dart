import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:one_take_pass_remake/pages/index.dart';

const testData = const {"24567111": "castlepeakhospital", "21800000": "kfc"};

class OTPLogin extends StatelessWidget {
  Duration get buffer => Duration(seconds: 5);

  ///Check authencation
  Future<String> _authUser(LoginData lD) {
    Future.delayed(buffer)
        //TODO: Convert to API compatable
        .then((_) {
      if (!testData.containsKey(lD.name)) {
        return "Username and password unmatched!";
      }
      if (testData[lD.name] != lD.password) {
        return "Username and password unmatched!";
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
        title: "One Take Pass",
        onLogin: _authUser,
        onSignup: _authUser,
        onSubmitAnimationCompleted: () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => OTPIndex()));
        },
        onRecoverPassword: (String) {},
        messages: LoginMessages(
          usernameHint: "Phone No.",
        ),
        emailValidator: (phoneNo) =>
            _isPhoneNum(phoneNo) ? null : "Please enter valid phone number");
  }
}

///Trigger login if user is not login yet
void requireLogin(Route currentRoute, BuildContext context) {
  Navigator.replace(context,
      oldRoute: currentRoute,
      newRoute: MaterialPageRoute(builder: (context) => OTPLogin()));
}

///Verify [input] which email originally is insert phone number
bool _isPhoneNum(String input) {
  if (input == null) {
    return false;
  } else if (input.length < 8) {
    return false;
  }
  int intPhoneNo = int.tryParse(input);
  if (intPhoneNo != null) {
    if (intPhoneNo >= 0) {
      return true;
    }
  }
  return false;
}
