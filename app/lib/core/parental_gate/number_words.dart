/// Spells 1–999 as words, so the gate asks for something a pre-reader can't copy.
library;

const _enOnes = [
  '', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten', //
  'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen', 'nineteen',
];
const _enTens = ['', '', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety'];

const _sqOnes = [
  '', 'një', 'dy', 'tre', 'katër', 'pesë', 'gjashtë', 'shtatë', 'tetë', 'nëntë', 'dhjetë', //
  'njëmbëdhjetë', 'dymbëdhjetë', 'trembëdhjetë', 'katërmbëdhjetë', 'pesëmbëdhjetë',
  'gjashtëmbëdhjetë', 'shtatëmbëdhjetë', 'tetëmbëdhjetë', 'nëntëmbëdhjetë',
];
const _sqTens = [
  '',
  '',
  'njëzet',
  'tridhjetë',
  'dyzet',
  'pesëdhjetë',
  'gjashtëdhjetë',
  'shtatëdhjetë',
  'tetëdhjetë',
  'nëntëdhjetë',
];

String numberToWords(int n, String locale) {
  if (n < 1 || n > 999) throw RangeError.range(n, 1, 999, 'n');
  return locale == 'sq' ? _sq(n) : _en(n);
}

String _en(int n) {
  final parts = <String>[];
  if (n >= 100) parts.add('${_enOnes[n ~/ 100]} hundred');
  final rest = n % 100;
  if (rest >= 20) {
    parts.add(rest % 10 == 0 ? _enTens[rest ~/ 10] : '${_enTens[rest ~/ 10]}-${_enOnes[rest % 10]}');
  } else if (rest > 0) {
    parts.add(_enOnes[rest]);
  }
  return parts.join(' ');
}

// Albanian joins every part with "e": 427 = katërqind e njëzet e shtatë.
String _sq(int n) {
  final parts = <String>[];
  if (n >= 100) parts.add('${_sqOnes[n ~/ 100]}qind');
  final rest = n % 100;
  if (rest >= 20) {
    parts.add(_sqTens[rest ~/ 10]);
    if (rest % 10 > 0) parts.add(_sqOnes[rest % 10]);
  } else if (rest > 0) {
    parts.add(_sqOnes[rest]);
  }
  return parts.join(' e ');
}
