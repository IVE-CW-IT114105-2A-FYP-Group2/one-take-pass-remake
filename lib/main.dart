import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_take_pass_remake/pages/index.dart';
import 'package:one_take_pass_remake/pages/login.dart';
import 'package:one_take_pass_remake/themes.dart';

///Rebuild version of one take pass for fitting chatting functions
void main() async {
  runApp(OneTakePass());
}

class OneTakePass extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'One Take Pass',
        localizationsDelegates: <LocalizationsDelegate<dynamic>>[
          DefaultMaterialLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate, //Remain iOS theme there
          DefaultWidgetsLocalizations.delegate
        ],
        theme: OTPMaterialTheme.apply().getInstanct(),
        home: OTPIndex());
  }
}
