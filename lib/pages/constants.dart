import 'package:flutter/material.dart';

const darkStyle = TextStyle(color: Colors.white);
const lightStyle = TextStyle(color: Colors.black);

const ColorProfile lightFlavor = ColorProfile(
    backgroundColor: Colors.white,
    headerColor: Color.fromARGB(255, 210, 210, 210),
    buttonColor: Colors.grey, 
    textColor: Colors.black,
    contrastTextColor: Colors.white,
    checkAnswerButtonColor: Colors.green,
    clearAnswerButtonColor: Colors.red,
    backBoxDecoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage("/images/eb_blank_background.png"), 
        repeat: ImageRepeat.repeat,
        scale: 0.4
      )
    ),
    backgroundImage: AssetImage("/images/eb_blank_background.png")
  );

  const ColorProfile darkFlavor = ColorProfile(
    backgroundColor: Color.fromARGB(255, 0, 0, 0),
    headerColor: Color.fromARGB(255, 210, 210, 210),
    buttonColor: Colors.grey, 
    textColor: Colors.black,
    contrastTextColor: Colors.white,
    checkAnswerButtonColor: Colors.green,
    clearAnswerButtonColor: Colors.red,
    backBoxDecoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage("/images/eb_blank_background.png"), 
        repeat: ImageRepeat.repeat,
        scale: 0.4,
        invertColors: true
      )
    ),
    backgroundImage: AssetImage("/images/eb_blank_background.png")
  );

const ColorProfile plainFlavor = ColorProfile(
    backgroundColor: Colors.white,
    headerColor: Color.fromARGB(255, 210, 210, 210),
    buttonColor: Colors.grey, 
    textColor: Colors.black,
    contrastTextColor: Colors.white,
    checkAnswerButtonColor: Colors.green,
    clearAnswerButtonColor: Colors.red,
    backBoxDecoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage("/images/eb_plain_background.png"), 
        repeat: ImageRepeat.repeat,
        scale: 0.4
      )
    ),
    backgroundImage: AssetImage("/images/eb_plain_background.png")
  );

const ColorProfile mintFlavor = ColorProfile(
    backgroundColor: Colors.white,
    headerColor: Color.fromARGB(255, 60, 144, 163),
    buttonColor: Color.fromARGB(255, 38, 171, 171), 
    textColor: Colors.black,
    contrastTextColor: Colors.white,
    checkAnswerButtonColor: Colors.green,
    clearAnswerButtonColor: Colors.red,
    backBoxDecoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage("/images/eb_mint_background.png"), 
        repeat: ImageRepeat.repeat,
        scale: 0.4
      )
    ),
    backgroundImage: AssetImage("/images/eb_mint_background.png")
  );

const ColorProfile strawberryFlavor = ColorProfile(
    backgroundColor: Colors.white,
    headerColor: Color.fromARGB(255, 255, 93, 93),
    buttonColor: Color.fromARGB(255, 250, 135, 135), 
    textColor: Colors.white,
    contrastTextColor: Colors.black,
    checkAnswerButtonColor: Colors.green,
    clearAnswerButtonColor: Colors.red,
    backBoxDecoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage("/images/eb_strawberry_background.png"), 
        repeat: ImageRepeat.repeat,
        scale: 0.4
      )
    ),
    backgroundImage: AssetImage("/images/eb_strawberry_background.png")
  );

const ColorProfile bananaFlavor = ColorProfile(
    backgroundColor: Colors.white,
    headerColor: Colors.yellow,
    buttonColor: Color.fromARGB(255, 101, 101, 101), 
    textColor: Colors.black,
    contrastTextColor: Colors.white,
    checkAnswerButtonColor: Colors.green,
    clearAnswerButtonColor: Colors.red,
    backBoxDecoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage("/images/eb_banana_background.png"), 
        repeat: ImageRepeat.repeat,
        scale: 0.4
      )
    ),
    backgroundImage: AssetImage("/images/eb_banana_background.png")
  );

const ColorProfile peanutFlavor = ColorProfile(
    backgroundColor: Colors.white,
    headerColor: Color.fromARGB(255, 215, 129, 43),
    buttonColor: Colors.grey, 
    textColor: Colors.white,
    contrastTextColor: Colors.white,
    checkAnswerButtonColor: Colors.green,
    clearAnswerButtonColor: Colors.red,
    backBoxDecoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage("/images/eb_nut_background.png"), 
        repeat: ImageRepeat.repeat,
        scale: 0.4
      )
    ),
    backgroundImage: AssetImage("/images/eb_nut_background.png")
  );

// Color profiles for the screens
class ColorProfile {
  const ColorProfile({
    required this.backgroundColor,
    required this.headerColor,
    required this.buttonColor,
    required this.textColor,
    required this.contrastTextColor,
    required this.checkAnswerButtonColor,
    required this.clearAnswerButtonColor,
    required this.backBoxDecoration,
    required this.backgroundImage,
    this.disabledButtonColor = Colors.grey,
  });

  final Color backgroundColor;
  final Color headerColor;
  final Color buttonColor;
  final Color textColor;
  final Color contrastTextColor;
  final Color checkAnswerButtonColor;
  final Color clearAnswerButtonColor;
  final AssetImage backgroundImage;
  final BoxDecoration backBoxDecoration;
  final Color disabledButtonColor;
}