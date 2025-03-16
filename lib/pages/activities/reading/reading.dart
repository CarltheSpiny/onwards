

import 'package:flutter/material.dart';
import 'package:onwards/pages/components/calculator.dart';
import 'package:onwards/pages/components/progress_bar.dart';
import 'package:onwards/pages/constants.dart';
import 'package:onwards/pages/activities/reading/voice_recorder.dart';
import 'package:onwards/pages/game_data.dart';
import 'package:onwards/pages/home.dart';
import 'package:onwards/pages/score_display.dart';

const ReadAloudGameData dummyData = ReadAloudGameData(displayedProblem: "", multiAcceptedAnswers: [], skills: []);

class ReadingActivityScreen extends StatelessWidget {
  const ReadingActivityScreen({
    super.key,
    this.colorProfile = lightFlavor,
    this.readingGameData = dummyData,
    this.fromLevelSelect = false
  });

  final ColorProfile colorProfile;
  final ReadAloudGameData readingGameData;
  final bool fromLevelSelect;

  const ReadingActivityScreen.fromLevelSelect({required ReadAloudGameData readingData, required ColorProfile profile, super.key}) :
    colorProfile = profile,
    readingGameData = readingData,
    fromLevelSelect = true;

  @override
  Widget build(BuildContext context) {
    ReadAloudGameData randomData = gameDataBank.getRandomReadingElement();

    return Scaffold(
      appBar: AppBar(
        title: Text('Read Aloud Game', style: TextStyle(color: colorProfile.textColor)),
        backgroundColor: colorProfile.headerColor,
        actions: const [ScoreDisplayAction(), CalcButton()]
      ),
      body: Container(
        decoration: colorProfile.backBoxDecoration,
        padding: const EdgeInsets.only(top: 40),
        child: !fromLevelSelect ?
          AudioTranscriptionWidget(
            key: const Key('1'),
            acceptedAnswers: randomData.multiAcceptedAnswers,
            questionLabel: randomData.displayedProblem,
            titleText: randomData.writtenPrompt,
            useNumWordProtocol: randomData.useNumWordProtocol,
            colorProfile: colorProfile,
            skills: randomData.skills,
          ) :
          AudioTranscriptionWidget(
            key: const Key('1'),
            acceptedAnswers: readingGameData.multiAcceptedAnswers,
            questionLabel: readingGameData.displayedProblem,
            titleText: readingGameData.writtenPrompt,
            useNumWordProtocol: readingGameData.useNumWordProtocol,
            colorProfile: colorProfile,
            skills: readingGameData.skills,
          )
      )
    );
  }
}