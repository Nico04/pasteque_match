import 'package:fetcher/extra.dart';
import 'package:flutter/material.dart';
import 'package:pasteque_match/widgets/lazy_indexed_stack.dart';

class PmTabbedPage extends StatefulWidget {
  const PmTabbedPage({
    Key? key,
    this.initialIndex = 0,
    required this.pages,
  }) : super(key: key);

  final int initialIndex;
  final List<PmTabbedPageItem> pages;

  @override
  State<PmTabbedPage> createState() => PmTabbedPageState();
}

class PmTabbedPageState extends State<PmTabbedPage> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  void setIndex(int index) {
    if (index == _index) return;
    context.clearFocus();
    setState(() {
      _index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_index == widget.initialIndex) {
          return true;
        } else {
          setIndex(widget.initialIndex);
          return false;
        }
      },
      child: Scaffold(
        body: LazyIndexedStack(
          index: _index,
          children: widget.pages.map((e) => e.page).toList(growable: false),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          onTap: setIndex,
          items: widget.pages.map((e) {
            return BottomNavigationBarItem(
              icon: Icon(e.unselectedIcon),
              activeIcon: Icon(e.selectedIcon),
              label: e.label,
            );
          }).toList(growable: false),
        ),
      ),
    );
  }
}

class PmTabbedPageItem {
  const PmTabbedPageItem({
    required this.unselectedIcon,
    required this.selectedIcon,
    required this.label,
    required this.page,
  });

  final IconData unselectedIcon;
  final IconData selectedIcon;
  final String label;
  final Widget page;
}
