// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pip\'s World';

  @override
  String get helloPip => 'Hello, Pip!';

  @override
  String get worldAnimals => 'Animals';

  @override
  String get worldNumbers => 'Numbers';

  @override
  String get worldLetters => 'Letters';

  @override
  String get worldShapesColours => 'Shapes & Colours';

  @override
  String get worldBoardGames => 'Board Games';

  @override
  String get worldPipsHouse => 'Pip\'s House';

  @override
  String get hearAgain => 'Hear again';

  @override
  String get back => 'Back';

  @override
  String levelNumber(int number) {
    return 'Level $number';
  }

  @override
  String levelGames(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count games', one: '1 game');
    return '$_temp0';
  }

  @override
  String get comingSoon => 'Pip is still getting this world ready.';

  @override
  String get offscreenWalkLikePenguin => 'Waddle like a penguin and show a grown-up!';

  @override
  String get gateTitle => 'For grown-ups';

  @override
  String get gateInstruction => 'Type this number using the keys:';

  @override
  String get gateTryAgain => 'Not quite. Here is a new number.';

  @override
  String get gateDelete => 'Delete';

  @override
  String get gateCancel => 'Cancel';

  @override
  String get debugMenu => 'Settings';

  @override
  String get debugLanguage => 'Language';

  @override
  String get debugAgeBand => 'Age band';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageAlbanian => 'Shqip';
}
