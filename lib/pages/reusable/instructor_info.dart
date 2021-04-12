import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_take_pass_remake/api/userdata/instructor.dart';

class InstructorInfo extends StatelessWidget {
  final Instructor instructor;

  InstructorInfo({@required this.instructor});

  Widget _heading(BuildContext context) {
    Widget _img(String url) {
      if (url != "") {
        return CircleAvatar(
          backgroundImage: NetworkImage(url),
          maxRadius: 36,
        );
      }
      return Container(
        child: Icon(
          CupertinoIcons.person,
          size: 48,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _img(instructor.avater),
        Padding(padding: EdgeInsets.only(right: 10)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              instructor.name,
              style: TextStyle(fontSize: 24),
            ),
            InstructorRating(context: context, rate: instructor.rating)
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: EdgeInsets.only(left: 10, right: 10, top: 10),
        children: [_heading(context)],
      ),
    );
  }
}
