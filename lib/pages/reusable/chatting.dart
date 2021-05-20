import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:one_take_pass_remake/api/url/localapiurl.dart';
import 'package:one_take_pass_remake/api/userdata/login_request.dart';
import 'package:one_take_pass_remake/themes.dart';
import 'package:web_socket_channel/io.dart';

class ChatComm extends StatefulWidget {
  //final wschat = IOWebSocketChannel.connect('ws://localhost:443');
  final Map<String, dynamic> pickedRESTResult;

  final bool isStudent;

  Timer t;

  StreamController<List<dynamic>> chatLog;

  ChatComm({@required this.pickedRESTResult, @required this.isStudent}) {
    chatLog = StreamController<List<dynamic>>();
    t = Timer.periodic(Duration(milliseconds: 500), (_) async {
      var dio = Dio();
      dio.options.headers["Content-Type"] = "application/json";
      dio
          .post(APISitemap.chatControl("get_msg").toString(),
              data: jsonEncode({
                "refresh_token": (await UserTokenLocalStorage.getToken()),
                "userPhoneNumber": pickedRESTResult["userPhoneNumber"]
              }))
          .then((resp) {
        chatLog.sink.add(resp.data);
      });
    });
  }

  void sendMsg(String msg) {
    UserTokenLocalStorage.getToken().then((token) {
      var sendREST = {
        "refresh_token": token,
        "msg": msg,
        "to": pickedRESTResult["userPhoneNumber"]
      };
      var dio = Dio();
      dio.options.headers["Content-Type"] = "application/json";
      dio.post(APISitemap.chatControl("send_msg").toString(),
          data: jsonEncode(sendREST));
    });
  }

  @override
  State<StatefulWidget> createState() => _ChatComm();
}

class _ChatComm extends State<ChatComm> {
  TextEditingController _controller;
  List<Widget> _chatElements = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    widget.t.cancel();
    try {
      widget.chatLog.close();
    } finally {
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.pickedRESTResult["name"]),
          centerTitle: true,
          actions: [
            TextButton.icon(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => SimpleDialog(
                            children: [
                              TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    "Make appointment",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: OTPColour.dark1,
                                        fontWeight: FontWeight.w700),
                                  ))
                            ],
                          ));
                },
                icon: Icon(
                  CupertinoIcons.list_bullet,
                  color: OTPColour.dark1,
                ),
                label: Text(
                  "Action",
                  style: TextStyle(color: OTPColour.dark2),
                ))
          ],
        ),
        body: StatefulBuilder(builder: (context, sentState) {
          return Stack(
            children: [
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: StreamBuilder(
                      stream: widget.chatLog.stream,
                      builder: (context, msgobj) {
                        if (msgobj.hasData) {
                          return ListView.builder(
                              itemCount: msgobj.data.length,
                              itemBuilder: (context, msgpos) =>
                                  _ChatElements._getMsgBox(
                                      msgobj.data[msgpos]));
                        } else {
                          return Container();
                        }
                      })),
              /*ListView.builder(
                                  itemCount: _chatElements.length,
                                  itemBuilder: (context, msgpos) =>
                                      _chatElements[msgpos])),*/
              Positioned(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 48,
                  child: Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width - 100,
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Message"),
                        ),
                      ),
                      Container(
                          height: 48,
                          width: 100,
                          child: MaterialButton(
                              color: OTPColour.light2,
                              child: Text("Send"),
                              onPressed: () {
                                if (_controller.text.isNotEmpty) {
                                  widget.sendMsg(_controller.text);
                                  sentState(() {
                                    _controller.clear();
                                  });
                                }
                              }))
                    ],
                  ),
                ),
                bottom: 0,
              )
            ],
          );
        }));
  }
}

class _ChatElements {
  static Widget _getMsgBox(Map<String, dynamic> restResp) {
    return Container(
      child: (restResp["status"] == "out")
          ? _senderBox(restResp["msg"])
          : _receiverBox(restResp["msg"]),
      margin: EdgeInsets.all(10),
    );
  }

  static Padding _senderBox(String msg) {
    return Padding(
        padding: EdgeInsets.only(left: 100),
        child: Container(
          decoration: BoxDecoration(
              color: OTPColour.light2,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(5))),
          child: Padding(
              padding: EdgeInsets.all(5),
              child: Text(
                msg,
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.right,
              )),
        ));
  }

  static Padding _receiverBox(String msg) {
    return Padding(
        padding: EdgeInsets.only(right: 100),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(5))),
          child: Padding(
              padding: EdgeInsets.all(5),
              child: Text(
                msg,
                style: TextStyle(fontSize: 18),
              )),
        ));
  }
}
