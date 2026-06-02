import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// 语音输入服务
/// 支持实时语音识别、多语言语音输入
class VoiceInputService {
  VoiceInputService._();
  static final VoiceInputService instance = VoiceInputService._();

  final stt.SpeechToText _speech = stt.SpeechToText();
  final _textController = StreamController<String>.broadcast();
  final _statusController = StreamController<VoiceInputStatus>.broadcast();

  Stream<String> get recognizedText => _textController.stream;
  Stream<VoiceInputStatus> get statusStream => _statusController.stream;

  VoiceInputStatus _status = VoiceInputStatus.idle;
  VoiceInputStatus get status => _status;
  bool get isListening => _status == VoiceInputStatus.listening;
  bool get isAvailable => _speech.isAvailable;
  bool get isNotAvailable => !_speech.isAvailable;

  /// 初始化语音识别
  Future<bool> initialize() async {
    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          switch (status) {
            case stt.SpeechToText.listeningStatus:
              _updateStatus(VoiceInputStatus.listening);
              break;
            case stt.SpeechToText.notListeningStatus:
              _updateStatus(VoiceInputStatus.idle);
              break;
            case stt.SpeechToText.doneStatus:
              _updateStatus(VoiceInputStatus.done);
              break;
          }
        },
        onError: (error) {
          _updateStatus(VoiceInputStatus.error);
          print('[VoiceInput] 错误: $error');
        },
      );
      return available;
    } catch (e) {
      print('[VoiceInput] 初始化失败: $e');
      return false;
    }
  }

  /// 开始监听
  Future<bool> startListening({
    String localeId = 'zh_CN',
  }) async {
    if (_status == VoiceInputStatus.listening) return true;

    try {
      final started = await _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            _textController.add(result.recognizedWords);
            _updateStatus(VoiceInputStatus.done);
          } else {
            // 实时识别结果
            _textController.add(result.recognizedWords);
          }
        },
        localeId: localeId,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        listenMode: stt.ListenMode.confirmation,
      );

      if (started) {
        _updateStatus(VoiceInputStatus.listening);
      }

      return started;
    } catch (e) {
      _updateStatus(VoiceInputStatus.error);
      print('[VoiceInput] 启动监听失败: $e');
      return false;
    }
  }

  /// 停止监听
  Future<void> stopListening() async {
    await _speech.stop();
    _updateStatus(VoiceInputStatus.idle);
  }

  /// 取消监听
  Future<void> cancelListening() async {
    await _speech.cancel();
    _updateStatus(VoiceInputStatus.idle);
  }

  /// 获取支持的语言
  List<VoiceLanguage> get supportedLanguages {
    final locales = _speech.locales();
    return locales
        .map((l) => VoiceLanguage(
              localeId: l.localeId,
              name: l.name,
            ))
        .toList();
  }

  void _updateStatus(VoiceInputStatus status) {
    _status = status;
    _statusController.add(status);
  }

  void dispose() {
    _speech.cancel();
    _textController.close();
    _statusController.close();
  }
}

/// 语音输入状态
enum VoiceInputStatus {
  idle,
  listening,
  done,
  error,
}

/// 语音语言
class VoiceLanguage {
  final String localeId;
  final String name;

  const VoiceLanguage({
    required this.localeId,
    required this.name,
  });
}
