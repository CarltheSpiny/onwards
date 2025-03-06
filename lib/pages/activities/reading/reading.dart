

import 'package:flutter/material.dart';
import 'package:onwards/pages/components/calculator.dart';
import 'package:onwards/pages/components/progress_bar.dart';
import 'package:onwards/pages/constants.dart';
import 'package:onwards/pages/activities/reading/voice_recorder.dart';
import 'package:onwards/pages/game_data.dart';
import 'package:onwards/pages/home.dart';
import 'package:onwards/pages/score_display.dart';

class ReadingActivityScreen extends StatelessWidget {
  const ReadingActivityScreen({
    super.key,
    this.colorProfile = lightFlavor,
  });

  final ColorProfile colorProfile;

  @override
  Widget build(BuildContext context) {
    ReadAloudGameData readingData = bank.getRandomReadingElement();

    return Scaffold(
      appBar: AppBar(
        title: Text('Read Aloud Game', style: TextStyle(color: colorProfile.textColor)),
        backgroundColor: colorProfile.headerColor,
        actions: const [ProgressBar(), ScoreDisplayAction(), CalcButton()]
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: AudioTranscriptionWidget(
          key: const Key('1'),
          acceptedAnswers: readingData.multiAcceptedAnswers,
          questionLabel: readingData.displayedProblem,
          titleText: readingData.writtenPrompt,
          useNumWordProtocol: readingData.useNumWordProtocol,
          colorProfile: colorProfile,
          skills: readingData.skills,
        ),
      )
    );
  }
}