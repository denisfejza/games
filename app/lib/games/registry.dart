import 'common/mini_game.dart';
import 'sound_match/sound_match_game.dart';

/// Every engine, by the `game` type used in content JSON.
const Map<String, GameEngine> engines = {
  'sound_match': SoundMatchEngine(),
};
