import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../../../../core/services/simiai_service.dart';

/// 认证服务
/// 负责用户注册、登录、Token 管理、会话持久化
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const _tokenKey = 'auth_token';
  static const _userKey = 'current_user';
  static const _userBox = 'users';

  final _storage = const FlutterSecureStorage();
  final _authStateController = StreamController<AuthState>.broadcast();

  User? _currentUser;
  AuthToken? _currentToken;

  Stream<AuthState> get authState => _authStateController.stream;
  User? get currentUser => _currentUser;
  AuthToken? get currentToken => _currentToken;
  bool get isAuthenticated => _currentUser != null && _currentToken != null;
  bool get isAnonymous => _currentUser == null;

  /// 初始化认证服务（从安全存储恢复会话）
  Future<void> initialize() async {
    try {
      // 恢复 Token
      final tokenJson = await _storage.read(key: _tokenKey);
      if (tokenJson != null) {
        _currentToken = AuthToken.fromJson(jsonDecode(tokenJson));
      }

      // 恢复用户
      final userJson = await _storage.read(key: _userKey);
      if (userJson != null) {
        _currentUser = User.fromJson(jsonDecode(userJson));
      }

      // 如果 Token 过期，尝试刷新
      if (_currentToken?.isExpired == true && _currentToken != null) {
        await refreshToken();
      }

      _emitState();
    } catch (e) {
      _currentToken = null;
      _currentUser = null;
      _emitState();
    }
  }

  /// 注册新用户
  Future<AuthResult> register({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      _emitLoading();

      // 调用 SIMIAIOS 认证智能体
      final response = await SimiaiService.instance.dispatchTask(
        agentId: 'auth_service',
        payload: {
          'action': 'register',
          'email': email,
          'password': password,
          'username': username,
        },
      );

      if (response['status'] == 'success') {
        // 模拟注册成功响应
        final user = User(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          username: username,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final token = AuthToken(
          accessToken: 'simi_${_generateToken()}',
          refreshToken: 'ref_${_generateToken()}',
          expiresIn: 86400, // 24h
        );

        await _persistSession(user, token);
        _emitAuthenticated(user);
        return AuthResult.success(user: user, token: token);
      }

      return AuthResult.failure(message: response['error'] ?? '注册失败');
    } catch (e) {
      _emitError(e.toString());
      return AuthResult.failure(message: e.toString());
    }
  }

  /// 登录
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      _emitLoading();

      final response = await SimiaiService.instance.dispatchTask(
        agentId: 'auth_service',
        payload: {
          'action': 'login',
          'email': email,
          'password': password,
        },
      );

      if (response['status'] == 'success') {
        // 模拟登录成功 - 从 SIMIAIOS 获取用户信息
        final userData = response['user'] as Map<String, dynamic>?;
        final user = userData != null
            ? User.fromJson(userData)
            : User(
                id: 'user_${DateTime.now().millisecondsSinceEpoch}',
                email: email,
                username: email.split('@').first,
              );

        final tokenData = response['token'] as Map<String, dynamic>?;
        final token = tokenData != null
            ? AuthToken.fromJson(tokenData)
            : AuthToken(
                accessToken: 'simi_${_generateToken()}',
                refreshToken: 'ref_${_generateToken()}',
                expiresIn: 86400,
              );

        await _persistSession(user, token);
        _emitAuthenticated(user);
        return AuthResult.success(user: user, token: token);
      }

      return AuthResult.failure(message: response['error'] ?? '登录失败');
    } catch (e) {
      _emitError(e.toString());
      return AuthResult.failure(message: e.toString());
    }
  }

  /// 刷新 Token
  Future<bool> refreshToken() async {
    if (_currentToken == null) return false;

    try {
      final response = await SimiaiService.instance.dispatchTask(
        agentId: 'auth_service',
        payload: {
          'action': 'refresh_token',
          'refresh_token': _currentToken!.refreshToken,
        },
      );

      if (response['status'] == 'success') {
        final newToken = AuthToken.fromJson(
          response['token'] as Map<String, dynamic>,
        );
        _currentToken = newToken;
        await _storage.write(
          key: _tokenKey,
          value: jsonEncode(newToken.toJson()),
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 退出登录
  Future<void> logout() async {
    try {
      await SimiaiService.instance.dispatchTask(
        agentId: 'auth_service',
        payload: {'action': 'logout', 'user_id': _currentUser?.id},
      );
    } catch (_) {}

    await _clearSession();
    _emitState();
  }

  /// 匿名登录（游客模式）
  Future<void> loginAnonymously() async {
    _currentUser = User.anonymous();
    _currentToken = null;
    _emitState();
  }

  /// 更新用户资料
  Future<AuthResult> updateProfile(Map<String, dynamic> updates) async {
    if (_currentUser == null) {
      return AuthResult.failure(message: '未登录');
    }

    try {
      final response = await SimiaiService.instance.dispatchTask(
        agentId: 'user_service',
        payload: {
          'action': 'update_profile',
          'user_id': _currentUser!.id,
          ...updates,
        },
      );

      if (response['status'] == 'success') {
        _currentUser = _currentUser!.copyWith(
          username: updates['username'] as String?,
          avatarUrl: updates['avatar_url'] as String?,
          bio: updates['bio'] as String?,
          updatedAt: DateTime.now(),
        );
        await _persistUser(_currentUser!);
        _emitAuthenticated(_currentUser!);
        return AuthResult.success(user: _currentUser!, token: _currentToken!);
      }

      return AuthResult.failure(message: '更新失败');
    } catch (e) {
      return AuthResult.failure(message: e.toString());
    }
  }

  // ===== 私有方法 =====

  Future<void> _persistSession(User user, AuthToken token) async {
    _currentUser = user;
    _currentToken = token;
    await _storage.write(key: _tokenKey, value: jsonEncode(token.toJson()));
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));

    // 同步到 Hive 本地缓存
    final box = await Hive.openBox(_userBox);
    await box.put(user.id, user.toJson());
  }

  Future<void> _persistUser(User user) async {
    _currentUser = user;
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  Future<void> _clearSession() async {
    _currentUser = null;
    _currentToken = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  String _generateToken() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch;
    return '${timestamp}_${random}_${_hashCode}';
  }

  static int _hashCode = 0;

  void _emitState() {
    _authStateController.add(
      AuthState(
        isAuthenticated: isAuthenticated,
        isAnonymous: isAnonymous,
        user: _currentUser,
        isLoading: false,
      ),
    );
  }

  void _emitLoading() {
    _authStateController.add(
      AuthState(
        isAuthenticated: false,
        isAnonymous: true,
        user: null,
        isLoading: true,
      ),
    );
  }

  void _emitAuthenticated(User user) {
    _authStateController.add(
      AuthState(
        isAuthenticated: true,
        isAnonymous: false,
        user: user,
        isLoading: false,
      ),
    );
  }

  void _emitError(String error) {
    _authStateController.add(
      AuthState(
        isAuthenticated: false,
        isAnonymous: true,
        user: null,
        isLoading: false,
        error: error,
      ),
    );
  }

  void dispose() {
    _authStateController.close();
  }
}

/// 认证状态
class AuthState {
  final bool isAuthenticated;
  final bool isAnonymous;
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    required this.isAuthenticated,
    required this.isAnonymous,
    this.user,
    this.isLoading = false,
    this.error,
  });

  factory AuthState.initial() => const AuthState(
        isAuthenticated: false,
        isAnonymous: true,
        user: null,
      );
}

/// 认证结果
class AuthResult {
  final bool isSuccess;
  final User? user;
  final AuthToken? token;
  final String? message;

  const AuthResult._({
    required this.isSuccess,
    this.user,
    this.token,
    this.message,
  });

  factory AuthResult.success({required User user, required AuthToken token}) =>
      AuthResult._(isSuccess: true, user: user, token: token);

  factory AuthResult.failure({required String message}) =>
      AuthResult._(isSuccess: false, message: message);
}
