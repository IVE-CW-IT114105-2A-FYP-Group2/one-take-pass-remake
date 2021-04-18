import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:one_take_pass_remake/themes.dart';

abstract class Question {
  String _question;
  List<Answer> _choice;

  void setQuestion(String question) {
    this._question = question;
  }

  void setChoice(List<Answer> choice) {
    this._choice = choice;
  }

  Widget interface(Function onCorrect, Function onWrong);

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
  Widget interface(Function onCorrect, Function onWrong) {
    return Container(
      child: Column(children: [
        Text(
          question,
          style: TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
        Padding(padding: EdgeInsets.all(10)),
        Container(
            height: 250,
            child: ListView.builder(
                itemCount: choice.length,
                itemBuilder: (context, qNo) => MaterialButton(
                      onPressed: choice[qNo].isCorrect ? onCorrect : onWrong,
                      child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            choice[qNo].answerString,
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          )),
                      color: OTPColour.dark1,
                    ))),
      ]),
    );
  }
}

class Answer {
  final bool isCorrect;
  final String answerString;
  Answer({@required this.answerString, @required this.isCorrect});
}
