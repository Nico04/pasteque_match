import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/utils/_utils.dart';

class PmTileButton extends StatelessWidget {
  const PmTileButton({super.key, this.color, required this.icon, required this.label, this.withTrailingArrow = true, required this.onPressed});

  final Color? color;
  final IconData icon;
  final String label;
  final bool withTrailingArrow;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          height: 60,
          padding: AppResources.paddingContent,
          child: Row(
            children: [

              // Icon
              Icon(icon),

              // Title
              AppResources.spacerMedium,
              Expanded(
                child: Text(
                  label,
                  style: context.textTheme.labelLarge,
                ),
              ),

              // Arrow
              if (withTrailingArrow)...[
                AppResources.spacerMedium,
                const Icon(
                  FontAwesomeIcons.chevronRight,
                  size: 16,
                ),
              ],

            ],
          ),
        )
      ),
    );
  }
}
