import '../core/keys.dart';
import '../l10n/app_localizations.dart';
import '../l10n/lookup.g.dart';

export '../core/keys.dart' show arbKey;

/// Looks up a string named in content. Returns null for unknown keys; tests
/// check every key used by content resolves.
String? lookupString(AppLocalizations l, String contentKey) => lookupArb(l, arbKey(contentKey));

/// True when [contentKey] names a string in the ARB files.
bool hasString(String contentKey) => arbKeys.contains(arbKey(contentKey));
