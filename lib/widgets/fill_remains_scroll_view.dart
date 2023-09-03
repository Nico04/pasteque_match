import 'package:flutter/material.dart';

class FillRemainsScrollView extends StatelessWidget {
  const FillRemainsScrollView({
    Key? key,
    this.controller,
    this.physics,
    this.child,
  }) : super(key: key);

  final ScrollController? controller;
  final ScrollPhysics? physics;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        return SingleChildScrollView(
          controller: controller,
          physics: physics,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: box.maxHeight),
            child: child,
          ),
        );
      },
    );
  }
}
