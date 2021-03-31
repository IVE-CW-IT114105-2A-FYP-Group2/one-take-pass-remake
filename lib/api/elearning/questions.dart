import 'package:flutter/widgets.dart';

abstract class Question {
  Widget questionContent();
  List<AnswerChoice> answers;
}

class AnswerChoice {
  final Widget ui;
  final bool isCorrect;
  AnswerChoice({@required this.ui, this.isCorrect});
}
