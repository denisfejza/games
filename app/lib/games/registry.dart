import 'common/mini_game.dart';
import 'drag_to_target/drag_to_target_game.dart';
import 'blend_tiles/blend_tiles_game.dart';
import 'pairs_memory/pairs_memory_game.dart';
import 'sequence_pattern/sequence_pattern_game.dart';
import 'sort_bins/sort_bins_game.dart';
import 'sound_match/sound_match_game.dart';
import 'tap_count/tap_count_game.dart';
import 'trace_path/trace_path_game.dart';

/// Every engine, by the `game` type used in content JSON.
const Map<String, GameEngine> engines = {
  'sound_match': SoundMatchEngine(),
  'drag_to_target': DragToTargetEngine(),
  'tap_count': TapCountEngine(),
  'trace_path': TracePathEngine(),
  'pairs_memory': PairsMemoryEngine(),
  'sequence_pattern': SequencePatternEngine(),
  'sort_bins': SortBinsEngine(),
  'blend_tiles': BlendTilesEngine(),
};
