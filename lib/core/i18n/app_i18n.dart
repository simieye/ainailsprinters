import 'package:easy_localization/easy_localization.dart';

/// 国际化工具封装
/// 提供类型安全的翻译获取方法，支持参数化翻译
class AppI18n {
  AppI18n._();

  // ===== 导航 =====
  static String get appName => 'app_name'.tr();
  static String get tagline => 'tagline'.tr();
  static String get navCreate => 'nav_create'.tr();
  static String get navGallery => 'nav_gallery'.tr();
  static String get navDevice => 'nav_device'.tr();
  static String get navAlliance => 'nav_alliance'.tr();
  static String get navMe => 'nav_me'.tr();

  // ===== 创作舱 =====
  static String get createTitle => 'create_title'.tr();
  static String get createSubtitle => 'create_subtitle'.tr();
  static String get createHint => 'create_hint'.tr();
  static String get createGenerate => 'create_generate'.tr();
  static String get createVoice => 'create_voice'.tr();
  static String get createImageRef => 'create_image_ref'.tr();
  static String get createStyle => 'create_style'.tr();
  static String get createEmptyState => 'create_empty_state'.tr();
  static String get createAnalyzing => 'create_analyzing'.tr();
  static String get createRefining => 'create_refining'.tr();
  static String get createGenerating => 'create_generating'.tr();
  static String get createSelectDesign => 'create_select_design'.tr();

  // ===== 灵感矩阵 =====
  static String get galleryTitle => 'gallery_title'.tr();
  static String galleryCount(int count) => 'gallery_count'.tr(args: ['$count']);
  static String get gallerySearch => 'gallery_search'.tr();
  static String get galleryRecommended => 'gallery_recommended'.tr();
  static String get galleryTryAr => 'gallery_try_ar'.tr();
  static String get galleryFavorite => 'gallery_favorite'.tr();
  static String get galleryUseDesign => 'gallery_use_design'.tr();

  static String galleryCategory(String key) => 'gallery_category_$key'.tr();

  // ===== 设备管理 =====
  static String get deviceTitle => 'device_title'.tr();
  static String get deviceOnline => 'device_online'.tr();
  static String get deviceOffline => 'device_offline'.tr();
  static String get deviceConnecting => 'device_connecting'.tr();
  static String get deviceTemp => 'device_temp'.tr();
  static String get deviceHumidity => 'device_humidity'.tr();
  static String get devicePrints => 'device_prints'.tr();
  static String get deviceLatency => 'device_latency'.tr();
  static String get deviceCpu => 'device_cpu'.tr();
  static String get deviceLifecycle => 'device_lifecycle'.tr();
  static String get deviceCartridge => 'device_cartridge'.tr();
  static String get deviceCoating => 'device_coating'.tr();
  static String get devicePrintHistory => 'device_print_history'.tr();
  static String get deviceSupplyRenewal => 'device_supply_renewal'.tr();
  static String get deviceOtaUpdate => 'device_ota_update'.tr();
  static String get deviceRemoteManage => 'device_remote_manage'.tr();

  // ===== 商业协同 =====
  static String get allianceTitle => 'alliance_title'.tr();
  static String get allianceModeB2c => 'alliance_mode_b2c'.tr();
  static String get allianceModeB2b => 'alliance_mode_b2b'.tr();
  static String get allianceTodayPrints => 'alliance_today_prints'.tr();
  static String get allianceTodayRevenue => 'alliance_today_revenue'.tr();
  static String get allianceAvgPrice => 'alliance_avg_price'.tr();
  static String get allianceRoiTitle => 'alliance_roi_title'.tr();
  static String allianceRoiDay(int day) => 'alliance_roi_day'.tr(args: ['$day']);
  static String get allianceRevenueChart => 'alliance_revenue_chart'.tr();
  static String get allianceStoreGrid => 'alliance_store_grid'.tr();
  static String get allianceTopDesigns => 'alliance_top_designs'.tr();
  static String get allianceAiInsight => 'alliance_ai_insight'.tr();
  static String get allianceTotalRevenue => 'alliance_total_revenue'.tr();
  static String get allianceDailyAvg => 'alliance_daily_avg'.tr();
  static String get allianceBreakEven => 'alliance_break_even'.tr();

