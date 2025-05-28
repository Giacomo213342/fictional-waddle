import 'package:flutter/material.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../../widgets/matrix/scopes/client_scope.dart';
import 'rule_set_tab.dart';

class NotificationPushRuleTab extends StatelessWidget {
  const NotificationPushRuleTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context);
    final client = ClientScope.of(context).client;
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).notificationSettings),
          bottom: TabBar(
            tabs: [
              Tab(
                text: AppLocalizations.of(context).notificationsGlobal,
              ),
              Tab(
                text: AppLocalizations.of(context).notificationsOverride,
              ),
              Tab(
                text: AppLocalizations.of(context).notificationsRoom,
              ),
              Tab(
                text: AppLocalizations.of(context).notificationsSender,
              ),
              Tab(
                text: AppLocalizations.of(context).notificationsUnderride,
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: controller,
          children: [
            client.globalPushRules,
            client.devicePushRules,
          ]
              .map(
                (rules) => TabBarView(
                  children: [
                    RuleSetTab(rules: rules?.content),
                    RuleSetTab(rules: rules?.override),
                    RuleSetTab(rules: rules?.room),
                    RuleSetTab(rules: rules?.sender),
                    RuleSetTab(rules: rules?.underride),
                  ],
                ),
              )
              .toList(),
        ),
        bottomNavigationBar: AnimatedBuilder(
          animation: controller,
          builder: (context, value) => NavigationBar(
            selectedIndex: controller.index,
            onDestinationSelected: (index) => controller.animateTo(index),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.account_circle),
                label: AppLocalizations.of(context).pushRulesGlobal,
              ),
              NavigationDestination(
                icon: const Icon(Icons.devices),
                label: AppLocalizations.of(context).pushRulesDevice,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
