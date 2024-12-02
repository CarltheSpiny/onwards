

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:onwards/pages/activities/game_series.dart';
import 'package:onwards/pages/activities/jumble.dart';
import 'package:onwards/pages/constants.dart';
import 'package:onwards/pages/activities/playback/player_widget.dart';
import 'package:onwards/pages/game_data.dart';
import 'package:onwards/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlaybackActivityScreen extends StatelessWidget {
  const PlaybackActivityScreen(
    {super.key,
    this.colorProfile = lightFlavor
  });

  final ColorProfile colorProfile;

  @override
  Widget build(BuildContext context) {
    PlaybackGameData playbackData = bank.getRandomPlaybackElement();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Playback and Answer Game'),
        backgroundColor: colorProfile.headerColor,
      ),
      body: Container(
        decoration: colorProfile.backBoxDecoration,
        child: 
          PlaybackGameForm(
            audioSource: AssetSource(playbackData.webAudioLink),
            answers: playbackData.multiAcceptedAnswers, 
            questionLabel: "Debug: ${playbackData.audioTranscript}", 
            maxSelectedAnswers: playbackData.getMinSelection(), 
            buttonOptions: playbackData.optionList,
            titleQuestion: playbackData.writtenPrompt,
            showArithmitic: true,
            colorProfile: colorProfile,
          ),
      )
    );
  }
}

class SoundPlayerWidget extends StatefulWidget {
  final Source audioSource;
  final ColorProfile colorProfile;

  const SoundPlayerWidget({
    super.key, 
    required this.audioSource,
    required this.colorProfile
  });
  
  @override
  SoundPlayerWidgetState createState() => SoundPlayerWidgetState();
}

class SoundPlayerWidgetState extends State<SoundPlayerWidget> {
  late AudioPlayer _audioPlayer;
  late Source audioSource;

  @override
  void initState() {
    super.initState();
    logger.i("Initialized the audio service");
    _audioPlayer = AudioPlayer();
    audioSource = widget.audioSource;
  }

  Future<void> playSound() async {
    await _audioPlayer.play(audioSource);
  }

  @override
  void dispose() {
    logger.i("Disposed the audio service object");
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _audioPlayer.setSource(audioSource);
    return PlayerWidget(
      player: _audioPlayer,
      colorProfile: widget.colorProfile,);
  }
}

// Show this game's unique game form using the data
// passed from GameData. The idea is to have the game
// move to the next question after the dialog, using context
// to pass the info over
class PlaybackGameForm extends StatefulWidget {
  const PlaybackGameForm({
    super.key,
    required this.answers, 
    required this.questionLabel,
    required this.maxSelectedAnswers,
    required this.buttonOptions,
    required this.titleQuestion,
    required this.showArithmitic,
    required this.colorProfile,
    required this.audioSource
  });

  final AssetSource audioSource;
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

  @override
  PlaybackGameFormState createState() => PlaybackGameFormState();
}

class PlaybackGameFormState extends State<PlaybackGameForm> {

  final List<String> _selectedAnswers = [];
  int maxSelection = 0;
  int currentCount = 0;
  final Future<SharedPreferencesWithCache> _prefs =
    SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: <String>{'correct'}
      ));
  late Future<int> _counter;
  OverlayEntry? entry;

  @override
  void initState() {
    maxSelection = widget.maxSelectedAnswers;
    super.initState();
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

  Future _showCorrectDialog(int errorIndex) {
    List<Widget> answerDialogList = [
      TextButton(
        onPressed: () => {
          _incrementCounter(),
          Navigator.pop(context), // dialog
          Navigator.pop(context), // page
        }, 
        child: Text('Continue', 
          style: TextStyle(
            color: widget.colorProfile.textColor,
          ),
        ),
      ),
    ];

    if (errorIndex == -1) {
      // Show dialog with correct answer
      return showDialog(
        context: context, 
        builder: (context) {
          return AlertDialog(
            actions: answerDialogList,
            title: Text('Way to go!',
              style: TextStyle(
                color: widget.colorProfile.textColor
              ),
            ),
            backgroundColor: widget.colorProfile.buttonColor,
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
                color: widget.colorProfile.textColor
              ),
            ),
            title: Text(
              'Incomplete Answer',
              style: TextStyle(
                color: widget.colorProfile.textColor
              ),
            ),
            backgroundColor: widget.colorProfile.buttonColor,
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
                color: widget.colorProfile.textColor
              ),
            ),
            title: Text(
              'Try again',
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
            color: widget.colorProfile.textColor
          ),
        )
      ));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    // List<String> selectedAnswers = [];
    // This is the data of multiple games
    List<Widget> dynamicButtonList = <Widget> [];
    int valid = 0;

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
          colorProfile: widget.colorProfile,
        ),
      );
      
      dynamicButtonList.add(button);
    }
    
    void hideOverlay() {
      entry?.remove();
      entry = null;
      _showCorrectDialog(valid);
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
  }
    // Render the form here
    return 
      Align(
        alignment: Alignment.center,
        child: Column(
          children: [
            Text(
              widget.titleQuestion,
              style: TextStyle(
                  color: widget.colorProfile.textColor, 
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
                  color: widget.colorProfile.textColor, 
                  fontSize: 30,
                  
                ),
              ) : null,
            ),
            SoundPlayerWidget(
              audioSource: widget.audioSource, 
              colorProfile: widget.colorProfile
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
                    valid = validateAnswer(),
                    if (valid < 0) {
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
                      style: TextStyle(
                        color: widget.colorProfile.contrastTextColor
                      ),
                  ),
                  
                ),
                TextButton(
                  onPressed: () => {
                    clearAnswers()
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(widget.colorProfile.clearAnswerButtonColor),
                  ),
                  child: Text(
                    'Clear all answers',
                    style: TextStyle(
                      color: widget.colorProfile.contrastTextColor),
                    )
                  )
              ],
            )
          ],
        ),
      );
  }
}