/// 用户模型
class User {
  final String id;
  final String email;
  final String username;
  final String? avatarUrl;
  final String? bio;
  final UserRole role;
  final UserLevel level;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool emailVerified;
  final List<String> badgeIds;

  const User({
    required this.id,
    required this.email,
    required this.username,
    this.avatarUrl,
    this.bio,
    this.role = UserRole.user,
    this.level = UserLevel.bronze,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.emailVerified = false,
    this.badgeIds = const [],
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  User copyWith({
    String? id,
    String? email,
    String? username,
    String? avatarUrl,
    String? bio,
    UserRole? role,
    UserLevel? level,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? emailVerified,
    List<String>? badgeIds,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      level: level ?? this.level,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      emailVerified: emailVerified ?? this.emailVerified,
      badgeIds: badgeIds ?? this.badgeIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'username': username,
        'avatar_url': avatarUrl,
        'bio': bio,
        'role': role.name,
        'level': level.name,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'email_verified': emailVerified,
        'badge_ids': badgeIds,
      };

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.user,
      ),
      level: UserLevel.values.firstWhere(
        (e) => e.name == json['level'],
        orElse: () => UserLevel.bronze,
      ),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      emailVerified: json['email_verified'] as bool? ?? false,
      badgeIds: (json['badge_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  /// 匿名用户
  factory User.anonymous() => User(
        id: 'anonymous',
        email: '',
        username: 'Guest',
      );
}

enum UserRole { user, creator, business, admin }

enum UserLevel { bronze, silver, gold, diamond, master }

/// 认证令牌
class AuthToken {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final DateTime issuedAt;

  const AuthToken({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'Bearer',
    required this.expiresIn,
    DateTime? issuedAt,
  }) : issuedAt = issuedAt ?? DateTime.now();

  bool get isExpired =>
      DateTime.now().difference(issuedAt).inSeconds >= expiresIn;

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'token_type': tokenType,
        'expires_in': expiresIn,
        'issued_at': issuedAt.toIso8601String(),
      };

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String? ?? 'Bearer',
      expiresIn: json['expires_in'] as int,
      issuedAt: json['issued_at'] != null
          ? DateTime.parse(json['issued_at'] as String)
          : null,
    );
  }
}

/// 登录请求
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

/// 注册请求
class RegisterRequest {
  final String email;
  final String password;
  final String username;

  const RegisterRequest({
    required this.email,
    required this.password,
    required this.username,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'username': username,
      };
}
