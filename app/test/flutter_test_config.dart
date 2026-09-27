import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the real fonts so golden images show actual text (ë/ç included)
/// instead of the test font's boxes.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await _load('Nunito', ['assets/fonts/Nunito-Regular.ttf', 'assets/fonts/Nunito-ExtraBold.ttf']);
  await _load('MaterialIcons', ['fonts/MaterialIcons-Regular.otf']);
  await testMain();
}

Future<void> _load(String family, List<String> assets) async {
  final loader = FontLoader(family);
  for (final a in assets) {
    loader.addFont(rootBundle.load(a));
  }
  await loader.load();
}
