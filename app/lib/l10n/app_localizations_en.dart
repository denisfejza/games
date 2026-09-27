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
  String get languageEnglish => 'English';

  @override
  String get languageAlbanian => 'Shqip';

  @override
  String get vocabCow => 'Cow';

  @override
  String get vocabSheep => 'Sheep';

  @override
  String get vocabPig => 'Pig';

  @override
  String get vocabHen => 'Hen';

  @override
  String get vocabHorse => 'Horse';

  @override
  String get vocabDuck => 'Duck';

  @override
  String get vocabGoat => 'Goat';

  @override
  String get vocabRooster => 'Rooster';

  @override
  String get vocabDog => 'Dog';

  @override
  String get vocabCat => 'Cat';

  @override
  String get vocabRabbit => 'Rabbit';

  @override
  String get vocabFish => 'Fish';

  @override
  String get vocabParrot => 'Parrot';

  @override
  String get vocabHamster => 'Hamster';

  @override
  String get vocabTurtle => 'Turtle';

  @override
  String get vocabMouse => 'Mouse';

  @override
  String get vocabLion => 'Lion';

  @override
  String get vocabElephant => 'Elephant';

  @override
  String get vocabMonkey => 'Monkey';

  @override
  String get vocabGiraffe => 'Giraffe';

  @override
  String get vocabZebra => 'Zebra';

  @override
  String get vocabTiger => 'Tiger';

  @override
  String get vocabSnake => 'Snake';

  @override
  String get vocabCrocodile => 'Crocodile';

  @override
  String get vocabWhale => 'Whale';

  @override
  String get vocabDolphin => 'Dolphin';

  @override
  String get vocabOctopus => 'Octopus';

  @override
  String get vocabCrab => 'Crab';

  @override
  String get vocabShark => 'Shark';

  @override
  String get vocabPenguin => 'Penguin';

  @override
  String get vocabSeal => 'Seal';

  @override
  String get vocabFox => 'Fox';

  @override
  String get vocabOwl => 'Owl';

  @override
  String get vocabBear => 'Bear';

  @override
  String get vocabBee => 'Bee';

  @override
  String get vocabFrog => 'Frog';

  @override
  String get vocabToad => 'Toad';

  @override
  String get vocabBird => 'Bird';

  @override
  String get vocabButterfly => 'Butterfly';

  @override
  String get vocabAnt => 'Ant';

  @override
  String get vocabSnail => 'Snail';

  @override
  String get vocabLadybird => 'Insect';

  @override
  String get vocabBoar => 'Boar';

  @override
  String get vocabKangaroo => 'Kangaroo';

  @override
  String get vocabPanda => 'Panda';

  @override
  String get vocabGrass => 'Grass';

  @override
  String get vocabCarrot => 'Carrot';

  @override
  String get vocabBanana => 'Banana';

  @override
  String get vocabBone => 'Bone';

  @override
  String get vocabMilk => 'Milk';

  @override
  String get vocabApple => 'Apple';

  @override
  String get vocabCheese => 'Cheese';

  @override
  String get vocabCorn => 'Corn';

  @override
  String get vocabHoney => 'Honey';

  @override
  String get vocabLeaf => 'Leaf';

  @override
  String get vocabGrapes => 'Grapes';

  @override
  String get vocabOrangeFruit => 'Orange';

  @override
  String get vocabStrawberry => 'Strawberry';

  @override
  String get vocabPear => 'Pear';

  @override
  String get vocabBread => 'Bread';

  @override
  String get vocabEgg => 'Egg';

  @override
  String get vocabWatermelon => 'Watermelon';

  @override
  String get vocabCherry => 'Cherry';

  @override
  String get vocabCake => 'Cake';

  @override
  String get vocabPizza => 'Pizza';

  @override
  String get vocabSun => 'Sun';

  @override
  String get vocabMoon => 'Moon';

  @override
  String get vocabStarObj => 'Star';

  @override
  String get vocabRain => 'Rain';

  @override
  String get vocabRainbow => 'Rainbow';

  @override
  String get vocabFlower => 'Flower';

  @override
  String get vocabTree => 'Tree';

  @override
  String get vocabBall => 'Ball';

  @override
  String get vocabBalloon => 'Balloon';

  @override
  String get vocabGift => 'Present';

  @override
  String get vocabBook => 'Book';

  @override
  String get vocabKey => 'Key';

  @override
  String get vocabHouse => 'House';

  @override
  String get vocabTent => 'Tent';

  @override
  String get vocabBed => 'Bed';

  @override
  String get vocabCup => 'Cup';

  @override
  String get vocabClock => 'Clock';

  @override
  String get vocabHeartObj => 'Heart';

  @override
  String get vocabCar => 'Car';

  @override
  String get vocabBus => 'Bus';

  @override
  String get vocabTrain => 'Train';

  @override
  String get vocabPlane => 'Plane';

  @override
  String get vocabBoat => 'Boat';

  @override
  String get vocabBike => 'Bike';

  @override
  String get vocabUmbrella => 'Umbrella';

  @override
  String get vocabHat => 'Hat';

  @override
  String get vocabSocks => 'Socks';

  @override
  String get vocabJacket => 'Jacket';

  @override
  String get vocabHand => 'Hand';

  @override
  String get vocabNose => 'Nose';

  @override
  String get vocabEar => 'Ear';

  @override
  String get vocabMouth => 'Mouth';

  @override
  String get vocabFoot => 'Foot';

  @override
  String get vocabNest => 'Nest';

  @override
  String get vocabCircus => 'Circus';

  @override
  String get colourRed => 'Red';

  @override
  String get colourBlue => 'Blue';

  @override
  String get colourYellow => 'Yellow';

  @override
  String get colourGreen => 'Green';

  @override
  String get colourOrange => 'Orange';

  @override
  String get colourPurple => 'Purple';

  @override
  String get colourPink => 'Pink';

  @override
  String get colourBrown => 'Brown';

  @override
  String get colourBlack => 'Black';

  @override
  String get colourWhite => 'White';

  @override
  String get shapeCircle => 'Circle';

  @override
  String get shapeSquare => 'Square';

  @override
  String get shapeTriangle => 'Triangle';

  @override
  String get shapeRectangle => 'Rectangle';

  @override
  String get shapeStar => 'Star';

  @override
  String get shapeHeart => 'Heart';

  @override
  String get shapeOval => 'Oval';

  @override
  String get shapeDiamond => 'Diamond';

  @override
  String get parentTitle => 'For grown-ups';

  @override
  String get parentLanguage => 'Language';

  @override
  String get parentAgeBand => 'Age band';

  @override
  String get pipBelly => 'Belly';

  @override
  String get pipTickle => 'Hee hee! That tickles!';

  @override
  String get pipYum => 'Mmm! Thank you!';

  @override
  String get pipHmm => 'Hmm, let\'s look again.';

  @override
  String get episodeIntro => 'Let\'s play together!';

  @override
  String get companionClap => 'Clap with Pip!';

  @override
  String get companionThanks => 'Yay! You\'re a great friend.';

  @override
  String get offscreenIntro => 'Now a game away from the screen!';

  @override
  String get offscreenDone => 'We did it!';

  @override
  String get episodeDone => 'All done! You played so well.';

  @override
  String get levelNotYet => 'Let\'s play this one first!';

  @override
  String get bedtimePipSleepy => 'Pip is getting sleepy. Time to rest!';

  @override
  String get bedtimeAllDone => 'All done for today';

  @override
  String get talkBackPrompt => 'Say something to Pip!';

  @override
  String parentExtraTime(int minutes) {
    return '+$minutes minutes today';
  }

  @override
  String get parentDailyLimit => 'Daily play time';

  @override
  String get parentLimitOff => 'No limit';

  @override
  String parentMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String parentPlayedToday(int minutes) {
    return 'Played today: $minutes min';
  }

  @override
  String get parentSound => 'Sound';

  @override
  String get parentCaptions => 'Captions';

  @override
  String get parentReducedMotion => 'Less motion';

  @override
  String get parentMicrophone => 'Microphone (Pip repeats)';

  @override
  String get parentMicHelp =>
      'Pip repeats what your child says in a funny voice. The sound is never saved or sent anywhere.';

  @override
  String get parentMicUnavailable => 'Not available on this device yet.';

  @override
  String get parentMicDenied => 'Microphone permission was not given. You can change it in the device settings.';

  @override
  String get parentPipDemo => 'Pip demo (for testing)';

  @override
  String get praiseGreat => 'Great job!';

  @override
  String get praiseWellDone => 'Well done!';

  @override
  String get praiseYouDidIt => 'You did it!';

  @override
  String get praiseSuper => 'Super!';
}
