
import 'package:flutter/material.dart';
import 'package:onwards/pages/activities/game_test.dart';
import 'package:onwards/pages/game_data.dart';

import '../constants.dart';

class JumbleActivityScreen extends StatelessWidget {
  const JumbleActivityScreen({
    super.key,
    this.colorProfile = lightFlavor
  });

  
  final ColorProfile colorProfile;

  @override
  Widget build(BuildContext context) {
    GameData data = GameData(
      arithmiticForm: '4 + 30 = 34',
      acceptedAnswers: [],
      multiAcceptedAnswers: [
        [
          "four", "plus", "thirty", "equals", "thirty-four"
        ]
      ],
      maxAnswerCount: 5,
      optionList: [
        "four", "plus", "thirty", "equals", "thirty-four"
      ]
    );

    GameData randData = bank.getRandomElement();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Jumble Game'),
        backgroundColor: colorProfile.headerColor,
      ),
      body: Center(
        child: GameForm(
          answers: randData.multiAcceptedAnswers, 
          questionLabel: randData.arithmiticForm, 
          data: const <GameData> [], 
          maxSelectedAnswers: randData.maxAnswerCount, 
          buttonOptions: randData.optionList,
          titleQuestion: "Use the blocks below to form the written form of the expression:",
          showArithmitic: true,
          colorProfile: colorProfile,
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
    required this.data,
    required this.maxSelectedAnswers,
    required this.buttonOptions,
    required this.titleQuestion,
    required this.showArithmitic,
    required this.colorProfile
  });

  final ColorProfile colorProfile; 
  /// The label for the question, which should be the math form for this game
  final String questionLabel;
  /// The list of combos accepted as answers
  final List<List<String>> answers;
  /// Game data with multiple questions
  final List<GameData> data;
  /// The number of max soloutions in the correct answer
  final int maxSelectedAnswers;
  /// the text for the buttons that can be used to create this phrase
  final List<String> buttonOptions;
  final String titleQuestion;
  final bool showArithmitic;

  @override
  GameFormState createState() => GameFormState();
}

class GameFormState extends State<GameForm> {

  final List<String> _selectedAnswers = [];
  final List<num> _selectedIds = [];
  int maxSelection = 0;
  int currentCount = 0;

  @override
  void initState() {
    maxSelection = widget.maxSelectedAnswers;
    super.initState();
  }

  int validateAnswer() {
    int errorIndex = 0;
    bool isCorrect = true;
    if (currentCount >= maxSelection) {
      for (List<String> answerList in widget.answers) {
        for (int i = 0; i < answerList.length; i++) {
          if (_selectedAnswers[i] != answerList[i]) {
            isCorrect = false;
            errorIndex = i;
            return errorIndex;
          }
        }

        if (isCorrect) {
          return -1;
        }
      }
    } else {
      return 0;
    }
    return 0;
  }

  void clearAnswers() {
    setState(() {
      currentCount = 0;
      _selectedAnswers.clear();
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
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => JumbleActivityScreen(colorProfile: widget.colorProfile,)
            )
          )
        }, 
        child: const Text('Go back Home')
      ),
    ];

    int errorIndex = validateAnswer();
    if (errorIndex == -1) {
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
              "Incorrect Answer at ${_selectedAnswers[errorIndex]}",
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

    for (String option in widget.buttonOptions) {
      Widget button = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: GameButton(
          onPressed: () => {
            setState(() {
              if (currentCount < maxSelection) {
                _selectedAnswers.add(option);

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
    
    // Render the form here
    return Container(
      decoration: widget.colorProfile.backBoxDecoration,
      child: Align(
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
                  onPressed: _showCorrectDialog, 
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
      ),
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