import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
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
}

class UserSessionAPI {
  final CookieJar cookieJar = new CookieJar();
  Future<List<Cookie>> getCookies() async {
    return await cookieJar.loadForRequest(UserInfoHandler.getSigninURI);
  }

  static final String sessionIdKey = "sid";
}

class PostSession extends UserSessionAPI {
  Future<void> saveSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Cookie> cookies = await getCookies();
    String sessionId =
        cookies.firstWhere((element) => element.name == "session").value;
    prefs.setString(UserSessionAPI.sessionIdKey, sessionId);
  }
}

class GetSession extends UserSessionAPI {
  ///Check current session is matched with http's session
  Future<bool> verifySession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Cookie> cookies = await getCookies();
    String sessionId =
        cookies.firstWhere((element) => element.name == "session").value;
    String currentId = prefs.getString(UserSessionAPI.sessionIdKey);
    return currentId == sessionId;
  }

  ///Actually logout
  Future<void> removeSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(UserSessionAPI.sessionIdKey);
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
  static final String _apiUrl = "ivefypgroup2w1offical.azurewebsites.net";

  static Uri get getSigninURI {
    return Uri.https(_apiUrl, '');
  }

  static Uri get getSignoutURI {
    return Uri.https(_apiUrl, 'signout');
  }

  Future<UserREST> getUserRest() async {
    var postSession = new PostSession();
    var dio = Dio();
    dio.interceptors.add(CookieManager(await postSession.cookieJar));
    try {
      FormData f = FormData.fromMap({'phoneno': _phone, 'password': _pwd});
      var resp = await dio.post(getSigninURI.toString(), data: f);
      if (resp.statusCode >= 400) {
        throw "Server error";
      }
      await postSession.saveSession();
      try {
        print(resp.data);
        return UserREST.fromJSON(resp.data); //Auto convert from json to object
      } catch (nouser) {
        return UserREST(phoneNo: "", roles: "errors_user", fullName: "");
      }
    } catch (e) {
      return UserREST(fullName: "", phoneNo: "", roles: "errors_server");
    }
  }
}
