import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_nails_app/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('should provide dark theme', () {
      final theme = AppTheme.darkTheme;

      expect(theme.brightness, Brightness.dark);
      expect(theme.useMaterial3, true);
    });

    test('should have correct color scheme', () {
      final theme = AppTheme.darkTheme;
      final scheme = theme.colorScheme;

      expect(scheme.brightness, Brightness.dark);
      expect(scheme.primary, isNotNull);
      expect(scheme.secondary, isNotNull);
    });
  });

  group('AppColors', () {
    test('should have primary neon green', () {
      expect(AppColors.primaryNeonGreen, const Color(0xFF00FF88));
    });

    test('should have secondary neon purple', () {
      expect(AppColors.secondaryNeonPurple, const Color(0xFFB44CFF));
    });

    test('should have accent neon cyan', () {
      expect(AppColors.accentNeonCyan, const Color(0xFF00E5FF));
    });

    test('should have accent neon pink', () {
      expect(AppColors.accentNeonPink, const Color(0xFFFF2D95));
    });

    test('should have background colors', () {
      expect(AppColors.bgPrimary, const Color(0xFF0A0E21));
      expect(AppColors.bgSecondary, const Color(0xFF111633));
      expect(AppColors.bgCard, const Color(0xFF1A1F3D));
    });
  });

  group('AppGradients', () {
    test('should have neon gradient', () {
      expect(AppGradients.neon, isA<LinearGradient>());
      final gradient = AppGradients.neon as LinearGradient;
      expect(gradient.colors.length, 2);
    });

    test('should have purple gradient', () {
      expect(AppGradients.purple, isA<LinearGradient>());
    });

    test('should have cyber gradient', () {
      expect(AppGradients.cyber, isA<LinearGradient>());
      final gradient = AppGradients.cyber as LinearGradient;
      expect(gradient.colors.length, 3);
    });
  });

  group('Theme Widget Test', () {
    testWidgets('should render with dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: Scaffold(
            backgroundColor: AppColors.bgPrimary,
            body: const Center(
              child: Text('AI NAILS', style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      );

      expect(find.text('AI NAILS'), findsOneWidget);
    });
  });
}
