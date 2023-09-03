import 'package:fetcher/fetcher.dart' hide ValueGetter;
import 'package:flutter/material.dart';

/// Simple widget that provides a value provided by [valueGetter] at init.
class ValueBuilder<T> extends StatefulWidget {
  const ValueBuilder({Key? key, required this.valueGetter, required this.builder}) : super(key: key);

  final ValueGetter<T> valueGetter;
  final DataWidgetBuilder<T> builder;

  @override
  State<ValueBuilder<T>> createState() => _ValueBuilderState<T>();
}

class _ValueBuilderState<T> extends State<ValueBuilder<T>> {
  late T value;

  @override
  void initState() {
    super.initState();
    value = widget.valueGetter();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, value);
}

