import 'package:flutter/material.dart';
import 'package:onwards/pages/constants.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AudioTranscriptionWidget extends StatefulWidget {
  const AudioTranscriptionWidget({
    super.key,
    required this.acceptedAnswers,
    required this.questionLabel,
    required this.titleText,
    required this.colorProfile
  });

  final ColorProfile colorProfile;
  final String questionLabel;
  final List<String> acceptedAnswers;
  final String titleText;

  @override
  AudioTranscriptionWidgetState createState() => AudioTranscriptionWidgetState();
}

class AudioTranscriptionWidgetState extends State<AudioTranscriptionWidget> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String defaultTranscribedText = "Press the button to start speaking and your words will appear here!";
  String _transcribedText = "Press the button to start speaking and your words will appear here!";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) => setState(() {
          _transcribedText = val.recognizedWords;
        }));
      } else {
        setState(() => _isListening = false);
        _speech.stop();
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  bool _validate() {
    bool isCorrect = true;

    for (String answer in widget.acceptedAnswers) {
      if (!(answer.toLowerCase().contains(_transcribedText.toLowerCase()))) {
        isCorrect = false;
      } else {
        isCorrect = true;
        break;
      }
    }

    return isCorrect;
  }

  void clearText() {
    setState(() {
      _isListening = false;
      _speech.cancel();
      _transcribedText = defaultTranscribedText;
    });
  }

  Future _showCorrectDialog() {
    List<Widget> answerDialogList = [
      TextButton(
        onPressed: () => {
          Navigator.pop(context),
          Navigator.popAndPushNamed(context, "/jumble")
        }, 
        child: const Text('Try Again')
      ),
      TextButton(
        onPressed: () => {
          Navigator.pop(context),
          Navigator.popAndPushNamed(context, "/")
        }, 
        child: const Text('Go back Home')
      ),
    ];

    if (_validate()) {
      return showDialog(
        context: context, 
        builder: (context) {
          return AlertDialog(
            actions: answerDialogList,
            title: const Text('Way to go!'),
            backgroundColor: widget.colorProfile.backgroundColor,
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
            backgroundColor: widget.colorProfile.backgroundColor,
          );
        }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(
            widget.titleText,
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
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Your phrase",
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.colorProfile.textColor
                  ),
                ),
                Text(
                  _transcribedText,
                  style: TextStyle(
                    fontSize: 18,
                    color: widget.colorProfile.textColor
                  ),
                ),
                const SizedBox(height: 20),
                FloatingActionButton(
                  onPressed: _listen,
                  backgroundColor: widget.colorProfile.buttonColor,
                  child: Icon(_isListening ? Icons.mic : Icons.mic_none),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: _showCorrectDialog,
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(widget.colorProfile.checkAnswerButtonColor),
                ),
                child: Text(
                  'Check Answer',
                  style: TextStyle(color: widget.colorProfile.contrastTextColor),
                )
              ),
              TextButton(
                onPressed: () => {
                  clearText()
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(widget.colorProfile.clearAnswerButtonColor),
                ),
                child: Text(
                  'Clear all answers',
                  style: TextStyle(color: widget.colorProfile.contrastTextColor),
                )
              )
            ],
          )
        ],
      ),
    );
  }
}

/// Fill in the blank needs the question to show with blanks, 
/// the arithmitic form, and the answer blocks
class GameData {
  const GameData({
    required this.arithmiticForm,
    required this.acceptedAnswers,
  });

  /// The form of the written expression with math symbols
  final String arithmiticForm;
  /// The list of lists that have answer combos tha are accepted.
  /// The lists inside are matched exactly against the user's selection
  final List<String> acceptedAnswers;
}