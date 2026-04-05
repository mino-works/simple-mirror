import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/fortune_provider.dart';
import '../models/fortune.dart';
import '../widgets/hamster_widget.dart';
import '../utils/fortune_generator.dart';

class FortuneResultScreen extends ConsumerStatefulWidget {
  const FortuneResultScreen({super.key});

  @override
  ConsumerState<FortuneResultScreen> createState() =>
      _FortuneResultScreenState();
}

class _FortuneResultScreenState extends ConsumerState<FortuneResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _badgeController;
  late final Animation<double> _badgeScale;
  bool _showBadge = false;

  @override
  void initState() {
    super.initState();
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _badgeScale = Tween<double>(begin: 0.0, end: 1.1).animate(
      CurvedAnimation(parent: _badgeController, curve: Curves.elasticOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      setState(() => _showBadge = true);
      _badgeController.forward();
    });
  }

  @override
  void dispose() {
    _badgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 18),
              _buildTitle(),
              const SizedBox(height: 14),
              Expanded(
                child: Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _build3DFortuneCard(context, fortune),
                      if (_showBadge) _buildBadgePopup(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
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
                        elevation: 5,
                        shadowColor: const Color(0x55FF6E99),
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
    return Column(
      children: [
        Text(
          '今日の占い結果',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: Colors.grey.shade800,
            shadows: const [
              Shadow(
                color: Colors.white70,
                offset: Offset(1, 1),
                blurRadius: 3,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          '3Dカードとバッジ獲得演出で盛り上げよう！',
          style: TextStyle(fontSize: 14, color: Color(0xFF8C7CAB)),
        ),
      ],
    );
  }

  Widget _buildBadgePopup() {
    return Positioned(
      right: -22,
      top: -22,
      child: ScaleTransition(
        scale: _badgeScale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFE07A), Color(0xFFFF8C8C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.emoji_events, color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text(
                'バッジ獲得！',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _build3DFortuneCard(BuildContext context, Fortune fortune) {
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateX(-0.045)
      ..rotateY(0.03)
      ..rotateZ(0);

    final totalScore = fortune.loveLuck + fortune.moneyLuck + fortune.workLuck;

    return Transform(
      transform: matrix,
      origin: const Offset(0, 0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.88,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFEFEFF), Color(0xFFF9F4FF)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.22),
              blurRadius: 28,
              offset: const Offset(0, 18),
            ),
          ],
          border: Border.all(color: Colors.purple.shade100, width: 1.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTopInfo(fortune, totalScore),
            const SizedBox(height: 20),
            _buildLuckBar('恋愛', fortune.loveLuck, Colors.pink.shade300),
            const SizedBox(height: 10),
            _buildLuckBar('金運', fortune.moneyLuck, Colors.amber.shade400),
            const SizedBox(height: 10),
            _buildLuckBar('仕事', fortune.workLuck, Colors.blue.shade300),
            const SizedBox(height: 16),
            _buildResultMessage(fortune),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueGrey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'バッジ: ${_badgeLabel(totalScore)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopInfo(Fortune fortune, int totalScore) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFB683FF), Color(0xFFFEA4A4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.25),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Center(
            child: HamsterWidget(expression: fortune.expression, size: 62),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fortune.overallTitle,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.purple.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '総合 ${totalScore ~/ 3} / 100',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              LinearProgressIndicator(
                value: (totalScore / 300).clamp(0.0, 1.0),
                color: _getLuckColor(totalScore),
                backgroundColor: Colors.purple.shade50,
                minHeight: 6,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLuckBar(String label, int value, Color color) {
    final ratio = (value / 100).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            Text(
              ' $value/100',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 12,
            color: Colors.grey.shade200,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: ratio,
              child: Container(color: color),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultMessage(Fortune fortune) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.pink.shade50.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        fortune.dailyMessage,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        textAlign: TextAlign.center,
      ),
    );
  }

  Color _getLuckColor(int totalScore) {
    if (totalScore >= 240) return Colors.deepPurpleAccent;
    if (totalScore >= 180) return Colors.indigo;
    if (totalScore >= 120) return Colors.blue;
    return Colors.lightBlue;
  }

  String _badgeLabel(int totalScore) {
    if (totalScore >= 240) return 'プラチナ 🔥';
    if (totalScore >= 180) return 'ゴールド 🌟';
    if (totalScore >= 120) return 'シルバー 🎖️';
    return 'ブロンズ 🥉';
  }

  Widget _buildFortuneRow({
    required String label,
    required int value,
    required Color color,
    bool isMain = true,
  }) {
    final int stars = ((value / 20).round()).clamp(0, 5);
    final starsString = '★' * stars + '☆' * (5 - stars);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: isMain ? 60 : 50,
          child: Text(
            label,
            style: TextStyle(
              fontSize: isMain ? 14 : 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            starsString,
            style: TextStyle(
              color: color,
              fontSize: isMain ? 16 : 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFortuneCard(Fortune fortune, {required bool isMain}) {
    return Container();
  }
}
