import 'package:flutter/material.dart';

class PmConfirmationDialog extends StatelessWidget {
  const PmConfirmationDialog({super.key, required this.title, required this.caption, this.confirmText, this.cancelText});

  final String title;
  final String caption;
  final String? confirmText;
  final String? cancelText;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(caption),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(false),
          child: Text(cancelText ?? 'Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
          child: Text(confirmText ?? 'OK'),
        ),
      ],
    );
  }
}
