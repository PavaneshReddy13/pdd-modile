import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'careflow_neon_background.dart';
import 'careflow_sidebar.dart';
import 'careflow_top_bar.dart';

class CareFlowDarkShell extends StatelessWidget {
  final String userName;
  final String userRole;
  final List<CareFlowSidebarItem> items;
  final String currentRoute;
  final VoidCallback onLogout;
  final Widget body;
  final String title;
  final bool showSearch;
  final String searchHint;
  final ValueChanged<String>? onSearchChanged;
  final Widget? quickActionButton;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  const CareFlowDarkShell({
    super.key,
    required this.userName,
    required this.userRole,
    required this.items,
    required this.currentRoute,
    required this.onLogout,
    required this.body,
    required this.title,
    this.showSearch = true,
    this.searchHint = 'Search...',
    this.onSearchChanged,
    this.quickActionButton,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final avatarInitials = userName.isNotEmpty ? userName[0] : 'U';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        if (isDesktop) {
          // Desktop Layout with left sidebar and right content area
          return CareFlowNeonBackground(
            showGrid: true,
            showOrb: true,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              floatingActionButton: floatingActionButton,
              body: Row(
                children: [
                  CareFlowSidebar(
                    userName: userName,
                    userRole: userRole,
                    items: items,
                    currentRoute: currentRoute,
                    onLogout: onLogout,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        CareFlowTopBar(
                          title: title,
                          showSearch: showSearch,
                          searchHint: searchHint,
                          onSearchChanged: onSearchChanged,
                          avatarInitials: avatarInitials,
                          quickActionButton: quickActionButton,
                        ),
                        Expanded(
                          child: SafeArea(
                            top: false,
                            bottom: true,
                            child: body,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          // Mobile Layout with drawer and app bar
          return CareFlowNeonBackground(
            showGrid: true,
            showOrb: false,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                backgroundColor: AppTheme.background.withValues(alpha: 0.4),
                elevation: 0,
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: AppTheme.primaryNeon),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                actions: [
                  if (quickActionButton != null) ...[
                    quickActionButton!,
                    const SizedBox(width: 8),
                  ],
                  IconButton(
                    icon: const Icon(Icons.notifications_none_outlined,
                        color: AppTheme.textSecondary),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              drawer: Drawer(
                backgroundColor: AppTheme.background,
                child: SafeArea(
                  child: CareFlowSidebar(
                    userName: userName,
                    userRole: userRole,
                    items: items,
                    currentRoute: currentRoute,
                    onLogout: () {
                      Navigator.pop(context); // close drawer
                      onLogout();
                    },
                  ),
                ),
              ),
              body: SafeArea(
                child: body,
              ),
              bottomNavigationBar: bottomNavigationBar,
              floatingActionButton: floatingActionButton,
            ),
          );
        }
      },
    );
  }
}
