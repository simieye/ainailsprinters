import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/di/providers.dart';
import '../widgets/voice_input_button.dart';
import '../widgets/prompt_refiner_card.dart';
import '../widgets/design_candidate_grid.dart';
import '../widgets/generation_progress_indicator.dart';
import '../../../../core/services/openclaw_service.dart';
import '../../domain/models/generated_design_ext.dart';

class CreatePage extends ConsumerStatefulWidget {
  const CreatePage({super.key});

  @override
  ConsumerState<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends ConsumerState<CreatePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _showRefinedPrompt = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleGenerate() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    ref.read(isGeneratingProvider.notifier).state = true;
    ref.read(currentPromptProvider.notifier).state = prompt;

    // 调用 OpenClaw 解析意图
    final openclaw = ref.read(openclawServiceProvider);
    final session = await openclaw.startSession(userId: 'user_001');
    final response = await openclaw.processInput(
      sessionId: session['sessionId'],
      input: prompt,
    );

    // 调用 nanobanana 3.0 生成设计
    final nanobanana = ref.read(nanobananaServiceProvider);
    final designs = await nanobanana.generateDesigns(
      prompt: response['refinedPrompt'],
      style: response['intent']['primary'],
    );

    ref.read(generatedDesignsProvider.notifier).state = 
        designs.map((d) => d.toNailDesign()).toList();
    ref.read(isGeneratingProvider.notifier).state = false;

    setState(() => _showRefinedPrompt = true);
  }

  @override
  Widget build(BuildContext context) {
    final isGenerating = ref.watch(isGeneratingProvider);
    final designs = ref.watch(generatedDesignsProvider);
    final voiceText = ref.watch(voiceTextProvider);

    // 同步语音识别结果到输入框
    if (voiceText.isNotEmpty && _promptController.text != voiceText) {
      _promptController.text = voiceText;
    }

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // ===== 顶部标题栏 =====
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),

            // ===== OpenClaw 智能大脑气泡 =====
            SliverToBoxAdapter(
              child: _buildOpenClawBrain(),
            ),

            // ===== 提示词输入区 =====
            SliverToBoxAdapter(
              child: _buildPromptInput(),
            ),

            // ===== 优化后的提示词卡片 =====
            if (_showRefinedPrompt)
              SliverToBoxAdapter(
                child: PromptRefinerCard(
                  rawPrompt: ref.read(currentPromptProvider),
                  refinedPrompt: '${_promptController.text}, high resolution nail art, 1200 DPI',
                  intent: '赛博朋克 · 霓虹微光',
                  confidence: 0.94,
                ),
              ),

            // ===== 生成进度指示器 =====
            if (isGenerating)
              const SliverToBoxAdapter(
                child: GenerationProgressIndicator(),
              ),

            // ===== 4张候选图案网格 =====
            if (designs.isNotEmpty)
              SliverToBoxAdapter(
                child: DesignCandidateGrid(designs: designs),
              ),

            // ===== 底部间距 =====
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
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
                shaderCallback: (bounds) => AppTheme.gradientNeon.createShader(bounds),
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
          // SIMIAIOS 集群状态指示器
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryNeonGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primaryNeonGreen.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNeonGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryNeonGreen.withOpacity(0.6),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  '64 Agents',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.primaryNeonGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenClawBrain() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.gradientCyber,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.secondaryNeonPurple.withOpacity(0.3 * _pulseAnimation.value),
                  blurRadius: 40 * _pulseAnimation.value,
                  spreadRadius: 5 * _pulseAnimation.value,
                ),
                BoxShadow(
                  color: AppTheme.primaryNeonGreen.withOpacity(0.2 * _pulseAnimation.value),
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
                  size: 36,
                ),
                const SizedBox(height: 4),
                Text(
                  'OpenClaw',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.bgDeepDark.withOpacity(0.8),
                    fontFamily: 'CyberNeon',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPromptInput() {
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
                decoration: const InputDecoration(
                  hintText: '描述你想要的甲面设计...\n"赛博朋克风格，深蓝色微光，蝴蝶翅膀纹理"',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            
            // 底部操作栏
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  // 语音输入按钮
                  const VoiceInputButton(),
                  const SizedBox(width: 8),
                  
                  // 图片参考按钮
                  _buildActionChip(
                    icon: Icons.image_outlined,
                    label: '图片参考',
                    onTap: () {},
                  ),
                  const SizedBox(width: 8),
                  
                  // 风格选择
                  _buildActionChip(
                    icon: Icons.style_outlined,
                    label: '风格',
                    onTap: _showStylePicker,
                  ),
                  
                  const Spacer(),
                  
                  // 生成按钮
                  GestureDetector(
                    onTap: _handleGenerate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppTheme.gradientNeon,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryNeonGreen.withOpacity(0.4),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: AppTheme.bgDeepDark,
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            '生成',
                            style: TextStyle(
                              color: AppTheme.bgDeepDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.bgElevatedDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.borderGlow.withOpacity(0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppTheme.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
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
      builder: (context) => _StylePickerSheet(),
    );
  }
}

class _StylePickerSheet extends StatelessWidget {
  final List<Map<String, dynamic>> styles = const [
    {'name': '赛博朋克', 'icon': Icons.memory, 'color': AppTheme.accentNeonCyan},
    {'name': '国风水墨', 'icon': Icons.brush, 'color': AppTheme.textPrimary},
    {'name': '法式极简', 'icon': Icons.auto_fix_high, 'color': AppTheme.textSecondary},
    {'name': '星空宇宙', 'icon': Icons.nightlight_round, 'color': AppTheme.secondaryNeonPurple},
    {'name': '花卉自然', 'icon': Icons.local_florist, 'color': AppTheme.accentNeonPink},
    {'name': '几何抽象', 'icon': Icons.hexagon_outlined, 'color': AppTheme.warningNeonOrange},
    {'name': '梦幻渐变', 'icon': Icons.gradient, 'color': AppTheme.primaryNeonGreen},
    {'name': '暗夜哥特', 'icon': Icons.dark_mode, 'color': AppTheme.bgElevatedDark},
  ];

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: styles.map((s) => GestureDetector(
              onTap: () => Navigator.pop(context, s['name']),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.bgSurfaceDark,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: (s['color'] as Color).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(s['icon'] as IconData, size: 18, color: s['color'] as Color),
                    const SizedBox(width: 8),
                    Text(
                      s['name'] as String,
                      style: TextStyle(
                        color: s['color'] as Color,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
