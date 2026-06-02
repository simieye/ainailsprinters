import 'dart:async';
import 'http_client.dart';
import 'api_config.dart';

/// OpenClaw Master 会话管理服务
/// 负责自然语言解析、多模态上下文会话管理及 MCP 状态反馈
/// 支持真实 API 调用 + 本地 Mock 回退
class OpenClawService {
  OpenClawService._();
  static final OpenClawService instance = OpenClawService._();

  final HttpClient _httpClient = HttpClient.instance;
  final List<Map<String, dynamic>> _conversationHistory = [];
  final StreamController<Map<String, dynamic>> _sessionController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get sessionStream => _sessionController.stream;
  List<Map<String, dynamic>> get conversationHistory =>
      List.unmodifiable(_conversationHistory);

  /// 启动新的创作会话
  Future<Map<String, dynamic>> startSession({
    required String userId,
    String? sessionType,
  }) async {
    try {
      final response = await _httpClient.post(
        ApiConfig.createSession,
        baseUrl: ApiConfig.openclawBaseUrl,
        data: {
          'user_id': userId,
          'session_type': sessionType ?? 'creative',
        },
      );

      if (response.isSuccess && response.dataAsMap.isNotEmpty) {
        final session = response.dataAsMap;
        _conversationHistory.add(session);
        _sessionController
            .add({'type': 'session_started', 'session': session});
        return session;
      }
    } catch (e) {
      print('[OpenClaw] API 调用失败，回退到 Mock: $e');
    }

    // Mock 回退
    final session = {
      'sessionId': 'oc_${DateTime.now().millisecondsSinceEpoch}',
      'userId': userId,
      'type': sessionType ?? 'creative',
      'status': 'active',
      'createdAt': DateTime.now().toIso8601String(),
      'context': <String, dynamic>{},
    };

    _conversationHistory.add(session);
    _sessionController.add({'type': 'session_started', 'session': session});

    return session;
  }

  /// 处理用户自然语言输入
  Future<Map<String, dynamic>> processInput({
    required String sessionId,
    required String input,
    InputType inputType = InputType.text,
  }) async {
    // 记录用户输入
    _conversationHistory.add({
      'sessionId': sessionId,
      'role': 'user',
      'content': input,
      'type': inputType.name,
      'timestamp': DateTime.now().toIso8601String(),
    });

    try {
      final response = await _httpClient.post(
        ApiConfig.processInput,
        baseUrl: ApiConfig.openclawBaseUrl,
        data: {
          'session_id': sessionId,
          'input': input,
          'input_type': inputType.name,
        },
      );

      if (response.isSuccess && response.dataAsMap.isNotEmpty) {
        final result = response.dataAsMap;
        _conversationHistory.add(result);
        _sessionController.add({'type': 'response', 'data': result});
        return result;
      }
    } catch (e) {
      print('[OpenClaw] 输入处理 API 失败，回退到 Mock: $e');
    }

    // Mock 回退
    await Future.delayed(const Duration(milliseconds: 300));

    final extractedIntent = _extractIntent(input);
    final refinedPrompt = _refinePrompt(input);

    final mockResponse = {
      'sessionId': sessionId,
      'role': 'assistant',
      'intent': extractedIntent,
      'refinedPrompt': refinedPrompt,
      'confidence': 0.94,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _conversationHistory.add(mockResponse);
    _sessionController.add({'type': 'response', 'data': mockResponse});

    return mockResponse;
  }

  /// 提取用户意图
  Map<String, dynamic> _extractIntent(String input) {
    final lower = input.toLowerCase();

    if (lower.contains('赛博') || lower.contains('cyber')) {
      return {'primary': 'cyberpunk', 'sub': 'neon', 'confidence': 0.95};
    } else if (lower.contains('花') || lower.contains('floral')) {
      return {'primary': 'floral', 'sub': 'natural', 'confidence': 0.92};
    } else if (lower.contains('简约') || lower.contains('minimal')) {
      return {'primary': 'minimalist', 'sub': 'clean', 'confidence': 0.90};
    } else if (lower.contains('渐变') || lower.contains('gradient')) {
      return {'primary': 'gradient', 'sub': 'smooth', 'confidence': 0.88};
    } else if (lower.contains('几何') || lower.contains('geometric')) {
      return {'primary': 'geometric', 'sub': 'abstract', 'confidence': 0.91};
    }

    return {'primary': 'creative', 'sub': 'custom', 'confidence': 0.85};
  }

  /// 优化用户提示词
  String _refinePrompt(String input) {
    final keywords = input.split(' ').where((w) => w.length > 1).toList();
    return '${input}, high resolution nail art design, 1200 DPI, '
        'professional lighting, nail-adaptive topology, '
        'nanobanana 3.0 engine, ${keywords.join(', ')}, '
        'vibrant colors, perfect nail coverage';
  }

  /// 结束会话
  Future<void> endSession(String sessionId) async {
    try {
      await _httpClient.post(
        ApiConfig.endSession,
        baseUrl: ApiConfig.openclawBaseUrl,
        data: {'session_id': sessionId},
      );
    } catch (_) {}

    _sessionController.add({
      'type': 'session_ended',
      'sessionId': sessionId,
    });
  }

  void dispose() {
    _sessionController.close();
  }
}

enum InputType { text, voice, image, gesture }
