import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/ui/big_button.dart';
import '../../app/ui/caption_bar.dart';
import '../../app/ui/hear_again_button.dart';
import '../../app/ui/outlined_text.dart';
import '../../app/ui/patterns.dart';
import '../../app/ui/tokens.dart';
import '../../companion/costumes.dart';
import '../../companion/pip_controller.dart';
import '../../companion/pip_view.dart';
import '../../core/audio/audio_service.dart';
import '../../core/voice/voice_service.dart';
import '../../l10n/app_localizations.dart';
import '../title_banner.dart';

/// Pip's House (PLAN 3.5): feed and tickle Pip, talk to him, dress him up,
/// look at stickers, and put him to bed. Rewards come from stars only.
class PipsHouseScreen extends ConsumerStatefulWidget {
  const PipsHouseScreen({super.key});

  @override
  ConsumerState<PipsHouseScreen> createState() => _PipsHouseScreenState();
}

enum _Panel { feed, wardrobe }

class _PipsHouseScreenState extends ConsumerState<PipsHouseScreen> {
  _Panel _panel = _Panel.feed;
  bool _asleep = false;
  late final PipController _pip = ref.read(pipControllerProvider);

  static const foods = ['apple', 'carrot', 'banana', 'cheese', 'cake', 'strawberry'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(audioServiceProvider).say('pipHouseHello'));
  }

  @override
  void dispose() {
    if (_asleep) _pip.onEvent(PipEvent.wake);
    super.dispose();
  }

  void _bedtime() {
    final audio = ref.read(audioServiceProvider);
    setState(() => _asleep = !_asleep);
    if (_asleep) {
      _pip.onEvent(PipEvent.bedtime);
      audio.effect(Effect.yawn);
      audio.say('pipGoodnight', interrupt: true);
    } else {
      _pip.onEvent(PipEvent.wake);
      audio.say('pipWakeUp', interrupt: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tokens = AgeBandTheme.of(context);
    final content = ref.watch(contentProvider).value;
    final stars = ref.watch(totalStarsProvider).value ?? 0;
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        foregroundDecoration: BoxDecoration(color: _asleep ? const Color(0x88201A4A) : Colors.transparent),
        child: PatternBackground(
          color: const Color(0xFFFF5C8A),
          pattern: Pattern.diagonal,
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      BigButton(
                        key: const Key('back'),
                        icon: Icons.arrow_back_rounded,
                        color: tokens.secondary,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: Center(
                          child: TitleBanner(title: l.worldPipsHouse, color: const Color(0xFFFF5C8A), height: 84),
                        ),
                      ),
                      const HearAgainButton(),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: _asleep
                        ? const PipView(width: 220, interactive: false)
                        : const PokeablePip(key: Key('house.pip'), width: 220),
                  ),
                ),
                if (!_asleep && content != null)
                  SizedBox(
                    height: 120,
                    child: _panel == _Panel.feed
                        ? ListView(
                            key: const Key('house.foods'),
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: [
                              for (final f in foods)
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: FoodItem(key: Key('food.$f'), item: content.item(f)),
                                ),
                            ],
                          )
                        : _Wardrobe(stars: stars),
                  ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      BigButton(
                        key: const Key('house.feed'),
                        icon: Icons.restaurant_rounded,
                        speakKey: 'houseFeed',
                        color: tokens.success,
                        onPressed: () => setState(() => _panel = _Panel.feed),
                      ),
                      BigButton(
                        key: const Key('house.wardrobe'),
                        icon: Icons.checkroom_rounded,
                        speakKey: 'houseWardrobe',
                        color: const Color(0xFF8E5CF7),
                        onPressed: () => setState(() => _panel = _Panel.wardrobe),
                      ),
                      BigButton(
                        key: const Key('house.stickers'),
                        icon: Icons.auto_awesome_rounded,
                        speakKey: 'houseStickers',
                        color: const Color(0xFFFFB020),
                        onPressed: () =>
                            Navigator.of(context)
                                .push(MaterialPageRoute<void>(builder: (_) => StickerBookScreen(stars: stars))),
                      ),
                      const _TalkButton(),
                      BigButton(
                        key: const Key('house.bedtime'),
                        icon: _asleep ? Icons.wb_sunny_rounded : Icons.bedtime_rounded,
                        speakKey: 'houseBedtime',
                        color: const Color(0xFF26215C),
                        onPressed: _bedtime,
                      ),
                    ],
                  ),
                ),
                const CaptionBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Costumes unlocked by stars; locked ones are shown faded (never a padlock).
