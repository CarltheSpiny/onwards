import 'dart:math';

import 'package:flutter/material.dart';
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

  final ColorProfile colorProfile = strawberryFlavor;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Onwards',
      routes: {
        // routes must be defined here to be used in the app
        '/': (context) => HomePage(colorProfile: colorProfile,),
        '/fill-in-the-blank': (context) => FillInActivityScreen(colorProfile: colorProfile,),
        '/audio-playback': (context) => PlaybackActivityScreen(colorProfile: colorProfile),
        '/typing': (context) => TypeActivityScreen(colorProfile: colorProfile,),
        '/jumble': (context) => JumbleActivityScreen(colorProfile: colorProfile),
        '/reading': (context) => ReadingActivityScreen(colorProfile: colorProfile),
        '/test' : (context) => const ThemeService()
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.colorProfile
  });

  final ColorProfile colorProfile;

  @override
  Widget build(BuildContext context) {

    final gameCards = <Widget> [
      const GameCard(
        imageAsset: AssetImage(
          'assets/images/audio-playback-preview.png'
        ),
        gameRoute: "/audio-playback", 
        keyId: 0,
        title: "Playback and Choose",
        subtitle: "Difficulty: Hard",
        styleMode: darkStyle,
      ),
      const GameCard(
        imageAsset: AssetImage(
          'assets/images/fill-in-the-blank-preview.png'
        ),
        gameRoute: '/fill-in-the-blank', 
        keyId: 1,
        title: "Fill in the Blank",
        subtitle: "Difficulty: Easy",
        styleMode: darkStyle,
      ),
      const GameCard(
        imageAsset: AssetImage(
          'assets/images/jumble-preview.png'
        ),
        gameRoute: '/jumble', 
        keyId: 2,
        title: "Translate Jumble",
        subtitle: "Difficulty: Medium",
        styleMode: darkStyle,
      ),
      const GameCard(
        imageAsset: AssetImage(
          'assets/images/reading-preview.png'
        ),
        gameRoute: '/reading', 
        keyId: 3,
        title: "Read Aloud",
        subtitle: "Difficulty: Challenging",
        styleMode: darkStyle,
      ),
      const GameCard(
        imageAsset: AssetImage(
          'assets/images/type-preview.png'
        ),
        gameRoute: '/typing', 
        keyId: 4,
        title: "Type it Out",
        subtitle: "Difficulty: Challenging",
        styleMode: darkStyle,
      ),
      const GameCard(
        imageAsset: AssetImage(
          'assets/images/placeholder.png'
        ),
        gameRoute: '/test', 
        keyId: 5,
        title: "Test it Out",
        subtitle: "Difficulty: N/A",
        styleMode: darkStyle,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: colorProfile.headerColor,
      ),
      body: Container(
        decoration: colorProfile.backBoxDecoration,
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
  const DesktopCarousel({super.key, required this.height, required this.children});

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

    return(Align(
        alignment: Alignment.center,
        child: Container(
          height: widget.height,
          constraints: const BoxConstraints(maxWidth: homeWidth),
          child: Stack(
            children: [
              const Text(
                "Game Select: Select the Game you want to try",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold
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
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
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
    required this.title,
    required this.subtitle,
    required this.styleMode,
  });

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
    final asset = this.imageAsset;
    final style = this.styleMode;
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
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context)
                    .popUntil((route) => route.settings.name == '/');
                    Navigator.of(context).restorablePushNamed(gameRoute);
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

// This will allow the user to select some theme from a menu
class ThemeSelector extends StatelessWidget {
  final ValueChanged<ColorProfile?> onProfileChanged;

  const ThemeSelector({
    super.key, 
    required this.onProfileChanged
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      hint: const Text('Select a Theme'),
      items: const [
        DropdownMenuItem(
          value: plainFlavor,
          child: Text('Plain Flavor')
        ),
        DropdownMenuItem(
          value: mintFlavor,
          child: Text('Mint Flavor')
        ),
        DropdownMenuItem(
          value: strawberryFlavor,
          child: Text('Strawberry Flavor')
        ),
        DropdownMenuItem(
          value: bananaFlavor,
          child: Text('Banana Flavor')
        ),
        DropdownMenuItem(
          value: peanutFlavor,
          child: Text('Peanut Flavor')
        ),
        DropdownMenuItem(
          value: lightFlavor,
          child: Text('Light Flavor')
        )
      ], 
      onChanged: onProfileChanged,
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

  Future<void> _incrementCounter() async {
    final SharedPreferencesWithCache prefs = await _prefs;
    final int counter = (prefs.getInt('counter') ?? 0) + 1;
    setState(() {
      _counter = prefs.setInt('counter', counter).then((_) {
        return counter;
      });
    });
  }

  Future<void> _getExternalCounter() async {
    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
    setState(() async {
      _externalCounter = (await prefs.getInt('externalCounter')) ?? 0;
    });
  }

  @override
  void initState() {
    super.initState();
    _counter = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getInt('counter') ?? 0;
    });
    _getExternalCounter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test???'),
      ),
      body: Center(
        child: FutureBuilder<int>(
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
          })),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}