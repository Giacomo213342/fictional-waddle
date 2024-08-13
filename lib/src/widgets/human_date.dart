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
    final today = now.copyWith(
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );
    if (isAfter(today)) {
      return DateFormat(DateFormat.HOUR_MINUTE, locale).format(this);
    }
    final yesterday = today.subtract(const Duration(days: 1));
    if (isAfter(yesterday)) {
      return localizations.yesterday;
    }
    final week = today.subtract(const Duration(days: 7));
    if (isAfter(week)) {
      return DateFormat(
        fullLength ? DateFormat.WEEKDAY : DateFormat.ABBR_WEEKDAY,
        locale,
      ).format(this);
    }
    final thisMonth = now.copyWith(
      day: 1,
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );

    if (isAfter(thisMonth)) {
      return localizations.thisMonth;
    }
    final lastMonth = now.copyWith(
      month: today.month - 1,
      day: 1,
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );

    if (isAfter(lastMonth)) {
      return localizations.lastMonth;
    }
    final year = today.copyWith(
      month: 1,
      day: 0,
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );
    if (isAfter(year)) {
      return DateFormat(DateFormat.MONTH, locale).format(this);
    }
    return DateFormat(
      fullLength ? DateFormat.YEAR_MONTH : DateFormat.YEAR_ABBR_MONTH,
      locale,
    ).format(this);
  }
}
