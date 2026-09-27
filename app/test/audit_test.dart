import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/audit_dependencies.dart' as audit;

void main() {
  test('child-safety dependency and network audit passes for the app (PLAN 5.4)', () {
    expect(audit.audit(), isEmpty);
  });

  test('the audit catches ads, undocumented packages and network calls', () {
    final tmp = Directory.systemTemp.createTempSync('audit');
    addTearDown(() => tmp.deleteSync(recursive: true));
    final app = Directory('${tmp.path}/app')..createSync();
    Directory('${tmp.path}/docs').createSync();
    Directory('${app.path}/lib').createSync();
    File('${tmp.path}/docs/DEPENDENCIES.md').writeAsStringSync('| `flame` |');
    File('${app.path}/pubspec.yaml').writeAsStringSync('dependencies:\n  flutter:\n    sdk: flutter\n  flame: ^1.0.0\n  mystery_pkg: ^1.0.0\n');
    File('${app.path}/pubspec.lock').writeAsStringSync('packages:\n  flame:\n    x\n  google_mobile_ads:\n    x\n');
    File('${app.path}/lib/a.dart').writeAsStringSync("final c = HttpClient();\nconst u = 'https://example.com';\n// https://fine-in-comments\n");
    final problems = audit.audit(root: app.path);
    expect(problems, contains(contains('mystery_pkg')));
    expect(problems, contains(contains('google_mobile_ads')));
    expect(problems, contains(contains('HttpClient')));
    expect(problems, contains(contains('web address')));
    expect(problems.where((p) => p.contains('fine-in-comments')), isEmpty);
  });
}
