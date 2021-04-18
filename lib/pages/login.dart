import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:one_take_pass_remake/api/userdata/login_request.dart';
import 'package:one_take_pass_remake/pages/index.dart';

class OTPLogin extends StatelessWidget {
  static bool _isLogin = true;

  ///Check authencation
  Future<String> _authUser(LoginData lD) async {
    _isLogin = true;
    UserInfoHandler uih = new UserInfoHandler(lD.name, lD.password);
    UserREST restData = UserREST(
        fullName: "Sia Tao",
        phoneNo: "91234567",
        roles: "student"); //await uih.getUserRest();
    switch (restData.roles) {
      case "errors_user":
        return "User not found or wrong password"; //When user not found
      case "errors_server":
        return "There is an error from server, please try again later"; //When server malfunction
      case "student":
      case "instructor":
        await UserLocalStorage.saveUser(restData);
        return null; //Use null for success according to API reference
      case "staff":
        return "Staff account is not allowed to login the mobile app";
    }
    return "Unexpected role";
  }

  //Future<String>

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
        title: "One Take Pass",
        onLogin: _authUser,
        onSignup: (lD) async {
          String errMsg = null;
          int stage = 0;
          int gender = -1; //0 = male, 1 = female
          int role = -1; //0 = students, 1 = instructor
          await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => SimpleDialog(
                    title: Text("Gender"),
                    children: [
                      SimpleDialogOption(
                        child: Text("Male"),
                        onPressed: () {
                          gender = 0;
                          Navigator.pop(context);
                        },
                      ),
                      SimpleDialogOption(
                        child: Text("Female"),
                        onPressed: () {
                          gender = 1;
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ));
          await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => SimpleDialog(
                    title: Text("Roles"),
                    children: [
                      SimpleDialogOption(
                        child: Text("Student"),
                        onPressed: () {
                          role = 0;
                          Navigator.pop(context);
                        },
                      ),
                      SimpleDialogOption(
                        child: Text("Instructor"),
                        onPressed: () {
                          role = 1;
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ));
          _isLogin = false;
          if (gender == -1 || role == -1) {
            errMsg = "Please complete all selections of the dialogs";
          }
          return errMsg;
        },
        onSubmitAnimationCompleted: () {
          if (_isLogin) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => OTPIndex()));
          } else {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title:
                          Text("Your account has been created successfully!"),
                      actions: [
                        TextButton(
                            onPressed: () {
                              requireLogin(ModalRoute.of(context), context);
                            },
                            child: Text("Back to login page"))
                      ],
                    ));
          }
        },
        onRecoverPassword: (_) {
          Future<String> getMsg() async {
            return Future.delayed(Duration(seconds: 1)).then((_) =>
                "Currently we may not handle forget password function, please content customer service if encounter login problems.");
          }

          return getMsg();
        },
        messages: LoginMessages(
          usernameHint: "Phone No.",
        ),
        emailValidator: (phoneNo) =>
            _isPhoneNum(phoneNo) ? null : "Please enter valid phone number");
  }
}

///Trigger login if user is not login yet
void requireLogin(Route currentRoute, BuildContext context) {
  //Naviaate
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
