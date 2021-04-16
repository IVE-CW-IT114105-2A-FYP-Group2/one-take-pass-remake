import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

///User data from REST
class UserREST {
  final String phoneNo;
  final String roles;
  final String fullName;

  UserREST({this.phoneNo, this.roles, this.fullName});

  factory UserREST.fromJSON(Map<String, dynamic> json) {
    return UserREST(
        phoneNo: json['phoneNo'].toString(),
        roles: json['type'],
        fullName: json['u_name']);
  }

  Map<String, dynamic> toJson() =>
      {'phoneNo': int.tryParse(phoneNo), 'type': roles, 'u_name': fullName};
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
    var dio = Dio();
    try {
      FormData f = FormData.fromMap({'phoneno': _phone, 'password': _pwd});
      var resp = await dio.post(Uri.https(_apiUrl, '').toString(), data: f);
      if (resp.statusCode >= 400) {
        throw "Server error";
      }
      try {
        return UserREST.fromJSON(resp.data); //Auto convert from json to object
      } catch (nouser) {
        return UserREST(phoneNo: "", roles: "errors_user", fullName: "");
      }
    } catch (e) {
      return UserREST(fullName: "", phoneNo: "", roles: "errors_server");
    }
  }
}

class UserLocalStorage {
  static final String _define = "otp_userrest";
  static Future<void> saveUser(UserREST uR) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_define, jsonEncode(uR.toJson()));
  }

  static Future<UserREST> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return UserREST.fromJSON(jsonDecode(prefs.getString(_define)));
  }

  static Future<void> clearUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(_define);
  }
}
