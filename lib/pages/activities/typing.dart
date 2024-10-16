

import 'package:flutter/material.dart';
import 'package:onwards/pages/constants.dart';

class TypeActivityScreen extends StatelessWidget {
  const TypeActivityScreen({
    super.key,
    required this.colorProfile
  });

  final ColorProfile colorProfile;

  @override
  Widget build(BuildContext context) {
    const GameData data = GameData(
      arithmiticForm: '4 + 30 = 34', 
      acceptedAnswers: [
        "four plus thirty equals thirty four", "four plus thirty equals thirty-four", "four plus thirty is thirty four",
      ]
    );

    final dataList = <GameData> [
      const GameData(
        arithmiticForm: '4 + 30 = 34', 
        acceptedAnswers: [
          "thirty-four", "thirty four",
        ],
      ),
      const GameData(
        arithmiticForm: '50 + 30 = 80', 
        acceptedAnswers: [
          "eighty",
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Type it Out Game'),
        backgroundColor: colorProfile.headerColor,
      ),
      body: GameForm(
        answers: data.acceptedAnswers, 
        questionLabel: data.arithmiticForm, 
        data: dataList,
        colorProfile: colorProfile,
      )
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
    required this.data,
    required this.colorProfile
  });

  final String questionLabel;
  final List<String> answers;
  final List<GameData> data;
  final ColorProfile colorProfile;
  final count = 0;


@override
  State<GameForm> createState() => _GameFormState();
}

class _GameFormState extends State<GameForm> {

  final _answerFieldController = TextEditingController();
  
  /// Checks the answer in the field against the accepted answers. The answer in the
  /// field is turned to lowercase before validation
  bool validateAnswer() {
    var isCorrect = true;
    if (widget.count > 0) {
      for (String potAnswer in widget.data[widget.count].acceptedAnswers) {
        if (potAnswer != _answerFieldController.text.toLowerCase()) {
          isCorrect = false;
          // print("Answer was incorrect at: ${potAnswer}");
        } else {
          isCorrect = true;
          break;

        }
      }
    } else {
      for (String potAnswer in widget.answers) {
        if (potAnswer != _answerFieldController.text) {
          isCorrect = false;
          // print("Answer was incorrect at: $potAnswer");
        } else {
          isCorrect = true;
          // print("answer was correct at: $potAnswer");
          break;
        }
      }
    }
    return isCorrect;
  }

  Future _showCorrectDialog() {
    List<Widget> answerDialogList = [
      TextButton(
        onPressed: () => {
          Navigator.pop(context),
          Navigator.popAndPushNamed(context, "/typing")
        }, 
        child: const Text('Try Again')
      ),
      TextButton(
        onPressed: () => {
          Navigator.pop(context),
          Navigator.pop(context),
          // Navigator.popAndPushNamed(context, "/")
        }, 
        child: const Text('Go back Home')
      ),
    ];

    if (validateAnswer()) {
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
                color: widget.colorProfile.contrastTextColor
              ),
            ),
            title: Text(
              'Try again...',
              style: TextStyle(
                color: widget.colorProfile.contrastTextColor
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
    
    return Container(
      decoration: widget.colorProfile.backBoxDecoration,
      child: Align(
        alignment: Alignment.center,
        child: Column(
          children: [
            Text(
              "Type the written form of the question:",
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
                  controller: _answerFieldController,
                  decoration: InputDecoration(
                    hintText: 'Type your answer...',
                    filled: true,
                    fillColor: widget.colorProfile.backgroundColor,
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0)))
                  ),
                ),
              )
            ),
            TextButton(
              onPressed: _showCorrectDialog, 
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
    );
  }}

/// Creates the data that will be used in the typing game. In production, this will be fetched from a database.
class GameData {
  const GameData({
    required this.arithmiticForm,
    required this.acceptedAnswers
  });

  final String arithmiticForm;
  final List<String> acceptedAnswers;
}