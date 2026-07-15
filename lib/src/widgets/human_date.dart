import 'package:flutter/widgets.dart';

import 'package:intl/intl.dart';

import '../../l10n/generated/app_localizations.dart';

extension HumanDate on DateTime {
  String humanShortDate({
    required BuildContext context,
    bool fullLength = false,
  }) {
    final localizations = AppLocalizations.of(context);
    final locale = localizations.localeName;
    final now = DateTime.now();
    final localDate = toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(localDate.year, localDate.month, localDate.day);
    final daysAgo = today.difference(eventDay).inDays;
    final time = DateFormat.jm(locale).format(localDate);

    if (daysAgo <= 0) return time;
    if (daysAgo == 1) return '${localizations.yesterday}, $time';
    if (daysAgo < 7) {
      final weekday = DateFormat(
        fullLength ? DateFormat.WEEKDAY : DateFormat.ABBR_WEEKDAY,
        locale,
      ).format(localDate);
      return '$weekday, $time';
    }

    final date = DateFormat(
      fullLength ? 'EEEE, d MMMM y' : 'EEE, d MMM y',
      locale,
    ).format(localDate);
    return '$date, $time';
  }
}
