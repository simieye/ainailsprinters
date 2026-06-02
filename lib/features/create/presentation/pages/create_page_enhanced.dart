import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/openclaw_service.dart';
import '../../../../core/services/nanobanana_service.dart';
import '../../../../core/services/voice_input_service.dart';
import '../../domain/models/generated_design_ext.dart';
import '../widgets/voice_input_button.dart';
import '../widgets/prompt_refiner_card.dart';
import '../widgets/design_candidate_grid.dart';
import '../widgets/generation_progress_indicator.dart';

/// TALK TO CREATE — 创作舱增强版
/// 白皮书 2.1 节：AI 语音与多模态创作舱
/// "对答即创作，Print in 10s"
class CreatePageEnhanced extends ConsumerStatefulWidget {
  const CreatePageEnhanced({super.key});

  @override
  ConsumerState<CreatePageEnhanced> createState() =>
      _CreatePageEnhancedState();
}

class _CreatePageEnhancedState extends ConsumerState<CreatePageEnhanced>
    with SingleTickerProviderStateMixin {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _pulseController;
  late AnimationController _particleController;
  late Animation<double> _pulseAnimation;

  bool _showRefinedPrompt = false;
  bool _isListening = false;
  String? _referenceImagePath;
  String _selectedStyle = '';
  String _refinedPromptText = '';
  String _detectedIntent = '';
  double _confidence = 0.0;
  final List<String> _styleTags = [];
  Timer? _generationTimer;
  int _generationProgress = 0;

  // 模拟的粒子数据
  final List<_BrainParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 初始化粒子
    final rng = Random(42);
    for (int i = 0; i < 20; i++) {
      _particles.add(_BrainParticle(
        angle: rng.nextDouble() * 2 * pi,
        distance: 40 + rng.nextDouble() * 30,
        size: 2 + rng.nextDouble() * 4,
        speed: 0.5 + rng.nextDouble() * 1.5,
        opacity: 0.3 + rng.nextDouble() * 0.7,
      ));
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    _generationTimer?.cancel();
    super.dispose();
  }

  /// 处理语音识别结果
  void _onVoiceResult(String text) {
    _promptController.text = text;
    _promptController.selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
    );
  }

  /// 选择参考图片
  Future<void> _pickReferenceImage() async {
    // 模拟图片选择（实际对接 image_picker）
    setState(() => _referenceImagePath = '已选择参考图片');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.primaryNeonGreen, size: 18),
            SizedBox(width: 8),
            Text('参考图片已添加，AI 将以此为风格基准'),
          ],
        ),
        backgroundColor: AppTheme.bgElevatedDark,
      ),
    );
  }

  /// 核心：生成图案（完整流程）
  Future<void> _handleGenerate() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    // 1. 设置生成状态
    setState(() {
      _generationProgress = 0;
    });
    final designsNotifier = ref.read(generatedDesignsProvider.notifier);
    designsNotifier.state = [];

    // 2. 调用 OpenClaw 解析意图 + 提示词优化
    final openclaw = ref.read(openclawServiceProvider);
    final session = await openclaw.startSession(userId: 'user_001');

    // 模拟进度
    _generationTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) {
        setState(() {
          _generationProgress = min(100, _generationProgress + 5);
        });
        if (_generationProgress >= 100) timer.cancel();
      },
    );

    final response = await openclaw.processInput(
      sessionId: session['sessionId'],
      input: prompt,
    );

    // 3. 显示优化后的提示词
    setState(() {
      _refinedPromptText = response['refinedPrompt'] ?? prompt;
      _detectedIntent = response['intent']?['primary'] ?? '通用风格';
      _confidence = (response['intent']?['confidence'] ?? 0.85).toDouble();
      _styleTags.clear();
      _styleTags.addAll(List<String>.from(response['intent']?['tags'] ?? []));
      _showRefinedPrompt = true;
    });

    // 4. 调用 nanobanana 3.0 生成4张候选图案（目标：0.8秒）
    final nanobanana = ref.read(nanobananaServiceProvider);
    final stopwatch = Stopwatch()..start();
    final designs = await nanobanana.generateDesigns(
      prompt: _refinedPromptText,
      style: _detectedIntent,
      referenceImage: _referenceImagePath,
    );
    stopwatch.stop();

    // 5. 应用甲型自适应形变
    final adaptedDesigns = await nanobanana.applyNailAdaptiveDeformation(designs);

    // 6. 更新 UI
    designsNotifier.state =
        adaptedDesigns.map((d) => d.toNailDesign()).toList();

    _generationTimer?.cancel();
    setState(() => _generationProgress = 100);

    // 显示生成速度
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.auto_awesome,
                  color: AppTheme.primaryNeonGreen, size: 16),
              const SizedBox(width: 8),
              Text(
                '生成完成 · ${stopwatch.elapsedMilliseconds}ms · ${adaptedDesigns.length} 张候选图案',
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
          backgroundColor: AppTheme.bgElevatedDark,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// 重新生成（换一批图案）
  Future<void> _handleRegenerate() async {
    await _handleGenerate();
  }

  @override
  Widget build(BuildContext context) {
    final designs = ref.watch(generatedDesignsProvider);
    final isGenerating = _generationProgress > 0 && _generationProgress < 100;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ===== 可滚动内容 =====
            Expanded(
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // 顶部标题
                  SliverToBoxAdapter(child: _buildHeader()),
                  // OpenClaw 智能大脑气泡
                  SliverToBoxAdapter(child: _buildOpenClawBrain()),
                  // 提示词输入区（多模态）
                  SliverToBoxAdapter(child: _buildMultimodalInput()),
                  // 优化后的提示词卡片
                  if (_showRefinedPrompt)
                    SliverToBoxAdapter(
                      child: PromptRefinerCard(
                        rawPrompt: _promptController.text,
                        refinedPrompt: _refinedPromptText,
                        intent: _detectedIntent,
                        confidence: _confidence,
                        styleTags: _styleTags,
                      ),
                    ),
                  // 生成进度
                  if (isGenerating)
                    SliverToBoxAdapter(
                      child: GenerationProgressIndicator(
                        progress: _generationProgress / 100.0,
                        message: _getProgressMessage(),
                      ),
                    ),
                  // 4张候选图案
                  if (designs.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: _buildCandidatesHeader(designs.length),
                    ),
                    SliverToBoxAdapter(
                      child: DesignCandidateGrid(
                        designs: designs,
                        onRegenerate: _handleRegenerate,
                      ),
                    ),
                  ],
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
            ),
            // ===== 底部打印栏（固定） =====
            if (designs.isNotEmpty) _buildPrintBar(),
          ],
        ),
      ),
    );
  }

  String _getProgressMessage() {
    if (_generationProgress < 25) return 'OpenClaw 解析意图中...';
    if (_generationProgress < 50) return 'nanobanana 3.0 图案重构...';
    if (_generationProgress < 75) return '甲型自适应形变计算...';
    if (_generationProgress < 95) return '1200 DPI 渲染输出...';
    return '即将完成...';
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.gradientNeon.createShader(bounds),
                child: const Text(
                  'TALK TO CREATE',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'CyberNeon',
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '对答即创作 · Print in 10s',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary.withOpacity(0.7),
                ),
              ),
            ],
          ),
          // SIMIAIOS 集群状态
          _buildAgentStatusBadge(),
        ],
      ),
    );
  }

  Widget _buildAgentStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryNeonGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryNeonGreen.withOpacity(0.3),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulsingDot(color: AppTheme.primaryNeonGreen),
          SizedBox(width: 6),
          Text(
            '64 Agents Online',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.primaryNeonGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenClawBrain() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _particleController]),
      builder: (context, child) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            width: 140,
            height: 140,
            child: CustomPaint(
              painter: _BrainParticlePainter(
                particles: _particles,
                progress: _particleController.value,
              ),
              child: Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.gradientCyber,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.secondaryNeonPurple
                            .withOpacity(0.3 * _pulseAnimation.value),
                        blurRadius: 40 * _pulseAnimation.value,
                        spreadRadius: 5 * _pulseAnimation.value,
                      ),
                      BoxShadow(
                        color: AppTheme.primaryNeonGreen
                            .withOpacity(0.2 * _pulseAnimation.value),
                        blurRadius: 30 * _pulseAnimation.value,
                        spreadRadius: 3 * _pulseAnimation.value,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.psychology,
                        color: AppTheme.bgDeepDark.withOpacity(0.9),
                        size: 30,
                      ),
                      Text(
                        'OpenClaw',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.bgDeepDark.withOpacity(0.8),
                          fontFamily: 'CyberNeon',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMultimodalInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.bgSurfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.borderGlow.withOpacity(0.5),
          ),
        ),
        child: Column(
          children: [
            // 输入框
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _promptController,
                maxLines: 3,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  height: 1.5,
                ),
                decoration: InputDecoration(
                  hintText: _referenceImagePath != null
                      ? '描述你想要的效果，AI 将结合参考图片生成...'
                      : '描述你想要的甲面设计...\n"赛博朋克风格，深蓝色微光，蝴蝶翅膀纹理"',
                  hintStyle: TextStyle(
                    color: AppTheme.textHint.withOpacity(0.6),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            // 参考图片预览
            if (_referenceImagePath != null) _buildReferencePreview(),
            // 底部操作栏
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  // 语音输入
                  VoiceInputButton(
                    onResult: _onVoiceResult,
                    onListeningChanged: (listening) {
                      setState(() => _isListening = listening);
                    },
                  ),
                  const SizedBox(width: 8),
                  // 图片参考
                  _buildActionChip(
                    icon: _referenceImagePath != null
                        ? Icons.image
                        : Icons.image_outlined,
                    label: _referenceImagePath != null ? '已添加参考' : '图片参考',
                    isActive: _referenceImagePath != null,
                    onTap: _pickReferenceImage,
                  ),
                  const SizedBox(width: 8),
                  // 风格选择
                  _buildActionChip(
                    icon: Icons.style_outlined,
                    label: _selectedStyle.isEmpty ? '风格' : _selectedStyle,
                    onTap: _showStylePicker,
                  ),
                  const Spacer(),
                  // 生成按钮
                  _buildGenerateButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferencePreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.secondaryNeonPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.secondaryNeonPurple.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.secondaryNeonPurple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.image,
              color: AppTheme.secondaryNeonPurple,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '参考图片',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'AI 将以图片风格为参考进行创作',
                  style: TextStyle(
                    color: AppTheme.textHint,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _referenceImagePath = null),
            child: const Icon(
              Icons.close,
              color: AppTheme.textHint,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primaryNeonGreen.withOpacity(0.1)
              : AppTheme.bgElevatedDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppTheme.primaryNeonGreen.withOpacity(0.4)
                : AppTheme.borderGlow.withOpacity(0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive
                  ? AppTheme.primaryNeonGreen
                  : AppTheme.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive
                    ? AppTheme.primaryNeonGreen
                    : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    final isGenerating =
        _generationProgress > 0 && _generationProgress < 100;

    return GestureDetector(
      onTap: isGenerating ? null : _handleGenerate,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: isGenerating
              ? AppTheme.gradientPurple
              : AppTheme.gradientNeon,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: isGenerating
                  ? AppTheme.secondaryNeonPurple.withOpacity(0.4)
                  : AppTheme.primaryNeonGreen.withOpacity(0.4),
              blurRadius: 15,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isGenerating)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation(AppTheme.bgDeepDark),
                ),
              )
            else
              const Icon(
                Icons.auto_awesome,
                color: AppTheme.bgDeepDark,
                size: 18,
              ),
            const SizedBox(width: 6),
            Text(
              isGenerating ? '生成中...' : '生成',
              style: const TextStyle(
                color: AppTheme.bgDeepDark,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCandidatesHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$count 张候选图案',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
            onTap: _handleRegenerate,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.secondaryNeonPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.secondaryNeonPurple.withOpacity(0.3),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh,
                      size: 14, color: AppTheme.secondaryNeonPurple),
                  SizedBox(width: 4),
                  Text(
                    '换一批',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.secondaryNeonPurple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrintBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: AppTheme.bgCardDark,
        border: Border(
          top: BorderSide(
            color: AppTheme.primaryNeonGreen.withOpacity(0.15),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryNeonGreen.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // AR 试戴
          _buildBottomAction(
            icon: Icons.view_in_ar,
            label: 'AR 试戴',
            onTap: () {
              // Navigator.pushNamed(context, '/ar-preview');
            },
          ),
          const SizedBox(width: 12),
          // 立即打印
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Navigator.pushNamed(context, '/print-confirm');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppTheme.gradientNeon,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryNeonGreen.withOpacity(0.3),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.print, color: AppTheme.bgDeepDark, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '开始打印 · Print in 10s',
                      style: TextStyle(
                        color: AppTheme.bgDeepDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.bgSurfaceDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.borderGlow.withOpacity(0.4),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.accentNeonCyan, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.accentNeonCyan,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStylePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgCardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _StylePickerSheetEnhanced(
        onSelected: (style) {
          setState(() => _selectedStyle = style);
          _promptController.text = '$_selectedStyle风格，${_promptController.text}';
        },
      ),
    );
  }
}

// ===== 风格选择器（增强版，带预览） =====
class _StylePickerSheetEnhanced extends StatelessWidget {
  final void Function(String) onSelected;

  const _StylePickerSheetEnhanced({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final styles = [
      _StyleOption('赛博朋克', Icons.memory, AppTheme.primaryNeonGreen,
          '霓虹灯、机械感、未来都市'),
      _StyleOption(
          '国风水墨', Icons.brush, AppTheme.textPrimary, '墨韵、留白、东方意境'),
      _StyleOption(
          '法式极简', Icons.auto_fix_high, AppTheme.textSecondary, '优雅、简约、高级感'),
      _StyleOption('星空宇宙', Icons.nightlight_round, AppTheme.secondaryNeonPurple,
          '星云、星系、宇宙深邃'),
      _StyleOption('花卉自然', Icons.local_florist, AppTheme.accentNeonPink,
          '花朵、藤蔓、自然生机'),
      _StyleOption('几何抽象', Icons.hexagon_outlined, AppTheme.warningNeonOrange,
          '线条、图形、现代构成'),
      _StyleOption('梦幻渐变', Icons.gradient, AppTheme.accentNeonCyan,
          '色彩流动、渐变层次'),
      _StyleOption('暗夜哥特', Icons.dark_mode, AppTheme.bgElevatedDark,
          '暗黑、神秘、华丽'),
      _StyleOption('日系卡哇伊', Icons.favorite, AppTheme.accentNeonPink,
          '可爱、甜美、少女心'),
      _StyleOption('波普艺术', Icons.palette, AppTheme.warningNeonOrange,
          '色彩碰撞、流行文化'),
      _StyleOption('3D 立体', Icons.view_in_ar, AppTheme.accentNeonCyan,
          '立体感、光影层次'),
      _StyleOption('金属质感', Icons.diamond, AppTheme.goldAccent,
          '金属光泽、奢华质感'),
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '选择风格',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'AI 将根据风格自动优化提示词',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: styles.map((s) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  onSelected(s.name);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.bgSurfaceDark,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: s.color.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(s.icon, size: 18, color: s.color),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.name,
                            style: TextStyle(
                              color: s.color,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            s.description,
                            style: const TextStyle(
                              color: AppTheme.textHint,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _StyleOption {
  final String name;
  final IconData icon;
  final Color color;
  final String description;
  const _StyleOption(this.name, this.icon, this.color, this.description);
}

// ===== 粒子动画 =====
class _BrainParticle {
  final double angle;
  final double distance;
  final double size;
  final double speed;
  final double opacity;
  _BrainParticle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class _BrainParticlePainter extends CustomPainter {
  final List<_BrainParticle> particles;
  final double progress;

  _BrainParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final p in particles) {
      final angle = p.angle + progress * p.speed * 2 * pi;
      final dx = center.dx + cos(angle) * p.distance;
      final dy = center.dy + sin(angle) * p.distance;

      final paint = Paint()
        ..color = AppTheme.primaryNeonGreen.withOpacity(p.opacity * 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(Offset(dx, dy), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BrainParticlePainter oldDelegate) => true;
}

// ===== 脉冲点组件 =====
class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.4 + _controller.value * 0.3),
                blurRadius: 4 + _controller.value * 4,
              ),
            ],
          ),
        );
      },
    );
  }
}
