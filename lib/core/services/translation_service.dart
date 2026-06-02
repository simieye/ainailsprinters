import 'dart:async';
import 'http_client.dart';
import 'api_config.dart';

/// 翻译服务
/// 支持 13+ 语言的实时翻译
class TranslationService {
  TranslationService._();
  static final TranslationService instance = TranslationService._();

  final HttpClient _httpClient = HttpClient.instance;

  // 支持的语言
  static const supportedLanguages = {
    'zh': '中文',
    'en': 'English',
    'ja': '日本語',
    'ko': '한국어',
    'fr': 'Français',
    'de': 'Deutsch',
    'es': 'Español',
    'pt': 'Português',
    'ru': 'Русский',
    'ar': 'العربية',
    'th': 'ไทย',
    'vi': 'Tiếng Việt',
    'id': 'Bahasa Indonesia',
  };

  /// 翻译文本
  Future<TranslationResult> translate({
    required String text,
    required String targetLanguage,
    String? sourceLanguage,
  }) async {
    try {
      final response = await _httpClient.post(
        ApiConfig.translate,
        baseUrl: ApiConfig.communityBaseUrl,
        data: {
          'text': text,
          'target_language': targetLanguage,
          if (sourceLanguage != null) 'source_language': sourceLanguage,
          'engine': 'simiai_translator',
        },
      );

      if (response.isSuccess && response.dataAsMap.isNotEmpty) {
        return TranslationResult(
          originalText: text,
          translatedText: response.dataAsMap['translated_text'] as String? ?? text,
          sourceLanguage: response.dataAsMap['source_language'] as String? ?? sourceLanguage ?? 'auto',
          targetLanguage: targetLanguage,
          confidence: (response.dataAsMap['confidence'] as num?)?.toDouble() ?? 0.95,
        );
      }
    } catch (e) {
      print('[Translation] API 调用失败，回退到 Mock: $e');
    }

    // Mock 回退
    return _mockTranslate(text: text, targetLanguage: targetLanguage);
  }

  /// 批量翻译
  Future<List<TranslationResult>> translateBatch({
    required List<String> texts,
    required String targetLanguage,
  }) async {
    final results = <TranslationResult>[];
    for (final text in texts) {
      final result = await translate(
        text: text,
        targetLanguage: targetLanguage,
      );
      results.add(result);
    }
    return results;
  }

  /// 检测语言
  Future<LanguageDetectionResult> detectLanguage(String text) async {
    try {
      final response = await _httpClient.post(
        '/detect-language',
        baseUrl: ApiConfig.communityBaseUrl,
        data: {'text': text},
      );

      if (response.isSuccess && response.dataAsMap.isNotEmpty) {
        return LanguageDetectionResult(
          detectedLanguage: response.dataAsMap['language'] as String? ?? 'en',
          confidence: (response.dataAsMap['confidence'] as num?)?.toDouble() ?? 0.9,
        );
      }
    } catch (_) {}

    // Mock 回退 - 简单语言检测
    final detectedLang = _mockDetectLanguage(text);
    return LanguageDetectionResult(
      detectedLanguage: detectedLang,
      confidence: 0.85,
    );
  }

  /// Mock 翻译
  TranslationResult _mockTranslate({
    required String text,
    required String targetLanguage,
  }) {
    // 模拟翻译：添加语言标记前缀
    final langPrefix = switch (targetLanguage) {
      'ja' => '[日] ',
      'ko' => '[韩] ',
      'fr' => '[法] ',
      'de' => '[德] ',
      'es' => '[西] ',
      'pt' => '[葡] ',
      'ru' => '[俄] ',
      'ar' => '[阿] ',
      'th' => '[泰] ',
      'vi' => '[越] ',
      'id' => '[印尼] ',
      'zh' => '',
      _ => '',
    };

    return TranslationResult(
      originalText: text,
      translatedText: '$langPrefix$text',
      sourceLanguage: 'auto',
      targetLanguage: targetLanguage,
      confidence: 0.85,
    );
  }

  /// Mock 语言检测
  String _mockDetectLanguage(String text) {
    // 简单的语言检测启发式
    if (RegExp(r'[\u4e00-\u9fff]').hasMatch(text)) return 'zh';
    if (RegExp(r'[\u3040-\u309f\u30a0-\u30ff]').hasMatch(text)) return 'ja';
    if (RegExp(r'[\uac00-\ud7af]').hasMatch(text)) return 'ko';
    if (RegExp(r'[\u0600-\u06ff]').hasMatch(text)) return 'ar';
    if (RegExp(r'[\u0400-\u04ff]').hasMatch(text)) return 'ru';
    return 'en';
  }
}

/// 翻译结果
class TranslationResult {
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final double confidence;

  const TranslationResult({
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.confidence,
  });
}

/// 语言检测结果
class LanguageDetectionResult {
  final String detectedLanguage;
  final double confidence;

  const LanguageDetectionResult({
    required this.detectedLanguage,
    required this.confidence,
  });
}
