enum Genders { male, female, others }

extension GenderHandler on Genders {
  String get str {
    switch (this) {
      case Genders.male:
        return "Male";
      case Genders.female:
        return "Female";
      default:
        return "Others";
    }
  }
}
