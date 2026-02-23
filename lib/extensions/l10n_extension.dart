import 'package:flutter/material.dart' as material;

import 'package:carman/localization/app_localizations.dart';

extension LocalizationExtension on material.BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
