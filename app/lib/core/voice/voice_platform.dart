import 'voice_platform_stub.dart' if (dart.library.js_interop) 'voice_platform_web.dart' as platform;
import 'voice_service.dart';

/// The microphone for the current platform.
TalkBack createTalkBack() => TalkBack(platform.createRecorder(), platform.createPlayer());
