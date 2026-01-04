import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:vyra/features/home/screen/home_screen.dart';
import 'package:vyra/features/meeting/screens/recent_meeting_screen.dart';
import 'package:vyra/features/meeting/screens/scheduled_meetings_screen.dart';
import 'package:vyra/features/profile/screens/profile_screen.dart';
import '../../../core/theme/app_colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  /// ✅ KEEP SCREENS ALIVE (CRITICAL FIX)
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      const HomeScreen(),
      ScheduledMeetingsScreen(),
      RecentMeetingScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      /// 🔥 FIX: IndexedStack PREVENTS DISPOSAL
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      /// 🌌 GLASS BOTTOM NAV
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.75),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _navItem(
                    icon: Icons.home_rounded,
                    label: "Home",
                    index: 0,
                  ),
                  _navItem(
                    icon: Icons.schedule,
                    label: "Scheduled",
                    index: 1,
                  ),
                  _navItem(
                    icon: Icons.history_rounded,
                    label: "Meetings",
                    index: 2,
                  ),
                  _navItem(
                    icon: Icons.person_rounded,
                    label: "Profile",
                    index: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🔘 NAV ITEM
  Widget _navItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        if (_currentIndex == index) return;
        setState(() => _currentIndex = index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withOpacity(0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 26,
              color: isActive
                  ? AppColors.primary
                  : AppColors.textMuted,
            ),
            const SizedBox(height: 4),
            AnimatedOpacity(
              opacity: isActive ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
