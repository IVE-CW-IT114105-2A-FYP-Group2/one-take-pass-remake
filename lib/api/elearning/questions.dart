import 'package:flutter/widgets.dart';

abstract class Question {
  String _question;
  List<Answer> _choice;

  void setQuestion(String question) {
    this._question = question;
  }

  void setChoice(List<Answer> choice) {
    this._choice = choice;
  }

  Widget interface();

  String get question {
    return _question;
  }

  List<Answer> get choice {
    return _choice;
  }
}

class TextQuestion extends Question {
  TextQuestion(String question, List<Answer> choice) {
    this.setQuestion(question);
    this.setChoice(choice);
  }
  @override
  Widget interface() {
    return Container(
      child: Column(
        children: [
          Text(
            question,
            style: TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
          Padding(padding: EdgeInsets.all(10)),
        ],
      ),
    );
  }
}

class Answer {
  final bool isCorrect;
  bool isSelected = false;
  final String answerString;
  Answer({@required this.answerString, @required this.isCorrect});
}
