import 'package:flutter/material.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/utils/_utils.dart';

class PmConfirmationDialog extends StatelessWidget {
  const PmConfirmationDialog({super.key, required this.text, required this.confirmText, this.cancelText});

  final String text;
  final String confirmText;
  final String? cancelText;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Label
          Padding(
            padding: AppResources.paddingContent,
            child: Text(
              text,
              style: context.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),

          // Buttons
          Row(
            children: [
              if (cancelText != null)
                Expanded(
                  child: _buildButton(
                    context,
                    label: cancelText!,
                    returnValue: false,
                  ),
                ),
              Expanded(
                child: _buildButton(
                  context,
                  label: confirmText,
                  returnValue: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, {required String label, required bool returnValue}) {
    return TextButton(
      style: TextButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: context.textTheme.bodyText1,
      ),
      onPressed: () => Navigator.of(context).pop(returnValue),
    );
  }
}
