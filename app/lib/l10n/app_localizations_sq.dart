// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Albanian (`sq`).
class AppLocalizationsSq extends AppLocalizations {
  AppLocalizationsSq([String locale = 'sq']) : super(locale);

  @override
  String get appTitle => 'Bota e Pipit';

  @override
  String get helloPip => 'Përshëndetje, Pip!';

  @override
  String get worldAnimals => 'Kafshët';

  @override
  String get worldNumbers => 'Numrat';

  @override
  String get worldLetters => 'Shkronjat';

  @override
  String get worldShapesColours => 'Format dhe Ngjyrat';

  @override
  String get worldBoardGames => 'Lojëra Tavoline';

  @override
  String get worldPipsHouse => 'Shtëpia e Pipit';

  @override
  String get hearAgain => 'Dëgjo përsëri';

  @override
  String get back => 'Prapa';

  @override
  String levelNumber(int number) {
    return 'Niveli $number';
  }

  @override
  String levelGames(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count lojëra', one: '1 lojë');
    return '$_temp0';
  }

  @override
  String get comingSoon => 'Pipi po e përgatit ende këtë botë.';

  @override
  String get offscreenWalkLikePenguin => 'Ec si pinguin dhe tregoja një të rrituri!';

  @override
  String get gateTitle => 'Për të rriturit';

  @override
  String get gateInstruction => 'Shkruaj këtë numër me butonat:';

  @override
  String get gateTryAgain => 'Jo tamam. Ja një numër i ri.';

  @override
  String get gateDelete => 'Fshi';

  @override
  String get gateCancel => 'Anulo';

  @override
  String get debugMenu => 'Cilësimet';

  @override
  String get debugLanguage => 'Gjuha';

  @override
  String get debugAgeBand => 'Mosha';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageAlbanian => 'Shqip';
}
