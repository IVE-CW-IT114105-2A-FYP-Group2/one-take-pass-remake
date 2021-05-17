///A range from start to end
class TimeRange {
  final String startTime;
  final String endTime;

  TimeRange({this.startTime, this.endTime});

  Map<String, String> get toJson => {"start": startTime, "stop": endTime};
}

///UNified interface for calendar
abstract class ClendarInteraface {
  String get title;
  String get vehicleType;
  List<TimeRange> get courseTime;
  Map<String, dynamic> get toJson;
}

///Detail of course
class CoursesCalendar implements ClendarInteraface {
  String _title, _vehicleType;
  List<TimeRange> _courseTime;
  dynamic _id; //Only available on get from JSON

  CoursesCalendar(String title, String vehicleType, List<TimeRange> courseTime,
      [dynamic id]) {
    this._title = title;
    this._vehicleType = vehicleType;
    this._courseTime = courseTime;
    this._id = id;
  }

  @override
  List<TimeRange> get courseTime => _courseTime;

  @override
  String get title => _title;

  @override
  String get vehicleType => _vehicleType;

  get id => _id;

  List<Map<String, String>> get _courseDateList {
    List<Map<String, String>> dl = [];
    _courseTime.forEach((pair) {
      dl.add(pair.toJson);
    });
    if (dl.isEmpty) {
      throw RangeError("Created event with no date");
    }
    return dl;
  }

  @override
  Map<String, dynamic> get toJson =>
      {"title": _title, "type": _vehicleType, "course_time": _courseDateList};

  factory CoursesCalendar.fromJson(Map<String, dynamic> json) {
    List<TimeRange> ranges = [];
    (json["course_time"] as List<Map<String, String>>).forEach((r) {
      ranges.add(TimeRange(startTime: r["start"], endTime: r["stop"]));
    });
    return CoursesCalendar(json["title"], json["type"], ranges, json["id"]);
  }
}
