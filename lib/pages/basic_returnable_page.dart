import 'package:flutter/material.dart';
import 'package:onwards/pages/constants.dart';
import 'package:onwards/pages/home.dart' as home;

class ReturnableRoute extends StatelessWidget {
  const ReturnableRoute({super.key});

  @override
  Widget build(BuildContext context) {
    final gameCards = <Widget> [
      const home.GameCard(
        imageAsset: AssetImage(
          'assets/images/audio-playback-preview.png'
        ),
        gameRoute: "/audio-playback", 
        keyId: 0,
        title: "Playback and Choose",
        subtitle: "Difficulty: Hard",
        styleMode: darkStyle,
      ),
      const home.GameCard(
        imageAsset: AssetImage(
          'assets/images/fill-in-the-blank-preview.png'
        ),
        gameRoute: '/fill-in-the-blank', 
        keyId: 1,
        title: "Fill in the Blank",
        subtitle: "Difficulty: Easy",
        styleMode: darkStyle,
      ),
      const home.GameCard(
        imageAsset: AssetImage(
          'assets/images/jumble-preview.png'
        ),
        gameRoute: '/jumble', 
        keyId: 2,
        title: "Translate Jumble",
        subtitle: "Difficulty: Medium",
        styleMode: darkStyle,
      ),
      const home.GameCard(
        imageAsset: AssetImage(
          'assets/images/reading-preview.png'
        ),
        gameRoute: '/reading', 
        keyId: 3,
        title: "Read Aloud",
        subtitle: "Difficulty: Challenging",
        styleMode: darkStyle,
      ),
      const home.GameCard(
        imageAsset: AssetImage(
          'assets/images/type-preview.png'
        ),
        gameRoute: '/type', 
        keyId: 4,
        title: "Type it Out",
        subtitle: "Difficulty: Challenging",
        styleMode: darkStyle,
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Returnable Route'),
      ),
      body: CarouselView(
        itemExtent: double.infinity, 
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        children: gameCards
      )
    );
  }
}