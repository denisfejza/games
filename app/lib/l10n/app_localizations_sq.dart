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
  String get languageEnglish => 'English';

  @override
  String get languageAlbanian => 'Shqip';

  @override
  String get vocabCow => 'Lopë';

  @override
  String get vocabSheep => 'Dele';

  @override
  String get vocabPig => 'Derr';

  @override
  String get vocabHen => 'Pulë';

  @override
  String get vocabHorse => 'Kalë';

  @override
  String get vocabDuck => 'Rosë';

  @override
  String get vocabGoat => 'Dhi';

  @override
  String get vocabRooster => 'Gjel';

  @override
  String get vocabDog => 'Qen';

  @override
  String get vocabCat => 'Mace';

  @override
  String get vocabRabbit => 'Lepur';

  @override
  String get vocabFish => 'Peshk';

  @override
  String get vocabParrot => 'Papagall';

  @override
  String get vocabHamster => 'Hamster';

  @override
  String get vocabTurtle => 'Breshkë';

  @override
  String get vocabMouse => 'Mi';

  @override
  String get vocabLion => 'Luan';

  @override
  String get vocabElephant => 'Elefant';

  @override
  String get vocabMonkey => 'Majmun';

  @override
  String get vocabGiraffe => 'Gjirafë';

  @override
  String get vocabZebra => 'Zebër';

  @override
  String get vocabTiger => 'Tigër';

  @override
  String get vocabSnake => 'Gjarpër';

  @override
  String get vocabCrocodile => 'Krokodil';

  @override
  String get vocabWhale => 'Balenë';

  @override
  String get vocabDolphin => 'Delfin';

  @override
  String get vocabOctopus => 'Oktapod';

  @override
  String get vocabCrab => 'Gaforre';

  @override
  String get vocabShark => 'Peshkaqen';

  @override
  String get vocabPenguin => 'Pinguin';

  @override
  String get vocabSeal => 'Fokë';

  @override
  String get vocabFox => 'Dhelpër';

  @override
  String get vocabOwl => 'Buf';

  @override
  String get vocabBear => 'Ari';

  @override
  String get vocabBee => 'Bletë';

  @override
  String get vocabFrog => 'Bretkosë';

  @override
  String get vocabToad => 'Zhabë';

  @override
  String get vocabBird => 'Zog';

  @override
  String get vocabButterfly => 'Flutur';

  @override
  String get vocabAnt => 'Milingonë';

  @override
  String get vocabSnail => 'Kërmill';

  @override
  String get vocabLadybird => 'Mollëkuqe';

  @override
  String get vocabBoar => 'Thi';

  @override
  String get vocabKangaroo => 'Kangur';

  @override
  String get vocabPanda => 'Panda';

  @override
  String get vocabGrass => 'Bar';

  @override
  String get vocabCarrot => 'Karotë';

  @override
  String get vocabBanana => 'Banane';

  @override
  String get vocabBone => 'Kockë';

  @override
  String get vocabMilk => 'Qumësht';

  @override
  String get vocabApple => 'Mollë';

  @override
  String get vocabCheese => 'Djathë';

  @override
  String get vocabCorn => 'Misër';

  @override
  String get vocabHoney => 'Mjaltë';

  @override
  String get vocabLeaf => 'Gjethe';

  @override
  String get vocabGrapes => 'Rrush';

  @override
  String get vocabOrangeFruit => 'Portokall';

  @override
  String get vocabStrawberry => 'Luleshtrydhe';

  @override
  String get vocabPear => 'Dardhë';

  @override
  String get vocabBread => 'Bukë';

  @override
  String get vocabEgg => 'Vezë';

  @override
  String get vocabWatermelon => 'Shalqi';

  @override
  String get vocabCherry => 'Qershi';

  @override
  String get vocabCake => 'Tortë';

  @override
  String get vocabPizza => 'Pica';

  @override
  String get vocabSun => 'Diell';

  @override
  String get vocabMoon => 'Hënë';

  @override
  String get vocabStarObj => 'Yll';

  @override
  String get vocabRain => 'Shi';

  @override
  String get vocabRainbow => 'Ylber';

  @override
  String get vocabFlower => 'Lule';

  @override
  String get vocabTree => 'Pemë';

  @override
  String get vocabBall => 'Top';

  @override
  String get vocabBalloon => 'Tullumbace';

  @override
  String get vocabGift => 'Dhuratë';

  @override
  String get vocabBook => 'Libër';

  @override
  String get vocabKey => 'Çelës';

  @override
  String get vocabHouse => 'Shtëpi';

  @override
  String get vocabTent => 'Tendë';

  @override
  String get vocabBed => 'Shtrat';

  @override
  String get vocabCup => 'Filxhan';

  @override
  String get vocabClock => 'Orë';

  @override
  String get vocabHeartObj => 'Zemër';

  @override
  String get vocabCar => 'Makinë';

  @override
  String get vocabBus => 'Autobus';

  @override
  String get vocabTrain => 'Tren';

  @override
  String get vocabPlane => 'Aeroplan';

  @override
  String get vocabBoat => 'Varkë';

  @override
  String get vocabBike => 'Biçikletë';

  @override
  String get vocabUmbrella => 'Çadër';

  @override
  String get vocabHat => 'Kapelë';

  @override
  String get vocabSocks => 'Çorape';

  @override
  String get vocabJacket => 'Xhaketë';

  @override
  String get vocabHand => 'Dorë';

  @override
  String get vocabNose => 'Hundë';

  @override
  String get vocabEar => 'Vesh';

  @override
  String get vocabMouth => 'Gojë';

  @override
  String get vocabFoot => 'Këmbë';

  @override
  String get vocabNest => 'Fole';

  @override
  String get vocabCircus => 'Cirk';

  @override
  String get colourRed => 'E kuqe';

  @override
  String get colourBlue => 'Blu';

  @override
  String get colourYellow => 'E verdhë';

  @override
  String get colourGreen => 'Jeshile';

  @override
  String get colourOrange => 'Portokalli';

  @override
  String get colourPurple => 'Vjollcë';

  @override
  String get colourPink => 'Rozë';

  @override
  String get colourBrown => 'Kafe';

  @override
  String get colourBlack => 'E zezë';

  @override
  String get colourWhite => 'E bardhë';

  @override
  String get shapeCircle => 'Rreth';

  @override
  String get shapeSquare => 'Katror';

  @override
  String get shapeTriangle => 'Trekëndësh';

  @override
  String get shapeRectangle => 'Drejtkëndësh';

  @override
  String get shapeStar => 'Yll';

  @override
  String get shapeHeart => 'Zemër';

  @override
  String get shapeOval => 'Vezak';

  @override
  String get shapeDiamond => 'Romb';

  @override
  String get parentTitle => 'Për të rriturit';

  @override
  String get parentLanguage => 'Gjuha';

  @override
  String get parentAgeBand => 'Mosha';

  @override
  String get pipBelly => 'Bark';

  @override
  String get pipTickle => 'Hi hi! Më gudulis!';

  @override
  String get pipYum => 'Mmm! Faleminderit!';

  @override
  String get pipHmm => 'Hmm, le ta shohim përsëri.';

  @override
  String get episodeIntro => 'Hajde të luajmë bashkë!';

  @override
  String get companionClap => 'Duartrokit me Pipin!';

  @override
  String get companionThanks => 'Urra! Je shok i mrekullueshëm.';

  @override
  String get offscreenIntro => 'Tani një lojë larg ekranit!';

  @override
  String get offscreenDone => 'E bëmë!';

  @override
  String get episodeDone => 'Mbaruam! Luajte shumë bukur.';

  @override
  String get levelNotYet => 'Le ta luajmë këtë më parë!';

  @override
  String get bedtimePipSleepy => 'Pipit po i vjen gjumë. Është koha për pushim!';

  @override
  String get bedtimeAllDone => 'Mbaruam për sot';

  @override
  String get talkBackPrompt => 'Thuaji diçka Pipit!';

  @override
  String parentExtraTime(int minutes) {
    return '+$minutes minuta sot';
  }

  @override
  String get parentDailyLimit => 'Koha e lojës në ditë';

  @override
  String get parentLimitOff => 'Pa kufi';

  @override
  String parentMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String parentPlayedToday(int minutes) {
    return 'Luajti sot: $minutes min';
  }

  @override
  String get parentSound => 'Zëri';

  @override
  String get parentCaptions => 'Titrat';

  @override
  String get parentReducedMotion => 'Më pak lëvizje';

  @override
  String get parentMicrophone => 'Mikrofoni (Pipi përsërit)';

  @override
  String get parentMicHelp =>
      'Pipi përsërit me zë qesharak atë që thotë fëmija. Zëri nuk ruhet dhe nuk dërgohet askund.';

  @override
  String get parentMicUnavailable => 'Ende nuk funksionon në këtë pajisje.';

  @override
  String get parentMicDenied => 'Leja për mikrofonin nuk u dha. Mund ta ndryshoni te cilësimet e pajisjes.';

  @override
  String get parentPipDemo => 'Demo e Pipit (për provë)';

  @override
  String get praiseGreat => 'Shumë mirë!';

  @override
  String get praiseWellDone => 'Të lumtë!';

  @override
  String get praiseYouDidIt => 'Ia dole!';

  @override
  String get praiseSuper => 'Super!';
}
