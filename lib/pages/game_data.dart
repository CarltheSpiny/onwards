import 'dart:math';

/// Fill in the blank needs the question to show with blanks, 
/// the arithmitic form, and the answer blocks
class GameData {
  GameData({
    required this.id
  });

  String id;
}

// Unique ID for each question; Should be meaningful
class PlaybackGameData extends GameData {
  PlaybackGameData({
    required this.webAudioLink,
    required this.multiAcceptedAnswers,
    required this.writtenPrompt,
    this.audioTranscript = 'Dummy transcript',
    required this.optionList,
    this.topicCategory = "arithmitic",
    super.id = "playback"
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

class JumbleGameData extends GameData {
  JumbleGameData({
    required this.displayedProblem,
    required this.multiAcceptedAnswers,
    this.writtenPrompt = "Use the buttons below to answer the prompt",
    required this.optionList,
    this.topicCategory = 'arthimitc',
    super.id = "jumble"
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

class ReadAloudGameData extends GameData {
  ReadAloudGameData({
    required this.displayedProblem,
    required this.multiAcceptedAnswers,
    this.writtenPrompt = "Answer the question by speaking into to the microphone.",
    this.addtionalInstructions = "Your speech will be turned into numbers. Make sure you have microphone access enabled.",
    this.useNumWordProtocol = true,
    this.topicCategory = 'arthimitc',
    super.id = "reading"
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

class TypingGameData extends GameData {
  TypingGameData({
    required this.displayedProblem,
    required this.multiAcceptedAnswers,
    this.writtenPrompt = "Write the expression in written form (do not use special characters)",
    this.topicCategory = 'arthimitc',
    super.id = "typing"
  });
  
  final String displayedProblem;
  final List<String> multiAcceptedAnswers;
  final String writtenPrompt;
  final String topicCategory;
}

class FillBlanksGameData extends GameData{
  FillBlanksGameData({
    required this.displayedProblem,
    required this.multiAcceptedAnswers,
    required this.writtenPrompt,
    required this.blankForm,
    required this.optionList,
    this.topicCategory = 'arthimitc',
    super.id = "fill"
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
    initJumbleBank();
    initPlaybackBank();
    initReadingBank();
    initTypingBank();
    initFillBlanksBank();
  }

  void initJumbleBank() {
    jumbleBank.addAll(
      // an example of a jumble game data object. This one does not use the optional writtenPrompt parameter
      <JumbleGameData> [
        JumbleGameData(
          displayedProblem: '4153 + 3567 = 7720', 
          multiAcceptedAnswers: [
            ['four thousand one hundred and fifty three', "plus", 'three thousand five hundred and sixty seven', 'equals', 'seven thousand seven hundred and twenty'], 
            ['four thousand one hundred and fifty three', "plus", 'three thousand five hundred and sixty seven', 'is', 'seven thousand seven hundred and twenty']
          ],
          optionList: ['four thousand one hundred and fifty three', "minus", 'fourty one hundred and fifty three', 'thirty five hundred and sixty seven',
          'three thousand five hundred and sixty seven', 'plus', 'seventy seven hundred and twenty', 'seven thousand seven hundred and twenty', 'equals'],
          id: "jumble.addition.multiple_digits"
        ),
        JumbleGameData(
          displayedProblem: '375 + 109 = 484', 
          multiAcceptedAnswers: [
            ['three hundred seventy five', "plus", 'one hundred and nine', 'equals', 'four hundred eighty four']
          ],
          optionList: ['three hundred seventy five', "minus", 'one o nine', 'three seven five',
          'one hundred and nine', 'plus', 'thirty seven and five', 'four hundred eighty four', 'equals'],
          id: "jumble.addition.multiple_digits"
        ),
        JumbleGameData(
          displayedProblem: '158 + 217 + 325 = 700', 
          multiAcceptedAnswers: [
            ['one hundred and fifty eight', "plus", 'two hundred and seventeen', 'plus ', 'three hundred and twenty five', 'equals', 'seven hundred'],
            ['one hundred and fifty eight', "plus ", 'two hundred and seventeen', 'plus', 'three hundred and twenty five', 'equals', 'seven hundred']
          ],
          optionList: ['one hundred and fifty eight', "plus ", 'twenty one and seven', 'thirty five hundred and sixty seven',
          'three hundred and twenty five', 'plus', 'seven hundred', 'two hundred and seventeen', 'equals'],
          id: "jumble.addition.two_or_more_opperands"
        ),
        JumbleGameData(
          displayedProblem: '176 + 95 + 160 = 431', 
          multiAcceptedAnswers: [
            ['one hundred and seventy six', "plus", 'ninety five', 'plus ', 'one hundred and sixty', 'equals', 'four hundred and thirty one'],
            ['one hundred and seventy six', "plus ", 'ninety five', 'plus', 'one hundred and sixty', 'equals', 'four hundred and thirty one']
          ],
          optionList: ['ninety five', "plus ", 'four hundred and thirty one', 'seventeen and six',
          'one hundred and seventy six', 'plus', 'four thrity one', 'one hundred and sixty', 'equals'],
          id: "jumble.addition.multiple_digits"
        ),
        JumbleGameData(
          displayedProblem: '5.32 + 4.63 = 9.95', 
          multiAcceptedAnswers: [
            ['five and thirty two hundredths', "plus", 'four and sixty three hundredths', 'equals', 'nine and ninety five hundredths']
          ],
          optionList: ['five and thirty two hundredths', "plus ", 'four point sixty three', 'nine and ninety five hundredths',
          'four and sixty three hundredths', 'plus', 'five point thirty two', 'nine point ninety five', 'equals'],
          id: "jumble.addition.decimals",
          writtenPrompt: "Write your answer in proper written form."
        ),
        JumbleGameData(
          displayedProblem: '0.293 + 1.954 = 2.247', 
          multiAcceptedAnswers: [
            ['two hundred and nintey three thousandths', "plus", 'one and nine hundred and fifty four thousandths', 'equals', 'two and two hundred and fourty seven thousandths']
          ],
          optionList: ['zero and two hundred and ninety three thousandths', "plus ", 'two hundred and nintey three thousandths', 'one point nine hundred and fifty four',
          'one and nine hundred and fifty four thousandths', 'plus', 'two and two hundred and fourty seven thousandths', 'equals'],
          id: "jumble.addition.decimals",
          writtenPrompt: "Write your answer in proper written form."
        )
      ]
    );

    jumbleBank.addAll(
      // an example of a jumble game data object. This one does use the optional writtenPrompt parameter
      [
        JumbleGameData(
          displayedProblem: 'Sally is 5 years old. Her mother 8 times as old as Sally is. How old is her mother?', 
          multiAcceptedAnswers: [
            ["She", "is", "forty", "years-old"]
          ],
          writtenPrompt: 'Answer the short-response question using the blocks below.',
          optionList: [
            "She", "eight", "five", "forty", "thrity-two", "is", "forty-eight", "years-old"
          ]
        ),
        JumbleGameData(
          displayedProblem: 'Gerald started a new collection with 325 bottle caps. He collects 158 more caps in September and 217 more in October. How many bottle caps did he have at the end of October?', 
          multiAcceptedAnswers: [
            ["Gerald", "has", "seven hundred", "bottle caps"]
          ],
          writtenPrompt: 'Answer the short-response question using the blocks below.',
          optionList: [
            "seven hundred and zero", "Gerald", "bottle caps", "seven hundred", "seven thousand", "has"
          ]
        ),
        JumbleGameData(
          displayedProblem: 'Franklin has a set of building blocks with 176 pieces. He received 2 more sets as gifts. One has 95 pieces; the other has 160 pieces. How many building blocks does Franklin have all together?', 
          multiAcceptedAnswers: [
            ["Franklin", "has", "four hundred and thirty one", "blocks"]
          ],
          writtenPrompt: 'Answer the short-response question using the blocks below.',
          optionList: [
            "blocks", "four hundred thirty one", "Franklin", "fourty-three and one", "has", "four thirty one", 
          ]
        ),
        JumbleGameData(
          displayedProblem: 'Archery Team A hit the target 367 times. Team B hit the target 412 times. Did the two teams hit the target 800 times? If not, by how much did they miss?', 
          multiAcceptedAnswers: [
            ["They", "missed", "twenty-one", "times"]
          ],
          writtenPrompt: 'Answer the short-response question using the blocks below.',
          optionList: [
            "seven hundred and seventy nine", "They", "twenty-one", "missed", "seven hundred seventy", "times"
          ]
        )
      ]
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
    typingBank.addAll(
      [
        TypingGameData(
          displayedProblem: '4153 + 3567 = 7720', 
          multiAcceptedAnswers: ["four thousand one hundred and fifty three plus three thousand five hundred and sixty seven equals seven thousand seven hundred and twenty",
          "four thousand one hundred and fifty three plus three thousand five hundred and sixty seven is seven thousand seven hundred and twenty"]
        ),
        TypingGameData(
          displayedProblem: 'Patrick has filled 1,485 of 3,000 baseball cards. How many cards are left to be filled?', 
          multiAcceptedAnswers: ["one thousand five hundred and fifteen", "one thousand five hundred fifteen"],
          writtenPrompt: "Type the remaining card amount in standard written form."
        ),
        TypingGameData(
          displayedProblem: 'Elizabeth and Jeanne are covering a fireplace mantel with 4500 fancy tacks. Elisabeth has added 934 tacks to the mantel. Jeanne has added 1,093 tacks. How many tacks do they have to add to complete the mantel?', 
          multiAcceptedAnswers: ["two thousand four hundred and seventy three", "two thousand four hundred seventy three"],
          writtenPrompt: "Type the remaining tacks needed in written form"
        )
      ]
    );
  }

  void initFillBlanksBank() {
    fillBlanksBank.addAll(
      [
        FillBlanksGameData(
          displayedProblem: 'Sally is 5 years old. Her mother 8 times as old as Sally is. How old is her mother?', 
          multiAcceptedAnswers: ["forty"], 
          writtenPrompt: 'Use the options below to answer the word problem.', 
          blankForm: "Sally's mother is  ____ years old", 
          optionList: [
            "eight", "five", "forty", "thrity-two", "forty-eight"
          ]
        ),
        FillBlanksGameData(
          displayedProblem: 'Archery Team A hit the target 367 times. Team B hit the target 412 times. How many times did they hit the target?', 
          multiAcceptedAnswers: ["seven hundred and seventy nine"], 
          writtenPrompt: 'Use the options below to answer the word problem.', 
          blankForm: "The teams hit the target ____ times", 
          optionList: [
            "eight hundred", "twenty one", "seven hundred and seventy nine", "four hundred and tweleve", "three hundred and sixty seven"
          ]
        ),
        FillBlanksGameData(
          displayedProblem: 'Murphy has an article with 72,885 words and an article with 59,993 words. How many more words does the longer article have?', 
          multiAcceptedAnswers: ["tweleve thousand eight hundred and ninety two"], 
          writtenPrompt: 'Use the options below to answer the word problem.', 
          blankForm: "The longer article has ____ more words than the shorter one.", 
          optionList: [
            "seventy two thousand eight hundred and eighty five", "tweleve thousand eight hundred and ninety two", "fifty nine thousand nine hundred and ninrty three", "one hundred two thousand eight hundred and ninety two", "five hundred thousand nine thousand nine hundred and ninety three"
          ]
        )
      ]
    );
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