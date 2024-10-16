

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:onwards/pages/activities/jumble.dart';
import 'package:onwards/pages/constants.dart';
import 'package:onwards/pages/activities/playback/player_widget.dart';

class PlaybackActivityScreen extends StatelessWidget {
  const PlaybackActivityScreen(
    {super.key,
    required this.colorProfile
  });

  final ColorProfile colorProfile;

  @override
  Widget build(BuildContext context) {
    const GameData data = GameData(
      arithmiticForm: '4 + 30 = 34', 
      acceptedAnswers: [
        [
          "four", "plus", "thirty", "equals", "thirty-four"
        ]
      ], 
      maxAnswerCount: 5, 
      optionList: [
        "four", "plus", "thirty", "equals", "thirty-four"
      ]
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Playback and Answer Game'),
        backgroundColor: colorProfile.headerColor,
      ),
      body: Container(
        decoration: colorProfile.backBoxDecoration,
        child: Column(
          children: [
            SoundPlayerWidget(
              audioSource: AssetSource('/audio/level_up_3h.mp3'),
              colorProfile: colorProfile,
            ),
            GameForm(
              answers: data.acceptedAnswers, 
              questionLabel: "", 
              data: const <GameData> [], 
              maxSelectedAnswers: data.maxAnswerCount, 
              buttonOptions: data.optionList,
              titleQuestion: "Listen to the audio, then use the blocks below to form the written form of the expression:",
              showArithmitic: false,
              colorProfile: colorProfile,
            ),
          ],
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
    _audioPlayer = AudioPlayer();
    audioSource = widget.audioSource;
  }

  Future<void> playSound() async {
    await _audioPlayer.play(audioSource);
  }

  @override
  void dispose() {
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