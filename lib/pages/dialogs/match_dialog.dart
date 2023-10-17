import 'package:confetti/confetti.dart';
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
  final _confettiController = ConfettiController(duration: const Duration(seconds: 3));

  @override
  void initState() {
    super.initState();
    _confettiController.play();
  }

  /// A custom Path that paint hearth shape
  Path _buildHeartPath(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();
    path.moveTo(0, 0);
    path.cubicTo(0, 0, 0, -h/2, w/4, -h/2);
    path.cubicTo(w/2, -h/2, w/2, 0, w/2, 0);
    path.cubicTo(w/2, 0, w/2, -h/2, 3/4*w, -h/2);
    path.cubicTo(w, -h/2, w, 0, w, 0);
    path.cubicTo(w, 0, w, h/2, w/2, h);
    path.cubicTo(0, h/2, 0, 0, 0, 0);
    return path;
  }

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
              Stack(
                alignment: Alignment.center,
                children: [
                  // Image
                  Image.asset(
                    'assets/match.png',
                    height: 300,
                  ),

                  // Confetti
                  Center(
                    child: ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirectionality: BlastDirectionality.explosive,
                      emissionFrequency: 0.05,
                      createParticlePath: _buildHeartPath,
                    ),
                  ),
                ],
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
              Padding(
                padding: AppResources.paddingContent,
                child: FittedBox(  // Auto size if too long
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
    _confettiController.dispose();
    super.dispose();
  }
}
