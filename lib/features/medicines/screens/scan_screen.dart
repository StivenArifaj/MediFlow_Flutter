import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../utils/medicine_text_parser.dart';

enum _ScanMode { ocr, barcode }
enum _ScanState { idle, processing, noText, success }

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _flashOn = false;
  _ScanMode _mode = _ScanMode.ocr;
  _ScanState _scanState = _ScanState.idle;
  String? _errorMessage;
  bool _cameraReady = false;
  bool _isCapturing = false;

  final _textRecognizer = TextRecognizer();
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) return;
      await _setupCamera(_cameras!.first);
    } catch (e) {}
  }

  Future<void> _setupCamera(CameraDescription camera) async {
    final controller = CameraController(camera, ResolutionPreset.high, enableAudio: false);
    try {
      await controller.initialize();
      if (mounted) setState(() { _cameraController = controller; _cameraReady = true; });
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) controller.dispose();
    else if (state == AppLifecycleState.resumed) _setupCamera(controller.description);
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null) return;
    try {
      await _cameraController!.setFlashMode(_flashOn ? FlashMode.off : FlashMode.torch);
      setState(() => _flashOn = !_flashOn);
    } catch (_) {}
  }

  Future<void> _capture() async {
    if (_isCapturing || _cameraController == null) return;
    setState(() { _isCapturing = true; _scanState = _ScanState.processing; _errorMessage = null; });
    try {
      final file = await _cameraController!.takePicture();
      await _processImageFile(file.path);
    } catch (e) {
      setState(() { _scanState = _ScanState.noText; _errorMessage = 'Capture failed. Please try again.'; _isCapturing = false; });
    }
  }

  Future<void> _pickFromGallery() async {
    final file = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    setState(() { _scanState = _ScanState.processing; _errorMessage = null; });
    await _processImageFile(file.path);
  }

  Future<void> _processImageFile(String path) async {
    try {
      final inputImage = InputImage.fromFilePath(path);
      final recognised = await _textRecognizer.processImage(inputImage);
      final fullText = recognised.text;
      if (fullText.trim().isEmpty) {
        setState(() { _scanState = _ScanState.noText; _errorMessage = "Couldn't read this image — try better lighting or Manual Entry."; _isCapturing = false; });
        return;
      }
      final parsed = MedicineTextParser.parse(fullText);
      if (mounted) { setState(() { _scanState = _ScanState.success; _isCapturing = false; }); context.push('/home/add-medicine', extra: parsed); }
    } catch (e) {
      setState(() { _scanState = _ScanState.noText; _errorMessage = 'Analysis failed. Please try again.'; _isCapturing = false; });
    }
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null) return;
    context.push('/home/add-medicine', extra: {'barcode': code});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: _buildCameraView()),
          if (_mode == _ScanMode.ocr) Positioned.fill(child: _ScanOverlay()),
          Positioned(top: 0, left: 0, right: 0, child: _buildTopBar()),
          Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomControls()),
          if (_scanState == _ScanState.processing) Positioned.fill(child: _ProcessingOverlay()),
          if (_scanState == _ScanState.noText && _errorMessage != null)
            Positioned(
              bottom: 120, left: AppDimensions.md, right: AppDimensions.md,
              child: _ErrorBanner(
                message: _errorMessage!,
                onDismiss: () => setState(() { _scanState = _ScanState.idle; _errorMessage = null; }),
                onManualEntry: () => context.push('/home/add-medicine'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    if (_mode == _ScanMode.barcode) return MobileScanner(onDetect: _onBarcodeDetected);
    if (!_cameraReady || _cameraController == null) {
      return Container(color: Colors.black, child: const Center(child: CircularProgressIndicator(color: AppColors.neonCyan)));
    }
    return CameraPreview(_cameraController!);
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.sm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _CircleButton(icon: Icons.close_rounded, onTap: () => context.pop()),
            Column(
              children: [
                Text(_mode == _ScanMode.ocr ? 'Scan Medicine Box' : 'Scan Barcode', style: AppTypography.titleMedium()),
                Text(_mode == _ScanMode.ocr ? 'Align medicine name within the frame' : 'Align barcode within the frame', style: AppTypography.bodySmall()),
              ],
            ),
            _CircleButton(icon: Icons.photo_library_rounded, onTap: _pickFromGallery),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppDimensions.xl, AppDimensions.md, AppDimensions.xl, AppDimensions.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModeToggle(mode: _mode, onChanged: (m) => setState(() => _mode = m)),
            const SizedBox(height: AppDimensions.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _CircleButton(icon: _flashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded, iconColor: _flashOn ? AppColors.warning : Colors.white, onTap: _toggleFlash),
                if (_mode == _ScanMode.ocr)
                  _CaptureButton(onTap: _isCapturing ? null : _capture)
                else
                  const SizedBox(width: 72, height: 72),
                GestureDetector(
                  onTap: () => context.push('/home/add-medicine'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0x33000000),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      border: Border.all(color: const Color(0x4D00E5FF)),
                    ),
                    child: Text('Manual Entry', style: AppTypography.bodySmall(color: AppColors.neonCyan)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Scan Overlay ─────────────────────────────────────────────────────────────
class _ScanOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const frameW = 280.0;
    const frameH = 180.0;
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Container(color: Colors.black54),
        Positioned(
          left: (screenW - frameW) / 2,
          top: (screenH - frameH) / 2 - 40,
          width: frameW,
          height: frameH,
          child: Container(color: Colors.transparent),
        ),
        Positioned(
          left: (screenW - frameW) / 2,
          top: (screenH - frameH) / 2 - 40,
          width: frameW,
          height: frameH,
          child: _CornerBrackets()
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 1500.ms, color: AppColors.neonCyan),
        ),
      ],
    );
  }
}

