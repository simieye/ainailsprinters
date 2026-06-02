import 'dart:async';
import 'package:camera/camera.dart';

/// 相机服务
/// 管理相机生命周期、AR 预览、拍照功能
class CameraService {
  CameraService._();
  static final CameraService instance = CameraService._();

  CameraController? _controller;
  List<CameraDescription>? _cameras;
  final _initializedController = StreamController<bool>.broadcast();

  Stream<bool> get onInitialized => _initializedController.stream;
  CameraController? get controller => _controller;
  bool get isInitialized => _controller?.value.isInitialized ?? false;
  bool get isRecording => _controller?.value.isRecordingVideo ?? false;

  /// 初始化相机
  Future<bool> initialize({
    CameraLensDirection direction = CameraLensDirection.back,
    ResolutionPreset resolution = ResolutionPreset.high,
  }) async {
    try {
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        _initializedController.add(false);
        return false;
      }

      final camera = _cameras!.firstWhere(
        (c) => c.lensDirection == direction,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(
        camera,
        resolution,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      _initializedController.add(true);
      return true;
    } catch (e) {
      print('[CameraService] 初始化失败: $e');
      _initializedController.add(false);
      return false;
    }
  }

  /// 拍照
  Future<String?> takePicture() async {
    if (!isInitialized || _controller == null) return null;

    try {
      final image = await _controller!.takePicture();
      return image.path;
    } catch (e) {
      print('[CameraService] 拍照失败: $e');
      return null;
    }
  }

  /// 开始录像
  Future<bool> startRecording() async {
    if (!isInitialized || _controller == null) return false;

    try {
      await _controller!.startVideoRecording();
      return true;
    } catch (e) {
      print('[CameraService] 录像开始失败: $e');
      return false;
    }
  }

  /// 停止录像
  Future<String?> stopRecording() async {
    if (!isRecording || _controller == null) return null;

    try {
      final video = await _controller!.stopVideoRecording();
      return video.path;
    } catch (e) {
      print('[CameraService] 录像停止失败: $e');
      return null;
    }
  }

  /// 切换闪光灯
  Future<void> toggleFlash() async {
    if (!isInitialized || _controller == null) return;

    final currentMode = _controller!.value.flashMode;
    final newMode = currentMode == FlashMode.off
        ? FlashMode.torch
        : FlashMode.off;

    await _controller!.setFlashMode(newMode);
  }

  /// 释放相机资源
  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
    _initializedController.close();
  }
}
