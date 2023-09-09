import 'package:flutter/material.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/widgets/fill_remains_scroll_view.dart';

class PmBasicPage extends StatelessWidget {
  const PmBasicPage({super.key, this.title, this.action, required this.child, this.withPadding = true, this.withScrollView = true});

  /// App bar title
  final String? title;

  /// Action widget to be displayed in the app bar
  final Widget? action;

  /// Content
  final Widget child;

  /// Whether to wrap [child] in a default padding
  final bool withPadding;

  /// Whether to wrap [child] in a scrollview or not
  final bool withScrollView;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title == null ? null : AppBar(
        title: Text(title!),
        actions: [if (action != null) action!],
        forceMaterialTransparency: true,
      ),
      body: () {
        var child = this.child;
        if (withPadding) {
          child = Padding(
            padding: AppResources.paddingPage,
            child: child,
          );
        }
        child = SafeArea(child: child);
        if (withScrollView) return FillRemainsScrollView(child: child);
        return child;
      } (),
    );
  }
}