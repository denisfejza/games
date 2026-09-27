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

  /// No description provided for @vocabCow.
  ///
  /// In en, this message translates to:
  /// **'Cow'**
  String get vocabCow;

  /// No description provided for @vocabSheep.
  ///
  /// In en, this message translates to:
  /// **'Sheep'**
  String get vocabSheep;

  /// No description provided for @vocabPig.
  ///
  /// In en, this message translates to:
  /// **'Pig'**
  String get vocabPig;

  /// No description provided for @vocabHen.
  ///
  /// In en, this message translates to:
  /// **'Hen'**
  String get vocabHen;

  /// No description provided for @vocabHorse.
  ///
  /// In en, this message translates to:
  /// **'Horse'**
  String get vocabHorse;

  /// No description provided for @vocabDuck.
  ///
  /// In en, this message translates to:
  /// **'Duck'**
  String get vocabDuck;

  /// No description provided for @vocabGoat.
  ///
  /// In en, this message translates to:
  /// **'Goat'**
  String get vocabGoat;

  /// No description provided for @vocabRooster.
  ///
  /// In en, this message translates to:
  /// **'Rooster'**
  String get vocabRooster;

  /// No description provided for @vocabDog.
  ///
  /// In en, this message translates to:
  /// **'Dog'**
  String get vocabDog;

  /// No description provided for @vocabCat.
  ///
  /// In en, this message translates to:
  /// **'Cat'**
  String get vocabCat;

  /// No description provided for @vocabRabbit.
  ///
  /// In en, this message translates to:
  /// **'Rabbit'**
  String get vocabRabbit;

  /// No description provided for @vocabFish.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get vocabFish;

  /// No description provided for @vocabParrot.
  ///
  /// In en, this message translates to:
  /// **'Parrot'**
  String get vocabParrot;

  /// No description provided for @vocabHamster.
  ///
  /// In en, this message translates to:
  /// **'Hamster'**
  String get vocabHamster;

  /// No description provided for @vocabTurtle.
  ///
  /// In en, this message translates to:
  /// **'Turtle'**
  String get vocabTurtle;

  /// No description provided for @vocabMouse.
  ///
  /// In en, this message translates to:
  /// **'Mouse'**
  String get vocabMouse;

  /// No description provided for @vocabLion.
  ///
  /// In en, this message translates to:
  /// **'Lion'**
  String get vocabLion;

  /// No description provided for @vocabElephant.
  ///
  /// In en, this message translates to:
  /// **'Elephant'**
  String get vocabElephant;

  /// No description provided for @vocabMonkey.
  ///
  /// In en, this message translates to:
  /// **'Monkey'**
  String get vocabMonkey;

  /// No description provided for @vocabGiraffe.
  ///
  /// In en, this message translates to:
  /// **'Giraffe'**
  String get vocabGiraffe;

  /// No description provided for @vocabZebra.
  ///
  /// In en, this message translates to:
  /// **'Zebra'**
  String get vocabZebra;

  /// No description provided for @vocabTiger.
  ///
  /// In en, this message translates to:
  /// **'Tiger'**
  String get vocabTiger;

  /// No description provided for @vocabSnake.
  ///
  /// In en, this message translates to:
  /// **'Snake'**
  String get vocabSnake;

  /// No description provided for @vocabCrocodile.
  ///
  /// In en, this message translates to:
  /// **'Crocodile'**
  String get vocabCrocodile;

  /// No description provided for @vocabWhale.
  ///
  /// In en, this message translates to:
  /// **'Whale'**
  String get vocabWhale;

  /// No description provided for @vocabDolphin.
  ///
  /// In en, this message translates to:
  /// **'Dolphin'**
  String get vocabDolphin;

  /// No description provided for @vocabOctopus.
  ///
  /// In en, this message translates to:
  /// **'Octopus'**
  String get vocabOctopus;

  /// No description provided for @vocabCrab.
  ///
  /// In en, this message translates to:
  /// **'Crab'**
  String get vocabCrab;

  /// No description provided for @vocabShark.
  ///
  /// In en, this message translates to:
  /// **'Shark'**
  String get vocabShark;

  /// No description provided for @vocabPenguin.
  ///
  /// In en, this message translates to:
  /// **'Penguin'**
  String get vocabPenguin;

  /// No description provided for @vocabSeal.
  ///
  /// In en, this message translates to:
  /// **'Seal'**
  String get vocabSeal;

  /// No description provided for @vocabFox.
  ///
  /// In en, this message translates to:
  /// **'Fox'**
  String get vocabFox;

  /// No description provided for @vocabOwl.
  ///
  /// In en, this message translates to:
  /// **'Owl'**
  String get vocabOwl;

  /// No description provided for @vocabBear.
  ///
  /// In en, this message translates to:
  /// **'Bear'**
  String get vocabBear;

  /// No description provided for @vocabBee.
  ///
  /// In en, this message translates to:
  /// **'Bee'**
  String get vocabBee;

  /// No description provided for @vocabFrog.
  ///
  /// In en, this message translates to:
  /// **'Frog'**
  String get vocabFrog;

  /// No description provided for @vocabToad.
  ///
  /// In en, this message translates to:
  /// **'Toad'**
  String get vocabToad;

  /// No description provided for @vocabBird.
  ///
  /// In en, this message translates to:
  /// **'Bird'**
  String get vocabBird;

  /// No description provided for @vocabButterfly.
  ///
  /// In en, this message translates to:
  /// **'Butterfly'**
  String get vocabButterfly;

  /// No description provided for @vocabAnt.
  ///
  /// In en, this message translates to:
  /// **'Ant'**
  String get vocabAnt;

  /// No description provided for @vocabSnail.
  ///
  /// In en, this message translates to:
  /// **'Snail'**
  String get vocabSnail;

  /// No description provided for @vocabLadybird.
  ///
  /// In en, this message translates to:
  /// **'Insect'**
  String get vocabLadybird;

  /// No description provided for @vocabBoar.
  ///
  /// In en, this message translates to:
  /// **'Boar'**
  String get vocabBoar;

  /// No description provided for @vocabKangaroo.
  ///
  /// In en, this message translates to:
  /// **'Kangaroo'**
  String get vocabKangaroo;

  /// No description provided for @vocabPanda.
  ///
  /// In en, this message translates to:
  /// **'Panda'**
  String get vocabPanda;

  /// No description provided for @vocabGrass.
  ///
  /// In en, this message translates to:
  /// **'Grass'**
  String get vocabGrass;

  /// No description provided for @vocabCarrot.
  ///
  /// In en, this message translates to:
  /// **'Carrot'**
  String get vocabCarrot;

  /// No description provided for @vocabBanana.
  ///
  /// In en, this message translates to:
  /// **'Banana'**
  String get vocabBanana;

  /// No description provided for @vocabBone.
  ///
  /// In en, this message translates to:
  /// **'Bone'**
  String get vocabBone;

  /// No description provided for @vocabMilk.
  ///
  /// In en, this message translates to:
  /// **'Milk'**
  String get vocabMilk;

  /// No description provided for @vocabApple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get vocabApple;

  /// No description provided for @vocabCheese.
  ///
  /// In en, this message translates to:
  /// **'Cheese'**
  String get vocabCheese;

  /// No description provided for @vocabCorn.
  ///
  /// In en, this message translates to:
  /// **'Corn'**
  String get vocabCorn;

  /// No description provided for @vocabHoney.
  ///
  /// In en, this message translates to:
  /// **'Honey'**
  String get vocabHoney;

  /// No description provided for @vocabLeaf.
  ///
  /// In en, this message translates to:
  /// **'Leaf'**
  String get vocabLeaf;

  /// No description provided for @vocabGrapes.
  ///
  /// In en, this message translates to:
  /// **'Grapes'**
  String get vocabGrapes;

  /// No description provided for @vocabOrangeFruit.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get vocabOrangeFruit;

  /// No description provided for @vocabStrawberry.
  ///
  /// In en, this message translates to:
  /// **'Strawberry'**
  String get vocabStrawberry;

  /// No description provided for @vocabPear.
  ///
  /// In en, this message translates to:
  /// **'Pear'**
  String get vocabPear;

  /// No description provided for @vocabBread.
  ///
  /// In en, this message translates to:
  /// **'Bread'**
  String get vocabBread;

  /// No description provided for @vocabEgg.
  ///
  /// In en, this message translates to:
  /// **'Egg'**
  String get vocabEgg;

  /// No description provided for @vocabWatermelon.
  ///
  /// In en, this message translates to:
  /// **'Watermelon'**
  String get vocabWatermelon;

  /// No description provided for @vocabCherry.
  ///
  /// In en, this message translates to:
  /// **'Cherry'**
  String get vocabCherry;

  /// No description provided for @vocabCake.
  ///
  /// In en, this message translates to:
  /// **'Cake'**
  String get vocabCake;

  /// No description provided for @vocabPizza.
  ///
  /// In en, this message translates to:
  /// **'Pizza'**
  String get vocabPizza;

  /// No description provided for @vocabSun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get vocabSun;

  /// No description provided for @vocabMoon.
  ///
  /// In en, this message translates to:
  /// **'Moon'**
  String get vocabMoon;

  /// No description provided for @vocabStarObj.
  ///
  /// In en, this message translates to:
  /// **'Star'**
  String get vocabStarObj;

  /// No description provided for @vocabRain.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get vocabRain;

  /// No description provided for @vocabRainbow.
  ///
  /// In en, this message translates to:
  /// **'Rainbow'**
  String get vocabRainbow;

  /// No description provided for @vocabFlower.
  ///
  /// In en, this message translates to:
  /// **'Flower'**
  String get vocabFlower;

  /// No description provided for @vocabTree.
  ///
  /// In en, this message translates to:
  /// **'Tree'**
  String get vocabTree;

  /// No description provided for @vocabBall.
  ///
  /// In en, this message translates to:
  /// **'Ball'**
  String get vocabBall;

  /// No description provided for @vocabBalloon.
  ///
  /// In en, this message translates to:
  /// **'Balloon'**
  String get vocabBalloon;

  /// No description provided for @vocabGift.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get vocabGift;

  /// No description provided for @vocabBook.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get vocabBook;

  /// No description provided for @vocabKey.
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get vocabKey;

  /// No description provided for @vocabHouse.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get vocabHouse;

  /// No description provided for @vocabTent.
  ///
  /// In en, this message translates to:
  /// **'Tent'**
  String get vocabTent;

  /// No description provided for @vocabBed.
  ///
  /// In en, this message translates to:
  /// **'Bed'**
  String get vocabBed;

  /// No description provided for @vocabCup.
  ///
  /// In en, this message translates to:
  /// **'Cup'**
  String get vocabCup;

  /// No description provided for @vocabClock.
  ///
  /// In en, this message translates to:
  /// **'Clock'**
  String get vocabClock;

  /// No description provided for @vocabHeartObj.
  ///
  /// In en, this message translates to:
  /// **'Heart'**
  String get vocabHeartObj;

  /// No description provided for @vocabCar.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get vocabCar;

  /// No description provided for @vocabBus.
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get vocabBus;

  /// No description provided for @vocabTrain.
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get vocabTrain;

  /// No description provided for @vocabPlane.
  ///
  /// In en, this message translates to:
  /// **'Plane'**
  String get vocabPlane;

  /// No description provided for @vocabBoat.
  ///
  /// In en, this message translates to:
  /// **'Boat'**
  String get vocabBoat;

  /// No description provided for @vocabBike.
  ///
  /// In en, this message translates to:
  /// **'Bike'**
  String get vocabBike;

  /// No description provided for @vocabUmbrella.
  ///
  /// In en, this message translates to:
  /// **'Umbrella'**
  String get vocabUmbrella;

  /// No description provided for @vocabHat.
  ///
  /// In en, this message translates to:
  /// **'Hat'**
  String get vocabHat;

  /// No description provided for @vocabSocks.
  ///
  /// In en, this message translates to:
  /// **'Socks'**
  String get vocabSocks;

  /// No description provided for @vocabJacket.
  ///
  /// In en, this message translates to:
  /// **'Jacket'**
  String get vocabJacket;

  /// No description provided for @vocabHand.
  ///
  /// In en, this message translates to:
  /// **'Hand'**
  String get vocabHand;

  /// No description provided for @vocabNose.
  ///
  /// In en, this message translates to:
  /// **'Nose'**
  String get vocabNose;

  /// No description provided for @vocabEar.
  ///
  /// In en, this message translates to:
  /// **'Ear'**
  String get vocabEar;

  /// No description provided for @vocabMouth.
  ///
  /// In en, this message translates to:
  /// **'Mouth'**
  String get vocabMouth;

  /// No description provided for @vocabFoot.
  ///
  /// In en, this message translates to:
  /// **'Foot'**
  String get vocabFoot;

  /// No description provided for @vocabNest.
  ///
  /// In en, this message translates to:
  /// **'Nest'**
  String get vocabNest;

  /// No description provided for @vocabCircus.
  ///
  /// In en, this message translates to:
  /// **'Circus'**
  String get vocabCircus;

  /// No description provided for @colourRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get colourRed;

  /// No description provided for @colourBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get colourBlue;

  /// No description provided for @colourYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get colourYellow;

  /// No description provided for @colourGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colourGreen;

  /// No description provided for @colourOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get colourOrange;

  /// No description provided for @colourPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get colourPurple;

  /// No description provided for @colourPink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get colourPink;

  /// No description provided for @colourBrown.
  ///
  /// In en, this message translates to:
  /// **'Brown'**
  String get colourBrown;

  /// No description provided for @colourBlack.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get colourBlack;

  /// No description provided for @colourWhite.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get colourWhite;

  /// No description provided for @shapeCircle.
  ///
  /// In en, this message translates to:
  /// **'Circle'**
  String get shapeCircle;

  /// No description provided for @shapeSquare.
  ///
  /// In en, this message translates to:
  /// **'Square'**
  String get shapeSquare;

  /// No description provided for @shapeTriangle.
  ///
  /// In en, this message translates to:
  /// **'Triangle'**
  String get shapeTriangle;

  /// No description provided for @shapeRectangle.
  ///
  /// In en, this message translates to:
  /// **'Rectangle'**
  String get shapeRectangle;

  /// No description provided for @shapeStar.
  ///
  /// In en, this message translates to:
  /// **'Star'**
  String get shapeStar;

  /// No description provided for @shapeHeart.
  ///
  /// In en, this message translates to:
  /// **'Heart'**
  String get shapeHeart;

  /// No description provided for @shapeOval.
  ///
  /// In en, this message translates to:
  /// **'Oval'**
  String get shapeOval;

  /// No description provided for @shapeDiamond.
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get shapeDiamond;
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
