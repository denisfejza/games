import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sq.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('sq')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Pip\'s World'**
  String get appTitle;

  /// Greeting on the map screen; also the narration key.
  ///
  /// In en, this message translates to:
  /// **'Hello, Pip!'**
  String get helloPip;

  /// No description provided for @worldAnimals.
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get worldAnimals;

  /// No description provided for @worldNumbers.
  ///
  /// In en, this message translates to:
  /// **'Numbers'**
  String get worldNumbers;

  /// No description provided for @worldLetters.
  ///
  /// In en, this message translates to:
  /// **'Letters'**
  String get worldLetters;

  /// No description provided for @worldShapesColours.
  ///
  /// In en, this message translates to:
  /// **'Shapes & Colours'**
  String get worldShapesColours;

  /// No description provided for @worldBoardGames.
  ///
  /// In en, this message translates to:
  /// **'Board Games'**
  String get worldBoardGames;

  /// No description provided for @worldPipsHouse.
  ///
  /// In en, this message translates to:
  /// **'Pip\'s House'**
  String get worldPipsHouse;

  /// No description provided for @hearAgain.
  ///
  /// In en, this message translates to:
  /// **'Hear again'**
  String get hearAgain;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @levelNumber.
  ///
  /// In en, this message translates to:
  /// **'Level {number}'**
  String levelNumber(int number);

  /// No description provided for @levelGames.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 game} other{{count} games}}'**
  String levelGames(int count);

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Pip is still getting this world ready.'**
  String get comingSoon;

  /// No description provided for @offscreenWalkLikePenguin.
  ///
  /// In en, this message translates to:
  /// **'Waddle like a penguin and show a grown-up!'**
  String get offscreenWalkLikePenguin;

  /// No description provided for @gateTitle.
  ///
  /// In en, this message translates to:
  /// **'For grown-ups'**
  String get gateTitle;

  /// No description provided for @gateInstruction.
  ///
  /// In en, this message translates to:
  /// **'Type this number using the keys:'**
  String get gateInstruction;

  /// No description provided for @gateTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Not quite. Here is a new number.'**
  String get gateTryAgain;

  /// No description provided for @gateDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get gateDelete;

  /// No description provided for @gateCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get gateCancel;

  /// No description provided for @debugMenu.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get debugMenu;

  /// No description provided for @debugLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get debugLanguage;

  /// No description provided for @debugAgeBand.
  ///
  /// In en, this message translates to:
  /// **'Age band'**
  String get debugAgeBand;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageAlbanian.
  ///
  /// In en, this message translates to:
  /// **'Shqip'**
  String get languageAlbanian;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'sq'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sq':
      return AppLocalizationsSq();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
