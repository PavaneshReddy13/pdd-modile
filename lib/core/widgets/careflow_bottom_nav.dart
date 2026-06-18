import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CareFlowBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CareFlowBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: const Border(
          top: BorderSide(color: AppTheme.borderCol, width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        backgroundColor: AppTheme.backgroundLight.withValues(alpha: 0.95),
        indicatorColor: AppTheme.primaryNeon.withValues(alpha: 0.15),
        height: 65,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: AppTheme.textSecondary),
            selectedIcon: Icon(Icons.home, color: AppTheme.primaryNeon),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined,
                color: AppTheme.textSecondary),
            selectedIcon:
                Icon(Icons.calendar_month, color: AppTheme.primaryNeon),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon:
                Icon(Icons.medication_outlined, color: AppTheme.textSecondary),
            selectedIcon: Icon(Icons.medication, color: AppTheme.primaryNeon),
            label: 'Meds',
          ),
          NavigationDestination(
            icon:
                Icon(Icons.chat_bubble_outline, color: AppTheme.textSecondary),
            selectedIcon: Icon(Icons.chat_bubble, color: AppTheme.primaryNeon),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, color: AppTheme.textSecondary),
            selectedIcon: Icon(Icons.person, color: AppTheme.primaryNeon),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
