

import 'package:flutter/material.dart';
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
    GameData data = GameData(
      arithmiticForm: '4 + 30 = 34', 
      acceptedAnswers: [
        "four plus thrity equals thirty four",
        "four plus thirty is thirty four",
        "4 + 30 = 34",
        "4 + 30 is 34"
      ],
      multiAcceptedAnswers: [],
      optionList: []
    );

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
              acceptedAnswers: data.acceptedAnswers,
              questionLabel: data.arithmiticForm,
              titleText: "Read the expression below",
              colorProfile: colorProfile,
            )
          ]
        ),
      )
    );
  }
}