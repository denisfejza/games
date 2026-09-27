// Release readiness (PLAN 6.1): fails while placeholders remain.
//
//   dart run tool/release_check.dart
import 'dart:convert';
import 'dart:io';

void main() {
  final problems = <String>[];

  var todos = 0;
  for (final f in Directory('lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'))) {
    todos += 'TODO(asset)'.allMatches(f.readAsStringSync()).length;
  }
  if (todos > 0) problems.add('$todos TODO(asset) placeholders in lib/');

  final arb = jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync()) as Map<String, dynamic>;
  const parentOnly = ['gate', 'debug', 'parent', 'language', 'privacy', 'purchase', 'appTitle'];
  final keys = [for (final k in arb.keys) if (!k.startsWith('@') && !parentOnly.any(k.startsWith)) k];
  for (final locale in ['en', 'sq']) {
    final missing = keys.where((k) => !File('assets/audio/$locale/$k.ogg').existsSync()).length;
    if (missing > 0) problems.add('$missing of ${keys.length} $locale recordings missing (docs/RECORDING_SCRIPT.md)');
  }
  if (!File('assets/rive/pip.riv').existsSync()) problems.add('assets/rive/pip.riv missing (docs/PIP_RIVE_SPEC.md)');
  if (File('../docs/CURRICULUM.md').readAsStringSync().contains('DRAFT')) problems.add('docs/CURRICULUM.md is still a draft');
  final unticked = '- [ ]'.allMatches(File('../docs/COMPLIANCE.md').readAsStringSync()).length;
  if (unticked > 0) problems.add('$unticked unticked items in docs/COMPLIANCE.md');

  if (problems.isEmpty) {
    stdout.writeln('Ready for release.');
    return;
  }
  stdout.writeln('Not ready for release:\n${problems.map((p) => '  - $p').join('\n')}');
  exitCode = 1;
}
