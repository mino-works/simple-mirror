import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/fortune_provider.dart';
import '../models/fortune.dart';
import '../widgets/hamster_widget.dart';

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
            colors: [Color(0xFFFFD6E7), Color(0xFFFFF0F5)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildTitle(),
              const SizedBox(height: 14),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildFortuneCard(fortune),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: Center(
                  child: SizedBox(
                    width: 220,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7FA3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 6,
                        shadowColor: const Color(0x66FF6E99),
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      '今日の運勢',
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w900,
        color: Colors.grey.shade800,
        shadows: const [
          Shadow(color: Colors.white70, offset: Offset(1, 1), blurRadius: 3),
        ],
      ),
    );
  }

  Widget _buildFortuneCard(Fortune fortune) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.purple.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.18),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTopBlock(fortune),
          const SizedBox(height: 22),
          _buildDivider(),
          const SizedBox(height: 18),
          _buildMiddleBlock(fortune),
          const SizedBox(height: 18),
          _buildDivider(),
          const SizedBox(height: 18),
          _buildCommentBox(fortune),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.pink.shade100,
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  // ▼上段: キャラクター（左）＋ 総合評価ラベル（右）
  Widget _buildTopBlock(Fortune fortune) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // キャラクター
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFB683FF), Color(0xFFFEA4A4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withValues(alpha: 0.22),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: HamsterWidget(expression: fortune.expression, size: 62),
          ),
        ),
        const SizedBox(width: 16),
        // 総合評価
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '総合評価',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7FA3),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF7FA3).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  fortune.overallTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ▼中段: 恋愛運 / 金運 / 仕事運（星評価＋色付き帯）
  Widget _buildMiddleBlock(Fortune fortune) {
    return Column(
      children: [
        _buildLuckRow('恋愛運', fortune.loveLuck, const Color(0xFFFF7FA3)),
        const SizedBox(height: 12),
        _buildLuckRow('金　運', fortune.moneyLuck, const Color(0xFFFFBB00)),
        const SizedBox(height: 12),
        _buildLuckRow('仕事運', fortune.workLuck, const Color(0xFF5B9CF6)),
      ],
    );
  }

  Widget _buildLuckRow(String label, int value, Color color) {
    final int stars = ((value / 20).round()).clamp(0, 5);
    final double fill = (value / 100).clamp(0.0, 1.0);

    return Row(
      children: [
        SizedBox(
          width: 48,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF666666),
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                // 背景
                Container(
                  height: 34,
                  color: color.withValues(alpha: 0.10),
                ),
                // 色付き帯
                FractionallySizedBox(
                  widthFactor: fill,
                  child: Container(
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withValues(alpha: 0.45), color.withValues(alpha: 0.25)],
                      ),
                    ),
                  ),
                ),
                // 星アイコン
                SizedBox(
                  height: 34,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return Icon(
                        i < stars
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: i < stars ? color : color.withValues(alpha: 0.35),
                        size: 22,
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ▼下段: コメントボックス
  Widget _buildCommentBox(Fortune fortune) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCCDD), width: 1),
      ),
      child: Text(
        fortune.dailyMessage,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF555555),
          height: 1.8,
        ),
        textAlign: TextAlign.center,
        softWrap: true,
      ),
    );
  }
}
