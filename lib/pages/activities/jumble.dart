
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:onwards/pages/calculator.dart';
import 'package:onwards/pages/game_data.dart';
import 'package:onwards/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class JumbleActivityScreen extends StatelessWidget {
  const JumbleActivityScreen({
    super.key,
    this.colorProfile = lightFlavor
  });
  
  final ColorProfile colorProfile;

  @override
  Widget build(BuildContext context) {

    JumbleGameData jumbleGameData = bank.getRandomJumbleElement();


    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Jumble Game'),
        backgroundColor: colorProfile.headerColor,
        actions: const [CalcButton()],
      ),
      body: Center(
        child: GameForm(
          answers: jumbleGameData.multiAcceptedAnswers, 
          questionLabel: jumbleGameData.displayedProblem, 
          maxSelectedAnswers: jumbleGameData.getMinSelection(), 
          buttonOptions: jumbleGameData.optionList,
          titleQuestion: jumbleGameData.writtenPrompt,
          showArithmitic: true,
          colorProfile: colorProfile,
          skills: jumbleGameData.skills,
        ),
      ),
    );
  }
}

// Show this game's unique game form using the data
// passed from GameData. The idea is to have the game
// move to the next question after the dialog, using context
// to pass the info over
class GameForm extends StatefulWidget {
  const GameForm({
    super.key,
    required this.answers, 
    required this.questionLabel,
    required this.maxSelectedAnswers,
    required this.buttonOptions,
    required this.titleQuestion,
    required this.showArithmitic,
    required this.colorProfile,
    required this.skills
  });

  final ColorProfile colorProfile; 
  /// The label for the question, which should be the math form for this game
  final String questionLabel;
  /// The list of combos accepted as answers
  final List<List<String>> answers;
  /// The number of max soloutions in the correct answer
  final int maxSelectedAnswers;
  /// the text for the buttons that can be used to create this phrase
  final List<String> buttonOptions;
  final String titleQuestion;
  final bool showArithmitic;
  final List<String> skills;

  @override
  GameFormState createState() => GameFormState();
}

