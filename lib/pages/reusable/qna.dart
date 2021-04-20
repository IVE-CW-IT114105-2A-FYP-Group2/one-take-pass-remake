import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:one_take_pass_remake/api/elearning/questions.dart';
import 'package:one_take_pass_remake/api/url/localapiurl.dart';
import 'package:one_take_pass_remake/themes.dart';

///Question handler between API and App
///
class QuestionPageHandler {
  final int mode;
  QuestionPageHandler({@required this.mode});

  Future<List<Question>> _loadQuestion() async {
    var dio = Dio();
    var _qHttp = await dio.get(APISitemap.getAns(mode).toString());
    List<dynamic> _qR = _qHttp.data;
    List<Question> _qOs = [];
    switch (mode) {
      case 0:
        _qR.forEach((q) {
          _qOs.add(TextQuestion.fromJSON(q));
        });
        break;
      case 1:
        break;
    }
    return _qOs;
  }

  static void start(BuildContext context, int mode) {
    new QuestionPageHandler(mode: mode)._loadQuestion().then((qL) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => QuestionPage(questions: qL)));
    });
  }
}

///The page that displaying questions
class QuestionPage extends StatefulWidget {
  final List<Question> questions;

  QuestionPage({@required this.questions});

  @override
  State<StatefulWidget> createState() => _QuestionPage();
}

///UI of QuestionPage
class _QuestionPage extends State<QuestionPage> {
  static bool _isTesting = true;
  List<Question> _qS;
  Question _q;
  int correctCount = 0;

  ///Toggle next question
  void _nextQuestion() {
    try {
      _q = _qS.removeLast();
    } catch (ended) {
      _q = null;
    }
    setState(() {});
  }

  ///Question number
  int get _questionNo {
    return widget.questions.length - _qS.length + 1;
  }

  @override
  void initState() {
    _qS = widget.questions;
    super.initState();
    _nextQuestion();
  }

  ///To listen the behaviour of answer review page
  void _ansReviewedListener(bool terminate) {
    if (terminate) {
      _isTesting = false;
      Navigator.pop(context);
    } else {
      _nextQuestion();
    }
  }

  ///Display data on this test when all question is asked
  Widget _allDonePage() {
    _isTesting = false;
    return Container(
        margin: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text("")],
        ));
  }

  ///Ask question
  Widget _showQuestion(Question q) {
    _isTesting = true;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Question " + _questionNo.toString(),
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.w300),
        ),
        q.interface(() {
          correctCount++;
          Navigator.push(context,
                  MaterialPageRoute(builder: (context) => _CorrectAns()))
              .then((isExit) {
            _ansReviewedListener(isExit as bool);
          });
        }, (String actual) {
          Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => _IncorrectAns(actual: actual)))
              .then((isExit) {
            _ansReviewedListener(isExit as bool);
          });
        })
      ],
    );
  }

  Scaffold _getScaffold(Widget inner) {
    return Scaffold(
      backgroundColor: OTPColour.light2,
      body: Center(child: inner),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: _getScaffold((_q == null) ? _allDonePage() : _showQuestion(_q)),
        onWillPop: () async {
          if (!_isTesting) {
            return true;
          }
          bool _exit = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          child: Text("Yes")),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: Text("No")),
                    ],
                    title: Text("Stop the mock test?"),
                    content: Text("Your record will be wiped"),
                  ));
          return _exit;
        });
  }
}

// ignore: must_be_immutable
abstract class _ReviewAnswer extends StatelessWidget {
  ///To listen the pop behaviour is come from button on the app or back button
  bool _triggerByButton = false;
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
    return WillPopScope(
      child: Scaffold(
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
              _actionBtn(context, "Next", OTPColour.mainTheme, () {
                _triggerByButton = true;
                Navigator.pop(context, true);
              }),
              _actionBtn(context, "Give Up", Colors.redAccent, () {
                _triggerByButton = true;
                Navigator.pop(context, false);
              })
            ],
          ),
        ),
      ),
      onWillPop: () async => _triggerByButton,
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
  ///Actual answer
  final String actual;
  _IncorrectAns({@required this.actual}) : super();

  @override
  Color bgColour() => colourPicker(175, 12, 12);

  @override
  String response() => "Incorrect!\nThe correct answer is:\n" + actual;
}
