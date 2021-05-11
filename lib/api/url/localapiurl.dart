class APISitemap {
  ///URL of API
  static final String _apiUrl = "ivefypgroup2w1offical.azurewebsites.net";
  static Uri get signin {
    return Uri.https(_apiUrl, 'signin');
  }

  static Uri get signup {
    return Uri.https(_apiUrl, 'signup');
  }

  static Uri get deleteUser {
    return Uri.https(_apiUrl, 'deleteuser');
  }

  static Uri get postAns {
    return Uri.https(_apiUrl, 'question/ask');
  }

  static Uri get fetchUserViaToken {
    return Uri.https(_apiUrl, 'getinfo');
  }

  static Uri get submitMockMark {
    return Uri.https(_apiUrl, 'question/result');
  }

  static Uri get findInstructor {
    return Uri.https(_apiUrl, 'search/user/teacher');
  }

  static Uri get recentMockMark {
    return Uri.https(_apiUrl, 'question/getAllResult');
  }

  static Uri get updateInfo {
    return Uri.https(_apiUrl, 'updateInfo');
  }

  static Uri getAns(int mode) {
    switch (mode) {
      case 0:
        return Uri.https(_apiUrl, 'question/get/text');
      case 1:
        return Uri.https(_apiUrl, 'question/get/symbol');
      case 2:
      default:
        return Uri.https(_apiUrl, 'question/get/mock');
    }
  }

  static Uri customPath(String subDir) {
    return Uri.https(_apiUrl, subDir);
  }
}
