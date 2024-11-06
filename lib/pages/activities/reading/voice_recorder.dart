import 'package:flutter/material.dart';
import 'package:onwards/pages/activities/reading/reading.dart';
import 'package:onwards/pages/activities/reading/speech_to_text_helper.dart';
import 'package:onwards/pages/constants.dart';
import 'package:onwards/pages/home.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AudioTranscriptionWidget extends StatefulWidget {
  const AudioTranscriptionWidget({
    super.key,
    required this.acceptedAnswers,
    required this.questionLabel,
    required this.titleText,
    required this.colorProfile,
    this.useNumWordProtocol = true
  });

  final ColorProfile colorProfile;
  final String questionLabel;
  final List<List<String>> acceptedAnswers;
  final String titleText;
  final bool useNumWordProtocol;

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
    // we get here from the microphone button

    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => logger.i('onStatus: $val'),
        onError: (val) => logger.e('onError: $val'),
      );
      if (available && mounted) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) => setState(() {
          _transcribedText = val.recognizedWords;
          if (widget.useNumWordProtocol) {
            _transcribedText = convertNumbersAndSymbolsToWords(_transcribedText);
          }
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
          setState(() => _isListening = false),
          _speech.stop(),
          Navigator.pop(context), // dialog
          Navigator.pop(context), // page
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => ReadingActivityScreen(colorProfile: widget.colorProfile,)
            )
          )
        }, 
        child: const Text('Try Again')
      ),
      TextButton(
        onPressed: () => {
          setState(() => _isListening = false),
          _speech.stop(),
          Navigator.pop(context),
          Navigator.pop(context)
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
            title:  Text('Way to go!',
              style: TextStyle(
                color: widget.colorProfile.textColor
              ),),
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