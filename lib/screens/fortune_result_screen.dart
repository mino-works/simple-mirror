import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../providers/fortune_provider.dart';
import '../providers/costume_provider.dart';
import '../providers/progress_provider.dart';
import '../models/fortune.dart';
import '../utils/fortune_translations.dart';
import 'costume_screen.dart';

// ─── UI Constants ─────────────────────────────────────────────────────────────
abstract class _C {
  // Layout
  static const double hPad = 20.0;
  static const double cardRadius = 22.0;
  static const double cardGap = 10.0;
  static const double narrowBreakpoint = 360.0;

  // Colors
  static const Color bgTop = Color(0xFFFFD6E7);
  static const Color bgBottom = Colors.white;
  static const Color loveCard = Color(0xFFFFF0F5);
  static const Color moneyCard = Color(0xFFFFFBE6);
  static const Color workCard = Color(0xFFE8F5FF);
  static const Color commentCard = Color(0xFFF0F8FF);  // より薄い水色
  static const Color brownText = Color(0xFF5D3A1A);
  static const Color starFilled = Color(0xFFFFCC00);
  static const Color starOutline = Color(0xFFB87800);  // 星の縁取り（濃い琥珀）
  static const Color starEmpty = Color(0xFFAAAAAA);    // より濃いグレー
  static const Color shadow = Color(0x22000000);
  static const Color closeShadow = Color(0x66FF6E99);

  // Asset paths
  static const String rabbitSmall = 'assets/images/rabbit_small.png';
  static const String iconLove = 'assets/images/icons/icon_love.png';
  static const String iconMoney = 'assets/images/icons/icon_money.png';
  static const String iconWork = 'assets/images/icons/icon_work.png';

  // Layout
  static const double heroRatio = 0.55;
  static const double titlePlateH = 44.0;
  static const double titleOverlap = titlePlateH / 2;
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class FortuneResultScreen extends ConsumerStatefulWidget {
  const FortuneResultScreen({super.key});

  @override
  ConsumerState<FortuneResultScreen> createState() => _FortuneResultScreenState();
}

class _FortuneResultScreenState extends ConsumerState<FortuneResultScreen> {
  @override
  void initState() {
    super.initState();
    // 占い結果を見た日として記録（累計ログイン日数カウント）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(progressProvider.notifier).recordFortuneView();
    });
  }

  @override
  Widget build(BuildContext context) {
    final fortune = ref.watch(fortuneProvider);
    final costume = ref.watch(costumeProvider);
    final l = AppLocalizations.of(context);

    if (fortune == null) {
      return const Scaffold(body: Center(child: Text('占いデータがありません')));
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_C.bgTop, _C.bgBottom],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < _C.narrowBreakpoint;
              final hPad = narrow ? 12.0 : _C.hPad;
              final heroH = constraints.maxHeight * _C.heroRatio;

              return SingleChildScrollView(
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: heroH,
                          child: _RabbitHero(
                            imagePath: costume.applyTo(fortune.imagePath),
                            backgroundPath: fortune.backgroundPath,
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(color: Colors.white),
                          padding: EdgeInsets.fromLTRB(hPad, _C.titleOverlap + 12, hPad, 24),
                          child: Column(
                            children: [
                              _FortuneCardsRow(fortune: fortune, narrow: narrow, l: l),
                              const SizedBox(height: 10),
                              _CommentCard(fortune: fortune, narrow: narrow, l: l),
                              const SizedBox(height: 12),
                              // 動画広告ボタン（プレースホルダー）
                              _WatchAdButton(l: l),
                              const SizedBox(height: 10),
                              _NavButtons(
                                l: l,
                                onMirror: () => Navigator.of(context).pop(),
                                onCostume: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const CostumeScreen()),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: heroH - _C.titleOverlap,
                      left: 0,
                      right: 0,
                      child: Center(child: _TitlePlate(title: FortuneTranslations.title(fortune.overallTitle, l.locale.languageCode))),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─── Rabbit hero image ────────────────────────────────────────────────────────
class _RabbitHero extends StatelessWidget {
  const _RabbitHero({required this.imagePath, this.backgroundPath});
  final String imagePath;
  final String? backgroundPath;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 背景画像（nullの場合はウサギ画像に背景込みのため非表示）
        if (backgroundPath != null)
          Image.asset(
            backgroundPath!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox(),
          ),
        // 占い結果に応じたウサギ画像
        Center(
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(
              Icons.pets,
              size: 100,
              color: Colors.white54,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Title plate ──────────────────────────────────────────────────────────────
class _TitlePlate extends StatelessWidget {
  const _TitlePlate({required this.title});
  final String title;

  static const _textStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.5,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB5D8), Color(0xFFB5D8FF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(color: _C.shadow, blurRadius: 14, offset: Offset(0, 4)),
        ],
      ),
      // 白縁取り: stroke レイヤー + fill レイヤーを重ねる
      child: Stack(
        children: [
          Text(
            title,
            style: _textStyle.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 4
                ..strokeJoin = StrokeJoin.round
                ..color = Colors.white,
            ),
          ),
          Text(
            title,
            style: _textStyle.copyWith(color: _C.brownText),
          ),
        ],
      ),
    );
  }
}

// ─── Fortune cards row ────────────────────────────────────────────────────────
class _FortuneCardsRow extends StatelessWidget {
  const _FortuneCardsRow({required this.fortune, required this.narrow, required this.l});
  final Fortune fortune;
  final bool narrow;
  final AppLocalizations l;

  static int _toStars(int value) => (value / 20).round().clamp(1, 5);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _FortuneCard(
            iconPath: _C.iconLove,
            label: l.get('love'),
            stars: _toStars(fortune.loveLuck),
            bgColor: _C.loveCard,
            narrow: narrow,
          ),
        ),
        const SizedBox(width: _C.cardGap),
        Expanded(
          child: _FortuneCard(
            iconPath: _C.iconMoney,
            label: l.get('money'),
            stars: _toStars(fortune.moneyLuck),
            bgColor: _C.moneyCard,
            narrow: narrow,
          ),
        ),
        const SizedBox(width: _C.cardGap),
        Expanded(
          child: _FortuneCard(
            iconPath: _C.iconWork,
            label: l.get('work'),
            stars: _toStars(fortune.workLuck),
            bgColor: _C.workCard,
            narrow: narrow,
          ),
        ),
      ],
    );
  }
}

