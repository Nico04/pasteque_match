import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pasteque_match/widgets/themed/pages/pm_tabbed_page.dart';

import 'swipe.page.dart';
import 'matches.page.dart';
import 'profile.page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PmTabbedPage(
      pages: [
        PmTabbedPageItem(unselectedIcon: FontAwesomeIcons.baby, selectedIcon: FontAwesomeIcons.baby, label: 'Swipe', page: SwipePage()),
        PmTabbedPageItem(unselectedIcon: FontAwesomeIcons.heart, selectedIcon: FontAwesomeIcons.solidHeart, label: 'Matches', page: MatchesPage()),
        PmTabbedPageItem(unselectedIcon: FontAwesomeIcons.user, selectedIcon: FontAwesomeIcons.solidUser, label: 'Profil', page: ProfilePage()),
      ],
    );
  }
}
