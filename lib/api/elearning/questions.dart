class Questions {
  String question;
  List<AnswersChoice> answer;
}

class AnswersChoice {
  String answerName;
  bool isCorrect;
}

class QuestionsManager {
  List<Questions> questionList;

  Questions get nextQuestion {
    try {
      return questionList.removeAt(0);
    } catch (ofre) {
      return null;
    }
  }
}
