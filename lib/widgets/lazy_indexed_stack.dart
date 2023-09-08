import 'package:flutter/material.dart';
import 'package:pasteque_match/utils/extensions_base.dart';

class LazyIndexedStack extends StatefulWidget {
  const LazyIndexedStack({
    Key? key,
    required this.index,
    required this.children,
  }) : super(key: key);

  /// The index of the child to show.
  final int index;

  /// Widgets to display.
  /// Only one will be displayed at once.
  /// They are lazily built when corresponding index is set.
  /// Once built, their state will be preserved.
  final List<Widget> children;

  @override
  State<LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<LazyIndexedStack> {
   late final List<bool> _loaded;

  @override
  void initState() {
    super.initState();
    _loaded = List.filled(widget.children.length, false);
    _loaded[widget.index] = true;
  }

   @override
   void didUpdateWidget(final LazyIndexedStack oldWidget) {
     super.didUpdateWidget(oldWidget);
     _loaded[widget.index] = true;
   }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.index,
      children: _buildChildren(),
    );
  }

  List<Widget> _buildChildren() {
    return widget.children.mapIndexed((index, item) {
      return _loaded[index]
        ? Visibility(   // Enforce that animations are disabled when hidden
            visible: index == widget.index,
            maintainState: true,
            child: item,
          )
        : const SizedBox();
    }).toList(growable: false);
  }
}
