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
    required this.optionList,
    this.topicCategory = 'arithmitic'
  });

  String arithmiticForm;
  final List<String> acceptedAnswers;
  final List<List<String>> multiAcceptedAnswers;
  String blankForm;
  int maxAnswerCount;
  final List<String> optionList;
  final String topicCategory;
}

// Unique ID for each question; Should be meaningful
class PlaybackGameData {
  PlaybackGameData({
    required this.webAudioLink,
    required this.multiAcceptedAnswers,
    required this.writtenPrompt,
    this.audioTranscript = 'Dummy transcript',
    required this.optionList,
    this.topicCategory = "arithmitic"
  });
  
  final String webAudioLink;
  final List<List<String>> multiAcceptedAnswers;
  final String writtenPrompt;
  String audioTranscript;
  final List<String> optionList;
  final String topicCategory;

  int getMinSelection() {
    return multiAcceptedAnswers[0].length;
  }
}

class JumbleGameData {
  JumbleGameData({
    required this.displayedProblem,
    required this.multiAcceptedAnswers,
    this.writtenPrompt = "Use the buttons below to answer the prompt",
    required this.optionList,
    this.topicCategory = 'arthimitc'
  });
  
  /// The actual problem shown under the written prompt. This can be arithmitic or a word problem
  final String displayedProblem;
  /// A list of string lists that represent the multiple combinations of words from the options lists that are correct
  /// for this problem
  final List<List<String>> multiAcceptedAnswers;
  /// The title prompt for the Jumble game. Use this to provide unique instructions for this problem. Optional.
  final String writtenPrompt;
  /// The labels that will be used on the buttons
  final List<String> optionList;
  final String topicCategory;

  int getMinSelection() {
    return multiAcceptedAnswers[0].length;
  }
}

class ReadAloudGameData {
  ReadAloudGameData({
    required this.displayedProblem,
    required this.multiAcceptedAnswers,
    this.writtenPrompt = "Answer the question by speaking into to the microphone.",
    this.addtionalInstructions = "Your speech will be turned into numbers. Make sure you have microphone access enabled.",
    this.useNumWordProtocol = true,
    this.topicCategory = 'arthimitc'
  });
  
  /// The actual problem shown under the written prompt. This can be arithmitic or a word problem
  final String displayedProblem;
  /// A list of string lists that represent the multiple combinations of words from the options lists that are correct
  /// for this problem
  final List<List<String>> multiAcceptedAnswers;
  /// The title prompt for the Jumble game. Use this to provide unique instructions for this problem. Optional.
  final String writtenPrompt;
  final String addtionalInstructions;
  final bool useNumWordProtocol;
  final String topicCategory;
}

class TypingGameData {
  TypingGameData({
    required this.displayedProblem,
    required this.multiAcceptedAnswers,
    this.writtenPrompt = "Write the expression in written form (do not use special characters)",
    this.topicCategory = 'arthimitc'
  });
  
  final String displayedProblem;
  final List<String> multiAcceptedAnswers;
  final String writtenPrompt;
  final String topicCategory;
}

class FillBlanksGameData {
  FillBlanksGameData({
    required this.displayedProblem,
    required this.multiAcceptedAnswers,
    required this.writtenPrompt,
    required this.blankForm,
    required this.optionList,
    this.topicCategory = 'arthimitc'
  });
  
  final String displayedProblem;
  final List<String> multiAcceptedAnswers;
  final String writtenPrompt;
  final String blankForm;
  final List<String> optionList;
  final String topicCategory;

  int getMinSelection() {
    return multiAcceptedAnswers.length;
  }
}

class GameDataBank {
  List<GameData> dataBank = [];
  final random = Random();

  // Modified banks
  List<JumbleGameData> jumbleBank = [];
  List<PlaybackGameData> playbackBank = [];
  List<ReadAloudGameData> readingBank = [];
  List<TypingGameData> typingBank = [];
  List<FillBlanksGameData> fillBlanksBank = [];

  GameDataBank();

  void initBanks() {
    initDefaultBank();

    initJumbleBank();
    initPlaybackBank();
    initReadingBank();
    initTypingBank();
    initFillBlanksBank();
  }

