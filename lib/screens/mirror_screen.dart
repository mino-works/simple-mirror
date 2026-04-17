import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../l10n/app_localizations.dart';
import '../providers/fortune_provider.dart';
import '../providers/progress_provider.dart';
import '../utils/fortune_generator.dart';
import 'fortune_result_screen.dart';
import 'costume_screen.dart';
import 'menu_drawer.dart';

enum _BubbleState { inProgress, ready }

class MirrorScreen extends ConsumerStatefulWidget {
  const MirrorScreen({super.key});

  @override
  ConsumerState<MirrorScreen> createState() => _MirrorScreenState();
}

class _MirrorScreenState extends ConsumerState<MirrorScreen>
    with TickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  CameraController? _controller;
  _BubbleState _bubbleState = _BubbleState.inProgress;
  bool _isMirrorMode = true;
  double _minExposure = -2.0;
  double _maxExposure = 2.0;
  double _exposureValue = 0.0;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _zoomValue = 1.0;
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _bounceAnim = Tween(
      begin: 0.0,
      end: -6.0,
    ).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut));
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final status = await _requestCameraPermission();
    if (!status) {
      if (mounted) {
        setState(() {});
        _startFortuneFlow();
      }
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        final front = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        );
        _controller = CameraController(front, ResolutionPreset.veryHigh, enableAudio: false);
        await _controller!.initialize();
        try {
          _minExposure = await _controller!.getMinExposureOffset();
          _maxExposure = await _controller!.getMaxExposureOffset();
        } catch (_) {}
        try {
          _minZoom = await _controller!.getMinZoomLevel();
          _maxZoom = await _controller!.getMaxZoomLevel();
        } catch (_) {}
      }
    } catch (_) {}

    if (mounted) {
      setState(() {});
      _startFortuneFlow();
    }
  }

  Future<bool> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      status = await Permission.camera.request();
    }
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied && mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('カメラの許可が必要です'),
          content: const Text('鏡として使うにはカメラの許可が必要です。設定から許可してください。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await openAppSettings();
              },
              child: const Text('設定を開く'),
            ),
          ],
        ),
      );
    }
    return false;
  }

  Future<void> _startFortuneFlow() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final existing = ref.read(fortuneProvider);
    if (existing != null) {
      setState(() => _bubbleState = _BubbleState.ready);
      return;
    }

    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    await ref.read(fortuneProvider.notifier).generateAndSaveFortune();
    if (mounted) setState(() => _bubbleState = _BubbleState.ready);
  }

  Future<void> _onExposureChanged(double value) async {
    setState(() => _exposureValue = value);
    try {
      await _controller!.setExposureOffset(value);
    } catch (_) {}
  }

  Future<void> _onZoomChanged(double value) async {
    setState(() => _zoomValue = value);
    try {
      await _controller!.setZoomLevel(value);
    } catch (_) {}
  }

  void _goToResult() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FortuneResultScreen()));
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;
    final l = AppLocalizations.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      drawer: const MenuDrawer(),
      body: Stack(
        children: [
          // カメラ映像（全画面）
          Positioned.fill(child: _buildCameraPreview()),

          // 上部: ハンバーガー ＋ 明るさスライダー ＋ ミラートグル
          Positioned(
            top: top + 16,
            left: 16,
            right: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHamburgerButton(),
                const SizedBox(width: 8),
                Expanded(child: _buildBrightnessSlider()),
                const SizedBox(width: 8),
                _buildMirrorToggle(l),
              ],
            ),
          ),

          // デバッグボタン（明るさスライダーの下）
          Positioned(
            top: top + 70,
            left: 16,
            child: _buildDebugButton(),
          ),

          // 左下: ズームスライダー
          Positioned(
            bottom: bottom + 20,
            left: 16,
            right: 160,
            child: _buildZoomSlider(),
          ),

          // 右下: 占いアイコン + 着せ替えアイコン
          Positioned(
            bottom: bottom + 16,
            right: 16,
            child: _buildBottomRightIcons(l),
          ),
        ],
      ),
    );
  }

  Widget _buildHamburgerButton() {
    return GestureDetector(
      onTap: () => _scaffoldKey.currentState?.openDrawer(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(130),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withAlpha(60), width: 1),
        ),
        child: const Icon(Icons.menu_rounded, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF2d1b4e)],
          ),
        ),
      );
    }
    final previewSize = _controller!.value.previewSize!;
    Widget camera = SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: previewSize.height,
          height: previewSize.width,
          child: CameraPreview(_controller!),
        ),
      ),
    );
    if (!_isMirrorMode) {
      return Transform.scale(scaleX: -1, child: camera);
    }
    return camera;
  }

  Widget _buildBottomRightIcons(AppLocalizations l) {
    final isReady = _bubbleState == _BubbleState.ready;
    const iconSize = 56.0;
    const gap = 4.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // アイコン2つのRow（幅: 56 + 4 + 56 = 116px）
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 着せ替えアイコン
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CostumeScreen()),
              ),
              child: _buildIconCircle(
                borderColor: const Color(0xFFCCA8E8),
                bgColor: Colors.white,
                child: const Icon(Icons.checkroom_rounded, color: Color(0xFF9B6DD6), size: 26),
              ),
            ),
            const SizedBox(width: gap),
            // 占いアイコン
            GestureDetector(
              onTap: isReady ? _goToResult : null,
              child: AnimatedBuilder(
                animation: _bounceAnim,
                builder: (context, child) => Transform.translate(
                  offset: isReady ? Offset(0, _bounceAnim.value) : Offset.zero,
                  child: child,
                ),
                child: _buildIconCircle(
                  borderColor: isReady ? const Color(0xFFFFB5D0) : const Color(0xFF999999),
                  bgColor: isReady ? Colors.white : const Color(0xFFCCCCCC),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: ColorFiltered(
                        colorFilter: isReady
                            ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
                            : const ColorFilter.matrix([
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0,      0,      0,      1, 0,
                              ]),
                        child: Image.asset('assets/images/fortune.png', fit: BoxFit.contain),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        // 吹き出し: Stackの外側（上方）に絶対配置。レイアウト幅に影響させない
        Positioned(
          right: 0,
          bottom: iconSize + 6,
          child: GestureDetector(
            onTap: isReady ? _goToResult : null,
            child: _SpeechBubble(
              text: isReady ? l.get('fortune_done') : l.get('divining'),
              isReady: isReady,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconCircle({
    required Color borderColor,
    required Color bgColor,
    required Widget child,
  }) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
        border: Border.all(color: borderColor, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildZoomSlider() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(130),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.zoom_out_rounded, color: Colors.white54, size: 18),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.white30,
                thumbColor: Colors.white,
                overlayColor: Colors.white24,
              ),
              child: Slider(
                value: _zoomValue.clamp(_minZoom, _maxZoom.clamp(_minZoom + 0.01, 3.0)),
                min: _minZoom,
                max: _maxZoom.clamp(_minZoom + 0.01, 3.0),
                onChanged: _onZoomChanged,
              ),
            ),
          ),
          const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 18),
        ],
      ),
    );
  }

  Widget _buildBrightnessSlider() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(130),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.brightness_4_rounded, color: Colors.white54, size: 18),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.white30,
                thumbColor: Colors.white,
                overlayColor: Colors.white24,
              ),
              child: Slider(
                value: _exposureValue,
                min: _minExposure,
                max: _maxExposure,
                onChanged: _onExposureChanged,
              ),
            ),
          ),
          const Icon(Icons.brightness_7_rounded, color: Colors.white, size: 18),
        ],
      ),
    );
  }

  Widget _buildDebugButton() {
    return GestureDetector(
      onTap: () => _showDebugFortuneSheet(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.orange.withAlpha(200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'TEST',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  void _showDebugFortuneSheet() {
    final fortunes = FortuneGenerator.getAllFortunes();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Consumer(
          builder: (ctx, r, _) {
            final progress = r.watch(progressProvider);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── ログイン日数セクション ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        '📅 累計ログイン日数: ${progress.totalDays}日',
                        style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: Row(
                    children: [
                      _debugDayBtn('+1日', () => r.read(progressProvider.notifier).debugAddDays(1)),
                      const SizedBox(width: 8),
                      _debugDayBtn('+7日', () => r.read(progressProvider.notifier).debugAddDays(7)),
                      const SizedBox(width: 8),
                      _debugDayBtn('+14日', () => r.read(progressProvider.notifier).debugAddDays(14)),
                      const SizedBox(width: 8),
                      _debugDayBtn('リセット', () => r.read(progressProvider.notifier).debugResetDays(),
                          color: Colors.redAccent),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),
                // ── 占い選択セクション ──
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    '結果画面を選択',
                    style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: fortunes.length,
                    separatorBuilder: (_, _) => const Divider(color: Colors.white12, height: 1),
                    itemBuilder: (_, i) {
                      final f = fortunes[i];
                      return ListTile(
                        dense: true,
                        leading: Text('${i + 1}',
                            style: const TextStyle(color: Colors.white38, fontSize: 12)),
                        title: Text(f.overallTitle,
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                        subtitle: Text(
                          '総合${f.overallLuck} / 恋${f.loveLuck} / 金${f.moneyLuck} / 仕${f.workLuck}',
                          style: const TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          ref.read(fortuneProvider.notifier).setFortune(f);
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const FortuneResultScreen()),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _debugDayBtn(String label, VoidCallback onTap, {Color color = Colors.orange}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(180),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildMirrorToggle(AppLocalizations l) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(130),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(60), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption(l.get('mirror'), isMirrorMode: true),
          _buildToggleOption(l.get('others_view'), isMirrorMode: false),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String label, {required bool isMirrorMode}) {
    final isActive = _isMirrorMode == isMirrorMode;
    return GestureDetector(
      onTap: () => setState(() => _isMirrorMode = isMirrorMode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withAlpha(220) : Colors.transparent,
          borderRadius: BorderRadius.circular(19),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black87 : Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ─── 吹き出しウィジェット ────────────────────────────────────────

class _SpeechBubble extends StatelessWidget {
  final String text;
  final bool isReady;

  const _SpeechBubble({required this.text, required this.isReady});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomRight,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(minWidth: 96),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isReady ? Colors.pink.shade100 : Colors.white.withAlpha(230),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isReady ? Colors.pink.shade300 : Colors.grey.shade300,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(30),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isReady ? FontWeight.bold : FontWeight.normal,
              color: isReady ? Colors.pink.shade700 : const Color(0xFF444444),
            ),
          ),
        ),
        // 三角テイル（アイコン中心に合わせて right: 22 = アイコン半径 28px から右端）
        Positioned(
          bottom: -7,
          right: 22,
          child: CustomPaint(
            size: const Size(12, 7),
            painter: _TailPainter(
              fill: isReady ? Colors.pink.shade100 : Colors.white,
              border: isReady ? Colors.pink.shade300 : Colors.grey.shade300,
            ),
          ),
        ),
      ],
    );
  }
}

class _TailPainter extends CustomPainter {
  final Color fill;
  final Color border;
  const _TailPainter({required this.fill, required this.border});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height)
        ..close(),
      Paint()..color = border,
    );
    canvas.drawPath(
      Path()
        ..moveTo(1.5, 0)
        ..lineTo(size.width - 1.5, 0)
        ..lineTo(size.width / 2, size.height - 1.5)
        ..close(),
      Paint()..color = fill,
    );
  }

  @override
  bool shouldRepaint(_TailPainter old) =>
      old.fill != fill || old.border != border;
}
