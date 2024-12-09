import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:onwards/pages/calculator.dart';
import 'package:onwards/pages/constants.dart';
import 'package:onwards/pages/game_data.dart';
import 'package:onwards/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The screen for the 'Fill in the Blank' game.
/// Uses data in the form of GameData 
///
class FillInActivityScreen extends StatelessWidget {
  const FillInActivityScreen({
    super.key,
    this.colorProfile = plainFlavor
  });

  final ColorProfile colorProfile;

  @override
  Widget build(BuildContext context) {

    FillBlanksGameData fillBlanksGameData = bank.getRandomFillBlanksElement();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fill in the Blank Game'),
        backgroundColor: colorProfile.headerColor,
        actions: const [CalcButton()],
      ),
      body: GameForm(
        answers: fillBlanksGameData.multiAcceptedAnswers, 
        questionLabel: fillBlanksGameData.displayedProblem,  
        blankQuestLabel: fillBlanksGameData.blankForm,
        maxSelectedAnswers: fillBlanksGameData.getMinSelection(),
        buttonOptions: fillBlanksGameData.optionList,
        colorProfile: colorProfile,
        skills: fillBlanksGameData.skills,
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
    required this.blankQuestLabel,
    required this.maxSelectedAnswers,
    required this.buttonOptions,
    required this.colorProfile,
    required this.skills
  });

  final ColorProfile colorProfile;
  final String questionLabel;
  final List<String> answers;
  final String blankQuestLabel;
  final int maxSelectedAnswers;
  final List<String> buttonOptions;
  final List<String> skills;

  @override
  GameFormState createState() => GameFormState();
}

class GameFormState extends State<GameForm> {

  final List<String> _selectedAnswers = [];
  int maxSelection = 0;
  int currentCount = 0;
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
  ColorProfile? cachedTheme;
  // placeholder
  ColorProfile currentProfile = lightFlavor;

  OverlayEntry? entry;
  // confetti animation
  late ConfettiController _bottom_right_controller1;
  late ConfettiController _bottom_right_controller2;
  late ConfettiController _bottom_left_controller1;
  late ConfettiController _bottom_left_controller2;
  final globalGravity = 0.10;
  final maxBlastForce = 60.0;
  final minBlastForce = 50.0;

  @override
  void initState() {
    Random random = Random();
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

  bool validateAnswer() {
    bool isCorrect = true;
    if (currentCount >= widget.maxSelectedAnswers) {
      for (int i = 0; i < _selectedAnswers.length; i++) {
        if (_selectedAnswers[i] != widget.answers[i]) {
          isCorrect = false;
          logger.d("Correct answer did not match at: ${widget.answers[i]}");
        }
      }
    } else {
      isCorrect = false;
    }
    logger.d("validated answer");
    return isCorrect;
  }

  Future _showCorrectDialog(bool showOverlay) {
    List<Widget> answerDialogList = [
      TextButton(
        onPressed: () async {
          _incrementCounter();
          for (String skill in widget.skills) {
            addMasteredTopic(skill);
          }
          Navigator.pop(context);
          Navigator.pop(context);
        }, 
        child: Text('Continue', 
          style: TextStyle(
              color: currentProfile.textColor,
            ),
          ),
      ),
    ];

    if (showOverlay) {
      return showDialog(
        context: context, 
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            actions: answerDialogList,
            title: Text('Way to go!', 
            style: TextStyle(
                color: currentProfile.textColor,
              ),),
            backgroundColor: currentProfile.buttonColor,
          );
        }
      );
    } else {
      return showDialog(
        context: context, 
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            content: Text(
              "Click any where to return to the problem",
              style: TextStyle(
                color: currentProfile.textColor
              ),
            ),
            title: Text(
              'Try again...',
              style: TextStyle(
                color: currentProfile.textColor
              ),
            ),
            backgroundColor: currentProfile.buttonColor,
          );
        }
      );
    }
  }

  List<Widget> renderConditionalLabels(List<String> splitter) {
    List<Widget> widgets =[];
    int countForSelected = 0;
    for (String part in splitter) {
      if (part.contains("_")) {
        if (_selectedAnswers.isNotEmpty && countForSelected < _selectedAnswers.length) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5), 
              child: Text(
                _selectedAnswers[countForSelected],
                style: TextStyle(
                  fontSize: 18.0,
                  color: currentProfile.contrastTextColor
                ),
              )
            )
          );
          countForSelected += 1;
        } else {
          widgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5), 
              child: Text(
                part,
                style: TextStyle(
                  fontSize: 18.0,
                  color: currentProfile.textColor
                ),
              ),
            )
          );
        }
      }
      else {
          widgets.add(Padding(
            padding: const EdgeInsets.symmetric(vertical: 5), 
            child: Text(
              part,
              style: TextStyle(
                fontSize: 18.0,
                color: currentProfile.textColor
              ),
            ),
          )
        );
      }
      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 5), 
          child: Text(
            " ",
            style: TextStyle(
              fontSize: 18.0,
              color: currentProfile.textColor
            ),
          ),
        )
      );
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
    List<String> splitter = widget.blankQuestLabel.split(" ");

    for (String option in widget.buttonOptions) {
      ElevatedButton button = ElevatedButton(
        onPressed: () => {
          setState(() {
            if (currentCount < maxSelection) {
              _selectedAnswers.add(option);
              currentCount += 1;
            }
          })
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: currentProfile.buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 24
          ),
        ),
        child: Text(
          option, 
          style: TextStyle(color: currentProfile.contrastTextColor),
        ),
      );
      Padding padding = Padding(
        padding: const EdgeInsets.all(8.0),
        child: button,
      );
      dynamicButtonList.add(padding);
    }
    
    // Render the form here
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
                  "Use the blocks below to form the written form of the expression:",
                  style: TextStyle(
                    color: currentProfile.textColor, 
                    fontSize: 30,
                  ),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    widget.questionLabel,
                    style: TextStyle(
                      color: currentProfile.textColor, 
                      fontSize: 30,
                      
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column( // attempt to render the selected answers as they are moved into the list
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: renderConditionalLabels(splitter),
                      ),
                    ],
                  )
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: dynamicButtonList,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextButton(
                        onPressed: () => {
                          if (validateAnswer()) {
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
                          style: TextStyle(color: currentProfile.contrastTextColor),
                        )
                      )
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          currentCount = 0;
                          _selectedAnswers.clear();
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(currentProfile.clearAnswerButtonColor),
                      ),
                      child: Text(
                        'Clear all answers',
                        style: TextStyle(color: currentProfile.contrastTextColor),
                        )
                      )
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