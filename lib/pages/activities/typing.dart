

import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:onwards/pages/activities/game_series.dart';
import 'package:onwards/pages/constants.dart';
import 'package:onwards/pages/game_data.dart';
import 'package:onwards/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TypeActivityScreen extends StatelessWidget {
  const TypeActivityScreen({
    super.key,
    this.colorProfile = lightFlavor
  });

  final ColorProfile colorProfile;

  @override
  Widget build(BuildContext context) {
    TypingGameData typingGameData = bank.getRandomTypingElement();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Type it Out Game'),
        backgroundColor: colorProfile.headerColor,
      ),
      body: GameForm(
        answers: typingGameData.multiAcceptedAnswers, 
        questionLabel: typingGameData.displayedProblem,
        instructions: typingGameData.writtenPrompt, 
        colorProfile: colorProfile,
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
    required this.instructions
  });

  final String questionLabel;
  final List<String> answers;
  final ColorProfile colorProfile;
  final String instructions;
  final count = 0;


@override
  State<GameForm> createState() => _GameFormState();
}

class _GameFormState extends State<GameForm> {
  final Future<SharedPreferencesWithCache> _prefs =
    SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: <String>{'correct'}
      ));
  late Future<int> _counter;
  final _answerFieldController = TextEditingController();
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
    _counter = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getInt('correct') ?? 0;
    });
    _bottom_right_controller1 = ConfettiController(duration: const Duration(seconds: 5));
    _bottom_right_controller2 = ConfettiController(duration: const Duration(seconds: 5));
    _bottom_left_controller1 = ConfettiController(duration: const Duration(seconds: 5));
    _bottom_left_controller2 = ConfettiController(duration: const Duration(seconds: 5));
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
      _counter = prefs.setInt('correct', counter).then((_) {
        logger.i('Updating correct count...');
        return counter;
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
        onPressed: () => {
          _incrementCounter(),
          Navigator.pop(context),
          Navigator.pop(context),
        }, 
        child: Text('Go back Home',
          style: TextStyle(
            color: widget.colorProfile.textColor
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
                color: widget.colorProfile.textColor
              ),),
            backgroundColor: widget.colorProfile.buttonColor,
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
                color: widget.colorProfile.textColor
              ),
            ),
            title: Text(
              'Try again...',
              style: TextStyle(
                color: widget.colorProfile.textColor
              ),
            ),
            backgroundColor: widget.colorProfile.buttonColor,
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
      decoration: widget.colorProfile.backBoxDecoration,
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
                      color: widget.colorProfile.textColor, 
                      fontSize: 30,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      widget.questionLabel,
                      style: TextStyle(
                        color: widget.colorProfile.textColor, 
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
                          hintStyle: TextStyle(color: widget.colorProfile.textColor, fontSize: 18),
                          fillColor: Colors.grey,
                          labelStyle: TextStyle(color: widget.colorProfile.textColor, fontSize: 18),
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
                      backgroundColor: WidgetStatePropertyAll(widget.colorProfile.checkAnswerButtonColor),
                    ),
                    child: Text(
                      'Check Answer',
                      style: TextStyle(color: widget.colorProfile.contrastTextColor),
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