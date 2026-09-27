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

  @override
  String get vocabHabitatFarm => 'Farm';

  @override
  String get vocabHabitatHome => 'Home';

  @override
  String get vocabHabitatJungle => 'Jungle';

  @override
  String get vocabHabitatSea => 'Sea';

  @override
  String get vocabHabitatSnow => 'Snow';

  @override
  String get vocabHabitatGarden => 'Garden';

  @override
  String get vocabHabitatForest => 'Forest';

  @override
  String get num0 => 'zero';

  @override
  String get num1 => 'one';

  @override
  String get num2 => 'two';

  @override
  String get num3 => 'three';

  @override
  String get num4 => 'four';

  @override
  String get num5 => 'five';

  @override
  String get num6 => 'six';

  @override
  String get num7 => 'seven';

  @override
  String get num8 => 'eight';

  @override
  String get num9 => 'nine';

  @override
  String get num10 => 'ten';

  @override
  String get num11 => 'eleven';

  @override
  String get num12 => 'twelve';

  @override
  String get num13 => 'thirteen';

  @override
  String get num14 => 'fourteen';

  @override
  String get num15 => 'fifteen';

  @override
  String get num16 => 'sixteen';

  @override
  String get num17 => 'seventeen';

  @override
  String get num18 => 'eighteen';

  @override
  String get num19 => 'nineteen';

  @override
  String get num20 => 'twenty';

  @override
  String get letterEnA => 'a';

  @override
  String get letterEnB => 'b';

  @override
  String get letterEnC => 'c';

  @override
  String get letterEnD => 'd';

  @override
  String get letterEnE => 'e';

  @override
  String get letterEnF => 'f';

  @override
  String get letterEnG => 'g';

  @override
  String get letterEnH => 'h';

  @override
  String get letterEnI => 'i';

  @override
  String get letterEnJ => 'j';

  @override
  String get letterEnK => 'k';

  @override
  String get letterEnL => 'l';

  @override
  String get letterEnM => 'm';

  @override
  String get letterEnN => 'n';

  @override
  String get letterEnO => 'o';

  @override
  String get letterEnP => 'p';

  @override
  String get letterEnQ => 'q';

  @override
  String get letterEnR => 'r';

  @override
  String get letterEnS => 's';

  @override
  String get letterEnT => 't';

  @override
  String get letterEnU => 'u';

  @override
  String get letterEnV => 'v';

  @override
  String get letterEnW => 'w';

  @override
  String get letterEnX => 'x';

  @override
  String get letterEnY => 'y';

  @override
  String get letterEnZ => 'z';

  @override
  String get letterSqA => 'a';

  @override
  String get letterSqB => 'b';

  @override
  String get letterSqC => 'c';

  @override
  String get letterSqCCedilla => 'ç';

  @override
  String get letterSqD => 'd';

  @override
  String get letterSqDh => 'dh';

  @override
  String get letterSqE => 'e';

  @override
  String get letterSqEDiaeresis => 'ë';

  @override
  String get letterSqF => 'f';

  @override
  String get letterSqG => 'g';

  @override
  String get letterSqGj => 'gj';

  @override
  String get letterSqH => 'h';

  @override
  String get letterSqI => 'i';

  @override
  String get letterSqJ => 'j';

  @override
  String get letterSqK => 'k';

  @override
  String get letterSqL => 'l';

  @override
  String get letterSqLl => 'll';

  @override
  String get letterSqM => 'm';

  @override
  String get letterSqN => 'n';

  @override
  String get letterSqNj => 'nj';

  @override
  String get letterSqO => 'o';

  @override
  String get letterSqP => 'p';

  @override
  String get letterSqQ => 'q';

  @override
  String get letterSqR => 'r';

  @override
  String get letterSqRr => 'rr';

  @override
  String get letterSqS => 's';

  @override
  String get letterSqSh => 'sh';

  @override
  String get letterSqT => 't';

  @override
  String get letterSqTh => 'th';

  @override
  String get letterSqU => 'u';

  @override
  String get letterSqV => 'v';

  @override
  String get letterSqX => 'x';

  @override
  String get letterSqXh => 'xh';

  @override
  String get letterSqY => 'y';

  @override
  String get letterSqZ => 'z';

  @override
  String get letterSqZh => 'zh';

  @override
  String get gameFindThis => 'Find this one!';

  @override
  String get gameWhoSays => 'Who makes this sound?';

  @override
  String get gameFindNumber => 'Find the number!';

  @override
  String get gameHowMany => 'How many?';

  @override
  String get gameWhichMore => 'Which has more?';

  @override
  String get gameWhichFewer => 'Which has fewer?';

  @override
  String get gameStartsWith => 'What starts with this sound?';

  @override
  String get gameFindLetter => 'Find the letter!';

  @override
  String get gameFindColour => 'Find the colour!';

  @override
  String get gameFindShape => 'Find the shape!';

  @override
  String get gameFeed => 'Give the food to the right animal!';

  @override
  String get gameWhereLives => 'Where does it live?';

  @override
  String get gameFindMummy => 'Help the baby find its mummy!';

  @override
  String get gameShapeHole => 'Put the shape in its hole!';

  @override
  String get gameCountTap => 'Tap each one and count!';

  @override
  String get praiseCountedAll => 'You counted every one!';

  @override
  String get gameTrace => 'Trace it with your finger!';

  @override
  String get praiseTraced => 'Beautiful tracing!';

  @override
  String get gameFindPairs => 'Find the pairs!';

  @override
  String get praisePair => 'A pair!';

  @override
  String get gameWhatNext => 'What comes next?';

  @override
  String get gameSortBins => 'Put each one in the right place!';

  @override
  String get gameBuildWord => 'Put the sounds together!';

  @override
  String get gameBondTo5 => 'How many more to make five?';

  @override
  String get gameBondTo10 => 'How many more to make ten?';

  @override
  String get gameSumWhat => 'How many altogether?';

  @override
  String get gameTakeAway => 'How many are left?';

  @override
  String get gameListen => 'Listen!';

  @override
  String get binBig => 'Big';

  @override
  String get binSmall => 'Small';

  @override
  String get binLand => 'Land';

  @override
  String get binWater => 'Water';

  @override
  String get vocabPlate => 'Plate';

  @override
  String get offscreenMooLikeCow => 'Moo like a cow and crawl on all fours!';

  @override
  String get offscreenWagLikeDog => 'Wag your tail like a happy dog!';

  @override
  String get offscreenStompLikeElephant => 'Stomp like an elephant: one, two, three!';

  @override
  String get offscreenSwimLikeFish => 'Swim like a fish around the room!';

  @override
  String get offscreenHugGrownUp => 'Give a grown-up a big bear hug!';

  @override
  String get offscreenBuildDen => 'Build a cosy den with cushions!';

  @override
  String get offscreenAnimalCharades => 'Act like an animal. Can a grown-up guess which one?';

  @override
  String get offscreenJumpCount => 'Jump three times and count out loud!';

  @override
  String get offscreenCountToys => 'Count five toys and line them up!';

  @override
  String get offscreenCountSteps => 'Count your steps to the door!';

  @override
  String get offscreenFindDots => 'Find something with dots on it!';

  @override
  String get offscreenMoreLessBlocks => 'Make two piles of blocks. Which has more?';

  @override
  String get offscreenAirWrite => 'Write a number in the air with your finger!';

  @override
  String get offscreenShareSnack => 'Share a snack fairly with someone!';

  @override
  String get offscreenFiveFingers => 'Show five fingers, then hide some. How many are hiding?';

  @override
  String get offscreenTenFingers => 'Show ten fingers! Bend some down and count the rest.';

  @override
  String get offscreenAddSpoons => 'Put two spoons and one more on the table. How many?';

  @override
  String get offscreenLetterHunt => 'Find something at home that starts with the same sound!';

  @override
  String get offscreenBodyLetter => 'Make the letter\'s shape with your body!';

  @override
  String get offscreenSoundWalk => 'Say the sound every time you take a step!';

  @override
  String get offscreenReadWithGrownup => 'Read a picture book with a grown-up!';

  @override
  String get offscreenNameLetters => 'Find the first letter of your name somewhere!';

  @override
  String get offscreenShapeHunt => 'Find something round and something square!';

  @override
  String get offscreenDrawShape => 'Draw a big circle in the air!';

  @override
  String get offscreenColourHunt => 'Find three red things at home!';

  @override
  String get offscreenMixColours => 'Ask a grown-up to help you mix two paints!';

  @override
  String get offscreenClapPattern => 'Clap a pattern: clap, stamp, clap, stamp!';

  @override
  String get offscreenShapeWalk => 'Walk around the room and name the shapes you see!';

  @override
  String get pipHouseHello => 'Welcome to my house!';

  @override
  String get pipGoodnight => 'Goodnight! Sweet dreams.';

  @override
  String get pipWakeUp => 'Good morning! I\'m awake.';

  @override
  String get houseStickers => 'My stickers';

  @override
  String get houseWardrobe => 'Dress up Pip';

  @override
  String get houseFeed => 'Feed Pip';

  @override
  String get houseTalk => 'Talk to Pip';

  @override
  String get houseBedtime => 'Pip\'s bedtime';

  @override
  String get stickersMore => 'Collect stars to find more stickers!';

  @override
  String get costumeMore => 'Collect more stars for this one!';

  @override
  String get pipLovesIt => 'I love it!';

  @override
  String get turnRabbit => 'Rabbit\'s turn!';

  @override
  String get turnTurtle => 'Turtle\'s turn!';

  @override
  String get turnPip => 'Pip\'s turn!';

  @override
  String get boardChoosePlayers => 'Who is playing?';

  @override
  String get boardTwoFriends => 'Two friends';

  @override
  String get boardWithPip => 'Play with Pip';

  @override
  String get boardEveryoneWins => 'Hooray! Everyone played so well!';

  @override
  String get boardRoll => 'Tap the dice!';

  @override
  String get boardHop => 'Tap your animal to hop!';

  @override
  String get boardVineUp => 'A vine! Climb up!';

  @override
  String get boardSlideDown => 'Wheee! A slide!';

  @override
  String get boardFinish => 'You reached the end!';

  @override
  String get boardQuestion => 'A little question!';

  @override
  String get dominoPlay => 'Find a tile that matches an end!';

  @override
  String get dominoDraw => 'No match. Take a new tile!';

  @override
  String get bingoFind => 'Is it on your card?';

  @override
  String get bingoLine => 'Bingo! A full row!';

  @override
  String get ticTacTurn => 'Pick a square!';

  @override
  String get ticTacLine => 'Three in a row!';

  @override
  String get ticTacDraw => 'The board is full. Good game!';

  @override
  String get jigsawPlace => 'Put the pieces in their places!';

  @override
  String get ispyColour => 'Find something this colour!';

  @override
  String get ispyAnimal => 'Find this animal!';

  @override
  String get ispyDifference => 'Find what is different!';

  @override
  String get feedRaceRoll => 'Roll the dice and feed your animal!';

  @override
  String get feedRaceTap => 'Tap a berry for each dot!';

  @override
  String get feedRaceFull => 'Full tummy!';

  @override
  String get offscreenRealPuzzle => 'Do a real puzzle with a grown-up!';

  @override
  String get offscreenMemoryObjects => 'Hide three toys under cups. Where is the teddy?';

  @override
  String get offscreenHopRace => 'Have a hopping race with a grown-up. Everyone wins!';

  @override
  String get offscreenSpyRoom => 'Play I Spy in your room with a grown-up!';

  @override
  String get offscreenFeedTeddy => 'Give your teddy three pretend berries!';

  @override
  String get offscreenLineUp => 'Line up your shoes, matching pairs!';

  @override
  String get offscreenFamilyGame => 'Play a real board game with your family!';
}
