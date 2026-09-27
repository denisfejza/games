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

  @override
  String get vocabHabitatFarm => 'Fermë';

  @override
  String get vocabHabitatHome => 'Shtëpi';

  @override
  String get vocabHabitatJungle => 'Xhungël';

  @override
  String get vocabHabitatSea => 'Det';

  @override
  String get vocabHabitatSnow => 'Borë';

  @override
  String get vocabHabitatGarden => 'Kopsht';

  @override
  String get vocabHabitatForest => 'Pyll';

  @override
  String get num0 => 'zero';

  @override
  String get num1 => 'një';

  @override
  String get num2 => 'dy';

  @override
  String get num3 => 'tre';

  @override
  String get num4 => 'katër';

  @override
  String get num5 => 'pesë';

  @override
  String get num6 => 'gjashtë';

  @override
  String get num7 => 'shtatë';

  @override
  String get num8 => 'tetë';

  @override
  String get num9 => 'nëntë';

  @override
  String get num10 => 'dhjetë';

  @override
  String get num11 => 'njëmbëdhjetë';

  @override
  String get num12 => 'dymbëdhjetë';

  @override
  String get num13 => 'trembëdhjetë';

  @override
  String get num14 => 'katërmbëdhjetë';

  @override
  String get num15 => 'pesëmbëdhjetë';

  @override
  String get num16 => 'gjashtëmbëdhjetë';

  @override
  String get num17 => 'shtatëmbëdhjetë';

  @override
  String get num18 => 'tetëmbëdhjetë';

  @override
  String get num19 => 'nëntëmbëdhjetë';

  @override
  String get num20 => 'njëzet';

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
  String get gameFindThis => 'Gjeje këtë!';

  @override
  String get gameWhoSays => 'Kush e bën këtë zë?';

  @override
  String get gameFindNumber => 'Gjej numrin!';

  @override
  String get gameHowMany => 'Sa janë?';

  @override
  String get gameWhichMore => 'Cili ka më shumë?';

  @override
  String get gameWhichFewer => 'Cili ka më pak?';

  @override
  String get gameStartsWith => 'Çfarë fillon me këtë tingull?';

  @override
  String get gameFindLetter => 'Gjej shkronjën!';

  @override
  String get gameFindColour => 'Gjej ngjyrën!';

  @override
  String get gameFindShape => 'Gjej formën!';

  @override
  String get gameFeed => 'Jepi ushqimin kafshës së duhur!';

  @override
  String get gameWhereLives => 'Ku jeton?';

  @override
  String get gameFindMummy => 'Ndihmoje të voglin të gjejë mamanë!';

  @override
  String get gameShapeHole => 'Vendose formën në vrimën e saj!';

  @override
  String get gameCountTap => 'Prek secilin dhe numëro!';

  @override
  String get praiseCountedAll => 'I numërove një nga një!';

  @override
  String get gameTrace => 'Ndiqe me gisht!';

  @override
  String get praiseTraced => 'Shumë bukur!';

  @override
  String get gameFindPairs => 'Gjej çiftet!';

  @override
  String get praisePair => 'Një çift!';

  @override
  String get gameWhatNext => 'Çfarë vjen më pas?';

  @override
  String get gameSortBins => 'Vendose secilin në vendin e duhur!';

  @override
  String get gameBuildWord => 'Bashko tingujt!';

  @override
  String get gameBondTo5 => 'Sa duhen që të bëhen pesë?';

  @override
  String get gameBondTo10 => 'Sa duhen që të bëhen dhjetë?';

  @override
  String get gameSumWhat => 'Sa janë gjithsej?';

  @override
  String get gameTakeAway => 'Sa mbeten?';

  @override
  String get gameListen => 'Dëgjo!';

  @override
  String get binBig => 'I madh';

  @override
  String get binSmall => 'I vogël';

  @override
  String get binLand => 'Tokë';

  @override
  String get binWater => 'Ujë';

  @override
  String get vocabPlate => 'Pjatë';

  @override
  String get offscreenMooLikeCow => 'Bëj mu si lopa dhe ec me katër këmbë!';

  @override
  String get offscreenWagLikeDog => 'Tunde bishtin si një qen i gëzuar!';

  @override
  String get offscreenStompLikeElephant => 'Shkel fort si elefanti: një, dy, tre!';

  @override
  String get offscreenSwimLikeFish => 'Noto si peshk nëpër dhomë!';

  @override
  String get offscreenHugGrownUp => 'Përqafo fort një të rritur!';

  @override
  String get offscreenBuildDen => 'Ndërto një strofull të ngrohtë me jastëkë!';

  @override
  String get offscreenAnimalCharades => 'Luaj si një kafshë. A e gjen i rrituri cila është?';

  @override
  String get offscreenJumpCount => 'Kërce tri herë dhe numëro me zë!';

  @override
  String get offscreenCountToys => 'Numëro pesë lodra dhe rreshtoji!';

  @override
  String get offscreenCountSteps => 'Numëro hapat deri te dera!';

  @override
  String get offscreenFindDots => 'Gjej diçka me pika!';

  @override
  String get offscreenMoreLessBlocks => 'Bëj dy grumbuj me kube. Cili ka më shumë?';

  @override
  String get offscreenAirWrite => 'Shkruaj një numër në ajër me gisht!';

  @override
  String get offscreenShareSnack => 'Ndaje një ushqim në mënyrë të drejtë me dikë!';

  @override
  String get offscreenFiveFingers => 'Trego pesë gishta, pastaj fshih disa. Sa janë fshehur?';

  @override
  String get offscreenTenFingers => 'Trego dhjetë gishta! Palos disa dhe numëro të tjerët.';

  @override
  String get offscreenAddSpoons => 'Vendos dy lugë dhe një tjetër në tavolinë. Sa janë?';

  @override
  String get offscreenLetterHunt => 'Gjej diçka në shtëpi që fillon me të njëjtin tingull!';

  @override
  String get offscreenBodyLetter => 'Bëje formën e shkronjës me trupin tënd!';

  @override
  String get offscreenSoundWalk => 'Thuaj tingullin sa herë që bën një hap!';

  @override
  String get offscreenReadWithGrownup => 'Lexo një libër me figura me një të rritur!';

  @override
  String get offscreenNameLetters => 'Gjej diku shkronjën e parë të emrit tënd!';

  @override
  String get offscreenShapeHunt => 'Gjej diçka të rrumbullakët dhe diçka katrore!';

  @override
  String get offscreenDrawShape => 'Vizato një rreth të madh në ajër!';

  @override
  String get offscreenColourHunt => 'Gjej tri gjëra të kuqe në shtëpi!';

  @override
  String get offscreenMixColours => 'Kërkoji një të rrituri të të ndihmojë të përziesh dy bojëra!';

  @override
  String get offscreenClapPattern => 'Duartrokit një model: duartrokit, shkel, duartrokit, shkel!';

  @override
  String get offscreenShapeWalk => 'Ec nëpër dhomë dhe thuaj emrat e formave që sheh!';

  @override
  String get pipHouseHello => 'Mirë se erdhe në shtëpinë time!';

  @override
  String get pipGoodnight => 'Natën e mirë! Ëndrra të ëmbla.';

  @override
  String get pipWakeUp => 'Mirëmëngjes! U zgjova.';

  @override
  String get houseStickers => 'Ngjitëset e mia';

  @override
  String get houseWardrobe => 'Vishe Pipin';

  @override
  String get houseFeed => 'Ushqeje Pipin';

  @override
  String get houseTalk => 'Fol me Pipin';

  @override
  String get houseBedtime => 'Koha e gjumit për Pipin';

  @override
  String get stickersMore => 'Mblidh yje për të gjetur më shumë ngjitëse!';

  @override
  String get costumeMore => 'Mblidh më shumë yje për këtë!';

  @override
  String get pipLovesIt => 'Më pëlqen shumë!';

  @override
  String get turnRabbit => 'Radha e lepurit!';

  @override
  String get turnTurtle => 'Radha e breshkës!';

  @override
  String get turnPip => 'Radha e Pipit!';

  @override
  String get boardChoosePlayers => 'Kush po luan?';

  @override
  String get boardTwoFriends => 'Dy shokë';

  @override
  String get boardWithPip => 'Luaj me Pipin';

  @override
  String get boardEveryoneWins => 'Urra! Të gjithë luajtën shumë bukur!';

  @override
  String get boardRoll => 'Prek zarin!';

  @override
  String get boardHop => 'Prek kafshën tënde që të kërcejë!';

  @override
  String get boardVineUp => 'Një hardhi! Ngjitu lart!';

  @override
  String get boardSlideDown => 'Uiii! Një rrëshqitëse!';

  @override
  String get boardFinish => 'Arrite në fund!';

  @override
  String get boardQuestion => 'Një pyetje e vogël!';

  @override
  String get dominoPlay => 'Gjej një pllakë që përputhet me një skaj!';

  @override
  String get dominoDraw => 'Asnjë përputhje. Merr një pllakë të re!';

  @override
  String get bingoFind => 'A është në kartën tënde?';

  @override
  String get bingoLine => 'Bingo! Një rresht i plotë!';

  @override
  String get ticTacTurn => 'Zgjidh një katror!';

  @override
  String get ticTacLine => 'Tre në një rresht!';

  @override
  String get ticTacDraw => 'Tabela u mbush. Lojë e bukur!';

  @override
  String get jigsawPlace => 'Vendosi pjesët në vendet e tyre!';

  @override
  String get ispyColour => 'Gjej diçka me këtë ngjyrë!';

  @override
  String get ispyAnimal => 'Gjej këtë kafshë!';

  @override
  String get ispyDifference => 'Gjej çfarë është ndryshe!';

  @override
  String get feedRaceRoll => 'Hidh zarin dhe ushqe kafshën tënde!';

  @override
  String get feedRaceTap => 'Prek një kokërr për çdo pikë!';

  @override
  String get feedRaceFull => 'Barku plot!';

  @override
  String get offscreenRealPuzzle => 'Bëj një enigmë të vërtetë me një të rritur!';

  @override
  String get offscreenMemoryObjects => 'Fshih tri lodra nën gota. Ku është arushi?';

  @override
  String get offscreenHopRace => 'Bëni një garë me kërcime me një të rritur. Të gjithë fitojnë!';

  @override
  String get offscreenSpyRoom => 'Luaj «Shoh diçka» në dhomën tënde me një të rritur!';

  @override
  String get offscreenFeedTeddy => 'Jepi arushit tënd tri kokrra për lojë!';

  @override
  String get offscreenLineUp => 'Rreshto këpucët, çift pas çifti!';

  @override
  String get offscreenFamilyGame => 'Luaj një lojë të vërtetë tavoline me familjen!';

  @override
  String get parentProgress => 'Përparimi';

  @override
  String get parentSettings => 'Cilësimet';

  @override
  String parentStars(int stars) {
    return '$stars yje';
  }

  @override
  String parentLevelsDone(int done, int total) {
    return '$done nga $total nivele';
  }

  @override
  String parentSkillsMastered(int mastered, int total) {
    return '$mastered nga $total aftësi të zotëruara';
  }

  @override
  String get parentTodayIdea => 'Ideja e sotme larg ekranit';

  @override
  String get parentBilingual => 'Mënyra dygjuhëshe (emrat në të dy gjuhët)';

  @override
  String get parentLargeTargets => 'Butona shumë të mëdhenj';

  @override
  String get parentLeftUnfinished => 'Lojëra që shpesh lihen pa mbaruar';

  @override
  String get parentNone => 'Asnjë ende';

  @override
  String get parentFullVersion => 'Versioni i plotë';

  @override
  String get parentSamplerInfo =>
      'Versioni falas ka dy nivelet e para të çdo bote. Një blerje i hap të gjitha, përgjithmonë. Pa reklama, pa abonime.';

  @override
  String parentBuy(String price) {
    return 'Hapi të gjitha për $price';
  }

  @override
  String get parentRestore => 'Rikthe blerjen';

  @override
  String get parentUnlocked => 'Gjithçka është e hapur. Faleminderit!';

  @override
  String get parentStoreUnavailable => 'Blerjet janë të disponueshme në versionet e App Store dhe Google Play.';

  @override
  String get parentPrivacy => 'Privatësia';

  @override
  String get parentPrivacyShort => 'Asgjë nuk largohet nga kjo pajisje';

  @override
  String get parentMusic => 'Muzikë';
}
