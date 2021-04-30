import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:one_take_pass_remake/api/userdata/login_request.dart';
import 'package:one_take_pass_remake/themes.dart';
import 'package:web_socket_channel/io.dart';

class ChatComm extends StatefulWidget {
  final wschat = IOWebSocketChannel.connect('ws://localhost:443');
  final String name;
  ChatComm({@required this.name});
  @override
  State<StatefulWidget> createState() => _ChatComm();
}

class _ChatComm extends State<ChatComm> {
  TextEditingController _controller;
  List<Widget> _chatElements = [];

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.name),
          centerTitle: true,
        ),
        body: FutureBuilder<String>(
            future: (<String>() async {
              return (await UserAPIHandler.getUserRest(
                      await UserTokenLocalStorage.getToken()))
                  .fullName;
            }()),
            builder: (context, cu) {
              if (cu.hasData) {
                Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: StreamBuilder(
                        stream: widget.wschat.stream,
                        builder: (context, msgobj) {
                          if (msgobj.hasData) {
                            var wsd = (msgobj.data is String)
                                ? jsonDecode(msgobj.data)
                                : msgobj.data;
                            return StatefulBuilder(
                                builder: (context, msgState) {
                              msgState(() {
                                _chatElements.add(_ChatElements._getMsgBox(
                                    wsd["msg"], (cu.data == wsd["from"])));
                              });
                              return ListView.builder(
                                  itemCount: _chatElements.length,
                                  itemBuilder: (context, msgpos) =>
                                      _chatElements[msgpos]);
                            });
                          }
                          return ListView.builder(
                              itemCount: _chatElements.length,
                              itemBuilder: (context, msgpos) =>
                                  _chatElements[msgpos]);
                        },
                      ),
                    ),
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
                                child: StatefulBuilder(
                                    builder: (context, sentState) {
                                  return MaterialButton(
                                      color: OTPColour.light2,
                                      child: Text("Send"),
                                      onPressed: () {
                                        if (_controller.text.isNotEmpty) {
                                          widget.wschat.sink.add(jsonEncode({
                                            "msg": _controller.text,
                                            "from": cu.data,
                                            "to": widget.name
                                          }));
                                          sentState(() {
                                            _controller.clear();
                                          });
                                        }
                                      });
                                }))
                          ],
                        ),
                      ),
                      bottom: 0,
                    )
                  ],
                );
              }

              return Container();
            }));
  }
}

class _ChatElements {
  static Widget _getMsgBox(String msg, bool isSender) {
    return Container(
      child: isSender ? _senderBox(msg) : _receiverBox(msg),
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
