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

  OTPUsers(String name) {
    this.name = name;
  }
}

class Instructor extends OTPUsers {
  String desc;
  Personality personality;
  HKDistrict hkDistrict;
  String vehicles;

  Instructor(String name, String desc, Personality personality,
      HKDistrict hkDistrict, String vehicles)
      : super(name) {
    this.desc = desc;
    this.personality = personality;
    this.hkDistrict = hkDistrict;
    this.vehicles = vehicles;
  }

  factory Instructor.fromJSON(Map<String, dynamic> json) {
    return Instructor(
        json["name"],
        json["description"],
        PersonalityGetter.getEnumObj(json["instructorStyle"]),
        HKDistrictGetter.getEnumObj(json["location"]),
        json["vehicleType"]);
  }

  static List<Instructor> get dummyInstructor {
    return [
      Instructor(
        "John Siu",
        "Serious",
        Personality.calm,
        HKDistrict.est,
        "Private Car",
      ),
      Instructor(
        "Polly Chan",
        "I love cars",
        Personality.easy_going,
        HKDistrict.ssp,
        "Private Car",
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
