import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_take_pass_remake/api/elearning/questions.dart';
import 'package:one_take_pass_remake/themes.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

///E-Learning interface
///
class OTPELearning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: ListView(
        children: [
          _writtenTest(),
          Padding(padding: EdgeInsets.only(top: 10, bottom: 10)),
          _roadTest(),
          Padding(padding: EdgeInsets.only(top: 10, bottom: 10)),
        ],
      ),
    );
  }
}

///Make sub-title
Text _subTitle(String title) {
  return Text(title,
      style: TextStyle(decoration: TextDecoration.underline, fontSize: 24));
}

///A completed module of the button
///
///Define [icon] symbol, then show button text in [label] and define functions in [onclick]
MaterialButton _elButton(IconData icon, String label, Function onclick) {
  return MaterialButton(
      padding: EdgeInsets.all(5),
      color: OTPColour.light1,
      child: Row(
        children: [
          Icon(icon, size: 24),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              label,
              style: TextStyle(fontSize: 20),
            ),
          )
        ],
      ),
      onPressed: onclick);
}

///Entire module of written test
Column _writtenTest() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _subTitle("Written Test"),
      //Text-only questions
      _elButton(
          FontAwesomeIcons.wordpressSimple, "Text-only Questions", () => {}),
      //End text-only question
      Padding(padding: EdgeInsets.all(10)),
      //Symbol questions
      _elButton(FontAwesomeIcons.road, "Symbol Questions", () => {}),
      //End symbol questions
      Padding(padding: EdgeInsets.all(10)),
      //Combine questions
      _elButton(FontAwesomeIcons.chartBar, "Combine Questions", () => {}),
      //End combine questions
      Padding(padding: EdgeInsets.all(10)),
      //Mock written test
      _elButton(FontAwesomeIcons.pencilRuler, "Mock Written Test", () => {})
      //End mock written test
    ],
  );
}

Column _roadTest() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _subTitle("Road Test"),
      //Driving skill videos
      _elButton(FontAwesomeIcons.prayingHands, "Driving Skill Video", () => {}),
      //End driving skill video
      Padding(padding: EdgeInsets.all(10)),
      //Road exam video
      _elButton(FontAwesomeIcons.car, "Road Exam Video", () => {})
      //End road exam video
    ],
  );
}

abstract class _QuestionPage extends StatelessWidget {
  final Questions question;

  _QuestionPage({@required this.question});

  Widget questionWidget();
  Widget answerWidget();

  @override
  Widget build(BuildContext context) {
    if (question == null) {
      return Scaffold(
          body: Expanded(
        child: Center(
          child: Column(
            children: [
              Text("All questions has been asked!"),
              Padding(padding: EdgeInsets.only(top: 50, bottom: 50)),
              MaterialButton(
                  child: Text("Review your result"),
                  minWidth: MediaQuery.of(context).size.width - 100,
                  onPressed: () {})
            ],
          ),
        ),
      ));
    }
    return Scaffold(
        body: Expanded(
      child: Stack(
        children: [
          Positioned(
              top: 32,
              left: 32,
              child: GestureDetector(
                child: Icon(
                  CupertinoIcons.xmark,
                  size: 48,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              )),
          Center(
            child: Column(
              children: [
                questionWidget(),
                Padding(padding: EdgeInsets.only(top: 50, bottom: 50)),
                answerWidget()
              ],
            ),
          )
        ],
      ),
    ));
  }
}

abstract class _AskedAns extends StatelessWidget {
  String _postAskedMsg;
  Color _backgroundColour;
  final _QuestionPage nextQuestion;

  _AskedAns(String postAskedMsg, Color backgroundColour,
      {@required this.nextQuestion}) {
    this._backgroundColour = backgroundColour;
    this._postAskedMsg = postAskedMsg;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text(
              _postAskedMsg,
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.w300),
            ),
            Container(height: MediaQuery.of(context).size.height / 4),
            MaterialButton(
              minWidth: MediaQuery.of(context).size.width - 50,
              child: Text(
                "Next question",
                style: TextStyle(fontSize: 18),
              ),
              onPressed: () {
                //Act like press back button
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => nextQuestion));
              },
            )
          ],
        ),
      ),
    );
  }
}

class _AskedCorrectAns extends _AskedAns {
  final _QuestionPage nextQuestion;
  _AskedCorrectAns({@required this.nextQuestion})
      : super("Correct!", colourPicker(61, 201, 61),
            nextQuestion: nextQuestion);
}

class _AskedWrongAns extends _AskedAns {
  final _QuestionPage nextQuestion;
  _AskedWrongAns({@required this.nextQuestion})
      : super("Incorrect!", colourPicker(194, 12, 12),
            nextQuestion: nextQuestion);
}
