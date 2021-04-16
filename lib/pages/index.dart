import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_take_pass_remake/pages/login.dart';
import 'package:one_take_pass_remake/pages/subpages/about.dart';
import 'package:one_take_pass_remake/pages/subpages/calender.dart';
import 'package:one_take_pass_remake/pages/subpages/inbox.dart';
import 'package:one_take_pass_remake/themes.dart';
import './subpages/export.dart';

class _PageOpt {
  Widget opts;
  BottomNavigationBarItem bnb;

  _PageOpt({@required this.bnb, @required this.opts});
}

class _PageMap {
  List<_PageOpt> pageOpt;
  _PageMap({@required this.pageOpt});

  List<Widget> get widgetList {
    List<Widget> _widget = [];
    pageOpt.forEach((o) {
      _widget.add(o.opts);
    });
    return _widget;
  }

  List<BottomNavigationBarItem> get bnbItems {
    List<BottomNavigationBarItem> _bnb = [];
    pageOpt.forEach((o) {
      _bnb.add(o.bnb);
    });
    return _bnb;
  }
}

final _PageMap _pmap = _PageMap(pageOpt: [
  _PageOpt(
      bnb: BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.home), label: "Home"),
      opts: OTPHome()),
  _PageOpt(
      bnb: BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.calendar), label: "Calendar"),
      opts: OTPCalender()),
  _PageOpt(
      bnb: BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.envelope), label: "Inbox"),
      opts: OTPInbox()),
  _PageOpt(
      bnb: BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.book), label: "E-Learning"),
      opts: OTPELearning()),
  _PageOpt(
      bnb: BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.person), label: "About"),
      opts: OTPAbout())
]);

class OTPIndex extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OTPIndex();
}

class _OTPIndex extends State<OTPIndex> {
  int _currentIdx = 0;

  void _onTab(int idx) {
    setState(() {
      _currentIdx = idx;
    });
  }

  @override
  Widget build(BuildContext context) {
    return UserIdentify(
        child: Scaffold(
      appBar: AppBar(
        title: Text("One Take Pass"),
        titleTextStyle: TextStyle(fontWeight: FontWeight.w300),
        centerTitle: true,
      ),
      body: _pmap.widgetList.elementAt(_currentIdx),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIdx,
        items: _pmap.bnbItems,
        onTap: _onTab,
        backgroundColor: OTPColour.light1,
        unselectedItemColor: OTPColour.light2,
        selectedItemColor: OTPColour.dark2,
      ),
    ));
  }
}

class UserIdentify extends StatelessWidget {
  final Widget child;

  UserIdentify({@required this.child});

  ///When received user data
  Widget _onSuccess(Widget child) {
    return child;
  }

  ///When user data can not receive
  Widget _onFailed(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
          Icon(
            CupertinoIcons.xmark_circle,
            size: 120,
          ),
          Padding(padding: EdgeInsets.only(top: 50)),
          Text(
              "Unable to get your current login session. Or session has been expired",
              style: TextStyle(fontSize: 18)),
          Padding(padding: EdgeInsets.only(top: 50)),
          Container(
              margin: EdgeInsets.all(50),
              width: MediaQuery.of(context).size.width,
              child: MaterialButton(
                  padding: EdgeInsets.all(15),
                  color: OTPColour.mainTheme,
                  minWidth: MediaQuery.of(context).size.width - 10,
                  child: Text(
                    "Logout",
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  onPressed: () {
                    requireLogin(ModalRoute.of(context), context);
                  }))
        ])));
  }

  ///Initalize page
  Widget _oninit() {
    return Scaffold(
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
          Text("Initialize with your user data..."),
          Padding(padding: EdgeInsets.only(top: 50)),
          CircularProgressIndicator()
        ])));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(Duration(seconds: 1), () => true),
      builder: (context, userdata) {
        if (userdata.hasData) {
          return _onSuccess(child);
        } else if (userdata.hasError) {
          return _onFailed(context);
        }
        return _oninit();
      },
    );
  }
}