class GameFormState extends State<GameForm> {
  final Future<SharedPreferencesWithCache> _prefs =
    SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: <String>{'correct', 'theme_id', 'missed', 'mastered_topics', 'weak_topics'}
      ));
  late Future<int> correctCounter;
  late Future<int> missedCounter;
  late Future<List<String>> masteredTopicList;
  late Future<List<String>> weakTopicList;
  late Future<int> themeId;
  OverlayEntry? entry;
  ColorProfile? cachedTheme;
  // confetti animation
  late ConfettiController _bottom_right_controller1;
  late ConfettiController _bottom_right_controller2;
  late ConfettiController _bottom_left_controller1;
  late ConfettiController _bottom_left_controller2;
  final globalGravity = 0.10;
  final maxBlastForce = 60.0;
  final minBlastForce = 50.0;

  ColorProfile currentProfile = lightFlavor;
  final List<String> _selectedAnswers = [];
  int maxSelection = 0;
  int currentCount = 0;

  @override
  void initState() {
    Random random = Random();
    currentProfile = widget.colorProfile;

    widget.buttonOptions.shuffle(random);
    maxSelection = widget.maxSelectedAnswers;
    correctCounter = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getInt('correct') ?? 0;
    });
    missedCounter = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getInt('missed') ?? 0;
    });
    themeId = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getInt('theme_id') ?? 0;
    });
    masteredTopicList = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getStringList('mastered_topics') ?? <String>[];
    });
    weakTopicList = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getStringList('weak_topics') ?? <String>[];
    });
    // confetti controller states
    _bottom_right_controller1 = ConfettiController(duration: const Duration(seconds: 5));
    _bottom_right_controller2 = ConfettiController(duration: const Duration(seconds: 5));
    _bottom_left_controller1 = ConfettiController(duration: const Duration(seconds: 5));
    _bottom_left_controller2 = ConfettiController(duration: const Duration(seconds: 5));
    loadTheme();

    super.initState();
  }

  @override
  void dispose() {
    _bottom_right_controller1.dispose();
    _bottom_right_controller2.dispose();
    _bottom_left_controller1.dispose();
    _bottom_left_controller2.dispose();
    super.dispose();
  }

  Future<void> _incrementCounter() async {
    final SharedPreferencesWithCache prefs = await _prefs;
    final int counter = (prefs.getInt('correct') ?? 0) + 1;
    setState(() {
      correctCounter = prefs.setInt('correct', counter).then((_) {
        logger.i('Updating correct count...');
        return counter;
      });
    });
  }

  Future<void> loadTheme() async {
    final SharedPreferencesWithCache prefs = await _prefs;
    int? themeIndex = (prefs.getInt('theme_id') ?? 0);
    setState(() {
      cachedTheme = _getProfileByIndex(themeIndex);
      logger.i("Loaded theme: ${cachedTheme?.idKey}");
    });
    // check if cached theme is diffrent from the current one
    if (cachedTheme?.idKey != widget.colorProfile.idKey) {
      logger.w("Cached theme did not match the current one. Current: ${widget.colorProfile.idKey}, Cached: ${cachedTheme?.idKey}");
      currentProfile = cachedTheme!;
    } else {
      logger.i("Both themes match");
      currentProfile = widget.colorProfile;
    }
  }

  ColorProfile _getProfileByIndex(int index) {
    switch(index) {
        case 0:
          return lightFlavor;
        case 1:
          return darkFlavor;
        case 2:
          return plainFlavor;
        case 3:
          return mintFlavor;
        case 4:
          return strawberryFlavor;
        case 5:
          return bananaFlavor;
        case 6:
          return peanutFlavor;
        default:
          return lightFlavor;
      }
  }

  Future<void> addMasteredTopic(String topic) async {
    final SharedPreferencesWithCache prefs = await _prefs;
    final List<String> mastered = (prefs.getStringList('mastered_topics') ?? <String>[]);
    if (mastered.contains(topic)) {
      logger.i("The skill mastery list already contained: $topic");
      return;
    } else {
      mastered.add(topic);
    }

    setState(() {
      masteredTopicList = prefs.setStringList('mastered_topics', mastered).then((_) {
        return mastered;
      });
    });
  }

  /// Validate the current selection against the multiple answers
  int validateAnswer() {
    int errorIndex = 0;
    bool isCorrect = true;
    if (currentCount >= maxSelection) {
      for (List<String> answerList in widget.answers) {
        for (int i = 0; i < answerList.length; i++) {
          if (_selectedAnswers[i] != answerList[i]) {
            logger.d("Validating Answer: Expected ${answerList[i]}");
            isCorrect = false;
            errorIndex = i;
          } else {
            // in the case that there are multiple answers, we need to see if the other ones (besides the first) are correct
            // instead of failing on the first
            logger.d("Validating Answer: Another answer matched the current assortment");
            isCorrect = true;
          }
        }
        
        // when we are done going through one answer, if its correct, just skip checking the rest
        if (isCorrect) {
          logger.i("Not enough answers are selected, could not validate");
          return -1;
        } else {
          return errorIndex;
        }
      }
    } else {
      logger.d("Not enough answers are selected, could not validate");
      return 0;
    }
    return 0;
  }

  void clearAnswers() {
    setState(() {
      currentCount = 0;
      logger.d("Cleared answer selection");
      _selectedAnswers.clear();
    });
  }

  Future _showCorrectDialog(errorIndex) {
    List<Widget> answerDialogList = [
      TextButton(
        onPressed: () async {
          _incrementCounter();
          for (String skill in widget.skills) {
            addMasteredTopic(skill);
          }
          // removes the dialog
          Navigator.of(context)
            .pop('someString');
          Navigator.of(context)
            .pop('someString');
          // the line here pushes the homepage again. for series, it should not do this
          /*
          Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const HomePage()));
          */
        }, 
        child: Text('Continue', 
          style: TextStyle(
            color: currentProfile.textColor,
          ),
        ),
      ),
    ];

   // show an error dialog if the selected answers are empty (obselete)
    if (_selectedAnswers.isEmpty) {
      return showDialog(
        context: context, 
        builder: (context) {
          return AlertDialog(
            content: Text(
              "Select more options",
              style: TextStyle(
                color: currentProfile.textColor
              ),
            ),
            title: Text(
              'Incomplete Answer',
              style: TextStyle(
                color: currentProfile.textColor
              ),
            ),
            backgroundColor: currentProfile.buttonColor,
          );
        }
      );
    }
    
    if (errorIndex == -1) {
      // Show dialog with correct answer
      return showDialog(
        context: context, 
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            actions: answerDialogList,
            title: Text('Way to go!',
              style: TextStyle(
                color: currentProfile.textColor
              ),
            ),
            backgroundColor: currentProfile.buttonColor,
          );
        }
      );
    } else if (errorIndex == 0) {
      // Show dialog with error message on too few selected answers
      return showDialog(
        context: context, 
        builder: (context) {
          return AlertDialog(
            content: Text(
              "Please select more answers",
              style: TextStyle(
                color: currentProfile.textColor
              ),
            ),
            title: Text(
              'Incomplete Answer',
              style: TextStyle(
                color: currentProfile.textColor
              ),
            ),
            backgroundColor: currentProfile.buttonColor,
          );
        }
      );
    
    } else {
      // Show dialog with location of error
      return showDialog(
        context: context, 
        builder: (context) {
          return AlertDialog(
            content: Text(
              "Incorrect Answer at ${_selectedAnswers[errorIndex]}",
              style: TextStyle(
                color: currentProfile.textColor
              ),
            ),
            title: Text(
              'Try again',
              style: TextStyle(
                color: currentProfile.textColor
              ),
            ),
            backgroundColor: currentProfile.backgroundColor,
          );
        }
      );
    }
  }

  // create a list of widgets that represents the selected button choices
  List<Widget> renderConditionalLabels() {
    List<Widget> widgets =[];

    for (String part in _selectedAnswers) {
      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5), 
        child: Text(
          part,
          style: TextStyle(
            fontSize: 18.0,
            color: currentProfile.textColor
          ),
        )
      ));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    
    void hideOverlay() {
      entry?.remove();
      entry = null;
      _showCorrectDialog(validateAnswer());
    }

    void showAnimation() {
      entry = OverlayEntry(
        builder: (context) => OverlayBanner(
          onBannerDismissed: () {
            hideOverlay();
          },
        )
      );

      final overlay = Overlay.of(context);
      overlay.insert(entry!);
    }

    void showDisplay() {
      WidgetsBinding.instance.addPostFrameCallback((_) => showAnimation());
        _bottom_left_controller1.play();
        _bottom_left_controller2.play();
        _bottom_right_controller1.play();
        _bottom_right_controller2.play();
    }
    // List<String> selectedAnswers = [];
    // This is the data of multiple games
    List<Widget> dynamicButtonList = <Widget> [];

    for (String option in widget.buttonOptions) {
      Widget button = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: GameButton(
          onPressed: () => {
            setState(() {
              if (currentCount < maxSelection) {
                _selectedAnswers.add(option);
                // _selectedIds.add(id);
                currentCount += 1;
              }
            }),
          }, 
          isDisabled: _selectedAnswers.contains(option), 
          label: option,
          colorProfile: currentProfile,
        ),
      );
      
      dynamicButtonList.add(button);
    }
    
    // Render the form here
    /*
    'Button tapped ${snapshot.data ?? 0 + _externalCounter} time${(snapshot.data ?? 0 + _externalCounter) == 1 ? '' : 's'}.\n\n'
    'This should persist across restarts.', style: TextStyle(color: currentProfile.textColor)
    */
    return Container(
      decoration: currentProfile.backBoxDecoration,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: ConfettiWidget(
              confettiController: _bottom_right_controller1,
              blastDirection: (4*pi)/3, // 7 pi /4
              emissionFrequency: 0.000001,
              particleDrag: 0.05,
              numberOfParticles: 25,
              gravity: globalGravity,
              minBlastForce: minBlastForce,
              maxBlastForce: maxBlastForce,
              shouldLoop: false,

            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: ConfettiWidget(
              confettiController: _bottom_right_controller2,
              blastDirection: (7*pi)/6, // 7 pi /4
              emissionFrequency: 0.000001,
              particleDrag: 0.05,
              numberOfParticles: 50,
              gravity: globalGravity,
              minBlastForce: minBlastForce,
              maxBlastForce: maxBlastForce,
              shouldLoop: false,

            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: ConfettiWidget(
              confettiController: _bottom_left_controller1,
              blastDirection: (11*pi)/6,
              emissionFrequency: 0.000001,
              particleDrag: 0.05,
              numberOfParticles: 50,
              gravity: globalGravity,
              minBlastForce: minBlastForce,
              maxBlastForce: maxBlastForce,
              shouldLoop: false,

            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: ConfettiWidget(
              confettiController: _bottom_left_controller2,
              blastDirection: (5*pi)/3,
              emissionFrequency: 0.000001,
              particleDrag: 0.05,
              numberOfParticles: 25,
              gravity: globalGravity,
              minBlastForce: minBlastForce,
              maxBlastForce: maxBlastForce,
              shouldLoop: false,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  widget.titleQuestion,
                  style: TextStyle(
                      color: currentProfile.textColor, 
                      fontSize: 30,
                    ),
                    textAlign: TextAlign.center,
                ),
                // Render the question label
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: widget.showArithmitic ? Text(
                    widget.questionLabel,
                    style: TextStyle(
                      color: currentProfile.textColor, 
                      fontSize: 30,
                      
                    ),
                  ) : null,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column( 
                    // attempt to render the selected answers as they are moved into the list
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: renderConditionalLabels(),
                      ),
                    ],
                  )
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: dynamicButtonList,
                    ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: _selectedAnswers.isEmpty ? null : () => {
                        if (validateAnswer() < 0) {
                          showDisplay()
                        } else {
                          _showCorrectDialog(validateAnswer())
                        }
                      }, 
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(currentProfile.checkAnswerButtonColor),
                      ),
                      child: Text(
                        'Check Answer',
                          style: TextStyle(
                            color: currentProfile.contrastTextColor
                          ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => {
                        clearAnswers()
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(currentProfile.clearAnswerButtonColor),
                      ),
                      child: Text(
                        'Clear all answers',
                        style: TextStyle(
                          color: currentProfile.contrastTextColor),
                      )
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      )
    );
    
  }
}

class GameButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isDisabled;
  final String label;
  final String disabledLabel;
  final ColorProfile colorProfile;
  final int id;

  const GameButton({
    super.key, 
    required this.onPressed, 
    required this.isDisabled,
    required this.label,
    this.disabledLabel = "",
    this.id = 0,
    required this.colorProfile
    });

    int getID() {
      return id;
    }

  @override
  GameButtonState createState() => GameButtonState();

}

class GameButtonState extends State<GameButton> {
  late bool isDisabled;

  @override
  void initState() {
    super.initState();
    isDisabled = widget.isDisabled; // Initialize internal state based on external flag
  }

  @override
  void didUpdateWidget(GameButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update the internal state when the external flag changes
    if (widget.isDisabled != oldWidget.isDisabled) {
      setState(() {
        isDisabled = widget.isDisabled;
      });
    }
  }

  void setDisabled(bool disabled) {
    setState(() {
      isDisabled = disabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : () {
        widget.onPressed();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        decoration: BoxDecoration(
          image: isDisabled ? const DecorationImage(
            image: AssetImage('images/disabled_button.png'),
            fit: BoxFit.fitHeight
          ) : null,
          color: isDisabled ? widget.colorProfile.buttonColor : widget.colorProfile.buttonColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            color: widget.colorProfile.contrastTextColor,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}