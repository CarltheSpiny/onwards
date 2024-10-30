import 'dart:math';

/// Fill in the blank needs the question to show with blanks, 
/// the arithmitic form, and the answer blocks
class GameData {
  GameData({
    this.arithmiticForm = '4 + 30 = 34',
    required this.acceptedAnswers,
    required this.multiAcceptedAnswers,
    this.blankForm = 'Forty ____ thirty ____ thirty-four',
    this.maxAnswerCount = 2,
    required this.optionList
  });

  String arithmiticForm;
  final List<String> acceptedAnswers;
  final List<List<String>> multiAcceptedAnswers;
  String blankForm;
  int maxAnswerCount;
  final List<String> optionList;
}

class GameDataBank {
  List<GameData> dataBank = [];

  GameDataBank();

  void initBank() {
    dataBank.add(
      GameData(
        arithmiticForm: '4153 + 3567 = 7720',
        acceptedAnswers: ['four thousand one hundred and fifty three', 'three thousand five hundred and sixty seven', 'seven thousand seven hundred and twenty'],
        multiAcceptedAnswers: [['four thousand one hundred and fifty three', 'three thousand five hundred and sixty seven', 'seven thousand seven hundred and twenty']],
        blankForm: '____ plus ____ is ____',
        maxAnswerCount: 3,
        optionList: ['four thousand one hundred and fifty three', 'fourty one hundred and fifty three', 'thirty five hundred and sixty seven',
        'three thousand five hundred and sixty seven', 'seventy seven hundred and twenty', 'seven thousand seven hundred and twenty']
      ));
    
    dataBank.add(
      GameData(
        arithmiticForm: '31 + 9 = 18 + 22',
        acceptedAnswers: ["thirty-one", "plus", "nine", "equals", "teighteen", "plus", "twenty-two"],
        multiAcceptedAnswers: [
          [
            "thirty-one", "plus", "nine", "equals", "eighteen", "plus", "twenty-two"
          ],
          [
            "thirty-one", "plus", "nine", "equals", "eighteen", "is", "twenty-two"
          ]
        ],
        maxAnswerCount: 7,
        optionList: [
          "thirty-one", "nine", "plus", "equals", "twenty-two", "eighteen", "plus", "is", "ten and eight"
        ]
      ));
    }

  GameData getRandomElement() {
  final random = Random();
  if (dataBank.isNotEmpty) {
    int randomIndex = random.nextInt(dataBank.length);
    return dataBank[randomIndex];
  } else {
    throw Exception('The data bank is empty');
  }
}

}