import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/fortune_provider.dart';
import '../widgets/hamster_widget.dart';
import '../models/fortune.dart';
import 'fortune_result_screen.dart';

enum _BubbleState { inProgress, ready }

class MirrorScreen extends ConsumerStatefulWidget {
  const MirrorScreen({super.key});

  @override
  ConsumerState<MirrorScreen> createState() => _MirrorScreenState();
}

class _MirrorScreenState extends ConsumerState<MirrorScreen>
    with TickerProviderStateMixin {
  CameraController? _controller;
  _BubbleState _bubbleState = _BubbleState.inProgress;
  bool _isMirrorMode = true;
  double _minExposure = -2.0;
  double _maxExposure = 2.0;
  double _exposureValue = 0.0;
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
      }
    } catch (_) {}

    if (mounted) {
      setState(() {});
      _startFortuneFlow();
    }
  }

  // カメラ権限を確認・リクエストする。true = 許可済み
  Future<bool> _requestCameraPermission() async {
    var status = await Permission.camera.status;

    // 未確認の場合はリクエストダイアログを表示
    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    if (status.isGranted) return true;

    // 永久に拒否された場合は設定画面へ誘導
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

    // 占い中... のまま3秒待つ
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

  void _goToResult() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const FortuneResultScreen()));
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

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // カメラ映像（全画面）
          Positioned.fill(child: _buildCameraPreview()),

          // 右上：キャラクター + 吹き出し
          Positioned(top: top + 20, right: 16, child: _buildCharacterArea()),

          // 左下：明るさスライダー
          Positioned(
            bottom: bottom + 24,
            left: 16,
            right: 16,
            child: _buildBottomControls(),
          ),
        ],
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
    // previewSize はランドスケープ基準なので、ポートレートでは height/width を入れ替える
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
    // 他人から見た自分: さらに反転
    if (!_isMirrorMode) {
      return Transform.scale(scaleX: -1, child: camera);
    }
    return camera;
  }

  Widget _buildCharacterArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 吹き出し
        GestureDetector(
          onTap: _bubbleState == _BubbleState.ready ? _goToResult : null,
          child: _SpeechBubble(
            text: _bubbleState == _BubbleState.inProgress ? '占い中...' : '占い完了！',
            isReady: _bubbleState == _BubbleState.ready,
          ),
        ),
        const SizedBox(height: 6),
        // バウンドするキャラクター（タップ可能）
        GestureDetector(
          onTap: _bubbleState == _BubbleState.ready ? _goToResult : null,
          child: AnimatedBuilder(
            animation: _bounceAnim,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, _bounceAnim.value),
              child: child,
            ),
            child: HamsterWidget(
              expression: _bubbleState == _BubbleState.ready
                  ? HamsterExpression.cheer
                  : HamsterExpression.normal,
              size: 72,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 明るさスライダー（左寄り）
        Expanded(child: _buildBrightnessSlider()),
        const SizedBox(width: 12),
        // ミラー切替（右）
        _buildMirrorToggle(),
      ],
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
          const Icon(
            Icons.brightness_4_rounded,
            color: Colors.white54,
            size: 18,
          ),
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

  Widget _buildMirrorToggle() {
    return GestureDetector(
      onTap: () => setState(() => _isMirrorMode = !_isMirrorMode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _isMirrorMode
              ? Colors.white.withAlpha(220)
              : Colors.black.withAlpha(130),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withAlpha(100), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isMirrorMode ? Icons.flip : Icons.person_outline_rounded,
              color: _isMirrorMode ? Colors.black87 : Colors.white,
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              _isMirrorMode ? 'ミラー' : '他人から',
              style: TextStyle(
                color: _isMirrorMode ? Colors.black87 : Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
          duration: const Duration(milliseconds: 300),
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
            style: TextStyle(
              fontSize: 14,
              fontWeight: isReady ? FontWeight.bold : FontWeight.normal,
              color: isReady ? Colors.pink.shade700 : const Color(0xFF444444),
            ),
          ),
        ),
        // 三角テイル
        Positioned(
          bottom: -7,
          right: 20,
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
