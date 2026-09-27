import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../worlds/world_map_screen.dart';
import 'bedtime.dart';
import 'providers.dart';
import 'ui/tokens.dart';

class PipsWorldApp extends ConsumerWidget {
  const PipsWorldApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
    onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
    debugShowCheckedModeBanner: false,
    locale: ref.watch(localeProvider),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: buildTheme(ref.watch(ageBandProvider)),
    builder: (context, child) => LargeTargets(
      enabled: ref.watch(largeTargetsProvider),
      child: PlayTimeGuard(child: child!),
    ),
    home: const WorldMapScreen(),
  );
}
