import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:one_take_pass_remake/themes.dart';

class Instructor {
  String name;
  String desc;
  double rating;
  String avater;

  Instructor(String name, String desc, double rating, [String avater = ""]) {
    if (rating > 5 || rating < 0) {
      throw new RangeError("Rating range must between 0 to 5");
    }
    this.name = name;
    this.desc = desc;
    this.rating = rating;
    this.avater = avater;
  }
}

class InstructorRating extends StatelessWidget {
  final BuildContext context;
  final double rate;

  InstructorRating({@required this.context, @required this.rate});

  @override
  Widget build(BuildContext context) {
    return RatingBarIndicator(
      rating: rate,
      itemBuilder: (context, index) => Icon(
        Icons.star,
        color: OTPColour.light2,
      ),
      itemCount: 5,
      itemSize: 24,
      unratedColor: OTPColour.dark2,
    );
  }
}
