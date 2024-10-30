import 'package:flutter/material.dart';
import 'package:onwards/pages/constants.dart';
import 'package:onwards/pages/game_data.dart';

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

    GameData data = GameData(
      arithmiticForm: '4 + 30 = 34', 
      acceptedAnswers: [
        "plus", "equals",
      ],
      multiAcceptedAnswers: [],
      blankForm: 'Forty ____ thirty ____ thirty-four',
      maxAnswerCount: 2,
      optionList: ["plus", "minus", "times", "equals"]
    );

    var dataList = <GameData> [
      data
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fill in the Blank Game'),
        backgroundColor: colorProfile.headerColor,
      ),
      body: GameForm(
        answers: data.acceptedAnswers, 
        questionLabel: data.arithmiticForm, 
        data: dataList, 
        blankQuestLabel: data.blankForm,
        maxSelectedAnswers: data.maxAnswerCount,
        buttonOptions: data.optionList,
        colorProfile: colorProfile,
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
    required this.data,
    required this.blankQuestLabel,
    required this.maxSelectedAnswers,
    required this.buttonOptions,
    required this.colorProfile
  });

  final ColorProfile colorProfile;
  final String questionLabel;
  final List<String> answers;
  final List<GameData> data;
  final String blankQuestLabel;
  final int maxSelectedAnswers;
  final List<String> buttonOptions;

  @override
  GameFormState createState() => GameFormState();
}

class GameFormState extends State<GameForm> {

  List<String> _selectedAnswers = [];
  int maxSelection = 0;
  int currentCount = 0;

  @override
  void initState() {
    maxSelection = widget.maxSelectedAnswers;
    super.initState();
  }

  bool validateAnswer() {
    bool isCorrect = true;
    if (currentCount >= widget.maxSelectedAnswers) {
      for (int i = 0; i < _selectedAnswers.length; i++) {
        if (_selectedAnswers[i] != widget.answers[i]) {
          isCorrect = false;
        }
      }
    } else {
      isCorrect = false;
    }
    return isCorrect;
  }

  Future _showCorrectDialog() {
    List<Widget> answerDialogList = [
      TextButton(
        onPressed: () => {
          Navigator.pop(context),
          Navigator.popAndPushNamed(context, "/fill-in-the-blank")
        }, 
        child: const Text('Try Again')
      ),
      TextButton(
        onPressed: () => {
          Navigator.pop(context),
          Navigator.pop(context),
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
                  color: widget.colorProfile.contrastTextColor
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
                  color: widget.colorProfile.textColor
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
                color: widget.colorProfile.textColor
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
              color: widget.colorProfile.textColor
            ),
          ),
        )
      );
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    // List<String> selectedAnswers = [];
    // This is the data of multiple games
    List<ButtonStyleButton> dynamicButtonList = <ButtonStyleButton> [];
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
          backgroundColor: widget.colorProfile.buttonColor,
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
          style: TextStyle(color: widget.colorProfile.contrastTextColor),
        ),
      );
      dynamicButtonList.add(button);
    }
    
    // Render the form here
    return Container(
      decoration: widget.colorProfile.backBoxDecoration,
      child: Align(
        alignment: Alignment.center,
        child: Column(
          children: [
            Text(
              "Use the blocks below to form the written form of the expression:",
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: dynamicButtonList,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextButton(
                    onPressed: _showCorrectDialog, 
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(widget.colorProfile.checkAnswerButtonColor),
                    ),
                    child: Text(
                      'Check Answer',
                      style: TextStyle(color: widget.colorProfile.contrastTextColor),
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
      ),
    );
    
  }
}