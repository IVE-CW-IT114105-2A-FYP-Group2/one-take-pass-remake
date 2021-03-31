class Instructor {
  String name;
  String desc;
  double rating;

  Instructor(String name, String desc, double rating) {
    if (rating > 5 || rating < 0) {
      throw new RangeError("Rating range must between 0 to 5");
    }
    this.name = name;
    this.desc = desc;
    this.rating = rating;
  }
}
