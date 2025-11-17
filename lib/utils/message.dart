import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:pasteque_match/main.dart';
import 'package:pasteque_match/utils/_utils.dart';

/// Display a message to the user, like a SnackBar
void showMessage(String message, {bool isError = false, String? details, int? durationInSeconds, Color? backgroundColor}) {
  // Dismiss previous message
  _messageController?.dismiss();

  // Display new message
  backgroundColor ??= (isError ? Colors.orange : Colors.white);
  showFlash(
    context: App.navigatorContext,
    duration: Duration(seconds: durationInSeconds ?? (details == null ? 4 : 8)),
    builder: (context, controller) {
      _messageController = controller;

      return FlashBar(
        controller: controller,
        position: FlashPosition.top,
        behavior: FlashBehavior.floating,
        backgroundColor: backgroundColor,
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 2,
        primaryAction: details == null
            ? null
            : TextButton(
                child: const Text(
                  'Détails',
                ),
                onPressed: () {
                  controller.dismiss();
                  showDialog(
                    context: context,     // context and NOT parent context must be used, otherwise it may throw error
                    builder: (context) => AlertDialog(
                      title: SelectableText(message),
                      content: SelectableText(details),
                    ),
                  );
                },
              ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(color: backgroundColor?.foregroundTextColor),
        ),
      );
    },
  ).then(_clearController, onError: _clearController);;
}

// Store last controller to be able to dismiss it
FlashController? _messageController;

void _clearController([dynamic _]) {
  _messageController = null;
}
