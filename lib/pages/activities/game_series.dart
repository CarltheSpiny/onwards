
// ignore_for_file: unused_field

import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:onwards/pages/activities/fill_in_the_blank.dart';
import 'package:onwards/pages/activities/jumble.dart';
import 'package:onwards/pages/activities/playback/playback.dart';
import 'package:onwards/pages/activities/reading/reading.dart';
import 'package:onwards/pages/activities/typing.dart';
import 'package:onwards/pages/constants.dart';
import 'package:onwards/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameTestPage extends StatelessWidget {
  const GameTestPage({
    super.key,
    required this.colorProfile
  });

  final ColorProfile colorProfile;

  @override
  Widget build(BuildContext context) {
    logger.i("The number of questions for the games are as follows: Playback: ${bank.playbackBank.length}, Reading: ${bank.readingBank.length}, Fill-in-the-Blank: ${bank.fillBlanksBank.length}, Jumble: ${bank.jumbleBank.length}, Typing: ${bank.typingBank.length}");
    return Align(
      alignment: Alignment.center,
      child: SeriesHomePage(
        maxQuestCount: 5,
        colorProfile: colorProfile,
      ),
    );
  }
}

class SeriesHomePage extends StatefulWidget {

  final int maxQuestCount;
  final ColorProfile colorProfile;

  const SeriesHomePage({
    super.key, 
    required this.maxQuestCount,
    required this.colorProfile
  });
  
  @override
  SeriesHomePageState createState() => SeriesHomePageState();
}

class SeriesHomePageState extends State<SeriesHomePage> {
  final Future<SharedPreferencesWithCache> _prefs =
    SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: <String>{'correct'}
      ));
  late Future<int> _correctCounter;
  List<Widget> pages = [];
  List<int> selectedPageOrder = [];

  Future<void> _resetCorrectCount() async {
    final SharedPreferencesWithCache prefs = await _prefs;
    if ((prefs.getInt('correct') ?? 0) <= 0) {
      return;
    }

    const int correctCounter = 0;
    setState(() {
      _correctCounter = prefs.setInt('correct', correctCounter).then((_) {
        logger.i("reset counter for this session");
        return correctCounter;
      });
    });
  }
  
  @override
  void initState() {
    _correctCounter = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getInt('correct') ?? 0;
    });
    super.initState();
  }

  void selectRandPages() {
    final random = Random();
    int randStartIndex = random.nextInt(pages.length);
    selectedPageOrder.clear();

    for (int i =0; i < widget.maxQuestCount; i++) {
      int next = (randStartIndex + i) % pages.length;
      selectedPageOrder.add(next);
    }
    logger.d('Color profile for this series: ${widget.colorProfile.idKey}');
    logger.d('Order for this session: $selectedPageOrder');
  }

  void navigateToNext(int currentIndex) {
    logger.d("Profile for the next page is: ${widget.colorProfile.idKey}");
    if (currentIndex < selectedPageOrder.length) {
      Navigator.push(
        context, 
        MaterialPageRoute(
          builder: (context) => pages[selectedPageOrder[currentIndex]],
        ),
      ).then((_) {
        // recurssively navigate to next until we can't
        navigateToNext(currentIndex + 1);
      });
    } else {
      logger.d("Reached the end of the navigation, showing end results");
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => SeriesEndPage(
            colorProfile: widget.colorProfile, 
            seriesCount: selectedPageOrder.length,
          ))
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.d("This GameTest has a profile of: ${widget.colorProfile.idKey}");
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
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(
              widget.colorProfile.buttonColor
            )
          ),
          onPressed: () {
            selectRandPages();
            _resetCorrectCount();
            try {
              navigateToNext(0);

            } catch (exception)  {
              logger.e("an error has occured");
            }
          }, 
          child: Text(
            "Start Series",
            style: TextStyle(
              color: widget.colorProfile.textColor
            ),
          )
        ),
      );
  }
}

class SeriesEndPage extends StatefulWidget {
  const SeriesEndPage({
    super.key, 
    required this.colorProfile,
    this.seriesCount = 5
  });

  final ColorProfile colorProfile;
  final int seriesCount;

  @override
  State<StatefulWidget> createState() => SeriesEndPageState();

}

