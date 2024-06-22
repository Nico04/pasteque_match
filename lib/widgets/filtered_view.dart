import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';

typedef FilterDelegate<T, F> = bool Function(T item, F filter);

class FilteredView<T, F> extends StatefulWidget {
  const FilteredView({
    super.key,
    required this.list,
    required this.filter,
    this.ignoreWhen,
    required this.filterValue,
    required this.builder,
  });

  /// Unfiltered list
  final Iterable<T> list;

  /// Filter function
  final FilterDelegate<T, F> filter;

  /// If provided, filtering will be ignored when [ignoreWhen] return true.
  final bool Function(F)? ignoreWhen;

  /// Filter value
  final F filterValue;

  /// Widget builder, called when filter changes and provides the filtered list.
  final DataWidgetBuilder<Iterable<T>> builder;

  @override
  State<FilteredView> createState() => _FilteredViewState<T, F>();
}

class _FilteredViewState<T, F> extends State<FilteredView<T, F>> {
  late Iterable<T> filteredList;

  @override
  void initState() {
    super.initState();
    applyFilter();
  }

  void applyFilter() {
    setState(() {
      if (widget.ignoreWhen?.call(widget.filterValue) == true) {
        filteredList = widget.list;
      } else {
        filteredList = widget.list.where((e) => widget.filter(e, widget.filterValue)).toList(growable: false);
      }
    });
  }

  @override
  void didUpdateWidget(covariant FilteredView<T, F> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.list != oldWidget.list || widget.filter != oldWidget.filter || widget.filterValue != oldWidget.filterValue || widget.builder != oldWidget.builder) {
      applyFilter();
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, filteredList);
}