  void initDefaultBank() {
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
        acceptedAnswers: ["thirty-one", "plus ", "nine", "equals", "eighteen", "plus", "twenty-two"],
        multiAcceptedAnswers: [
          [
            "thirty-one", "plus ", "nine", "equals", "eighteen", "plus", "twenty-two"
          ],
          [
            "thirty-one", "plus", "nine", "equals", "eighteen", "plus ", "twenty-two"
          ]
        ],
        maxAnswerCount: 7,
        optionList: [
          "thirty-one", "nine", "plus ", "equals", "twenty-two", "eighteen", "plus", "is", "ten and eight"
        ]
      ));

      dataBank.add(
      GameData(
        arithmiticForm: '8 x 9 = 72',
        acceptedAnswers: ["eight", "times", "nine", "equals", "seventy-two"],
        multiAcceptedAnswers: [
          ["eight", "times", "nine", "equals", "seventy-two"],
          ["eight", "by", "nine", "equals", "seventy-two"],
          ["eight", "times", "nine", "is", "seventy-two"],
          ["eight", "by", "nine", "is", "seventy-two"]
        ],
        maxAnswerCount: 5,
        optionList: [
          "eight", "nine", "times", "equals", "by", "nine", "seventy-two", "is", "ten", "seven", "fifty-six"
        ]
      ));

      dataBank.add(
      GameData(
        arithmiticForm: 'Sally is 5 years old. Her mother 8 times as old as Sally is. How old is her mother?',
        acceptedAnswers: ["She", "is", "forty", "years-old"],
        multiAcceptedAnswers: [
          ["She", "is", "forty", "years-old"],
        ],
        maxAnswerCount: 4,
        optionList: [
          "She", "eight", "five", "forty", "thrity-two", "is", "forty-eight", "years-old"
        ]
      ));
    }

  void initJumbleBank() {
    jumbleBank.add(
      // an example of a jumble game data object. This one does not use the optional writtenPrompt parameter
      JumbleGameData(
        displayedProblem: '4153 + 3567 = 7720', 
        multiAcceptedAnswers: [
          ['four thousand one hundred and fifty three', "plus", 'three thousand five hundred and sixty seven', 'equals', 'seven thousand seven hundred and twenty'], 
          ['four thousand one hundred and fifty three', "plus", 'three thousand five hundred and sixty seven', 'is', 'seven thousand seven hundred and twenty']
        ],
        optionList: ['four thousand one hundred and fifty three', "minus", 'fourty one hundred and fifty three', 'thirty five hundred and sixty seven',
        'three thousand five hundred and sixty seven', 'plus', 'seventy seven hundred and twenty', 'seven thousand seven hundred and twenty', 'equals']
      )
    );

    jumbleBank.add(
      // an example of a jumble game data object. This one does use the optional writtenPrompt parameter
      JumbleGameData(
        displayedProblem: 'Sally is 5 years old. Her mother 8 times as old as Sally is. How old is her mother?', 
        multiAcceptedAnswers: [
          ["She", "is", "forty", "years-old"]
        ],
        writtenPrompt: 'Answer the short-response question using the blocks below.',
        optionList: [
          "She", "eight", "five", "forty", "thrity-two", "is", "forty-eight", "years-old"
        ]
      )
    );

    jumbleBank.add(
      JumbleGameData(
        displayedProblem: '31 + 9 = 18 + 22', 
        multiAcceptedAnswers: [
          // this one has the plus with a space first, then the normal plus (equals)
          [
            "thirty-one", "plus ", "nine", "equals", "eighteen", "plus", "twenty-two"
          ],
          // this one has the normal plus first, then the plus with a space (equals)
          [
            "thirty-one", "plus", "nine", "equals", "eighteen", "plus ", "twenty-two"
          ],
          // this one has the plus with a space first, then the normal plus (is)
          [
            "thirty-one", "plus ", "nine", "is", "eighteen", "plus", "twenty-two"
          ],
          // this one has the normal plus first, then the plus with a space (is)
          [
            "thirty-one", "plus", "nine", "is", "eighteen", "plus ", "twenty-two"
          ]
          
        ],
        optionList: [
          "thirty-one", "nine", "plus ", "equals", "twenty-two", "eighteen", "plus", "is", "ten and eight"
        ]
      )
    );
  }

  void initPlaybackBank() {
    playbackBank.add(
      // An example using the Sally's mom example
      PlaybackGameData(
        webAudioLink: '/audio/level_up_3h.mp3', 
        multiAcceptedAnswers: [
          ["She", "is", "forty", "years-old"]
        ],
        optionList: [
          "She", "eight", "five", "forty", "thrity-two", "is", "forty-eight", "years-old"
        ],
        writtenPrompt: "Listen to the audio and then create your response with the choices below", 
        audioTranscript: "If Sally's mother is 8 times older than her, and Sally is 5 years-old, how old is Sally's mother?"
      )
    );

    playbackBank.add(
      // The audio would say: Five times what number results in thrity?
      PlaybackGameData(
        webAudioLink: '/audio/level_up_3h.mp3', 
        multiAcceptedAnswers: [
          ["six"]
        ],
        optionList: [
          "seven", "eight", "five", "three", "six", "one", "eight", "nine"
        ],
        writtenPrompt: "Listen to the audio and then create your response with the choices below", 
        audioTranscript: 'Five times what number results in thrity?'
      )
    );
  }

  void initReadingBank() {
    readingBank.add(
      ReadAloudGameData(
        displayedProblem: "21 x 11 = ??", 
        writtenPrompt: "What is the product of the following expression?",
        addtionalInstructions: "Only say the product, do not repeat the expression.",
        multiAcceptedAnswers: [["two hundred thirty one"], ["231"]]
      )
    );

    readingBank.add(
      ReadAloudGameData(
        displayedProblem: "14 x 34 = ??", 
        writtenPrompt: "What is the product of the following expression?",
        addtionalInstructions: "Only say the product, do not repeat the expression.",
        multiAcceptedAnswers: [["four hundred seventy six"], ["476"]]
      )
    );
  }

  void initTypingBank() {
    typingBank.add(
      TypingGameData(
        displayedProblem: '4153 + 3567 = 7720', 
        multiAcceptedAnswers: ["four thousand one hundred and fifty three plus three thousand five hundred and sixty seven equals seven thousand seven hundred and twenty",
        "four thousand one hundred and fifty three plus three thousand five hundred and sixty seven is seven thousand seven hundred and twenty"]
      )
    );
    typingBank.add(
      TypingGameData(
        displayedProblem: 'The big hand is on the five, what time is it?', 
        multiAcceptedAnswers: ["It is five o'clock", "Its five o'clock", "five o'clock"],
        writtenPrompt: "Type your answer with \"o'clock\" at the end."
      )
    );
    typingBank.add(
      TypingGameData(
        displayedProblem: 'It is currently 4:50. I have an appointment in twenty minutes. What time is my appointment?', 
        multiAcceptedAnswers: ["5:10", "At 5:10", "It will be at 5:10"],
        writtenPrompt: "Type only the time without time of day or \"o'clock\""
      )
    );
    

  }

  void initFillBlanksBank() {
    fillBlanksBank.add(
      FillBlanksGameData(
        displayedProblem: 'Sally is 5 years old. Her mother 8 times as old as Sally is. How old is her mother?', 
        multiAcceptedAnswers: ["forty"], 
        writtenPrompt: 'Use the options below to answer the word problem.', 
        blankForm: "Sally's mother is  ____ years old", 
        optionList: [
          "eight", "five", "forty", "thrity-two", "forty-eight"
        ]
      )
    );
  }

  GameData getRandomDefaultElement() {
    if (dataBank.isNotEmpty) {
      int randomIndex = random.nextInt(dataBank.length);
      return dataBank[randomIndex];
    } else {
      throw Exception('The data bank is empty');
    }
  }

  FillBlanksGameData getRandomFillBlanksElement() {
    if (fillBlanksBank.isNotEmpty) {
      int randomIndex = random.nextInt(fillBlanksBank.length);
      return fillBlanksBank[randomIndex];
    } else {
      throw Exception('The fillBlanksBank data bank is empty');
    }
  }

  JumbleGameData getRandomJumbleElement() {
    if (jumbleBank.isNotEmpty) {
      int randomIndex = random.nextInt(jumbleBank.length);
      return jumbleBank[randomIndex];
    } else {
      throw Exception('The jumbleBank data bank is empty');
    }
  }

  ReadAloudGameData getRandomReadingElement() {
    if (readingBank.isNotEmpty) {
      int randomIndex = random.nextInt(readingBank.length);
      return readingBank[randomIndex];
    } else {
      throw Exception('The readingBank data bank is empty');
    }
  }

  PlaybackGameData getRandomPlaybackElement() {
    if (playbackBank.isNotEmpty) {
      int randomIndex = random.nextInt(playbackBank.length);
      return playbackBank[randomIndex];
    } else {
      throw Exception('The playbackBank data bank is empty');
    }
  }

  TypingGameData getRandomTypingElement() {
    if (typingBank.isNotEmpty) {
      int randomIndex = random.nextInt(typingBank.length);
      return typingBank[randomIndex];
    } else {
      throw Exception('The typingBank data bank is empty');
    }
  }

}