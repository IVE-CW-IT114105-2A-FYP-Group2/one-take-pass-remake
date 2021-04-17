import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:one_take_pass_remake/themes.dart';

class ChatComm extends StatefulWidget {
  final String name;
  ChatComm({@required this.name});
  @override
  State<StatefulWidget> createState() => _ChatComm();
}

class _ChatComm extends State<ChatComm> {
  TextEditingController _controller;
  List<Widget> _chatElements = [_ChatElements._receiverBox("Hi")];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
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
        body: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: ListView.builder(
                  itemCount: _chatElements.length,
                  itemBuilder: (context, count) => _chatElements[count]),
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
                            border: OutlineInputBorder(), labelText: "Message"),
                      ),
                    ),
                    Container(
                        height: 48,
                        width: 100,
                        child: MaterialButton(
                            color: OTPColour.light2,
                            child: Text("Send"),
                            onPressed: () {
                              _chatElements.add(
                                  _ChatElements._senderBox(_controller.text));
                              setState(() {});
                            }))
                  ],
                ),
              ),
              bottom: 0,
            )
          ],
        ));
  }
}

class _ChatElements {
  static Widget _senderBox(String msg) {
    return Padding(
        padding: EdgeInsets.only(left: 100),
        child: Container(
          child: Text(
            msg,
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.right,
          ),
          color: OTPColour.light2,
        ));
  }

  static Widget _receiverBox(String msg) {
    return Padding(
        padding: EdgeInsets.only(right: 100),
        child: Container(
          child: Text(
            msg,
            style: TextStyle(fontSize: 18),
          ),
          color: Colors.grey,
        ));
  }
}
