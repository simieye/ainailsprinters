import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/models/user.dart';

/// 登录页面
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AuthService.instance.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.isSuccess) {
      _animController.forward().then((_) {
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
        }
      });
    } else {
      setState(() => _errorMessage = result.message ?? '登录失败');
    }
  }

  Future<void> _handleAnonymousLogin() async {
    await AuthService.instance.loginAnonymously();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeepDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                // Logo & 标题
                _buildHeader().animate().fadeIn(duration: 600.ms).slideY(
                    begin: -0.1, duration: 600.ms, curve: Curves.easeOut),
                const SizedBox(height: 48),
                // 错误提示
                if (_errorMessage != null) _buildErrorBanner(),
                // 邮箱输入
                _buildEmailField().animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 16),
                // 密码输入
                _buildPasswordField().animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 12),
                // 忘记密码
                _buildForgotPassword().animate().fadeIn(delay: 350.ms),
                const SizedBox(height: 24),
                // 登录按钮
                _buildLoginButton().animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 16),
                // 分隔线
                _buildDivider().animate().fadeIn(delay: 450.ms),
                const SizedBox(height: 16),
                // 游客模式
                _buildAnonymousButton().animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 24),
                // 注册入口
                _buildRegisterLink().animate().fadeIn(delay: 550.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.gradientCyber,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryNeonGreen.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_awesome,
            color: Colors.white,
            size: 36,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'AI NAILS',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontFamily: 'CyberNeon',
                fontSize: 32,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '全球首款 AI 智能美甲客户端',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.accentNeonPink.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentNeonPink.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              color: AppTheme.accentNeonPink, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: AppTheme.accentNeonPink,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: const InputDecoration(
        labelText: '邮箱',
        hintText: '输入您的邮箱地址',
        prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textHint),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return '请输入邮箱';
        if (!value.contains('@')) return '请输入有效的邮箱地址';
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: '密码',
        hintText: '输入您的密码',
        prefixIcon:
            const Icon(Icons.lock_outlined, color: AppTheme.textHint),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: AppTheme.textHint,
          ),
          onPressed: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return '请输入密码';
        if (value.length < 6) return '密码至少需要6个字符';
        return null;
      },
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // TODO: 忘记密码流程
        },
        child: Text(
          '忘记密码？',
          style: TextStyle(
            color: AppTheme.primaryNeonGreen.withOpacity(0.8),
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryNeonGreen,
          foregroundColor: AppTheme.bgDeepDark,
          disabledBackgroundColor: AppTheme.primaryNeonGreen.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppTheme.bgDeepDark,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                '登录',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
            child: Container(
                height: 1,
                color: AppTheme.borderGlow.withOpacity(0.5))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('或',
              style: TextStyle(color: AppTheme.textHint, fontSize: 13)),
        ),
        Expanded(
            child: Container(
                height: 1,
                color: AppTheme.borderGlow.withOpacity(0.5))),
      ],
    );
  }

  Widget _buildAnonymousButton() {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _handleAnonymousLogin,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.textSecondary,
          side: BorderSide(color: AppTheme.borderGlow),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 20),
            SizedBox(width: 8),
            Text(
              '游客模式体验',
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '还没有账号？',
          style: TextStyle(color: AppTheme.textHint, fontSize: 14),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/register');
          },
          child: Text(
            '立即注册',
            style: TextStyle(
              color: AppTheme.primaryNeonGreen,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
