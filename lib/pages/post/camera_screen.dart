import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'preview_screen.dart';

// Utility for formatting time
extension DurationFormatter on Duration {
  String get formattedTime {
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _allCameras = [];
  List<CameraDescription> _backCameras = [];
  CameraDescription? _currentCamera;

  bool _isRecording = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _timer;
  bool _showDot = true;
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _timer?.cancel();
    _blinkTimer?.cancel();
    super.dispose();
  }

  Future<void> _initCamera() async {
    try {
      _allCameras = await availableCameras();
      _backCameras =
          _allCameras
              .where((c) => c.lensDirection == CameraLensDirection.back)
              .toList();

      // Find a back camera, prioritizing '0' (often the main wide-angle).
      // Fallback to the first back camera, then the first available camera.
      final preferredCamera =
          _backCameras.isNotEmpty
              ? (_backCameras.firstWhere(
                (c) => c.name.contains('0'),
                orElse: () => _backCameras.first,
              ))
              : _allCameras.first;

      await _switchCameraTo(preferredCamera);
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _switchCameraTo(CameraDescription camera) async {
    if (_controller != null) await _controller!.dispose();

    _currentCamera = camera;
    _controller = CameraController(
      _currentCamera!,
      ResolutionPreset.ultraHigh,
      enableAudio: true,
    );

    try {
      await _controller!.initialize();
      if (mounted) setState(() {});
    } on CameraException catch (e) {
      debugPrint('Error switching camera: $e');
      // Handle initialization error (e.g., show a message)
    }
  }

  // Helper to find a camera by lens direction
  CameraDescription? _getCameraByDirection(CameraLensDirection direction) {
    return _allCameras.firstWhere(
      (c) => c.lensDirection == direction,
      orElse: () => _allCameras.first,
    );
  }

  Future<void> _toggleCameraDirection() async {
    if (_isRecording) return; // Prevent switching while recording

    final currentDirection = _currentCamera?.lensDirection;
    final newDirection =
        currentDirection == CameraLensDirection.back
            ? CameraLensDirection.front
            : CameraLensDirection.back;

    final newCamera = _getCameraByDirection(newDirection);

    // For back cameras, prefer the main '0' one if switching *to* back.
    if (newDirection == CameraLensDirection.back && _backCameras.isNotEmpty) {
      final mainBack = _backCameras.firstWhere(
        (c) => c.name.contains('0'),
        orElse: () => _backCameras.first,
      );
      await _switchCameraTo(mainBack);
    } else if (newCamera != null) {
      await _switchCameraTo(newCamera);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _controller!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> takePicture() async {
    if (!_controller!.value.isInitialized) return;

    final XFile file = await _controller!.takePicture();
    HapticFeedback.mediumImpact();

    if (mounted) {
      _navigateToPreview(file.path, isVideo: false);
    }
  }

  Future<void> startVideoRecording() async {
    if (!_controller!.value.isInitialized || _isRecording) return;

    await _controller!.startVideoRecording();
    setState(() => _isRecording = true);

    _recordingDuration = Duration.zero;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _recordingDuration += const Duration(seconds: 1));
    });

    _blinkTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      setState(() => _showDot = !_showDot);
    });
  }

  Future<void> stopVideoRecording() async {
    if (!_isRecording || !_controller!.value.isRecordingVideo) return;

    final XFile video = await _controller!.stopVideoRecording();
    _timer?.cancel();
    _blinkTimer?.cancel();

    setState(() {
      _isRecording = false;
      _showDot = true; // Reset blink state
    });

    if (mounted) {
      _navigateToPreview(video.path, isVideo: true);
    }
  }

  void _navigateToPreview(String path, {required bool isVideo}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PreviewScreen(filePath: path, isVideo: isVideo),
      ),
    );
  }

  Widget _buildCameraLensButton(
    CameraDescription camera,
    String label,
    bool isSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: ElevatedButton(
        onPressed:
            _isRecording ? null : () async => await _switchCameraTo(camera),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.white : Colors.grey.shade700,
          minimumSize: const Size(40, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.zero,
          elevation: 0,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCameraLensControls() {
    if (_currentCamera?.lensDirection != CameraLensDirection.back) {
      return const Spacer();
    }

    // Function to derive a simple label based on camera name
    String getLabel(CameraDescription cam) {
      if (cam.name.contains('5')) return '0.5x';
      if (cam.name.contains('2')) return '2x';
      if (cam.name.contains('0')) return '1x';
      return 'Cam'; // Fallback
    }

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children:
              _backCameras.map((cam) {
                final isSelected = _currentCamera == cam;
                return _buildCameraLensButton(cam, getLabel(cam), isSelected);
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _isRecording ? null : () async => await takePicture(),
      onLongPressStart:
          _isRecording
              ? null
              : (_) async {
                HapticFeedback.heavyImpact();
                await startVideoRecording();
              },
      onLongPressEnd: (_) async {
        if (_isRecording) {
          HapticFeedback.mediumImpact();
          await stopVideoRecording();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: _isRecording ? 80 : 70,
        height: _isRecording ? 80 : 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(
            color: _isRecording ? Colors.redAccent : Colors.grey.shade400,
            width: _isRecording ? 5 : 3,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchCameraButton() {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: ElevatedButton(
              onPressed: _isRecording ? null : _toggleCameraDirection,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: const Size(40, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.zero,
                elevation: 0,
              ),
              child: const Icon(
                Icons.cameraswitch,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    return Scaffold(
      body: Stack(
        children: [
          // Camera preview
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.previewSize!.height,
                height: _controller!.value.previewSize!.width,
                child: CameraPreview(_controller!),
              ),
            ),
          ),
          if (_isRecording)
            Positioned(
              top: 50,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedOpacity(
                    opacity: _showDot ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _recordingDuration.formattedTime,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          // Bottom Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCameraLensControls(), // Back camera lens options or Spacer
                _buildCaptureButton(),
                _buildSwitchCameraButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
