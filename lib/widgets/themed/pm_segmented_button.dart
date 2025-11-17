import 'package:flutter/material.dart';
import 'package:pasteque_match/utils/utils.dart';

class PmSegmentedButton<T> extends StatelessWidget {
  const PmSegmentedButton({
    super.key,
    required this.options,
    this.selected,
    required this.iconBuilder,
    this.colorBuilder,
    required this.onSelectionChanged,
  });

  final List<T> options;
  final T? selected;
  final IconBuilder<T> iconBuilder;
  final ColorBuilder<T>? colorBuilder;
  final ValueChanged<T?> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<T>(
      selected: {if (selected != null) selected!},
      segments: options.map((value) => ButtonSegment(
        value: value,
        icon: Icon(iconBuilder(value), color: colorBuilder?.call(value)),
      )).toList(growable: false),
      multiSelectionEnabled: false,
      showSelectedIcon: false,
      emptySelectionAllowed: true,
      onSelectionChanged: (value) => onSelectionChanged(value.firstOrNull),
    );
  }
}