// ─── Individual fortune card ──────────────────────────────────────────────────
class _FortuneCard extends StatelessWidget {
  const _FortuneCard({
    required this.iconPath,
    required this.label,
    required this.stars,
    required this.bgColor,
    required this.narrow,
  });

  final String iconPath;
  final String label;
  final int stars;
  final Color bgColor;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final iconSize = narrow ? 36.0 : 44.0;
    final labelSize = narrow ? 11.0 : 13.0;
    final starSize = narrow ? 21.0 : 24.0;
    final vPad = narrow ? 6.0 : 9.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: vPad),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(_C.cardRadius),
        boxShadow: const [
          BoxShadow(color: _C.shadow, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // アイコン
          Image.asset(
            iconPath,
            width: iconSize,
            height: iconSize,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Icon(
              Icons.star_rounded,
              size: iconSize,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 4),
          // ラベル
          Text(
            label,
            style: TextStyle(
              fontSize: labelSize,
              fontWeight: FontWeight.w800,
              color: _C.brownText,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // 星評価（必ず1行）
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (i) {
                if (i < stars) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.star_rounded, color: _C.starOutline, size: starSize + 3),
                      Icon(Icons.star_rounded, color: _C.starFilled, size: starSize),
                    ],
                  );
                }
                return Icon(Icons.star_outline_rounded, color: _C.starEmpty, size: starSize);
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Comment card ─────────────────────────────────────────────────────────────
class _CommentCard extends StatelessWidget {
  const _CommentCard({required this.fortune, required this.narrow, required this.l});
  final Fortune fortune;
  final bool narrow;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final iconSize = narrow ? 36.0 : 44.0;
    final titleSize = narrow ? 12.0 : 14.0;
    final bodySize = narrow ? 13.0 : 15.0;
    final pad = narrow ? 14.0 : 18.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: pad, vertical: narrow ? 8.0 : 10.0),
      decoration: BoxDecoration(
        color: _C.commentCard,
        borderRadius: BorderRadius.circular(_C.cardRadius),
        boxShadow: const [
          BoxShadow(color: _C.shadow, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー: 小ウサギ + タイトル
          Row(
            children: [
              Image.asset(
                _C.rabbitSmall,
                width: iconSize,
                height: iconSize,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Icon(
                  Icons.pets,
                  size: iconSize,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l.get('rabbit_message'),
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w800,
                  color: _C.brownText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Divider(
            color: const Color(0xFFB0C8E0),
            thickness: 1,
            height: 1,
          ),
          const SizedBox(height: 6),
          // 本文
          Text(
            FortuneTranslations.message(fortune.dailyMessage, fortune.overallTitle, l.locale.languageCode),
            style: TextStyle(
              fontSize: bodySize,
              fontWeight: FontWeight.w500,
              color: _C.brownText,
              height: 1.7,
            ),
            textAlign: TextAlign.left,
            softWrap: true,
          ),
        ],
      ),
    );
  }
}

// ─── Navigation buttons ───────────────────────────────────────────────────────
class _NavButtons extends StatelessWidget {
  const _NavButtons({required this.onMirror, required this.onCostume, required this.l});
  final VoidCallback onMirror;
  final VoidCallback onCostume;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 130,
          height: 44,
          child: ElevatedButton(
            onPressed: onMirror,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB5D0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 4,
              shadowColor: _C.closeShadow,
            ),
            child: Text(
              l.get('back_to_mirror'),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 130,
          height: 44,
          child: ElevatedButton(
            onPressed: onCostume,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B6DD6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 4,
              shadowColor: const Color(0x669B6DD6),
            ),
            child: Text(
              l.get('outfit'),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Watch ad button (placeholder) ───────────────────────────────────────────
class _WatchAdButton extends StatelessWidget {
  const _WatchAdButton({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l.get('watch_ad_unavailable')),
              backgroundColor: const Color(0xFF9B6DD6),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
        icon: const Icon(Icons.play_circle_outline_rounded, size: 18),
        label: Text(
          l.get('watch_ad'),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF9B6DD6),
          side: const BorderSide(color: Color(0xFFCCA8E8), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }
}