class SeriesEndPageState extends State<SeriesEndPage> {
  final Future<SharedPreferencesWithCache> _prefs =
    SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: <String>{'correct', 'missed', 'mastered_topics', 'weak_topics'}
      ));
  late Future<int> correctCounter;
  late Future<int> missedCounter;
  late Future<List<String>> masteredTopicList;
  late Future<List<String>> weakTopicList;

  // handle the end of the series game
  @override
  void initState() {
    correctCounter = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getInt('correct') ?? 0;
    });
    missedCounter = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getInt('missed') ?? 0;
    });

    masteredTopicList = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getStringList('mastered_topics') ?? <String>[];
    });
    weakTopicList = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getStringList('weak_topics') ?? <String>[];
    });
    super.initState();
  }

  List<Widget> skillLabels = [];
  List<Widget> getSkillLabels(List<String>? skills, String heading) {
    if (skills != null) {
      logger.i("Skills: $skills");
      // <----------- Remove duplicate skills ---------------->
      Set<String> seen = {};
      List<String> uniqueSkills = [];

      for (String skill in skills) {
        if (!seen.contains(skill)) {
          seen.add(skill);
          uniqueSkills.add(skill);
        }
      }
      
      List<String> vals = List.of(skillMap.values);
      for (String skill in uniqueSkills) {
        int index = 0;
        int counter = 0;

        // for each mapped skill in the keys
        for (String mappedSkill in skillMap.keys) {
          if (mappedSkill == skill) {
            index = counter;
          } else {
            counter += 1;
          }
        }
        // add the true skill name into the list
        skillLabels.add(
          Text(
            vals[index],
            style: TextStyle(
              color: widget.colorProfile.textColor
            ),
          )
        );
      }
    }
    skillLabels.insert(0, 
      Text(
        heading, 
        style: TextStyle(
          color: widget.colorProfile.textColor,
          fontSize: 18
        ),
      )
    );
    return skillLabels;
  }

  @override
  Widget build(BuildContext context) {
    const double sizeFactor = 10;

    

    return Scaffold(
      appBar: AppBar(
        title: const Text("Results"),
        backgroundColor: widget.colorProfile.headerColor,
        centerTitle: true,
      ),
      body: Container(
        decoration: widget.colorProfile.backBoxDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Results from the question series",
              style: TextStyle(
                color: widget.colorProfile.textColor,
                  fontSize: 20 + sizeFactor,
              ),
            ),
            FutureBuilder<int>(
              future: correctCounter, 
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return const CircularProgressIndicator();
                  case ConnectionState.active:
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}', style: TextStyle(color: widget.colorProfile.textColor));
                    } else {
                      return Column(
                        children: [
                          Text(
                            'Number of Questions: ${widget.seriesCount}, Total Correct: ${snapshot.data}',
                            style: TextStyle(
                              color: widget.colorProfile.textColor,
                              fontSize: 15 + sizeFactor,
                            ),
                          ),
                          FutureBuilder<List<String>>(
                            future: weakTopicList, 
                            builder: (BuildContext context, AsyncSnapshot<List<String>> weaktopicSnapshot) {
                              switch (weaktopicSnapshot.connectionState) {
                                case ConnectionState.none:
                                case ConnectionState.waiting:
                                  return const CircularProgressIndicator();
                                case ConnectionState.active:
                                case ConnectionState.done:
                                  if (weaktopicSnapshot.hasError) {
                                    return Text('Error: ${weaktopicSnapshot.error}', style: TextStyle(color: widget.colorProfile.textColor));
                                  } else {
                                    return Column(
                                      children: getSkillLabels(weaktopicSnapshot.data, "Skills that need practice"),
                                    );
                                  }
                              }
                            }
                          ),
                          FutureBuilder<List<String>>(
                            future: masteredTopicList, 
                            builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.none:
                                case ConnectionState.waiting:
                                  return const CircularProgressIndicator();
                                case ConnectionState.active:
                                case ConnectionState.done:
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}', style: TextStyle(color: widget.colorProfile.textColor));
                                  } else {
                                    return Column(
                                      children: getSkillLabels(snapshot.data, "Mastered Skills"),
                                    );
                                  }
                              }
                            }
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(widget.colorProfile.buttonColor)
                                  ),
                                  onPressed: () => {
                                    Navigator.of(context).pop(),
                                    Navigator.of(context).pop(),
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => const HomePage()
                                      )
                                    )
                                  }, 
                                  child: Text(
                                    "Go back to Home",
                                    style: TextStyle(
                                      color: widget.colorProfile.textColor
                                    ),
                                  )
                                )
                              ],
                            ),
                          )
                        ],
                      );
                    }
                }
              }
            ),
          ],
        ),
      ),
    );
  }
}