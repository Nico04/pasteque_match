import 'package:flutter/material.dart';

/// A row that enforce his child to be aligned.
/// Parent widget must enforce size (will throw if unbound size is given) (limitation of MultiChildLayoutDelegate).
class AlignedRow extends StatelessWidget {
  const AlignedRow({Key? key, this.leading, this.center, this.trailing}) : super(key: key);

  final Widget? leading;
  final Widget? center;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: _AlignedRowCustomMultiChildLayoutDelegate(),
      children: [
        if (leading != null)
          LayoutId(
            id: _AlignedRowChildType.leading,
            child: leading!,
          ),
        if (center != null)
          LayoutId(
            id: _AlignedRowChildType.center,
            child: center!,
          ),
        if (trailing != null)
          LayoutId(
            id: _AlignedRowChildType.trailing,
            child: trailing!,
          ),
      ],
    );
  }
}

enum _AlignedRowChildType { leading, center, trailing }

class _AlignedRowCustomMultiChildLayoutDelegate extends MultiChildLayoutDelegate {
  _AlignedRowCustomMultiChildLayoutDelegate();

  @override
  void performLayout(Size size) {
    final looseConstraints = BoxConstraints.loose(size);

    // Leading
    Size? leadingSize;
    if (hasChild(_AlignedRowChildType.leading)) {
      leadingSize = layoutChild(_AlignedRowChildType.leading, looseConstraints);
      positionChild(_AlignedRowChildType.leading, Offset(0, size.height / 2 - leadingSize.height / 2));
    }

    // Trailing
    Size? trailingSize;
    if (hasChild(_AlignedRowChildType.trailing)) {
      trailingSize = layoutChild(_AlignedRowChildType.trailing, looseConstraints);
      positionChild(_AlignedRowChildType.trailing, Offset(size.width - trailingSize.width, size.height / 2 - trailingSize.height / 2));
    }

    // Center
    if (hasChild(_AlignedRowChildType.center)) {
      final centerSize = layoutChild(_AlignedRowChildType.center, looseConstraints);

      var x = size.width / 2 - centerSize.width / 2;
      if (leadingSize != null && leadingSize.width > x) {
        x = leadingSize.width;
      } else if (trailingSize != null && trailingSize.width > size.width - (x + centerSize.width)) {
        x = size.width - trailingSize.width - centerSize.width;
      }

      positionChild(_AlignedRowChildType.center, Offset(x, size.height / 2 - centerSize.height / 2));
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) => this != oldDelegate;
}
