import 'dart:math';

import 'package:flutter/material.dart';
import 'package:onwards/pages/activities/game_test.dart';
import 'package:onwards/pages/activities/jumble.dart';
import 'package:onwards/pages/activities/reading/reading.dart';
import 'package:onwards/pages/activities/typing.dart';
import 'package:onwards/pages/activities/fill_in_the_blank.dart';
import 'package:onwards/pages/activities/playback/playback.dart';
import 'package:onwards/pages/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

const ImageProvider placeholderImage = AssetImage('assets/images/placeholder.png');
const desktopPadding = 81.0;
const homeWidth = 1400.0;
const desktopMargin = 8.0;

// Image is currently 4:3 ratio
const itemWidth = 396.0; // controls the width of the card (should match image)
const minHeight = 340.0; // controls the height of the card (should match image)

class HomeApp extends StatelessWidget {
  const HomeApp({
    super.key,
  });

  final ColorProfile colorProfile = lightFlavor;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Onwards',
      home: const HomePage(),
      
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage ({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final Future<SharedPreferencesWithCache> _prefs =
    SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: <String>{'counter'}
      ));
  late Future<int> _counter;
  int _externalCounter = 0;

  final maxThemes = 6;

  ColorProfile currentProfile = lightFlavor;

  Future<void> _loadTheme() async {
    final SharedPreferencesWithCache prefs = await _prefs;
    int? themeIndex = (prefs.getInt('counter') ?? 0);

    setState(() {
      currentProfile = _getProfileByIndex(themeIndex);
    });
  }

  ColorProfile _getProfileByIndex(int index) {
    switch(index) {
        case 0:
          return lightFlavor;
        case 1:
          return darkFlavor;
        case 2:
          return plainFlavor;
        case 3:
          return mintFlavor;
        case 4:
          return strawberryFlavor;
        case 5:
          return bananaFlavor;
        case 6:
          return peanutFlavor;
        default:
          return lightFlavor;
      }
  }

  Future<void> _incrementCounter() async {
    final SharedPreferencesWithCache prefs = await _prefs;
    if ((prefs.getInt('counter') ?? 0) >= maxThemes) {
      return;
    }
    final int counter = (prefs.getInt('counter') ?? 0) + 1;
    setState(() {
      _counter = prefs.setInt('counter', counter).then((_) {
        currentProfile = _getProfileByIndex(counter);
        return counter;
      });
    });
  }

  Future<void> _decrementCounter() async {
    final SharedPreferencesWithCache prefs = await _prefs;
    if ((prefs.getInt('counter') ?? 0) <= 0) {
      return;
    }

    final int counter = (prefs.getInt('counter') ?? 0) - 1;
    setState(() {
      _counter = prefs.setInt('counter', counter).then((_) {
        currentProfile = _getProfileByIndex(counter);
        return counter;
      });
    });
  }

  Future<void> _getExternalCounter() async {
    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
    int? holder = (await prefs.getInt('externalCounter')) ?? 0;
    setState(() {
      _externalCounter = holder;
    });
  }

  @override
  void initState() {
    super.initState();
    _counter = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getInt('counter') ?? 0;
    });
    _getExternalCounter();
    _loadTheme();
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> gameCards = <Widget> [
      GameCard(
        imageAsset: const AssetImage(
          'assets/images/audio-playback-preview.png'
        ),
        gameRoute: "/audio-playback", 
        gameWidget: PlaybackActivityScreen(colorProfile: currentProfile),
        keyId: 0,
        title: "Playback and Choose",
        subtitle: "Difficulty: Hard",
        styleMode: darkStyle,
      ),
      GameCard(
        imageAsset: const AssetImage(
          'assets/images/fill-in-the-blank-preview.png'
        ),
        gameRoute: '/fill-in-the-blank',
        gameWidget: FillInActivityScreen(colorProfile: currentProfile,), 
        keyId: 1,
        title: "Fill in the Blank",
        subtitle: "Difficulty: Easy",
        styleMode: darkStyle,
      ),
      GameCard(
        imageAsset: const AssetImage(
          'assets/images/jumble-preview.png'
        ),
        gameRoute: '/jumble',
        gameWidget: JumbleActivityScreen(colorProfile: currentProfile),
        keyId: 2,
        title: "Translate Jumble",
        subtitle: "Difficulty: Medium",
        styleMode: darkStyle,
      ),
      GameCard(
        imageAsset: const AssetImage(
          'assets/images/reading-preview.png'
        ),
        gameRoute: '/reading', 
        gameWidget: ReadingActivityScreen(colorProfile: currentProfile),
        keyId: 3,
        title: "Read Aloud",
        subtitle: "Difficulty: Challenging",
        styleMode: darkStyle,
      ),
      GameCard(
        imageAsset: const AssetImage(
          'assets/images/type-preview.png'
        ),
        gameRoute: '/typing', 
        gameWidget: TypeActivityScreen(colorProfile: currentProfile),
        keyId: 4,
        title: "Type it Out",
        subtitle: "Difficulty: Challenging",
        styleMode: darkStyle,
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: currentProfile.headerColor,
      ),
      body: Container(
        decoration: currentProfile.backBoxDecoration,
        child: Column(
          children: [
            SizedBox(
              width: 900.0,
              height: 500.0,
              child: ListView(
                key: const ValueKey('HomeListView'),
                primary: true,
                padding: const EdgeInsetsDirectional.only(
                  top: 90.0
                ),
                children: [
                  _HomeItem(
                    child: DesktopCarousel(
                      height: minHeight, 
                      children: gameCards
                    )
                  )
                ],
              ),
            ),
            FutureBuilder<int>(
              future: _counter, 
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return const CircularProgressIndicator();
                  case ConnectionState.active:
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Text(
                        'Button tapped ${snapshot.data ?? 0 + _externalCounter} time${(snapshot.data ?? 0 + _externalCounter) == 1 ? '' : 's'}.\n\n'
                        'This should persist across restarts.',
                      );
                    }
                }
              }),
              ElevatedButton(
                onPressed: _incrementCounter,
                child: const Icon(Icons.add),
              ),
              ElevatedButton(
                onPressed: _decrementCounter, 
                child: const Icon(Icons.remove)
              ),
              GameTestPage(
                colorProfile: currentProfile
              )
          ],
        )
      )
    );
  }
}

