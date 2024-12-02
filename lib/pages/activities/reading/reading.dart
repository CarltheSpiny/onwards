

import 'package:flutter/material.dart';
import 'package:onwards/pages/activities/game_series.dart';
import 'package:onwards/pages/constants.dart';
import 'package:onwards/pages/activities/reading/voice_recorder.dart';
import 'package:onwards/pages/game_data.dart';

class ReadingActivityScreen extends StatelessWidget {
  const ReadingActivityScreen({
    super.key,
    this.colorProfile = lightFlavor
  });

  final ColorProfile colorProfile;

  @override
  Widget build(BuildContext context) {
    ReadAloudGameData readingData = bank.getRandomReadingElement();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Read Aloud Game'),
        backgroundColor: colorProfile.headerColor,
      ),
      body: Container(
        decoration: colorProfile.backBoxDecoration,
        child: Column(
          children: [
              AudioTranscriptionWidget(
              key: const Key('1'),
              acceptedAnswers: readingData.multiAcceptedAnswers,
              questionLabel: readingData.displayedProblem,
              titleText: readingData.writtenPrompt,
              useNumWordProtocol: readingData.useNumWordProtocol,
              colorProfile: colorProfile,
            )
          ]
        ),
      )
    );
  }
}