class _CornerBrackets extends StatelessWidget {
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _BracketPainter());
}

class _BracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.neonCyan
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 24.0;
    const r = 8.0;

    // Top-left
    canvas.drawLine(Offset(r, 0), Offset(len, 0), paint);
    canvas.drawLine(Offset(0, r), Offset(0, len), paint);
    canvas.drawArc(const Rect.fromLTWH(0, 0, r * 2, r * 2), -3.14, 1.57, false, paint);

    // Top-right
    canvas.drawLine(Offset(size.width - len, 0), Offset(size.width - r, 0), paint);
    canvas.drawLine(Offset(size.width, r), Offset(size.width, len), paint);
    canvas.drawArc(Rect.fromLTWH(size.width - r * 2, 0, r * 2, r * 2), -1.57, 1.57, false, paint);

    // Bottom-left
    canvas.drawLine(Offset(0, size.height - len), Offset(0, size.height - r), paint);
    canvas.drawLine(Offset(r, size.height), Offset(len, size.height), paint);
    canvas.drawArc(Rect.fromLTWH(0, size.height - r * 2, r * 2, r * 2), 1.57, 1.57, false, paint);

    // Bottom-right
    canvas.drawLine(Offset(size.width, size.height - len), Offset(size.width, size.height - r), paint);
    canvas.drawLine(Offset(size.width - len, size.height), Offset(size.width - r, size.height), paint);
    canvas.drawArc(Rect.fromLTWH(size.width - r * 2, size.height - r * 2, r * 2, r * 2), 0, 1.57, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Mode Toggle ─────────────────────────────────────────────────────────────
class _ModeToggle extends StatelessWidget {
  final _ScanMode mode;
  final ValueChanged<_ScanMode> onChanged;
  const _ModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0x33000000),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: const Color(0x4D00E5FF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleOption('OCR Text', _ScanMode.ocr),
          _toggleOption('Barcode', _ScanMode.barcode),
        ],
      ),
    );
  }

  Widget _toggleOption(String label, _ScanMode m) {
    final active = mode == m;
    return GestureDetector(
      onTap: () => onChanged(m),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          gradient: active ? AppColors.primaryGradient : null,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        child: Text(label, style: AppTypography.bodySmall(color: active ? AppColors.bgPrimary : Colors.white70)),
      ),
    );
  }
}

// ── Capture Button ──────────────────────────────────────────────────────────
class _CaptureButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _CaptureButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72, height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.neonCyan, width: 4),
          boxShadow: const [AppColors.cyanGlowStrong],
        ),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: onTap != null ? Colors.white : Colors.white38,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

// ── Circle Button ───────────────────────────────────────────────────────────
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color iconColor;
  const _CircleButton({required this.icon, this.onTap, this.iconColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: const Color(0x33000000),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0x4D00E5FF)),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }
}

// ── Processing Overlay ──────────────────────────────────────────────────────
class _ProcessingOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xBF000000),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.neonCyan, strokeWidth: 3),
            const SizedBox(height: AppDimensions.md),
            Text('Analyzing medicine...', style: AppTypography.titleMedium()),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}

// ── Error Banner ────────────────────────────────────────────────────────────
class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;
  final VoidCallback onManualEntry;
  const _ErrorBanner({required this.message, required this.onDismiss, required this.onManualEntry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
        boxShadow: const [AppDimensions.shadowMedium],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
              const SizedBox(width: AppDimensions.sm),
              Expanded(child: Text(message, style: AppTypography.bodySmall())),
              GestureDetector(onTap: onDismiss, child: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 18)),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          TextButton(
            onPressed: onManualEntry,
            child: Text('Enter Manually →', style: AppTypography.labelLarge(color: AppColors.neonCyan)),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0);
  }
}
