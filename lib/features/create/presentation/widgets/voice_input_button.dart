import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/di/providers.dart';
import 'dart:async';

class VoiceInputButton extends ConsumerStatefulWidget {
  const VoiceInputButton({super.key});

  @override
  ConsumerState<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends ConsumerState<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  bool _isListening = false;
  Timer? _mockTimer;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _mockTimer?.cancel();
    super.dispose();
  }

  void _toggleListening() {
    setState(() => _isListening = !_isListening);
    ref.read(isListeningProvider.notifier).state = _isListening;

    if (_isListening) {
      _waveController.repeat(reverse: true);
      // 模拟语音识别
      _mockTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        final mockPhrases = [
          '赛博朋克风格',
          '深蓝色微光',
          '蝴蝶翅膀纹理',
          '霓虹紫渐变',
        ];
        final phrase = mockPhrases[timer.tick % mockPhrases.length];
        ref.read(voiceTextProvider.notifier).state = phrase;
      });
    } else {
      _waveController.stop();
      _waveController.reset();
      _mockTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleListening,
      child: AnimatedBuilder(
        animation: _waveController,
        builder: (context, child) {
          return Container(
            width: _isListening ? 48 : 40,
            height: _isListening ? 48 : 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isListening
                  ? AppTheme.accentNeonPink.withOpacity(0.2)
                  : AppTheme.bgElevatedDark,
              border: Border.all(
                color: _isListening
                    ? AppTheme.accentNeonPink
                    : AppTheme.borderGlow.withOpacity(0.4),
                width: _isListening ? 2 : 1,
              ),
              boxShadow: _isListening
                  ? [
                      BoxShadow(
                        color: AppTheme.accentNeonPink.withOpacity(
                          0.3 * _waveController.value,
                        ),
                        blurRadius: 15 * _waveController.value,
                        spreadRadius: 2 * _waveController.value,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              size: 20,
              color: _isListening
                  ? AppTheme.accentNeonPink
                  : AppTheme.textSecondary,
            ),
          );
        },
      ),
    );
  }
}