class _HomeItem extends StatelessWidget {
  const _HomeItem({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return(
      Align(
        alignment: Alignment.center,
        child: Container(
          constraints: const BoxConstraints(maxWidth: homeWidth),
          padding: const EdgeInsets.symmetric(
            horizontal: desktopPadding
          ),
          child: child,
        ),
      )
    );
  }
}

class DesktopCarousel extends StatefulWidget {
  const DesktopCarousel({
    super.key, 
    required this.height, 
    required this.children
  });

  final double height;
  final List<Widget> children;

  @override
  DesktopCarouselState createState() => DesktopCarouselState();
}

class DesktopCarouselState extends State<DesktopCarousel> {
  late ScrollController controller;

  @override
  void initState() {
    super.initState();
    controller = ScrollController();
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var showPreviousButton = false;
    var showNextButton = true;

    if (controller.hasClients) {
      showPreviousButton = controller.offset > 0;
      showNextButton = controller.offset < controller.position.maxScrollExtent;
    }

    return(Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 300.0,
          width: 550.0,
          child: Align(
            alignment: Alignment.center,
            child: Container(
              height: widget.height,
              constraints: const BoxConstraints(maxWidth: homeWidth),
              child: Stack(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.0),
                    child: Text(
                    "Game Select: Select the Game you want to try",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ),
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: desktopPadding - desktopMargin,
                    ),
                    scrollDirection: Axis.horizontal,
                    primary:  false,
                    physics: const SnappingScrollPhysics(),
                    controller: controller,
                    itemExtent: itemWidth,
                    itemCount: widget.children.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: widget.children[index],
                    ),
                  ),
                  if (showPreviousButton)
                    _DesktopPageButton(
                      onTap: () {
                        controller.animateTo(
                          controller.offset - itemWidth, 
                          duration: const Duration(milliseconds: 200), 
                          curve: Curves.easeOut
                        );
                      },
                    ),
                  if (showNextButton)
                    _DesktopPageButton(
                      isEnd: true,
                      onTap: () {
                        controller.animateTo(
                          controller.offset + itemWidth, 
                          duration: const Duration(milliseconds: 200), 
                          curve: Curves.easeInOut,
                        );
                      },
                    )
                ],
              ),
            ),
          ),
        ),
        
      ],
    )
    );
  }
}

class _DesktopPageButton extends StatelessWidget {
  const _DesktopPageButton({
    this.isEnd = false,
    this.onTap,
  });

