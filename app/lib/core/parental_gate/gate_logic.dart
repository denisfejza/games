import 'dart:math';

import 'number_words.dart';

/// State of the grown-up check: type the three-digit number shown as words.
class GateChallenge {
  GateChallenge({Random? random}) : _random = random ?? Random.secure() {
    _next();
  }

  static const digits = 3;

  final Random _random;
  late int _number;
  String _input = '';

  int get number => _number;
  String get input => _input;
  String words(String locale) => numberToWords(_number, locale);

  /// Adds a digit. When three are entered, returns whether they match; a
  /// wrong answer picks a fresh number so guessing gets no easier.
  GateResult enter(int digit) {
    if (digit < 0 || digit > 9) throw RangeError.range(digit, 0, 9, 'digit');
    _input += '$digit';
    if (_input.length < digits) return GateResult.pending;
    final ok = int.parse(_input) == _number;
    if (!ok) _next();
    _input = '';
    return ok ? GateResult.passed : GateResult.failed;
  }

  void deleteLast() {
    if (_input.isNotEmpty) _input = _input.substring(0, _input.length - 1);
  }

  void _next() {
    var n = _number0();
    // Avoid numbers whose digits are all the same (e.g. 555): too easy to hit by mashing.
    while (n % 111 == 0) {
      n = _number0();
    }
    _number = n;
    _input = '';
  }

  int _number0() => 100 + _random.nextInt(900);
}

enum GateResult { pending, passed, failed }
