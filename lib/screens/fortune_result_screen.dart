import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/fortune_provider.dart';
import '../models/fortune.dart';

// ─── UI Constants ─────────────────────────────────────────────────────────────
abstract class _C {
  // Layout
  static const double hPad = 20.0;
  static const double cardRadius = 22.0;
  static const double cardGap = 10.0;
  static const double narrowBreakpoint = 360.0;

  // Colors
  static const Color bgTop = Color(0xFFFFD6E7);
  static const Color bgBottom = Color(0xFFCCE8FF);
  static const Color loveCard = Color(0xFFFFF0F5);
  static const Color moneyCard = Color(0xFFFFFBE6);
  static const Color workCard = Color(0xFFE8F5FF);
  static const Color commentCard = Color(0xFFDEF0FF);
  static const Color brownText = Color(0xFF5D3A1A);
  static const Color starFilled = Color(0xFFFFCC00);
  static const Color starEmpty = Color(0xFFDDDDDD);
  static const Color shadow = Color(0x22000000);
  static const Color closeBg = Color(0xFFFF7FA3);
  static const Color closeShadow = Color(0x66FF6E99);

  // Asset paths
  static const String rabbitFun = 'assets/images/rabbit_fun.png';
  static const String rabbitBackground = 'assets/images/background.png';
  static const String rabbitSmall = 'assets/images/rabbit_small.png';
  static const String iconLove = 'assets/images/icon_love.png';
  static const String iconMoney = 'assets/images/icon_money.png';
  static const String iconWork = 'assets/images/icon_work.png';

  // Layout
  static const double heroRatio = 0.60;
  static const double titlePlateH = 44.0;
  static const double titleOverlap = titlePlateH / 2;
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class FortuneResultScreen extends ConsumerWidget {
  const FortuneResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fortune = ref.watch(fortuneProvider);
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
                    // ── 縦並びレイアウト ──
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 上部 60%: 背景＋ウサギ
                        SizedBox(height: heroH, child: const _RabbitHero()),
                        // 下部: 白背景・上角丸（高さ固定なし・コンテンツに合わせる）
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(28),
                            ),
                          ),
                          padding: EdgeInsets.fromLTRB(
                            hPad,
                            _C.titleOverlap + 12, // タイトルプレート重なり分を確保
                            hPad,
                            24,
                          ),
                          child: Column(
                            children: [
                              _FortuneCardsRow(fortune: fortune, narrow: narrow),
                              const SizedBox(height: 10),
                              _CommentCard(fortune: fortune, narrow: narrow),
                              const SizedBox(height: 12),
                              _CloseButton(
                                onClose: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // ── タイトルプレート: ヒーローと白背景の境界に重ねる ──
                    Positioned(
                      top: heroH - _C.titleOverlap,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: _TitlePlate(title: fortune.overallTitle),
                      ),
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
  const _RabbitHero();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 背景画像
        Image.asset(
          _C.rabbitBackground,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const SizedBox(),
        ),
        // ウサギ画像（中央に配置）
        Center(
          child: Image.asset(
            _C.rabbitFun,
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
  const _FortuneCardsRow({required this.fortune, required this.narrow});
  final Fortune fortune;
  final bool narrow;

  static int _toStars(int value) => (value / 20).round().clamp(1, 5);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _FortuneCard(
            iconPath: _C.iconLove,
            label: '恋愛運',
            stars: _toStars(fortune.loveLuck),
            bgColor: _C.loveCard,
            narrow: narrow,
          ),
        ),
        const SizedBox(width: _C.cardGap),
        Expanded(
          child: _FortuneCard(
            iconPath: _C.iconMoney,
            label: '金運',
            stars: _toStars(fortune.moneyLuck),
            bgColor: _C.moneyCard,
            narrow: narrow,
          ),
        ),
        const SizedBox(width: _C.cardGap),
        Expanded(
          child: _FortuneCard(
            iconPath: _C.iconWork,
            label: '仕事運',
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
    final starSize = narrow ? 14.0 : 16.0;
    final vPad = narrow ? 10.0 : 14.0;

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
          const SizedBox(height: 8),
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
          const SizedBox(height: 8),
          // 星評価（必ず1行）
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (i) {
              return Icon(
                i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                color: i < stars ? _C.starFilled : _C.starEmpty,
                size: starSize,
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Comment card ─────────────────────────────────────────────────────────────
class _CommentCard extends StatelessWidget {
  const _CommentCard({required this.fortune, required this.narrow});
  final Fortune fortune;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final iconSize = narrow ? 36.0 : 44.0;
    final titleSize = narrow ? 12.0 : 14.0;
    final bodySize = narrow ? 13.0 : 15.0;
    final pad = narrow ? 14.0 : 18.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(pad),
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
                '占い師ウサギのひとこと',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w800,
                  color: _C.brownText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 本文
          Text(
            fortune.dailyMessage,
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

// ─── Close button ─────────────────────────────────────────────────────────────
class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 54,
      child: ElevatedButton(
        onPressed: onClose,
        style: ElevatedButton.styleFrom(
          backgroundColor: _C.closeBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 6,
          shadowColor: _C.closeShadow,
        ),
        child: const Text(
          '閉じる',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}
