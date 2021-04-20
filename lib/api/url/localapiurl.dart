///URL of API
final String _apiUrl = "ivefypgroup2w1offical.azurewebsites.net";

class APISitemap {
  static Uri get signin {
    return Uri.https(_apiUrl, 'signin');
  }

  static Uri get postAns {
    return Uri.https(_apiUrl, 'question/ask');
  }

  static Uri getAns(int mode) {
    switch (mode) {
      case 0:
        return Uri.https(_apiUrl, 'question/get/text');
      case 1:
        return Uri.https(_apiUrl, 'question/get/symbol');
    }
  }
}
