import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:one_take_pass_remake/api/userdata/login_request.dart';
import 'package:one_take_pass_remake/pages/login.dart';
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

_PageMap _pmap(UserREST cur) => _PageMap(pageOpt: [
      _PageOpt(
          bnb: BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home), label: "Home"),
          opts: OTPHome(cur)),
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

  FloatingActionButton _actionBtnMap(BuildContext context, UserREST cur) {
    switch (_currentIdx) {
      case 1:
        if (cur.roles == "student") {
          return null;
        }
        return FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => OTPCalenderEventAdder()));
          },
          child: Icon(Icons.add),
          mini: false,
          tooltip: "Add courses",
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Scaffold _pageWithIdentityFactory(UserREST cur) {
      var _ipmap = _pmap(cur);
      return Scaffold(
        appBar: AppBar(
          title: Text("One Take Pass"),
          titleTextStyle: TextStyle(fontWeight: FontWeight.w300),
          centerTitle: true,
        ),
        body: _ipmap.widgetList.elementAt(_currentIdx),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIdx,
          items: _ipmap.bnbItems,
          onTap: _onTab,
          backgroundColor: OTPColour.light1,
          unselectedItemColor: OTPColour.light2,
          selectedItemColor: OTPColour.dark2,
        ),
        floatingActionButton: _actionBtnMap(context, cur),
      );
    }

    return UserIdentify(child: _pageWithIdentityFactory);
  }
}

class UserIdentify extends StatelessWidget {
  static bool _firstTime = true;
  final Widget Function(UserREST) child;
  //UserREST _currentLoginUser;

  //UserREST get currentLoginUser => _currentLoginUser;

  UserIdentify({@required this.child});

  ///When received user data
  Widget _onSuccess(Widget Function(UserREST) child, UserREST cur) {
    return child(cur);
  }

  ///When user data can not receive
  Widget _onFailed(BuildContext context) {
    void _toLogin() {
      _firstTime = false;
      requireLogin(ModalRoute.of(context), context);
    }

    //Defer time that back to login page
    Timer(Duration(seconds: _firstTime ? 0 : 5), _toLogin);

    return Scaffold(body: Center(child: Text("No existed login record!")));
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

  ///Get is logined before
  Future<UserREST> _loginStatus() async {
    UserREST _cur = await UserAPIHandler.getUserRest(
        await UserTokenLocalStorage.getToken());
    return _cur;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserREST>(
      future: _loginStatus(),
      builder: (context, userdata) {
        if (userdata.hasData) {
          return _onSuccess(child, userdata.data);
        } else if (userdata.hasError) {
          return _onFailed(context);
        }
        return _oninit();
      },
    );
  }
}
