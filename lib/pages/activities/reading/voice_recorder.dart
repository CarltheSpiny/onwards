import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:onwards/pages/activities/reading/speech_to_text_helper.dart';
import 'package:onwards/pages/constants.dart';
import 'package:onwards/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AudioTranscriptionWidget extends StatefulWidget {
  const AudioTranscriptionWidget({
    super.key,
    required this.acceptedAnswers,
    required this.questionLabel,
    required this.titleText,
    required this.colorProfile,
    this.useNumWordProtocol = true,
    required this.skills
  });

  final ColorProfile colorProfile;
  final String questionLabel;
  final List<List<String>> acceptedAnswers;
  final String titleText;
  final bool useNumWordProtocol;
  final List<String> skills;

  @override
  AudioTranscriptionWidgetState createState() => AudioTranscriptionWidgetState();
}

class AudioTranscriptionWidgetState extends State<AudioTranscriptionWidget> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String defaultTranscribedText = "Press the button to start speaking and your words will appear here!";
  String _transcribedText = "Press the button to start speaking and your words will appear here!";
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
    
    // confetti controller states
    _bottom_right_controller1 = ConfettiController(duration: const Duration(seconds: 5));
    _bottom_right_controller2 = ConfettiController(duration: const Duration(seconds: 5));
    _bottom_left_controller1 = ConfettiController(duration: const Duration(seconds: 5));
    _bottom_left_controller2 = ConfettiController(duration: const Duration(seconds: 5));
    loadTheme();
    super.initState();

    _speech = stt.SpeechToText();
    correctCounter = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getInt('correct') ?? 0;
    });
    missedCounter = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getInt('missed') ?? 0;
    });

    masteredTopicList = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getStringList('mastered_topics') ?? <String>[];
    });
    weakTopicList = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getStringList('weak_topics') ?? <String>[];
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

  void _listen() async {
    // we get here from the microphone button

    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => logger.i('onStatus: $val'),
        onError: (val) => logger.e('onError: $val'),
      );
      if (available && mounted) {
        setState(() => _isListening = true);
          _speech.listen(
            listenOptions: stt.SpeechListenOptions(partialResults: true),
            onResult: (val) => setState(() {
              _transcribedText = val.recognizedWords;
              if (widget.useNumWordProtocol) {
                _transcribedText = convertNumbersAndSymbolsToWords(_transcribedText);
              }
            }
          )
        );
      } else {
        setState(() => _isListening = false);
        _speech.stop();
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  bool validateAnswer() {
    bool isCorrect = true;

    for (List<String> answerList in widget.acceptedAnswers) {
      for (String answer in answerList) {
        if (!(answer.toLowerCase().contains(_transcribedText.toLowerCase()))) {
          logger.i("Could not find a match in one of the answers");
          isCorrect = false;
        } else {
          logger.i("Found one match in one of the answers");
          isCorrect = true;
          return isCorrect;
        }
      }
    }

    return isCorrect;
  }

  void clearText() {
    stopEngine();
    setState(() {
      _transcribedText = defaultTranscribedText;
    });
  }

  void stopEngine() {
    setState(() {
      _isListening = false;
      _speech.cancel();
    });
  }

  Future _showCorrectDialog(bool showOverlay) {
    List<Widget> answerDialogList = [
      TextButton(
        onPressed: () async {
          _incrementCounter();
          for (String skill in widget.skills) {
            addMasteredTopic(skill);
          }
          Navigator.pop(context); // dialog
          Navigator.pop(context); // page
        }, 
        child: Text('Go back Home',
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
    void hideOverlay() {
      entry?.remove();
      entry = null;
      // we can assert the answer is true if we got this far
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
    
    bool valid;
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
                  widget.titleText,
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Your phrase",
                        style: TextStyle(
                          fontSize: 14,
                          color: currentProfile.textColor
                        ),
                      ),
                      Text(
                        _transcribedText,
                        style: TextStyle(
                          fontSize: 18,
                          color: currentProfile.textColor
                        ),
                      ),
                      const SizedBox(height: 20),
                      FloatingActionButton(
                        onPressed: _listen,
                        backgroundColor: currentProfile.buttonColor,
                        child: Icon(_isListening ? Icons.mic : Icons.mic_none),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: _isListening || _speech.isListening ? stopEngine : () => {
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
                    ),
                    TextButton(
                      onPressed: () => {
                        clearText()
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
          )
        ],
      ),
    );
  }
}