  // ===== 创作者空间 =====
  static String get meTitle => 'me_title'.tr();
  static String get meLevel => 'me_level'.tr();
  static String meLevelName(String level) => 'me_level_$level'.tr();
  static String get meFollowers => 'me_followers'.tr();
  static String get meAssets => 'me_assets'.tr();
  static String get mePrints => 'me_prints'.tr();
  static String get meEarnings => 'me_earnings'.tr();
  static String get meEarningsTotal => 'me_earnings_total'.tr();
  static String get meEarningsMonth => 'me_earnings_month'.tr();
  static String get meEarningsSales => 'me_earnings_sales'.tr();
  static String get meEarningsTips => 'me_earnings_tips'.tr();
  static String get meEarningsPending => 'me_earnings_pending'.tr();
  static String get mePromptAssets => 'me_prompt_assets'.tr();
  static String get mePromptPublish => 'me_prompt_publish'.tr();
  static String get mePromptPrice => 'me_prompt_price'.tr();
  static String get mePromptSales => 'me_prompt_sales'.tr();
  static String get meCommunity => 'me_community'.tr();
  static String get meCommunityLike => 'me_community_like'.tr();
  static String get meCommunityComment => 'me_community_comment'.tr();
  static String get meCommunityShare => 'me_community_share'.tr();
  static String get meCommunityTranslate => 'me_community_translate'.tr();
  static String get meSettings => 'me_settings'.tr();
  static String get meEditProfile => 'me_edit_profile'.tr();

  // ===== 打印确认 =====
  static String get printConfirm => 'print_confirm'.tr();
  static String get printStart => 'print_start'.tr();
  static String get printFingerSelect => 'print_finger_select'.tr();
  static String get printNailShape => 'print_nail_shape'.tr();
  static String get printQuality => 'print_quality'.tr();
  static String get printCuring => 'print_curing'.tr();
  static String get printDeviceReady => 'print_device_ready'.tr();
  static String get printPrinting => 'print_printing'.tr();
  static String get printDone => 'print_done'.tr();
  static String get printShare => 'print_share'.tr();
  static String get printNewDesign => 'print_new_design'.tr();

  // ===== AR预览 =====
  static String get arPreview => 'ar_preview'.tr();
  static String get arScanning => 'ar_scanning'.tr();
  static String get arFingerSelect => 'ar_finger_select'.tr();
  static String get arConfirm => 'ar_confirm'.tr();
  static String get arRescan => 'ar_rescan'.tr();
  static String get arNailFit => 'ar_nail_fit'.tr();

  // ===== 通用 =====
  static String get commonCancel => 'common_cancel'.tr();
  static String get commonConfirm => 'common_confirm'.tr();
  static String get commonSave => 'common_save'.tr();
  static String get commonDelete => 'common_delete'.tr();
  static String get commonShare => 'common_share'.tr();
  static String get commonLoading => 'common_loading'.tr();
  static String get commonError => 'common_error'.tr();
  static String get commonRetry => 'common_retry'.tr();
  static String get commonNoData => 'common_no_data'.tr();
  static String get commonSeeAll => 'common_see_all'.tr();

  // ===== 风格 =====
  static String styleName(String key) => 'style_$key'.tr();

  // ===== 甲型 =====
  static String nailShapeName(String key) => 'nail_shape_$key'.tr();

  /// 获取当前语言代码
  static String get currentLanguageCode {
    return EasyLocalization.of(
      AppContextHolder.context!,
    )?.currentLocale?.languageCode ?? 'en';
  }

  /// 判断是否为 RTL 语言
  static bool get isRTL {
    final code = currentLanguageCode;
    return code == 'ar' || code == 'he' || code == 'fa';
  }

  /// 获取语言原生名称
  static String getLanguageNativeName(String code) {
    const names = {
      'en': 'English',
      'zh': '中文',
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
    return names[code] ?? code;
  }
}

/// 全局 context 持有者（用于非 Widget 上下文获取翻译）
class AppContextHolder {
  static BuildContext? context;
}
