import 'dart:convert';
import 'package:http/http.dart' as http;

///User data from REST
class UserREST {
  final String phoneNo;
  final String roles;
  final String fullName;

  UserREST({this.phoneNo, this.roles, this.fullName});

  factory UserREST.fromJSON(Map<String, dynamic> json) {
    UserREST u;
    try {
      u = UserREST(
          phoneNo: json['phoneNo'],
          roles: json['type'],
          fullName: json['u_name']);
    } catch (e) {
      u = UserREST(phoneNo: "", roles: "errors_user", fullName: "");
    }
    return u;
  }
}

class UserInfoHandler {
  String _phone;
  String _pwd;

  UserInfoHandler(String phone, String pwd) {
    this._phone = phone;
    this._pwd = pwd;
  }

  ///URL of API
  final String _apiUrl = "ivefypgroup2w1offical.azurewebsites.net";

  Future<UserREST> getUserRest() async {
    Uri _site = Uri.https(_apiUrl, 'signin');
    var formVal = {'phoneno': _phone, 'password': _pwd};
    var resp = await http.post(_site,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: formVal,
        encoding: Encoding.getByName("utf-8"));
    if (resp.statusCode >= 400) {
      return UserREST(fullName: "", phoneNo: "", roles: "errors_server");
    } else if (resp.body == "No record found") {
      return UserREST(fullName: "", phoneNo: "", roles: "errors_user");
    }
    return UserREST.fromJSON(jsonDecode(resp.body));
  }
}
