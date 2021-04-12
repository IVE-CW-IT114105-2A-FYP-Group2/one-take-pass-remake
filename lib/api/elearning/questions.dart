import 'package:flutter/widgets.dart';

class Question {
  String _question;
  List<Answer> _choice;
}

class Answer {
  final bool isCorrect;
  bool isSelected = false;
  final String answerString;
  Answer({@required this.answerString, @required this.isCorrect});
}