class _Wardrobe extends ConsumerWidget {
  const _Wardrobe({required this.stars});

  final int stars;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final worn = ref.watch(pipCostumeProvider);
    return ListView(
      key: const Key('house.wardrobeList'),
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        for (final c in costumes)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Opacity(
              opacity: stars >= c.stars ? 1 : 0.4,
              child: GestureDetector(
                key: Key('costume.${c.id}'),
                onTap: () {
                  final audio = ref.read(audioServiceProvider);
                  if (stars < c.stars) {
                    audio.say('costumeMore', interrupt: true);
                    return;
                  }
                  ref.read(pipCostumeProvider.notifier).set(worn == c.id ? null : c.id);
                  ref.read(pipControllerProvider).onEvent(PipEvent.poked);
                  audio.effect(Effect.pop);
                  audio.say('pipLovesIt', interrupt: true);
                },
                child: Container(
                  width: 96,
                  height: 96,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: worn == c.id ? const Color(0xFF3B2C4A) : Colors.white, width: 5),
                  ),
                  child: Text(c.emoji, style: const TextStyle(fontFamily: 'PipEmoji', fontSize: 52)),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _TalkButton extends ConsumerStatefulWidget {
  const _TalkButton();

  @override
  ConsumerState<_TalkButton> createState() => _TalkButtonState();
}

class _TalkButtonState extends ConsumerState<_TalkButton> {
  bool _busy = false;

  Future<void> _talk() async {
    if (_busy) return;
    setState(() => _busy = true);
    final audio = ref.read(audioServiceProvider);
    final pip = ref.read(pipControllerProvider);
    await audio.say('talkBackPrompt', interrupt: true);
    final result = await ref
        .read(talkBackProvider)
        .listenAndEcho(onChildSpoke: () => pip.onEvent(PipEvent.childSpeaking));
    pip.onEvent(PipEvent.childDone);
    // Any sound is a success: we reward the attempt, not the words (CLAUDE.md).
    if (result == EchoResult.echoed) {
      pip.onEvent(PipEvent.correct);
      audio.effect(Effect.giggle);
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    // Only when a grown-up has turned the microphone on in the parent area.
    if (!ref.watch(micEnabledProvider) || !ref.watch(talkBackProvider).supported) return const SizedBox.shrink();
    return BigButton(
      key: const Key('house.talk'),
      icon: _busy ? Icons.graphic_eq_rounded : Icons.mic_rounded,
      speakKey: 'houseTalk',
      color: const Color(0xFF1FB5E3),
      onPressed: _talk,
    );
  }
}

/// One sticker per star, in a fixed order.
class StickerBookScreen extends ConsumerWidget {
  const StickerBookScreen({super.key, required this.stars});

  final int stars;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = AgeBandTheme.of(context);
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: PatternBackground(
        color: const Color(0xFFFFB020),
        pattern: Pattern.stars,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    BigButton(
                      key: const Key('back'),
                      icon: Icons.arrow_back_rounded,
                      color: tokens.secondary,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(child: OutlinedText(l.houseStickers, fontSize: 34, maxLines: 1)),
                    const HearAgainButton(),
                  ],
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: MediaQuery.sizeOf(context).width > 700 ? 6 : 4,
                  padding: const EdgeInsets.all(16),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    for (var i = 0; i < stickers.length; i++)
                      GestureDetector(
                        key: Key('sticker.$i'),
                        onTap: () {
                          if (i >= stars) ref.read(audioServiceProvider).say('stickersMore', interrupt: true);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: i < stars ? Colors.white : Colors.white.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: i < stars
                              ? Text(stickers[i], style: const TextStyle(fontFamily: 'PipEmoji', fontSize: 48))
                              : const Icon(Icons.star_outline_rounded, size: 40, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
              const CaptionBar(),
            ],
          ),
        ),
      ),
    );
  }
}
