import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/services/auth_service.dart';

/// 注册页面
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AuthService.instance.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      username: _usernameController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('注册成功！欢迎加入 AI NAILS'),
          backgroundColor: AppTheme.primaryNeonGreen,
        ),
      );
      Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
    } else {
      setState(() => _errorMessage = result.message ?? '注册失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeepDark,
      appBar: AppBar(
        title: const Text('创建账号'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 副标题
                Text(
                  '加入 AI NAILS，开启智能美甲之旅',
                  style: Theme.of(context).textTheme.bodyMedium,
                ).animate().fadeIn(),
                const SizedBox(height: 32),
                if (_errorMessage != null) _buildErrorBanner(),
                _buildUsernameField().animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 16),
                _buildEmailField().animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 16),
                _buildPasswordField().animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 16),
                _buildConfirmPasswordField().animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 12),
                _buildAgreementText().animate().fadeIn(delay: 450.ms),
                const SizedBox(height: 24),
                _buildRegisterButton().animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 24),
                _buildLoginLink().animate().fadeIn(delay: 550.ms),
              ],
            ),
          ),
        ),
      ),
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
            child: Text(_errorMessage!,
                style: const TextStyle(
                    color: AppTheme.accentNeonPink, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: const InputDecoration(
        labelText: '用户名',
        hintText: '输入您的用户名',
        prefixIcon: Icon(Icons.person_outline, color: AppTheme.textHint),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return '请输入用户名';
        if (value.length < 2) return '用户名至少需要2个字符';
        if (value.length > 30) return '用户名不能超过30个字符';
        return null;
      },
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
        hintText: '至少6个字符',
        prefixIcon: const Icon(Icons.lock_outlined, color: AppTheme.textHint),
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

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirm,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: '确认密码',
        hintText: '再次输入密码',
        prefixIcon: const Icon(Icons.lock_outlined, color: AppTheme.textHint),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirm ? Icons.visibility_off : Icons.visibility,
            color: AppTheme.textHint,
          ),
          onPressed: () =>
              setState(() => _obscureConfirm = !_obscureConfirm),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return '请确认密码';
        if (value != _passwordController.text) return '两次输入的密码不一致';
        return null;
      },
    );
  }

  Widget _buildAgreementText() {
    return RichText(
      text: TextSpan(
        style: TextStyle(color: AppTheme.textHint, fontSize: 12),
        children: [
          const TextSpan(text: '注册即表示您同意我们的 '),
          TextSpan(
            text: '服务条款',
            style: TextStyle(color: AppTheme.primaryNeonGreen),
          ),
          const TextSpan(text: ' 和 '),
          TextSpan(
            text: '隐私政策',
            style: TextStyle(color: AppTheme.primaryNeonGreen),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryNeonGreen,
          foregroundColor: AppTheme.bgDeepDark,
          disabledBackgroundColor:
              AppTheme.primaryNeonGreen.withOpacity(0.3),
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
                '创建账号',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '已有账号？',
          style: TextStyle(color: AppTheme.textHint, fontSize: 14),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            '立即登录',
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
