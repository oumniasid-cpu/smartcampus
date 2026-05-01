import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

export '../../l10n/app_localizations.dart';
export 'package:flutter_localizations/flutter_localizations.dart';

extension AppLocalizationsDirection on AppLocalizations {
  TextDirection get textDirection {
    return localeName == 'ar' ? TextDirection.rtl : TextDirection.ltr;
  }
}
