import 'package:flutter/material.dart';

import '../../utils/about_dialog.dart';
import '../../widgets/matrix/matrix_scope.dart';
import '../../widgets/settings_manager.dart';
import 'application_settings_view.dart';
import 'components/language_dialog.dart';

class ApplicationSettingsPage extends StatefulWidget {
  const ApplicationSettingsPage({super.key});

  static const routeName = '/settings';

  static Uri makeSettingsUri(String routeName) {
    return Uri.parse('${ApplicationSettingsPage.routeName}/$routeName');
  }

  @override
  State<ApplicationSettingsPage> createState() =>
      ApplicationSettingsController();
}

class ApplicationSettingsController extends State<ApplicationSettingsPage> {
  @override
  Widget build(BuildContext context) =>
      ApplicationSettingsView(controller: this);

  Future<void> showLanguageDialog() async {
    final scope = MatrixScope.captureAll(context);
    final result = await showAdaptiveDialog<LocaleResponse>(
      context: context,
      builder: (context) => MatrixScope(
        scope: scope,
        child: const LanguageDialog(),
      ),
    );
    if (result == null || !mounted) {
      return;
    }

    SettingsManager.of(context).locale.value = result.locale;
  }

  void showAboutDialog() => showInfoDialog(context);
}