  final bool isEnd;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const buttonSize = 58.0;
    const padding = desktopPadding - buttonSize / 2;
    return ExcludeSemantics(
      child: Align(
        alignment: isEnd
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: Container(
          width: buttonSize,
          height: buttonSize,
          margin: EdgeInsetsDirectional.only(
            start: isEnd ? 0 : padding,
            end: isEnd ? padding : 0,
          ),
          child: Tooltip(
            message: isEnd
                ? MaterialLocalizations.of(context).nextPageTooltip
                : MaterialLocalizations.of(context).previousPageTooltip,
            child: Material(
              color: Colors.black.withOpacity(0.5),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                child: Icon(
                  isEnd ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SnappingScrollPhysics extends ScrollPhysics {
  const SnappingScrollPhysics({super.parent});

  @override
  ScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SnappingScrollPhysics(parent: buildParent(ancestor));
  }

  double getTargetPixels(ScrollMetrics pos, Tolerance tolerance,
    double velocity) {
    final itemW = pos.viewportDimension / 4;
    var item = pos.pixels / itemW;
    if (velocity < -tolerance.velocity) {
      item -= 0.5;
    } else if (velocity > tolerance.velocity) {
      item += 0.5;
    }
    return min(item.roundToDouble() * itemW, pos.maxScrollExtent);
  }

  

  @override
  bool get allowImplicitScrolling => true;
}

class GameCard extends StatelessWidget {
  const GameCard({super.key, 
    required this.gameRoute, 
    required this.keyId,
    this.imageAsset,
    this.gameWidget = const FillInActivityScreen(colorProfile: plainFlavor),
    required this.title,
    required this.subtitle,
    required this.styleMode,
  });

  final Widget gameWidget;
  final String gameRoute;
  final int? keyId;
  final ImageProvider? imageAsset;
  final String title;
  final String subtitle;
  final TextStyle? styleMode;
  
  final desktopMargin = 8.0;
  final minHeight = 240.0;
  final itemWidth = 296.0;

  @override
  Widget build(BuildContext context) {
    // final isDark = Theme.of(context).colorScheme.brightness == Brightness.dark;
    final asset = imageAsset;
    final style = styleMode;
    final titleText = title;
    final subtitleText = subtitle;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: desktopMargin),
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      height: minHeight,
      width: itemWidth,
      child: Material(
        key: ValueKey(keyId),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (asset != null)
            Image(
              image: asset,
              fit: BoxFit.cover,
              height: minHeight,
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 500.0,
                    color: const Color.fromARGB(221, 124, 124, 124),
                    child: Column(
                      children: [
                        Text(
                          titleText,
                          maxLines: 3,
                          overflow: TextOverflow.visible,
                          style: style,
                        ),
                        Text(
                          subtitleText,
                          maxLines: 5,
                          overflow: TextOverflow.visible,
                          style: style,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => gameWidget,
                      ),
                    );
                  },
                ),
              )
            )
          ],
        ),
      ),
    );
  }
}

class ThemeService extends StatefulWidget {
  const ThemeService({super.key});

  @override
  ThemeServiceState createState() => ThemeServiceState();
}

class ThemeServiceState extends State<ThemeService> {
  final Future<SharedPreferencesWithCache> _prefs =
    SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: <String>{'counter'}
      ));
  late Future<int> _counter;
  int _externalCounter = 0;

  ColorProfile currentProfile = lightFlavor;

  Future<void> _loadTheme() async {
    final SharedPreferencesWithCache prefs = await _prefs;
    int? themeIndex = (prefs.getInt('counter') ?? 0);

    setState(() {
      currentProfile = _getProfileByIndex(themeIndex);
    });
  }

  ColorProfile _getProfileByIndex(int index) {
    switch(index) {
        case 0:
          return plainFlavor;
        case 1:
          return mintFlavor;
        case 2:
          return strawberryFlavor;
        default:
          return lightFlavor;
      }
  }

  Future<void> _incrementCounter() async {
    final SharedPreferencesWithCache prefs = await _prefs;
    if ((prefs.getInt('counter') ?? 0) >= 2)
      return;
    final int counter = (prefs.getInt('counter') ?? 0) + 1;
    setState(() {
      _counter = prefs.setInt('counter', counter).then((_) {
        currentProfile = _getProfileByIndex(counter);
        return counter;
      });
    });
  }

  Future<void> _decrementCounter() async {
    final SharedPreferencesWithCache prefs = await _prefs;
    if ((prefs.getInt('counter') ?? 0) <= 0)
      return;

    final int counter = (prefs.getInt('counter') ?? 0) - 1;
    setState(() {
      _counter = prefs.setInt('counter', counter).then((_) {
        currentProfile = _getProfileByIndex(counter);
        return counter;
      });
    });
  }

  Future<void> _getExternalCounter() async {
    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
    int? holder = (await prefs.getInt('externalCounter')) ?? 0;
    setState(() {
      _externalCounter = holder;
    });
  }

  @override
  void initState() {
    super.initState();
    _counter = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getInt('counter') ?? 0;
    });
    _getExternalCounter();
    _loadTheme();
  }

  @override
  Widget build(BuildContext context) {
    
    

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test???'),
      ),
      body: Container(
        decoration: currentProfile.backBoxDecoration,
        child: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FutureBuilder<int>(
              future: _counter, 
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return const CircularProgressIndicator();
                  case ConnectionState.active:
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Text(
                        'Button tapped ${snapshot.data ?? 0 + _externalCounter} time${(snapshot.data ?? 0 + _externalCounter) == 1 ? '' : 's'}.\n\n'
                        'This should persist across restarts.',
                      );
                    }
                }
              }),
              ElevatedButton(
                onPressed: _incrementCounter,
                child: const Icon(Icons.add),
              ),
              ElevatedButton(
                onPressed: _decrementCounter, 
                child: const Icon(Icons.remove)
              )
            ]
          ),
        ),
      )
    );
  }
}