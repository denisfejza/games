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

  /// No description provided for @parentTitle.
  ///
  /// In en, this message translates to:
  /// **'For grown-ups'**
  String get parentTitle;

  /// No description provided for @parentLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get parentLanguage;

  /// No description provided for @parentAgeBand.
  ///
  /// In en, this message translates to:
  /// **'Age band'**
  String get parentAgeBand;

  /// No description provided for @pipBelly.
  ///
  /// In en, this message translates to:
  /// **'Belly'**
  String get pipBelly;

  /// No description provided for @pipTickle.
  ///
  /// In en, this message translates to:
  /// **'Hee hee! That tickles!'**
  String get pipTickle;

  /// No description provided for @pipYum.
  ///
  /// In en, this message translates to:
  /// **'Mmm! Thank you!'**
  String get pipYum;

  /// No description provided for @pipHmm.
  ///
  /// In en, this message translates to:
  /// **'Hmm, let\'s look again.'**
  String get pipHmm;

  /// No description provided for @episodeIntro.
  ///
  /// In en, this message translates to:
  /// **'Let\'s play together!'**
  String get episodeIntro;

  /// No description provided for @companionClap.
  ///
  /// In en, this message translates to:
  /// **'Clap with Pip!'**
  String get companionClap;

  /// No description provided for @companionThanks.
  ///
  /// In en, this message translates to:
  /// **'Yay! You\'re a great friend.'**
  String get companionThanks;

  /// No description provided for @offscreenIntro.
  ///
  /// In en, this message translates to:
  /// **'Now a game away from the screen!'**
  String get offscreenIntro;

  /// No description provided for @offscreenDone.
  ///
  /// In en, this message translates to:
  /// **'We did it!'**
  String get offscreenDone;

  /// No description provided for @episodeDone.
  ///
  /// In en, this message translates to:
  /// **'All done! You played so well.'**
  String get episodeDone;

  /// No description provided for @levelNotYet.
  ///
  /// In en, this message translates to:
  /// **'Let\'s play this one first!'**
  String get levelNotYet;

  /// No description provided for @bedtimePipSleepy.
  ///
  /// In en, this message translates to:
  /// **'Pip is getting sleepy. Time to rest!'**
  String get bedtimePipSleepy;

  /// No description provided for @bedtimeAllDone.
  ///
  /// In en, this message translates to:
  /// **'All done for today'**
  String get bedtimeAllDone;

  /// No description provided for @talkBackPrompt.
  ///
  /// In en, this message translates to:
  /// **'Say something to Pip!'**
  String get talkBackPrompt;

  /// No description provided for @parentExtraTime.
  ///
  /// In en, this message translates to:
  /// **'+{minutes} minutes today'**
  String parentExtraTime(int minutes);

  /// No description provided for @parentDailyLimit.
  ///
  /// In en, this message translates to:
  /// **'Daily play time'**
  String get parentDailyLimit;

  /// No description provided for @parentLimitOff.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get parentLimitOff;

  /// No description provided for @parentMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String parentMinutes(int minutes);

  /// No description provided for @parentPlayedToday.
  ///
  /// In en, this message translates to:
  /// **'Played today: {minutes} min'**
  String parentPlayedToday(int minutes);

  /// No description provided for @parentSound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get parentSound;

  /// No description provided for @parentCaptions.
  ///
  /// In en, this message translates to:
  /// **'Captions'**
  String get parentCaptions;

  /// No description provided for @parentReducedMotion.
  ///
  /// In en, this message translates to:
  /// **'Less motion'**
  String get parentReducedMotion;

  /// No description provided for @parentMicrophone.
  ///
  /// In en, this message translates to:
  /// **'Microphone (Pip repeats)'**
  String get parentMicrophone;

  /// No description provided for @parentMicHelp.
  ///
  /// In en, this message translates to:
  /// **'Pip repeats what your child says in a funny voice. The sound is never saved or sent anywhere.'**
  String get parentMicHelp;

  /// No description provided for @parentMicUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Not available on this device yet.'**
  String get parentMicUnavailable;

  /// No description provided for @parentMicDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission was not given. You can change it in the device settings.'**
  String get parentMicDenied;

  /// No description provided for @parentPipDemo.
  ///
  /// In en, this message translates to:
  /// **'Pip demo (for testing)'**
  String get parentPipDemo;

  /// No description provided for @praiseGreat.
  ///
  /// In en, this message translates to:
  /// **'Great job!'**
  String get praiseGreat;

  /// No description provided for @praiseWellDone.
  ///
  /// In en, this message translates to:
  /// **'Well done!'**
  String get praiseWellDone;

  /// No description provided for @praiseYouDidIt.
  ///
  /// In en, this message translates to:
  /// **'You did it!'**
  String get praiseYouDidIt;

  /// No description provided for @praiseSuper.
  ///
  /// In en, this message translates to:
  /// **'Super!'**
  String get praiseSuper;

  /// No description provided for @vocabHabitatFarm.
  ///
  /// In en, this message translates to:
  /// **'Farm'**
  String get vocabHabitatFarm;

  /// No description provided for @vocabHabitatHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get vocabHabitatHome;

  /// No description provided for @vocabHabitatJungle.
  ///
  /// In en, this message translates to:
  /// **'Jungle'**
  String get vocabHabitatJungle;

  /// No description provided for @vocabHabitatSea.
  ///
  /// In en, this message translates to:
  /// **'Sea'**
  String get vocabHabitatSea;

  /// No description provided for @vocabHabitatSnow.
  ///
  /// In en, this message translates to:
  /// **'Snow'**
  String get vocabHabitatSnow;

  /// No description provided for @vocabHabitatGarden.
  ///
  /// In en, this message translates to:
  /// **'Garden'**
  String get vocabHabitatGarden;

  /// No description provided for @vocabHabitatForest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get vocabHabitatForest;

  /// No description provided for @num0.
  ///
  /// In en, this message translates to:
  /// **'zero'**
  String get num0;

  /// No description provided for @num1.
  ///
  /// In en, this message translates to:
  /// **'one'**
  String get num1;

  /// No description provided for @num2.
  ///
  /// In en, this message translates to:
  /// **'two'**
  String get num2;

  /// No description provided for @num3.
  ///
  /// In en, this message translates to:
  /// **'three'**
  String get num3;

  /// No description provided for @num4.
  ///
  /// In en, this message translates to:
  /// **'four'**
  String get num4;

  /// No description provided for @num5.
  ///
  /// In en, this message translates to:
  /// **'five'**
  String get num5;

  /// No description provided for @num6.
  ///
  /// In en, this message translates to:
  /// **'six'**
  String get num6;

  /// No description provided for @num7.
  ///
  /// In en, this message translates to:
  /// **'seven'**
  String get num7;

  /// No description provided for @num8.
  ///
  /// In en, this message translates to:
  /// **'eight'**
  String get num8;

  /// No description provided for @num9.
  ///
  /// In en, this message translates to:
  /// **'nine'**
  String get num9;

  /// No description provided for @num10.
  ///
  /// In en, this message translates to:
  /// **'ten'**
  String get num10;

  /// No description provided for @num11.
  ///
  /// In en, this message translates to:
  /// **'eleven'**
  String get num11;

  /// No description provided for @num12.
  ///
  /// In en, this message translates to:
  /// **'twelve'**
  String get num12;

  /// No description provided for @num13.
  ///
  /// In en, this message translates to:
  /// **'thirteen'**
  String get num13;

  /// No description provided for @num14.
  ///
  /// In en, this message translates to:
  /// **'fourteen'**
  String get num14;

  /// No description provided for @num15.
  ///
  /// In en, this message translates to:
  /// **'fifteen'**
  String get num15;

  /// No description provided for @num16.
  ///
  /// In en, this message translates to:
  /// **'sixteen'**
  String get num16;

  /// No description provided for @num17.
  ///
  /// In en, this message translates to:
  /// **'seventeen'**
  String get num17;

  /// No description provided for @num18.
  ///
  /// In en, this message translates to:
  /// **'eighteen'**
  String get num18;

  /// No description provided for @num19.
  ///
  /// In en, this message translates to:
  /// **'nineteen'**
  String get num19;

  /// No description provided for @num20.
  ///
  /// In en, this message translates to:
  /// **'twenty'**
  String get num20;

  /// No description provided for @letterEnA.
  ///
  /// In en, this message translates to:
  /// **'a'**
  String get letterEnA;

  /// No description provided for @letterEnB.
  ///
  /// In en, this message translates to:
  /// **'b'**
  String get letterEnB;

  /// No description provided for @letterEnC.
  ///
  /// In en, this message translates to:
  /// **'c'**
  String get letterEnC;

  /// No description provided for @letterEnD.
  ///
  /// In en, this message translates to:
  /// **'d'**
  String get letterEnD;

  /// No description provided for @letterEnE.
  ///
  /// In en, this message translates to:
  /// **'e'**
  String get letterEnE;

  /// No description provided for @letterEnF.
  ///
  /// In en, this message translates to:
  /// **'f'**
  String get letterEnF;

  /// No description provided for @letterEnG.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get letterEnG;

  /// No description provided for @letterEnH.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get letterEnH;

  /// No description provided for @letterEnI.
  ///
  /// In en, this message translates to:
  /// **'i'**
  String get letterEnI;

  /// No description provided for @letterEnJ.
  ///
  /// In en, this message translates to:
  /// **'j'**
  String get letterEnJ;

  /// No description provided for @letterEnK.
  ///
  /// In en, this message translates to:
  /// **'k'**
  String get letterEnK;

  /// No description provided for @letterEnL.
  ///
  /// In en, this message translates to:
  /// **'l'**
  String get letterEnL;

  /// No description provided for @letterEnM.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get letterEnM;

  /// No description provided for @letterEnN.
  ///
  /// In en, this message translates to:
  /// **'n'**
  String get letterEnN;

  /// No description provided for @letterEnO.
  ///
  /// In en, this message translates to:
  /// **'o'**
  String get letterEnO;

  /// No description provided for @letterEnP.
  ///
  /// In en, this message translates to:
  /// **'p'**
  String get letterEnP;

  /// No description provided for @letterEnQ.
  ///
  /// In en, this message translates to:
  /// **'q'**
  String get letterEnQ;

  /// No description provided for @letterEnR.
  ///
  /// In en, this message translates to:
  /// **'r'**
  String get letterEnR;

  /// No description provided for @letterEnS.
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get letterEnS;

  /// No description provided for @letterEnT.
  ///
  /// In en, this message translates to:
  /// **'t'**
  String get letterEnT;

  /// No description provided for @letterEnU.
  ///
  /// In en, this message translates to:
  /// **'u'**
  String get letterEnU;

  /// No description provided for @letterEnV.
  ///
  /// In en, this message translates to:
  /// **'v'**
  String get letterEnV;

  /// No description provided for @letterEnW.
  ///
  /// In en, this message translates to:
  /// **'w'**
  String get letterEnW;

  /// No description provided for @letterEnX.
  ///
  /// In en, this message translates to:
  /// **'x'**
  String get letterEnX;

  /// No description provided for @letterEnY.
  ///
  /// In en, this message translates to:
  /// **'y'**
  String get letterEnY;

  /// No description provided for @letterEnZ.
  ///
  /// In en, this message translates to:
  /// **'z'**
  String get letterEnZ;

  /// No description provided for @letterSqA.
  ///
  /// In en, this message translates to:
  /// **'a'**
  String get letterSqA;

  /// No description provided for @letterSqB.
  ///
  /// In en, this message translates to:
  /// **'b'**
  String get letterSqB;

  /// No description provided for @letterSqC.
  ///
  /// In en, this message translates to:
  /// **'c'**
  String get letterSqC;

  /// No description provided for @letterSqCCedilla.
  ///
  /// In en, this message translates to:
  /// **'ç'**
  String get letterSqCCedilla;

  /// No description provided for @letterSqD.
  ///
  /// In en, this message translates to:
  /// **'d'**
  String get letterSqD;

  /// No description provided for @letterSqDh.
  ///
  /// In en, this message translates to:
  /// **'dh'**
  String get letterSqDh;

  /// No description provided for @letterSqE.
  ///
  /// In en, this message translates to:
  /// **'e'**
  String get letterSqE;

  /// No description provided for @letterSqEDiaeresis.
  ///
  /// In en, this message translates to:
  /// **'ë'**
  String get letterSqEDiaeresis;

  /// No description provided for @letterSqF.
  ///
  /// In en, this message translates to:
  /// **'f'**
  String get letterSqF;

  /// No description provided for @letterSqG.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get letterSqG;

  /// No description provided for @letterSqGj.
  ///
  /// In en, this message translates to:
  /// **'gj'**
  String get letterSqGj;

  /// No description provided for @letterSqH.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get letterSqH;

  /// No description provided for @letterSqI.
  ///
  /// In en, this message translates to:
  /// **'i'**
  String get letterSqI;

  /// No description provided for @letterSqJ.
  ///
  /// In en, this message translates to:
  /// **'j'**
  String get letterSqJ;

  /// No description provided for @letterSqK.
  ///
  /// In en, this message translates to:
  /// **'k'**
  String get letterSqK;

  /// No description provided for @letterSqL.
  ///
  /// In en, this message translates to:
  /// **'l'**
  String get letterSqL;

  /// No description provided for @letterSqLl.
  ///
  /// In en, this message translates to:
  /// **'ll'**
  String get letterSqLl;

  /// No description provided for @letterSqM.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get letterSqM;

  /// No description provided for @letterSqN.
  ///
  /// In en, this message translates to:
  /// **'n'**
  String get letterSqN;

  /// No description provided for @letterSqNj.
  ///
  /// In en, this message translates to:
  /// **'nj'**
  String get letterSqNj;

  /// No description provided for @letterSqO.
  ///
  /// In en, this message translates to:
  /// **'o'**
  String get letterSqO;

  /// No description provided for @letterSqP.
  ///
  /// In en, this message translates to:
  /// **'p'**
  String get letterSqP;

  /// No description provided for @letterSqQ.
  ///
  /// In en, this message translates to:
  /// **'q'**
  String get letterSqQ;

  /// No description provided for @letterSqR.
  ///
  /// In en, this message translates to:
  /// **'r'**
  String get letterSqR;

  /// No description provided for @letterSqRr.
  ///
  /// In en, this message translates to:
  /// **'rr'**
  String get letterSqRr;

  /// No description provided for @letterSqS.
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get letterSqS;

  /// No description provided for @letterSqSh.
  ///
  /// In en, this message translates to:
  /// **'sh'**
  String get letterSqSh;

  /// No description provided for @letterSqT.
  ///
  /// In en, this message translates to:
  /// **'t'**
  String get letterSqT;

  /// No description provided for @letterSqTh.
  ///
  /// In en, this message translates to:
  /// **'th'**
  String get letterSqTh;

  /// No description provided for @letterSqU.
  ///
  /// In en, this message translates to:
  /// **'u'**
  String get letterSqU;

  /// No description provided for @letterSqV.
  ///
  /// In en, this message translates to:
  /// **'v'**
  String get letterSqV;

  /// No description provided for @letterSqX.
  ///
  /// In en, this message translates to:
  /// **'x'**
  String get letterSqX;

  /// No description provided for @letterSqXh.
  ///
  /// In en, this message translates to:
  /// **'xh'**
  String get letterSqXh;

  /// No description provided for @letterSqY.
  ///
  /// In en, this message translates to:
  /// **'y'**
  String get letterSqY;

  /// No description provided for @letterSqZ.
  ///
  /// In en, this message translates to:
  /// **'z'**
  String get letterSqZ;

  /// No description provided for @letterSqZh.
  ///
  /// In en, this message translates to:
  /// **'zh'**
  String get letterSqZh;

  /// No description provided for @gameFindThis.
  ///
  /// In en, this message translates to:
  /// **'Find this one!'**
  String get gameFindThis;

  /// No description provided for @gameWhoSays.
  ///
  /// In en, this message translates to:
  /// **'Who makes this sound?'**
  String get gameWhoSays;

  /// No description provided for @gameFindNumber.
  ///
  /// In en, this message translates to:
  /// **'Find the number!'**
  String get gameFindNumber;

  /// No description provided for @gameHowMany.
  ///
  /// In en, this message translates to:
  /// **'How many?'**
  String get gameHowMany;

  /// No description provided for @gameWhichMore.
  ///
  /// In en, this message translates to:
  /// **'Which has more?'**
  String get gameWhichMore;

  /// No description provided for @gameWhichFewer.
  ///
  /// In en, this message translates to:
  /// **'Which has fewer?'**
  String get gameWhichFewer;

  /// No description provided for @gameStartsWith.
  ///
  /// In en, this message translates to:
  /// **'What starts with this sound?'**
  String get gameStartsWith;

  /// No description provided for @gameFindLetter.
  ///
  /// In en, this message translates to:
  /// **'Find the letter!'**
  String get gameFindLetter;

  /// No description provided for @gameFindColour.
  ///
  /// In en, this message translates to:
  /// **'Find the colour!'**
  String get gameFindColour;

  /// No description provided for @gameFindShape.
  ///
  /// In en, this message translates to:
  /// **'Find the shape!'**
  String get gameFindShape;

  /// No description provided for @gameFeed.
  ///
  /// In en, this message translates to:
  /// **'Give the food to the right animal!'**
  String get gameFeed;

  /// No description provided for @gameWhereLives.
  ///
  /// In en, this message translates to:
  /// **'Where does it live?'**
  String get gameWhereLives;

  /// No description provided for @gameFindMummy.
  ///
  /// In en, this message translates to:
  /// **'Help the baby find its mummy!'**
  String get gameFindMummy;

  /// No description provided for @gameShapeHole.
  ///
  /// In en, this message translates to:
  /// **'Put the shape in its hole!'**
  String get gameShapeHole;

  /// No description provided for @gameCountTap.
  ///
  /// In en, this message translates to:
  /// **'Tap each one and count!'**
  String get gameCountTap;

  /// No description provided for @praiseCountedAll.
  ///
  /// In en, this message translates to:
  /// **'You counted every one!'**
  String get praiseCountedAll;

  /// No description provided for @gameTrace.
  ///
  /// In en, this message translates to:
  /// **'Trace it with your finger!'**
  String get gameTrace;

  /// No description provided for @praiseTraced.
  ///
  /// In en, this message translates to:
  /// **'Beautiful tracing!'**
  String get praiseTraced;

  /// No description provided for @gameFindPairs.
  ///
  /// In en, this message translates to:
  /// **'Find the pairs!'**
  String get gameFindPairs;

  /// No description provided for @praisePair.
  ///
  /// In en, this message translates to:
  /// **'A pair!'**
  String get praisePair;

  /// No description provided for @gameWhatNext.
  ///
  /// In en, this message translates to:
  /// **'What comes next?'**
  String get gameWhatNext;

  /// No description provided for @gameSortBins.
  ///
  /// In en, this message translates to:
  /// **'Put each one in the right place!'**
  String get gameSortBins;

  /// No description provided for @gameBuildWord.
  ///
  /// In en, this message translates to:
  /// **'Put the sounds together!'**
  String get gameBuildWord;

  /// No description provided for @gameBondTo5.
  ///
  /// In en, this message translates to:
  /// **'How many more to make five?'**
  String get gameBondTo5;

  /// No description provided for @gameBondTo10.
  ///
  /// In en, this message translates to:
  /// **'How many more to make ten?'**
  String get gameBondTo10;

  /// No description provided for @gameSumWhat.
  ///
  /// In en, this message translates to:
  /// **'How many altogether?'**
  String get gameSumWhat;

  /// No description provided for @gameTakeAway.
  ///
  /// In en, this message translates to:
  /// **'How many are left?'**
  String get gameTakeAway;

  /// No description provided for @gameListen.
  ///
  /// In en, this message translates to:
  /// **'Listen!'**
  String get gameListen;

  /// No description provided for @binBig.
  ///
  /// In en, this message translates to:
  /// **'Big'**
  String get binBig;

  /// No description provided for @binSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get binSmall;

  /// No description provided for @binLand.
  ///
  /// In en, this message translates to:
  /// **'Land'**
  String get binLand;

  /// No description provided for @binWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get binWater;

  /// No description provided for @vocabPlate.
  ///
  /// In en, this message translates to:
  /// **'Plate'**
  String get vocabPlate;

  /// No description provided for @offscreenMooLikeCow.
  ///
  /// In en, this message translates to:
  /// **'Moo like a cow and crawl on all fours!'**
  String get offscreenMooLikeCow;

  /// No description provided for @offscreenWagLikeDog.
  ///
  /// In en, this message translates to:
  /// **'Wag your tail like a happy dog!'**
  String get offscreenWagLikeDog;

  /// No description provided for @offscreenStompLikeElephant.
  ///
  /// In en, this message translates to:
  /// **'Stomp like an elephant: one, two, three!'**
  String get offscreenStompLikeElephant;

  /// No description provided for @offscreenSwimLikeFish.
  ///
  /// In en, this message translates to:
  /// **'Swim like a fish around the room!'**
  String get offscreenSwimLikeFish;

  /// No description provided for @offscreenHugGrownUp.
  ///
  /// In en, this message translates to:
  /// **'Give a grown-up a big bear hug!'**
  String get offscreenHugGrownUp;

  /// No description provided for @offscreenBuildDen.
  ///
  /// In en, this message translates to:
  /// **'Build a cosy den with cushions!'**
  String get offscreenBuildDen;

  /// No description provided for @offscreenAnimalCharades.
  ///
  /// In en, this message translates to:
  /// **'Act like an animal. Can a grown-up guess which one?'**
  String get offscreenAnimalCharades;

  /// No description provided for @offscreenJumpCount.
  ///
  /// In en, this message translates to:
  /// **'Jump three times and count out loud!'**
  String get offscreenJumpCount;

  /// No description provided for @offscreenCountToys.
  ///
  /// In en, this message translates to:
  /// **'Count five toys and line them up!'**
  String get offscreenCountToys;

  /// No description provided for @offscreenCountSteps.
  ///
  /// In en, this message translates to:
  /// **'Count your steps to the door!'**
  String get offscreenCountSteps;

  /// No description provided for @offscreenFindDots.
  ///
  /// In en, this message translates to:
  /// **'Find something with dots on it!'**
  String get offscreenFindDots;

  /// No description provided for @offscreenMoreLessBlocks.
  ///
  /// In en, this message translates to:
  /// **'Make two piles of blocks. Which has more?'**
  String get offscreenMoreLessBlocks;

  /// No description provided for @offscreenAirWrite.
  ///
  /// In en, this message translates to:
  /// **'Write a number in the air with your finger!'**
  String get offscreenAirWrite;

  /// No description provided for @offscreenShareSnack.
  ///
  /// In en, this message translates to:
  /// **'Share a snack fairly with someone!'**
  String get offscreenShareSnack;

  /// No description provided for @offscreenFiveFingers.
  ///
  /// In en, this message translates to:
  /// **'Show five fingers, then hide some. How many are hiding?'**
  String get offscreenFiveFingers;

  /// No description provided for @offscreenTenFingers.
  ///
  /// In en, this message translates to:
  /// **'Show ten fingers! Bend some down and count the rest.'**
  String get offscreenTenFingers;

  /// No description provided for @offscreenAddSpoons.
  ///
  /// In en, this message translates to:
  /// **'Put two spoons and one more on the table. How many?'**
  String get offscreenAddSpoons;

  /// No description provided for @offscreenLetterHunt.
  ///
  /// In en, this message translates to:
  /// **'Find something at home that starts with the same sound!'**
  String get offscreenLetterHunt;

  /// No description provided for @offscreenBodyLetter.
  ///
  /// In en, this message translates to:
  /// **'Make the letter\'s shape with your body!'**
  String get offscreenBodyLetter;

  /// No description provided for @offscreenSoundWalk.
  ///
  /// In en, this message translates to:
  /// **'Say the sound every time you take a step!'**
  String get offscreenSoundWalk;

  /// No description provided for @offscreenReadWithGrownup.
  ///
  /// In en, this message translates to:
  /// **'Read a picture book with a grown-up!'**
  String get offscreenReadWithGrownup;

  /// No description provided for @offscreenNameLetters.
  ///
  /// In en, this message translates to:
  /// **'Find the first letter of your name somewhere!'**
  String get offscreenNameLetters;

  /// No description provided for @offscreenShapeHunt.
  ///
  /// In en, this message translates to:
  /// **'Find something round and something square!'**
  String get offscreenShapeHunt;

  /// No description provided for @offscreenDrawShape.
  ///
  /// In en, this message translates to:
  /// **'Draw a big circle in the air!'**
  String get offscreenDrawShape;

  /// No description provided for @offscreenColourHunt.
  ///
  /// In en, this message translates to:
  /// **'Find three red things at home!'**
  String get offscreenColourHunt;

  /// No description provided for @offscreenMixColours.
  ///
  /// In en, this message translates to:
  /// **'Ask a grown-up to help you mix two paints!'**
  String get offscreenMixColours;

  /// No description provided for @offscreenClapPattern.
  ///
  /// In en, this message translates to:
  /// **'Clap a pattern: clap, stamp, clap, stamp!'**
  String get offscreenClapPattern;

  /// No description provided for @offscreenShapeWalk.
  ///
  /// In en, this message translates to:
  /// **'Walk around the room and name the shapes you see!'**
  String get offscreenShapeWalk;

  /// No description provided for @pipHouseHello.
  ///
  /// In en, this message translates to:
  /// **'Welcome to my house!'**
  String get pipHouseHello;

  /// No description provided for @pipGoodnight.
  ///
  /// In en, this message translates to:
  /// **'Goodnight! Sweet dreams.'**
  String get pipGoodnight;

  /// No description provided for @pipWakeUp.
  ///
  /// In en, this message translates to:
  /// **'Good morning! I\'m awake.'**
  String get pipWakeUp;

  /// No description provided for @houseStickers.
  ///
  /// In en, this message translates to:
  /// **'My stickers'**
  String get houseStickers;

  /// No description provided for @houseWardrobe.
  ///
  /// In en, this message translates to:
  /// **'Dress up Pip'**
  String get houseWardrobe;

  /// No description provided for @houseFeed.
  ///
  /// In en, this message translates to:
  /// **'Feed Pip'**
  String get houseFeed;

  /// No description provided for @houseTalk.
  ///
  /// In en, this message translates to:
  /// **'Talk to Pip'**
  String get houseTalk;

  /// No description provided for @houseBedtime.
  ///
  /// In en, this message translates to:
  /// **'Pip\'s bedtime'**
  String get houseBedtime;

  /// No description provided for @stickersMore.
  ///
  /// In en, this message translates to:
  /// **'Collect stars to find more stickers!'**
  String get stickersMore;

  /// No description provided for @costumeMore.
  ///
  /// In en, this message translates to:
  /// **'Collect more stars for this one!'**
  String get costumeMore;

  /// No description provided for @pipLovesIt.
  ///
  /// In en, this message translates to:
  /// **'I love it!'**
  String get pipLovesIt;

  /// No description provided for @turnRabbit.
  ///
  /// In en, this message translates to:
  /// **'Rabbit\'s turn!'**
  String get turnRabbit;

  /// No description provided for @turnTurtle.
  ///
  /// In en, this message translates to:
  /// **'Turtle\'s turn!'**
  String get turnTurtle;

  /// No description provided for @turnPip.
  ///
  /// In en, this message translates to:
  /// **'Pip\'s turn!'**
  String get turnPip;

  /// No description provided for @boardChoosePlayers.
  ///
  /// In en, this message translates to:
  /// **'Who is playing?'**
  String get boardChoosePlayers;

  /// No description provided for @boardTwoFriends.
  ///
  /// In en, this message translates to:
  /// **'Two friends'**
  String get boardTwoFriends;

  /// No description provided for @boardWithPip.
  ///
  /// In en, this message translates to:
  /// **'Play with Pip'**
  String get boardWithPip;

  /// No description provided for @boardEveryoneWins.
  ///
  /// In en, this message translates to:
  /// **'Hooray! Everyone played so well!'**
  String get boardEveryoneWins;

  /// No description provided for @boardRoll.
  ///
  /// In en, this message translates to:
  /// **'Tap the dice!'**
  String get boardRoll;

  /// No description provided for @boardHop.
  ///
  /// In en, this message translates to:
  /// **'Tap your animal to hop!'**
  String get boardHop;

  /// No description provided for @boardVineUp.
  ///
  /// In en, this message translates to:
  /// **'A vine! Climb up!'**
  String get boardVineUp;

  /// No description provided for @boardSlideDown.
  ///
  /// In en, this message translates to:
  /// **'Wheee! A slide!'**
  String get boardSlideDown;

  /// No description provided for @boardFinish.
  ///
  /// In en, this message translates to:
  /// **'You reached the end!'**
  String get boardFinish;

  /// No description provided for @boardQuestion.
  ///
  /// In en, this message translates to:
  /// **'A little question!'**
  String get boardQuestion;

  /// No description provided for @dominoPlay.
  ///
  /// In en, this message translates to:
  /// **'Find a tile that matches an end!'**
  String get dominoPlay;

  /// No description provided for @dominoDraw.
  ///
  /// In en, this message translates to:
  /// **'No match. Take a new tile!'**
  String get dominoDraw;

  /// No description provided for @bingoFind.
  ///
  /// In en, this message translates to:
  /// **'Is it on your card?'**
  String get bingoFind;

  /// No description provided for @bingoLine.
  ///
  /// In en, this message translates to:
  /// **'Bingo! A full row!'**
  String get bingoLine;

  /// No description provided for @ticTacTurn.
  ///
  /// In en, this message translates to:
  /// **'Pick a square!'**
  String get ticTacTurn;

  /// No description provided for @ticTacLine.
  ///
  /// In en, this message translates to:
  /// **'Three in a row!'**
  String get ticTacLine;

  /// No description provided for @ticTacDraw.
  ///
  /// In en, this message translates to:
  /// **'The board is full. Good game!'**
  String get ticTacDraw;

  /// No description provided for @jigsawPlace.
  ///
  /// In en, this message translates to:
  /// **'Put the pieces in their places!'**
  String get jigsawPlace;

  /// No description provided for @ispyColour.
  ///
  /// In en, this message translates to:
  /// **'Find something this colour!'**
  String get ispyColour;

  /// No description provided for @ispyAnimal.
  ///
  /// In en, this message translates to:
  /// **'Find this animal!'**
  String get ispyAnimal;

  /// No description provided for @ispyDifference.
  ///
  /// In en, this message translates to:
  /// **'Find what is different!'**
  String get ispyDifference;

  /// No description provided for @feedRaceRoll.
  ///
  /// In en, this message translates to:
  /// **'Roll the dice and feed your animal!'**
  String get feedRaceRoll;

  /// No description provided for @feedRaceTap.
  ///
  /// In en, this message translates to:
  /// **'Tap a berry for each dot!'**
  String get feedRaceTap;

  /// No description provided for @feedRaceFull.
  ///
  /// In en, this message translates to:
  /// **'Full tummy!'**
  String get feedRaceFull;

  /// No description provided for @offscreenRealPuzzle.
  ///
  /// In en, this message translates to:
  /// **'Do a real puzzle with a grown-up!'**
  String get offscreenRealPuzzle;

  /// No description provided for @offscreenMemoryObjects.
  ///
  /// In en, this message translates to:
  /// **'Hide three toys under cups. Where is the teddy?'**
  String get offscreenMemoryObjects;

  /// No description provided for @offscreenHopRace.
  ///
  /// In en, this message translates to:
  /// **'Have a hopping race with a grown-up. Everyone wins!'**
  String get offscreenHopRace;

  /// No description provided for @offscreenSpyRoom.
  ///
  /// In en, this message translates to:
  /// **'Play I Spy in your room with a grown-up!'**
  String get offscreenSpyRoom;

  /// No description provided for @offscreenFeedTeddy.
  ///
  /// In en, this message translates to:
  /// **'Give your teddy three pretend berries!'**
  String get offscreenFeedTeddy;

  /// No description provided for @offscreenLineUp.
  ///
  /// In en, this message translates to:
  /// **'Line up your shoes, matching pairs!'**
  String get offscreenLineUp;

  /// No description provided for @offscreenFamilyGame.
  ///
  /// In en, this message translates to:
  /// **'Play a real board game with your family!'**
  String get offscreenFamilyGame;

  /// No description provided for @parentProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get parentProgress;

  /// No description provided for @parentSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get parentSettings;

  /// No description provided for @parentStars.
  ///
  /// In en, this message translates to:
  /// **'{stars} stars'**
  String parentStars(int stars);

  /// No description provided for @parentLevelsDone.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} levels'**
  String parentLevelsDone(int done, int total);

  /// No description provided for @parentSkillsMastered.
  ///
  /// In en, this message translates to:
  /// **'{mastered} of {total} skills mastered'**
  String parentSkillsMastered(int mastered, int total);

  /// No description provided for @parentTodayIdea.
  ///
  /// In en, this message translates to:
  /// **'Today\'s idea away from the screen'**
  String get parentTodayIdea;

  /// No description provided for @parentBilingual.
  ///
  /// In en, this message translates to:
  /// **'Bilingual mode (names in both languages)'**
  String get parentBilingual;

  /// No description provided for @parentLargeTargets.
  ///
  /// In en, this message translates to:
  /// **'Extra-large buttons'**
  String get parentLargeTargets;

  /// No description provided for @parentLeftUnfinished.
  ///
  /// In en, this message translates to:
  /// **'Games often left unfinished'**
  String get parentLeftUnfinished;

  /// No description provided for @parentNone.
  ///
  /// In en, this message translates to:
  /// **'None yet'**
  String get parentNone;

  /// No description provided for @parentFullVersion.
  ///
  /// In en, this message translates to:
  /// **'Full version'**
  String get parentFullVersion;

  /// No description provided for @parentSamplerInfo.
  ///
  /// In en, this message translates to:
  /// **'The free version has the first two levels of every world. One purchase unlocks everything, forever. No ads, no subscriptions.'**
  String get parentSamplerInfo;

  /// No description provided for @parentBuy.
  ///
  /// In en, this message translates to:
  /// **'Unlock everything for {price}'**
  String parentBuy(String price);

  /// No description provided for @parentRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore purchase'**
  String get parentRestore;

  /// No description provided for @parentUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Everything is unlocked. Thank you!'**
  String get parentUnlocked;

  /// No description provided for @parentStoreUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Purchases are available in the App Store and Google Play versions.'**
  String get parentStoreUnavailable;

  /// No description provided for @parentPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get parentPrivacy;

  /// No description provided for @parentPrivacyShort.
  ///
  /// In en, this message translates to:
  /// **'Nothing leaves this device'**
  String get parentPrivacyShort;

  /// No description provided for @parentMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get parentMusic;
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
