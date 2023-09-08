import 'package:flutter/material.dart';
import 'package:pasteque_match/widgets/themed/pages/pm_tabbed_page.dart';

import 'swipe_page.dart';
import 'matches_page.dart';
import 'profile.page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PmTabbedPage(
      pages: [
        PmTabbedPageItem(unselectedIcon: Icons.child_friendly_outlined, selectedIcon: Icons.child_friendly, label: 'Swipe', page: SwipePage()),
        PmTabbedPageItem(unselectedIcon: Icons.favorite_outline, selectedIcon: Icons.favorite, label: 'Matches', page: MatchesPage()),
        PmTabbedPageItem(unselectedIcon: Icons.person_outline, selectedIcon: Icons.person, label: 'Profil', page: ProfilePage()),
      ],
    );
  }
}
