import 'package:flutter/material.dart';

class LetterBackground extends StatelessWidget {
  const LetterBackground({super.key, required this.letter, required this.child});

  final String letter;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const backgroundLetterHeight = 200.0;
    final letter = this.letter.substring(0, 1).toUpperCase();

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Background
        Positioned(
          top: -backgroundLetterHeight / 2, // Couldn't find a better way to center the letter vertically.
          child: Text(
            letter,
            style: TextStyle(
              fontFamily: 'Passions Conflict',
              fontSize: backgroundLetterHeight,
              color: Colors.black.withOpacity(0.1),
            ),
          ),
        ),

        // Content
        child,
      ],
    );
  }
}
