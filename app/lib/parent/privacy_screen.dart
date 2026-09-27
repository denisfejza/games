import 'package:flutter/material.dart';

import '../companion/pip_view.dart';
import '../l10n/app_localizations.dart';

/// Plain-language privacy page for grown-ups, with a child-friendly summary
/// at the top that a parent can read out (PLAN 5.3). Keep in sync with
/// docs/PRIVACY_POLICY.md.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const _en = [
    (
      'No accounts, no tracking',
      'Children never sign up or log in. The app has no ads, no analytics, no attribution and no crash-reporting services.',
    ),
    (
      'Stays on this device',
      'Progress, stars, settings and a child\'s nickname and age band are stored only on this device. Nothing is sent to us or anyone else. Deleting the app deletes all of it.',
    ),
    (
      'Microphone',
      'Off until a grown-up turns it on here. When Pip repeats what your child says, the sound is kept in memory for a few seconds, played back once and then discarded. It is never saved or sent anywhere.',
    ),
    (
      'Purchases',
      'The one-time unlock goes through the App Store or Google Play. We never see payment details. Purchase buttons are only in this grown-up area.',
    ),
    (
      'Links and permissions',
      'The app has no links out of the app. Anything that needs a permission is behind the grown-up check.',
    ),
  ];

  static const _sq = [
    (
      'Pa llogari, pa gjurmim',
      'Fëmijët nuk regjistrohen dhe nuk hyjnë me llogari. Aplikacioni nuk ka reklama, analitikë, shërbime atribuimi apo raportime gabimesh.',
    ),
    (
      'Mbetet në këtë pajisje',
      'Përparimi, yjet, cilësimet, si dhe pseudonimi dhe mosha e fëmijës ruhen vetëm në këtë pajisje. Asgjë nuk na dërgohet ne apo dikujt tjetër. Kur fshini aplikacionin, fshihet gjithçka.',
    ),
    (
      'Mikrofoni',
      'Është i fikur derisa një i rritur ta ndezë këtu. Kur Pipi përsërit atë që thotë fëmija, zëri mbahet në kujtesë për pak sekonda, luhet një herë dhe pastaj fshihet. Nuk ruhet dhe nuk dërgohet kurrë askund.',
    ),
    (
      'Blerjet',
      'Hapja e njëhershme bëhet përmes App Store ose Google Play. Ne nuk i shohim kurrë të dhënat e pagesës. Butonat e blerjes janë vetëm në këtë pjesë për të rriturit.',
    ),
    (
      'Lidhje dhe leje',
      'Aplikacioni nuk ka lidhje që të çojnë jashtë tij. Çdo gjë që kërkon leje është pas kontrollit për të rriturit.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final sections = Localizations.localeOf(context).languageCode == 'sq' ? _sq : _en;
    return Scaffold(
      appBar: AppBar(title: Text(l.parentPrivacy)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            color: const Color(0xFFFFF3E0),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const PipView(width: 80, interactive: false),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      l.parentPrivacyShort,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
          ),
          for (final (title, body) in sections) ...[
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(body),
          ],
        ],
      ),
    );
  }
}
