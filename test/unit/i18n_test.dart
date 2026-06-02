import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart' show rootBundle;

/// 国际化测试
/// 验证所有翻译文件键值完整性和一致性
void main() {
  late Map<String, dynamic> zh;
  late Map<String, dynamic> en;
  late Map<String, dynamic> ja;
  late Map<String, dynamic> ko;

  setUpAll(() async {
    // 直接读取 JSON 文件
    zh = jsonDecode(await _loadJson('zh'));
    en = jsonDecode(await _loadJson('en'));
    ja = jsonDecode(await _loadJson('ja'));
    ko = jsonDecode(await _loadJson('ko'));
  });

  group('i18n - Key Completeness', () {
    test('all languages should have same keys', () {
      final zhKeys = zh.keys.toSet();
      final enKeys = en.keys.toSet();
      final jaKeys = ja.keys.toSet();
      final koKeys = ko.keys.toSet();

      // 英文作为基准
      for (final key in enKeys) {
        expect(zhKeys.contains(key), true, reason: 'zh missing key: $key');
        expect(jaKeys.contains(key), true, reason: 'ja missing key: $key');
        expect(koKeys.contains(key), true, reason: 'ko missing key: $key');
      }

      // 中文作为基准反向检查
      for (final key in zhKeys) {
        expect(enKeys.contains(key), true, reason: 'en missing key: $key');
      }
    });

    test('all languages should have same number of keys', () {
      expect(zh.length, en.length);
      expect(ja.length, en.length);
      expect(ko.length, en.length);
    });
  });

  group('i18n - Navigation Keys', () {
    final navKeys = [
      'app_name', 'tagline',
      'nav_create', 'nav_gallery', 'nav_device', 'nav_alliance', 'nav_me',
    ];

    for (final key in navKeys) {
      test('$key exists in all languages', () {
        expect(zh.containsKey(key), true);
        expect(en.containsKey(key), true);
        expect(ja.containsKey(key), true);
        expect(ko.containsKey(key), true);
      });

      test('$key is not empty in all languages', () {
        expect(zh[key], isNotEmpty);
        expect(en[key], isNotEmpty);
        expect(ja[key], isNotEmpty);
        expect(ko[key], isNotEmpty);
      });
    }
  });

  group('i18n - Create Module Keys', () {
    final keys = [
      'create_title', 'create_subtitle', 'create_hint',
      'create_generate', 'create_voice', 'create_image_ref', 'create_style',
      'create_empty_state', 'create_analyzing', 'create_refining',
      'create_generating', 'create_select_design',
    ];

    for (final key in keys) {
      test('$key exists and non-empty', () {
        expect(zh[key], isNotEmpty);
        expect(en[key], isNotEmpty);
        expect(ja[key], isNotEmpty);
        expect(ko[key], isNotEmpty);
      });
    }
  });

  group('i18n - Gallery Module Keys', () {
    final keys = [
      'gallery_title', 'gallery_search',
      'gallery_recommended', 'gallery_try_ar', 'gallery_favorite', 'gallery_use_design',
    ];

    for (final key in keys) {
      test('$key exists', () {
        expect(zh.containsKey(key), true);
        expect(en.containsKey(key), true);
      });
    }

    test('gallery_count has placeholder', () {
      expect(en['gallery_count'], contains('{count}'));
      expect(zh['gallery_count'], contains('{count}'));
    });

    test('all category keys exist', () {
      final cats = ['all', 'cosmic', 'ink', 'minimal', 'cyber', 'floral', 'geometric', 'gradient', 'cartoon'];
      for (final cat in cats) {
        final key = 'gallery_category_$cat';
        expect(en.containsKey(key), true, reason: 'en missing $key');
        expect(zh.containsKey(key), true, reason: 'zh missing $key');
      }
    });
  });

  group('i18n - Device Module Keys', () {
    final keys = [
      'device_title', 'device_online', 'device_offline', 'device_connecting',
      'device_temp', 'device_humidity', 'device_prints', 'device_latency',
      'device_cpu', 'device_lifecycle', 'device_cartridge', 'device_coating',
      'device_print_history', 'device_supply_renewal', 'device_ota_update',
      'device_remote_manage',
    ];

    for (final key in keys) {
      test('$key exists', () {
        expect(en.containsKey(key), true);
      });
    }

    test('cartridge color keys exist', () {
      for (final color in ['cyan', 'magenta', 'yellow', 'black']) {
        final key = 'device_cartridge_$color';
        expect(en.containsKey(key), true);
      }
    });
  });

  group('i18n - Alliance Module Keys', () {
    final keys = [
      'alliance_title', 'alliance_mode_b2c', 'alliance_mode_b2b',
      'alliance_today_prints', 'alliance_today_revenue', 'alliance_avg_price',
      'alliance_roi_title', 'alliance_revenue_chart', 'alliance_store_grid',
      'alliance_top_designs', 'alliance_ai_insight',
      'alliance_total_revenue', 'alliance_daily_avg', 'alliance_break_even',
    ];

    for (final key in keys) {
      test('$key exists', () {
        expect(en.containsKey(key), true);
      });
    }

    test('alliance_roi_day has placeholder', () {
      expect(en['alliance_roi_day'], contains('{day}'));
    });
  });

  group('i18n - Me Module Keys', () {
    final keys = [
      'me_title', 'me_level', 'me_followers', 'me_assets', 'me_prints',
      'me_earnings', 'me_earnings_total', 'me_earnings_month',
      'me_earnings_sales', 'me_earnings_tips', 'me_earnings_pending',
      'me_prompt_assets', 'me_prompt_publish', 'me_prompt_price', 'me_prompt_sales',
      'me_community', 'me_community_like', 'me_community_comment',
      'me_community_share', 'me_community_translate',
      'me_settings', 'me_edit_profile',
    ];

    for (final key in keys) {
      test('$key exists', () {
        expect(en.containsKey(key), true);
      });
    }

    test('level names exist', () {
      for (final level in ['bronze', 'silver', 'gold', 'diamond', 'master']) {
        final key = 'me_level_$level';
        expect(en.containsKey(key), true, reason: 'en missing $key');
      }
    });
  });

  group('i18n - Print & AR Keys', () {
    final keys = [
      'print_confirm', 'print_start', 'print_finger_select',
      'print_nail_shape', 'print_quality', 'print_curing',
      'print_device_ready', 'print_printing', 'print_done',
      'print_share', 'print_new_design',
      'ar_preview', 'ar_scanning', 'ar_finger_select',
      'ar_confirm', 'ar_rescan', 'ar_nail_fit',
    ];

    for (final key in keys) {
      test('$key exists', () {
        expect(en.containsKey(key), true);
      });
    }
  });

  group('i18n - Common Keys', () {
    final keys = [
      'common_cancel', 'common_confirm', 'common_save', 'common_delete',
      'common_share', 'common_loading', 'common_error', 'common_retry',
      'common_no_data', 'common_see_all',
    ];

    for (final key in keys) {
      test('$key exists', () {
        expect(en.containsKey(key), true);
      });
    }
  });

  group('i18n - Style & Nail Shape Keys', () {
    test('style keys exist', () {
      final styles = ['cyberpunk', 'ink_wash', 'minimalist', 'floral', 'geometric', 'gradient', 'cartoon', 'galaxy'];
      for (final s in styles) {
        expect(en.containsKey('style_$s'), true);
      }
    });

    test('nail shape keys exist', () {
      final shapes = ['almond', 'square', 'oval', 'coffin', 'stiletto', 'round'];
      for (final s in shapes) {
        expect(en.containsKey('nail_shape_$s'), true);
      }
    });
  });

  group('i18n - Total Key Count', () {
    test('should have comprehensive key set', () {
      // 验证总键数在合理范围内
      expect(en.length, greaterThan(100));
    });
  });
}

/// 从 asset 加载 JSON 字符串
Future<String> _loadJson(String lang) async {
  // 直接读取文件内容
  final filePath = 'assets/i18n/$lang.json';
  return await rootBundle.loadString(filePath);
}
