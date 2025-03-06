

import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:onwards/pages/components/calculator.dart';
import 'package:onwards/pages/components/progress_bar.dart';
import 'package:onwards/pages/constants.dart';
import 'package:onwards/pages/game_data.dart';
import 'package:onwards/pages/home.dart';
import 'package:onwards/pages/score_display.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TypeActivityScreen extends StatelessWidget {
  const TypeActivityScreen({
    super.key,
    this.colorProfile = lightFlavor,
  });

  final ColorProfile colorProfile;

  @override
  Widget build(BuildContext context) {
    TypingGameData typingGameData = bank.getRandomTypingElement();

    return Scaffold(
      appBar: AppBar(
        title: Text('Type it Out Game', style: TextStyle(color: colorProfile.textColor)),
        backgroundColor: colorProfile.headerColor,
        actions: const [ProgressBar(), ScoreDisplayAction(), CalcButton()]
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: GameForm(
          answers: typingGameData.multiAcceptedAnswers, 
          questionLabel: typingGameData.displayedProblem,
          instructions: typingGameData.writtenPrompt, 
          colorProfile: colorProfile, 
          skills: typingGameData.skills,
        ),
      )
    );
  }
}

/// Show this game's unique game form using the data
/// passed from GameData. The idea is to have the game
/// move to the next question after the dialog, using context
/// to pass the info over
class GameForm extends StatefulWidget {
  const GameForm({
    super.key,
    required this.answers, 
    required this.questionLabel,
    required this.colorProfile,
    required this.instructions, 
    required this.skills
  });

  final String questionLabel;
  final List<String> answers;
  final ColorProfile colorProfile;
  final String instructions;
  final count = 0;
  final List<String> skills;


@override
  State<GameForm> createState() => _GameFormState();
}

class _GameFormState extends State<GameForm> {
  final Future<SharedPreferencesWithCache> _prefs =
    SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: <String>{'correct', 'theme_id', 'missed', 'mastered_topics', 'weak_topics'}
      ));
  late Future<int> correctCounter;
  late Future<int> missedCounter;
  late Future<List<String>> masteredTopicList;
  late Future<List<String>> weakTopicList;
  final _answerFieldController = TextEditingController();
  late Future<int> themeId;
  ColorProfile? cachedTheme;
  // placeholder
  ColorProfile currentProfile = lightFlavor;
  OverlayEntry? entry;
  late ConfettiController _bottom_right_controller1;
  late ConfettiController _bottom_right_controller2;
  late ConfettiController _bottom_left_controller1;
  late ConfettiController _bottom_left_controller2;
  final globalGravity = 0.10;
  final maxBlastForce = 80.0;
  final minBlastForce = 60.0;

  @override
  void initState() {
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
  
  /// Checks the answer in the field against the accepted answers. The answer in the
  /// field is turned to lowercase before validation
  bool validateAnswer() {
    var isCorrect = true;
    if (widget.count > 0) {
      
    } else {
      for (String potAnswer in widget.answers) {
        logger.i("Validating against $potAnswer");
        if (potAnswer != _answerFieldController.text) {
          isCorrect = false;
          // print("Answer was incorrect at: $potAnswer");
        } else {
          isCorrect = true;
          return isCorrect;
        }
      }
    }
    return isCorrect;
  }

  Future _showCorrectDialog(bool showOverlay) {
    List<Widget> answerDialogList = [
      TextButton(
        onPressed: () async {
          _incrementCounter();
          for (String skill in widget.skills) {
            addMasteredTopic(skill);
          };
          Navigator.pop(context);
          Navigator.pop(context);
        }, 
        child: Text('Continue',
          style: TextStyle(
            color: currentProfile.textColor
          ),
        )
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
                color: currentProfile.textColor
              ),),
            backgroundColor: currentProfile.buttonColor,
          );
        }
      );
    } else {
      return showDialog(
        context: context, 
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

  @override
  Widget build(BuildContext context) {
    bool valid;

    List<Widget> confettiAnimators = <Widget> [
      
    ];

    void hideOverlay() {
      entry?.remove();
      entry = null;
      _showCorrectDialog(true);
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
              numberOfParticles: 25,
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
              numberOfParticles: 25,
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
            child: Form(
              key: const Key("_formKey"),
              child: Column(
                children: [
                  Text(
                    widget.instructions,
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
                  SizedBox(
                    width: 500.0,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextFormField(
                        maxLines: 3,
                        controller: _answerFieldController,
                        decoration: InputDecoration(
                          hintText: 'Type your answer...',
                          labelText: 'Your Answer',
                          filled: true,
                          hintStyle: TextStyle(color: currentProfile.textColor, fontSize: 18),
                          fillColor: Colors.grey,
                          labelStyle: TextStyle(color: currentProfile.textColor, fontSize: 18),
                          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                        ),
                        onFieldSubmitted: (value) {
                          showDisplay();
                        }
                      ),
                    )
                  ),
                  TextButton(
                    onPressed: () => {
                      valid = validateAnswer(),
                      if (valid) {
                        showDisplay()
                      } else {
                        _showCorrectDialog(valid)
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
                ],
              ),
            ),
          ),
        ],
      )
    );
  }}