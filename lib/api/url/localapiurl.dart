class APISitemap {
  ///URL of API
  static final String _apiUrl = "ivefypgroup2w1offical.azurewebsites.net";
  static Uri get signin {
    return Uri.https(_apiUrl, 'signin');
  }

  static Uri get signup {
    return Uri.https(_apiUrl, 'signup');
  }

  static Uri get postAns {
    return Uri.https(_apiUrl, 'question/ask');
  }

  static Uri get fetchUserViaToken {
    return Uri.https(_apiUrl, 'getinfo');
  }

  static Uri getAns(int mode) {
    switch (mode) {
      case 0:
        return Uri.https(_apiUrl, 'question/get/text');
      case 1:
        return Uri.https(_apiUrl, 'question/get/symbol');
    }
  }

  static Uri customPath(String subDir) {
    return Uri.https(_apiUrl, subDir);
  }
}
