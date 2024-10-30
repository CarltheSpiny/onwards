
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:onwards/pages/activities/fill_in_the_blank.dart';
import 'package:onwards/pages/activities/jumble.dart';
import 'package:onwards/pages/activities/playback/playback.dart';
import 'package:onwards/pages/activities/reading/reading.dart';
import 'package:onwards/pages/activities/typing.dart';
import 'package:onwards/pages/constants.dart';
import 'package:onwards/pages/game_data.dart';

GameDataBank bank = GameDataBank();

class GameTestPage extends StatelessWidget {
  const GameTestPage({
    super.key,
    required this.colorProfile
  });

  final ColorProfile colorProfile;

  @override
  Widget build(BuildContext context) {
    bank.initBank();
    return Align(
      alignment: Alignment.center,
      child: HomePage(
        maxQuestCount: 10,
        colorProfile: colorProfile,
      ),
    );
  }
}

class HomePage extends StatefulWidget {

  final int maxQuestCount;
  final ColorProfile colorProfile;

  const HomePage({
    super.key, 
    required this.maxQuestCount,
    required this.colorProfile
  });
  
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<Widget> pages = [];

  List<int> selectedPageOrder = [];

  void selectRandPages() {
    final random = Random();
    int randStartIndex = random.nextInt(pages.length);
    selectedPageOrder.clear();

    for (int i =0; i < widget.maxQuestCount; i++) {
      int next = (randStartIndex + i) % pages.length;
      selectedPageOrder.add(next);
    }
    print('Color profile for this series: ${widget.colorProfile.idKey}');
    print('Order for this session: $selectedPageOrder');
  }

  void navigateToNext(int currentIndex) {
    print("Profile for the next page is: ${widget.colorProfile.idKey}");
    if (currentIndex < selectedPageOrder.length) {
      Navigator.push(
        context, 
        MaterialPageRoute(
          builder: (context) => pages[selectedPageOrder[currentIndex]],
        ),
      ).then((_) {
        navigateToNext(currentIndex + 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("This GameTest has a profile of: ${widget.colorProfile.idKey}");
    pages.addAll(List.of([
      FillInActivityScreen(colorProfile: widget.colorProfile),
      JumbleActivityScreen(colorProfile: widget.colorProfile),
      PlaybackActivityScreen(colorProfile: widget.colorProfile),
      ReadingActivityScreen(colorProfile: widget.colorProfile),
      TypeActivityScreen(colorProfile: widget.colorProfile,)
    ]));
    return Align(
        alignment: Alignment.center,
        child: ElevatedButton(
          onPressed: () {
            selectRandPages();
            navigateToNext(0);
          }, 
          child: const Text("Start Series")),
      );
  }
}