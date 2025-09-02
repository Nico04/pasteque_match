import 'package:fetcher/fetcher_bloc.dart';
import 'package:flutter/material.dart';

/// Simple widget that build value from [valueGetter] at init,
/// then provide it to [builder], keeping built value in state between rebuilds.
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

