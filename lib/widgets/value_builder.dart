import 'package:fetcher/fetcher_bloc.dart';
import 'package:flutter/material.dart';

/// Simple widget that build value from [valueBuilder] when [value] changes.
/// Rebuilds the widget using [builder] with the built value.
/// Useful for expensive value transformations that should only be done when the input value changes.
class ValueBuilder<I, O> extends StatefulWidget {
  const ValueBuilder({
    super.key,
    required this.value,
    required this.valueBuilder,
    required this.builder,
  });

  final I value;
  final O Function(I value) valueBuilder;
  final DataWidgetBuilder<O> builder;

  @override
  State<ValueBuilder<I, O>> createState() => _ValueBuilderState<I, O>();
}

class _ValueBuilderState<I, O> extends State<ValueBuilder<I, O>> {
  late O _builtValue;

  @override
  void initState() {
    super.initState();
    _builtValue = widget.valueBuilder(widget.value);
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      setState(() {
        _builtValue = widget.valueBuilder(widget.value);
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _builtValue);
}

