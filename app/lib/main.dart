import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'core/storage/database.dart';
import 'core/storage/settings_store.dart';
import 'games/common/mini_game.dart';
import 'games/registry.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  final settings = await DriftSettingsStore(db).loadAll();
  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        initialSettingsProvider.overrideWithValue(settings),
        gameRegistryProvider.overrideWithValue(engines),
      ],
      child: const PipsWorldApp(),
    ),
  );
}
