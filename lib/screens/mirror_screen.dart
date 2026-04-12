import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/fortune_provider.dart';
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

  Future<void> _onZoomChanged(double value) async {
    setState(() => _zoomValue = value);
    try {
      await _controller!.setZoomLevel(value);
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

          // 上部：明るさスライダー（キャラクターと重ならないよう右マージン）
          Positioned(
            top: top + 16,
            left: 16,
            right: 130,
            child: _buildBrightnessSlider(),
          ),

          // 右上：キャラクター + 吹き出し
          Positioned(top: top + 20, right: 16, child: _buildCharacterArea()),

          // 下部：ズームスライダー + ミラー切替
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
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _bubbleState == _BubbleState.ready
                    ? Colors.white
                    : const Color(0xFFCCCCCC),
                border: Border.all(
                  color: _bubbleState == _BubbleState.ready
                      ? const Color(0xFFFFB5D0)
                      : const Color(0xFF999999),
                  width: 2.5,
                ),
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: ColorFiltered(
                    colorFilter: _bubbleState == _BubbleState.ready
                        ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
                        : const ColorFilter.matrix([
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0,      0,      0,      1, 0,
                          ]),
                    child: Image.asset(
                      'assets/images/fortune.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
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
        Expanded(child: _buildZoomSlider()),
        const SizedBox(width: 12),
        _buildMirrorToggle(),
      ],
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
                value: _zoomValue,
                min: _minZoom,
                max: _maxZoom.clamp(1.0, 3.0),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(130),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(60), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption('ミラー', _isMirrorMode),
          _buildToggleOption('他人から', !_isMirrorMode),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String label, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => _isMirrorMode = label == 'ミラー'),
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
