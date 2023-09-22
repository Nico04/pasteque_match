import 'package:flutter/material.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/utils/_utils.dart';

class MatchDialog extends StatefulWidget {
  static void open(BuildContext context, String matchingName) => showDialog(
    context: context,
    useSafeArea: false,
    builder: (_) => MatchDialog(matchingName),
  );

  const MatchDialog(this.matchingName, {super.key});

  final String matchingName;

  @override
  State<MatchDialog> createState() => _MatchDialogState();
}

class _MatchDialogState extends State<MatchDialog> {
  final _stopwatch = Stopwatch()..start();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset(
            'assets/match_bg.png',
            opacity: const AlwaysStoppedAnimation(0.8),
            fit: BoxFit.cover,
          ),

          // Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image
              Image.asset(
                'assets/match.png',
                height: 300,
              ),

              // Title
              AppResources.spacerMedium,
              Text(
                'C\'est un match !',
                style: context.textTheme.displaySmall?.copyWith(color: Colors.white),
              ),

              // Caption
              AppResources.spacerExtraLarge,
              Text(
                'Vous avez tous les deux aimé le prénom',
                style: context.textTheme.titleMedium?.copyWith(color: Colors.white),
              ),

              // Name
              AppResources.spacerMedium,
              FittedBox(  // Auto size if too long
                child: Text(
                  widget.matchingName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 100,
                    fontFamily: 'Passions Conflict',
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        offset: Offset(2, 2),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Barrier
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () {
                  // Cooldown to avoid to close pop-up too fast
                  if (_stopwatch.elapsed > const Duration(seconds: 1)) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }
}
