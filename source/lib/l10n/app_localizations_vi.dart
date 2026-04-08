// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get navHome => 'Sổ giao dịch';

  @override
  String get navSettings => 'Cài đặt';

  @override
  String get fabAddTransaction => 'Giao dịch mới';

  @override
  String get settingsLanguage => 'Ngôn ngữ';

  @override
  String get settingsCategories => 'Quản lý thể loại';
}
