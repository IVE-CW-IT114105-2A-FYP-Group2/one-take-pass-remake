import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_take_pass_remake/api/elearning/questions.dart';
import 'package:one_take_pass_remake/api/url/types.dart';
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
          _writtenTest(context),
          Padding(
              padding: EdgeInsets.only(top: 10, bottom: 2.5),
              child: Divider(color: colourPicker(128, 128, 128, 120))),
          _roadTest(context),
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
Column _writtenTest(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _subTitle("Written Test"),
      //Text-only questions
      _elButton(FontAwesomeIcons.wordpressSimple, "Text-only Questions", () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => _QuestionPage()));
      }),
      //End text-only question
      Padding(padding: EdgeInsets.all(10)),
      //Symbol questions
      _elButton(FontAwesomeIcons.road, "Symbol Questions", () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => _QuestionPage()));
      }),
      //End symbol questions
      Padding(padding: EdgeInsets.all(10)),
      //Combine questions
      _elButton(FontAwesomeIcons.chartBar, "Combine Questions", () {}),
      //End combine questions
      Padding(padding: EdgeInsets.all(10)),
      //Mock written test
      _elButton(FontAwesomeIcons.pencilRuler, "Mock Written Test", () {})
      //End mock written test
    ],
  );
}

Column _roadTest(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _subTitle("Road Test"),
      //Driving skill videos
      _elButton(FontAwesomeIcons.prayingHands, "Driving Skill Video", () {
        URLType.website.exec(
            "youtube.com/playlist?list=PLGJzFdLxDuotoJ0m7VNcSTBB8_Pt5QJE8",
            true);
      }),
      //End driving skill video
      Padding(padding: EdgeInsets.all(10)),
      //Road exam video
      _elButton(FontAwesomeIcons.car, "Road Exam Video", () {
        URLType.website.exec(
            "youtube.com/playlist?list=PLGJzFdLxDuovecmtXlaJKf5Vgr5oT8p4x",
            true);
      })
      //End road exam video
    ],
  );
}

class _QuestionPage extends StatefulWidget {
  List<Question> questions = [
    TextQuestion("Foo", [
      Answer(answerString: "bar", isCorrect: false),
      Answer(answerString: "bar", isCorrect: false),
      Answer(answerString: "Bar", isCorrect: true)
    ])
  ];
  @override
  State<StatefulWidget> createState() => _QuestionPageUI();
}

class _QuestionPageUI extends State<_QuestionPage> {
  Question currentQuestion;

  Question _fetchQuestion() {
    try {
      return widget.questions.removeLast();
    } catch (ioor) {
      if (widget.questions.length == 0) {
        return null;
      }
      throw "Unexcepted exception when receiving question";
    }
  }

  @override
  void initState() {
    super.initState();
    currentQuestion = _fetchQuestion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            currentQuestion.interface(() {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => _CorrectAns()));
            }, () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => _IncorrectAns()));
            })
          ],
        ),
      ),
    );
  }
}

abstract class _ReviewAnswer extends StatelessWidget {
  Color bgColour();
  String response();

  ///Predefine style of action button
  Container _actionBtn(
      BuildContext context, String btnTxt, Color bg, Function onPressed) {
    return Container(
      margin: EdgeInsets.only(top: 25, bottom: 25),
      width: MediaQuery.of(context).size.width - 10,
      height: 50,
      child: MaterialButton(
        child:
            Text(btnTxt, style: TextStyle(fontSize: 18, color: Colors.white)),
        color: bg,
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColour(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              response(),
              style: TextStyle(
                  fontSize: 63,
                  fontWeight: FontWeight.w400,
                  color: Colors.black),
              textAlign: TextAlign.center,
            ),
            Padding(padding: EdgeInsets.only(top: 100)),
            _actionBtn(context, "Next Question", OTPColour.mainTheme, () {}),
            _actionBtn(context, "Give Up", Colors.redAccent, () {})
          ],
        ),
      ),
    );
  }
}

class _CorrectAns extends _ReviewAnswer {
  @override
  Color bgColour() => OTPColour.light2;

  @override
  String response() => "Correct!";
}

class _IncorrectAns extends _ReviewAnswer {
  @override
  Color bgColour() => colourPicker(175, 12, 12);

  @override
  String response() => "Incorrect!";
}
