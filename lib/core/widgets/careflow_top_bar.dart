import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CareFlowTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String searchHint;
  final ValueChanged<String>? onSearchChanged;
  final bool showSearch;
  final String avatarInitials;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final Widget? quickActionButton;

  const CareFlowTopBar({
    super.key,
    required this.title,
    this.searchHint = 'Search...',
    this.onSearchChanged,
    this.showSearch = true,
    this.avatarInitials = 'U',
    this.onNotificationTap,
    this.onProfileTap,
    this.quickActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderCol, width: 1.0),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Title or Sidebar toggle
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Search field (if enabled)
            if (showSearch)
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderCol),
                    ),
                    child: TextField(
                      onChanged: onSearchChanged,
                      style: const TextStyle(
                          color: AppTheme.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: searchHint,
                        hintStyle: TextStyle(
                            color:
                                AppTheme.textSecondary.withValues(alpha: 0.5)),
                        prefixIcon: const Icon(Icons.search,
                            color: AppTheme.textSecondary, size: 18),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              )
            else
              const Spacer(),

            // Actions (Quick action + Notification + Profile)
            Row(
              children: [
                if (quickActionButton != null) ...[
                  quickActionButton!,
                  const SizedBox(width: 16),
                ],

                // Notifications icon
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none_outlined,
                          color: AppTheme.textSecondary),
                      onPressed: onNotificationTap ?? () {},
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryNeon,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),

                // Profile avatar
                GestureDetector(
                  onTap: onProfileTap,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryNeon, AppTheme.cyanAccent],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        avatarInitials.toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.background,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
