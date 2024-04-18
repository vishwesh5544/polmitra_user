import 'package:flutter/material.dart';
import 'package:user_app/utils/color_provider.dart';

class EventsReportAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<String> tabs;
  final TabController tabController;
  final VoidCallback initialize;

  const EventsReportAppBar({required this.tabs, required this.tabController, required this.initialize, super.key});

  final double appBarHeight = 56.0; // Default app bar height
  final double tabBarHeight = 48.0; // Default tab bar height

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ColorProvider.lightLemon,
      title: const InkWell(
        child: Text('Reports'),
      ),
      bottom: TabBar(
        controller: tabController,
        isScrollable: true,
        tabs: tabs.map((e) => Tab(text: e)).toList(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: initialize,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight + tabBarHeight);
}
