import 'package:flutter/material.dart';

import 'components/notification_push_rule_tab.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  static const routeName = 'notifications';

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2,
      child: NotificationPushRuleTab(),
    );
  }
}
