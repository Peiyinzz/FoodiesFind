import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class TypewriterSearchText extends StatelessWidget {
  final String text;

  const TypewriterSearchText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(fontSize: 16, color: Colors.grey),
      child: AnimatedTextKit(
        animatedTexts: [
          TypewriterAnimatedText(
            text,
            speed: const Duration(milliseconds: 80),
            cursor: '',
          ),
        ],

        pause: const Duration(seconds: 2),
        isRepeatingAnimation: true,
        repeatForever: true,
        displayFullTextOnTap: true,
        stopPauseOnTap: true,
      ),
    );
  }
}
