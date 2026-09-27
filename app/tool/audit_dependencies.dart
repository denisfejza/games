// Child-safety audit (PLAN 5.4). Fails if:
//  1. a direct dependency isn't listed in docs/DEPENDENCIES.md;
//  2. any package (direct or transitive) looks like ads, analytics,
//     attribution, crash reporting, sign-in or push;
//  3. app code (lib/) uses a network API or contains a web address.
//
//   dart run tool/audit_dependencies.dart      (also run by test/audit_test.dart and CI)
import 'dart:io';

/// Package-name fragments that are never allowed in the child-facing app.
const forbiddenPackages = [
  'firebase', 'analytics', 'admob', 'google_mobile_ads', 'crashlytics', 'sentry', 'bugsnag', 'facebook', //
  'appsflyer', 'adjust', 'amplitude', 'mixpanel', 'segment', 'onesignal', 'branch_io', 'kochava', 'flurry',
  'appcenter', 'datadog', 'newrelic', 'posthog', 'clevertap', 'braze', 'google_sign_in', 'sign_in', 'push',
  'unity_ads', 'applovin', 'ironsource', 'tracking', 'attribution', 'url_launcher', 'webview',
];

/// Explained in docs/DEPENDENCIES.md: pulled in by audioplayers, json_schema and
/// rive_native; we never use it for app traffic (rule 3 checks our code).
const allowedTransitive = {'http', 'http_parser', 'http_multi_server'};

/// Network APIs and patterns our own code must not use.
final forbiddenCode = <RegExp, String>{
  RegExp(r'\bHttpClient\b'): 'HttpClient',
  RegExp(r'''package:http/'''): 'package:http',
  RegExp(r'\bUrlSource\('): 'audioplayers UrlSource (remote audio)',
  RegExp(r'\bWebSocket\b'): 'WebSocket',
  RegExp(r'\bSocket\.connect\b'): 'Socket.connect',
  RegExp(r'\blaunchUrl\b'): 'launchUrl (external links)',
  RegExp(r'\bXMLHttpRequest\b'): 'XMLHttpRequest',
  RegExp(r'\bfetch\('): 'fetch()',
  RegExp(r'''['"]https?://'''): 'a web address in code',
  RegExp(r'FileLoader\.fromUrl'): 'Rive file from a URL',
};

List<String> audit({String root = '.'}) {
  final problems = <String>[];
  final pubspec = File('$root/pubspec.yaml').readAsStringSync();
  final lock = File('$root/pubspec.lock').readAsStringSync();
  final docs = File('$root/../docs/DEPENDENCIES.md').readAsStringSync();

  // 1. Direct dependencies are documented.
  final deps = RegExp(r'^dependencies:\n((?:  .*\n|\n)*)', multiLine: true).firstMatch(pubspec)?.group(1) ?? '';
  for (final m in RegExp(r'^  ([a-z_0-9]+):', multiLine: true).allMatches(deps)) {
    final name = m.group(1)!;
    if (name == 'flutter') continue;
    if (!docs.contains('`$name`')) problems.add('Dependency "$name" is not listed in docs/DEPENDENCIES.md');
  }

  // 2. Nothing in the whole package graph looks like ads/analytics/etc.
  for (final m in RegExp(r'^  ([a-z_0-9]+):\n', multiLine: true).allMatches(lock)) {
    final name = m.group(1)!;
    if (allowedTransitive.contains(name)) continue;
    for (final bad in forbiddenPackages) {
      if (name.contains(bad)) problems.add('Package "$name" matches forbidden "$bad"');
    }
  }

  // 3. Our code doesn't talk to the network.
  for (final f in Directory('$root/lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'))) {
    final lines = f.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trimLeft();
      if (line.startsWith('//') || line.startsWith('*') || line.startsWith('///')) continue;
      for (final e in forbiddenCode.entries) {
        if (e.key.hasMatch(lines[i])) problems.add('${f.path}:${i + 1}: ${e.value}');
      }
    }
  }
  return problems;
}

void main() {
  final problems = audit();
  if (problems.isEmpty) {
    stdout.writeln('Audit passed: no ads, analytics or network use found.');
    return;
  }
  stderr.writeln('Child-safety audit failed:\n${problems.map((p) => '  - $p').join('\n')}');
  exitCode = 1;
}
