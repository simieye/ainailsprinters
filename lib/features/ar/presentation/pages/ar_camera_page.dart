import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/camera_service.dart';
import '../../../../core/services/nanobanana_service.dart';

/// AR 相机预览页面（真实相机实现）
/// 支持手指识别、甲面定位、实时预览
class ArCameraPage extends ConsumerStatefulWidget {
  final String? designId;

  const ArCameraPage({super.key, this.designId});

  @override
  ConsumerState<ArCameraPage> createState() => _ArCameraPageState();
}

class _ArCameraPageState extends ConsumerState<ArCameraPage>
    with WidgetsBindingObserver {
  final CameraService _cameraService = CameraService.instance;
  bool _isCameraReady = false;
  bool _isFlashOn = false;
  NailShape _selectedShape = NailShape.almond;
  int _selectedFinger = 0; // 拇指
  Timer? _scanTimer;

  static const List<String> fingerNames = [
    '拇指',
    '食指',
    '中指',
    '无名指',
    '小指',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanTimer?.cancel();
    _cameraService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    final success = await _cameraService.initialize();
    if (mounted) {
      setState(() => _isCameraReady = success);
      if (success) {
        _startScanAnimation();
      }
    }
  }

  void _startScanAnimation() {
    _scanTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _toggleFlash() async {
    await _cameraService.toggleFlash();
    setState(() => _isFlashOn = !_isFlashOn);
  }

  Future<void> _takePhoto() async {
    final path = await _cameraService.takePicture();
    if (path != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('拍照成功: $path'),
          backgroundColor: AppTheme.primaryNeonGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 相机预览
            if (_isCameraReady && _cameraService.controller != null)
              CameraPreview(_cameraService.controller!)
            else
              _buildCameraPlaceholder(),

            // AR 扫描线
            _buildArOverlay(),

            // 手指选择器
            _buildFingerSelector(),

            // 甲型选择器
            _buildShapeSelector(),

            // 顶部工具栏
            _buildTopToolbar(),

            // 底部操作栏
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPlaceholder() {
    return Container(
      color: AppTheme.bgDeepDark,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined,
                color: AppTheme.textHint, size: 64),
            SizedBox(height: 16),
            Text(
              '正在初始化相机...',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArOverlay() {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ArScanPainter(),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildFingerSelector() {
    return Positioned(
      bottom: 140,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 5,
          itemBuilder: (context, index) {
            final isSelected = _selectedFinger == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedFinger = index),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryNeonGreen.withOpacity(0.2)
                      : AppTheme.bgSurfaceDark.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryNeonGreen
                        : AppTheme.borderGlow,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  fingerNames[index],
                  style: TextStyle(
                    color: isSelected
                        ? AppTheme.primaryNeonGreen
                        : AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildShapeSelector() {
    return Positioned(
      bottom: 200,
      right: 16,
      child: Column(
        children: NailShape.values.map((shape) {
          final isSelected = _selectedShape == shape;
          return GestureDetector(
            onTap: () => setState(() => _selectedShape = shape),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.secondaryNeonPurple.withOpacity(0.2)
                    : AppTheme.bgSurfaceDark.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.secondaryNeonPurple
                      : AppTheme.borderGlow,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Icon(
                _shapeIcon(shape),
                size: 20,
                color: isSelected
                    ? AppTheme.secondaryNeonPurple
                    : AppTheme.textHint,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _shapeIcon(NailShape shape) {
    return switch (shape) {
      NailShape.almond => Icons.circle,
      NailShape.square => Icons.crop_square,
      NailShape.oval => Icons.circle_outlined,
      NailShape.coffin => Icons.rectangle,
      NailShape.stiletto => Icons.change_history,
      NailShape.round => Icons.circle,
    };
  }

  Widget _buildTopToolbar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            // 返回按钮
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const Spacer(),
            // V-ALIGN 3D 状态
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryNeonGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryNeonGreen.withOpacity(0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryNeonGreen,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'V-ALIGN 3D',
                    style: TextStyle(
                      color: AppTheme.primaryNeonGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // 闪光灯
            IconButton(
              icon: Icon(
                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
              ),
              onPressed: _toggleFlash,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 提示文字
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              '请将手指对准框内，AR 自动识别甲面',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
          ),
          // 操作按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 拍照
              GestureDetector(
                onTap: _takePhoto,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 32),
              // 确认设计·打印
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    '/print-confirm',
                    arguments: {
                      'shape': _selectedShape.name,
                      'finger': _selectedFinger,
                    },
                  );
                },
                icon: const Icon(Icons.print, size: 20),
                label: const Text('确认设计·准备打印'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNeonGreen,
                  foregroundColor: AppTheme.bgDeepDark,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// AR 扫描线画笔
class _ArScanPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryNeonGreen.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // 绘制手指定位框
    final boxWidth = size.width * 0.5;
    final boxHeight = size.height * 0.35;
    final left = (size.width - boxWidth) / 2;
    final top = size.height * 0.15;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, boxWidth, boxHeight),
      const Radius.circular(24),
    );

    // 外框
    canvas.drawRRect(rect, paint);

    // 角标
    final cornerLength = 30.0;
    final corners = [
      Offset(left, top), // 左上
      Offset(left + boxWidth, top), // 右上
      Offset(left, top + boxHeight), // 左下
      Offset(left + boxWidth, top + boxHeight), // 右下
    ];

    for (final corner in corners) {
      final isLeft = corner.dx == left;
      final isTop = corner.dy == top;

      canvas.drawLine(
        corner,
        Offset(
          corner.dx + (isLeft ? cornerLength : -cornerLength),
          corner.dy,
        ),
        paint..color = AppTheme.primaryNeonGreen,
      );
      canvas.drawLine(
        corner,
        Offset(
          corner.dx,
          corner.dy + (isTop ? cornerLength : -cornerLength),
        ),
        paint..color = AppTheme.primaryNeonGreen,
      );
    }

    // 扫描线动画
    final now = DateTime.now().millisecondsSinceEpoch;
    final scanY = top +
        ((now % 3000) / 3000) * boxHeight;

    final scanPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.primaryNeonGreen.withOpacity(0),
          AppTheme.primaryNeonGreen.withOpacity(0.5),
          AppTheme.primaryNeonGreen.withOpacity(0),
        ],
      ).createShader(Rect.fromLTWH(left, scanY - 10, boxWidth, 20));

    canvas.drawRect(
      Rect.fromLTWH(left, scanY - 1, boxWidth, 2),
      scanPaint,
    );

    // 网格线
    final gridPaint = Paint()
      ..color = AppTheme.borderGlow.withOpacity(0.2)
      ..strokeWidth = 0.5;

    for (double y = top; y <= top + boxHeight; y += 30) {
      canvas.drawLine(
        Offset(left, y),
        Offset(left + boxWidth, y),
        gridPaint,
      );
    }
    for (double x = left; x <= left + boxWidth; x += 30) {
      canvas.drawLine(
        Offset(x, top),
        Offset(x, top + boxHeight),
        gridPaint,
      );
    }

    // 提示文字
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '将手指置于框内',
        style: TextStyle(
          color: AppTheme.primaryNeonGreen,
          fontSize: 14,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        top + boxHeight + 16,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
