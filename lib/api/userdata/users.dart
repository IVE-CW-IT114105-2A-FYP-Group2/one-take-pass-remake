import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:one_take_pass_remake/api/userdata/behaviours.dart';
import 'package:one_take_pass_remake/api/userdata/districts.dart';
import 'package:one_take_pass_remake/api/userdata/gender.dart';
import 'package:one_take_pass_remake/themes.dart';

//Integrated those object that required
export 'package:one_take_pass_remake/api/userdata/behaviours.dart';
export 'package:one_take_pass_remake/api/userdata/districts.dart';
export 'package:one_take_pass_remake/api/userdata/gender.dart';

class OTPUsers {
  String name;
  Genders gender;
  String avater;

  OTPUsers(String name, Genders gender, [String avater = ""]) {
    this.name = name;
    this.gender = gender;
    this.avater = avater;
  }
}

class Instructor extends OTPUsers {
  String desc;
  double rating;
  Personality personality;
  SpeakingLanguage speakingLanguage;
  HKDistrict hkDistrict;
  String vehicles;

  Instructor(
      String name,
      String desc,
      double rating,
      Personality personality,
      SpeakingLanguage speakingLanguage,
      HKDistrict hkDistrict,
      String vehicles,
      Genders gender,
      [String avater = ""])
      : super(name, gender, avater) {
    if (rating > 5 || rating < 0) {
      throw new RangeError("Rating range must between 0 to 5");
    }
    this.desc = desc;
    this.rating = rating;
    this.personality = personality;
    this.speakingLanguage = speakingLanguage;
    this.hkDistrict = hkDistrict;
    this.vehicles = vehicles;
  }

  static List<Instructor> get dummyInstructor {
    return [
      Instructor(
          "John Siu",
          "Serious",
          3,
          Personality.calm,
          SpeakingLanguage.cantonese,
          HKDistrict.est,
          "Private Car",
          Genders.male),
      Instructor(
        "Polly Chan",
        "I love cars",
        4,
        Personality.easy_going,
        SpeakingLanguage.cantonese,
        HKDistrict.ssp,
        "Private Car",
        Genders.female,
      )
    ];
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
