import 'package:flutter/material.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/utils/_utils.dart';

/// Confirmation dialog, with an optional form.
class PmConfirmationDialog extends StatelessWidget {
  const PmConfirmationDialog({super.key, required this.title, required this.caption, this.form, this.confirmText, this.cancelText});

  final String title;
  final String caption;
  final Widget? form;
  final String? confirmText;
  final String? cancelText;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Builder(
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(caption),
                if (form != null)...[
                  AppResources.spacerMedium,
                  form!,
                ],
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context, rootNavigator: true).pop(false),
                child: Text(
                  cancelText ?? 'Annuler',
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
              TextButton(
                onPressed: () => context.validateForm(
                  onSuccess: () => Navigator.of(context, rootNavigator: true).pop(true),
                ),
                child: Text(confirmText ?? 'OK'),
              ),
            ],
          );
        },
      ),
    );
  }
}
