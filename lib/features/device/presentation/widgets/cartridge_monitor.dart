import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CartridgeMonitor extends StatelessWidget {
  final Map<String, double> levels;

  const CartridgeMonitor({super.key, required this.levels});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgCardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.borderGlow.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.palette, size: 16, color: AppTheme.primaryNeonGreen),
                SizedBox(width: 8),
                Text(
                  'CMYK 墨盒余量监控',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCartridgeGauge('C', levels['C'] ?? 0, const Color(0xFF00BCD4)),
                _buildCartridgeGauge('M', levels['M'] ?? 0, const Color(0xFFE91E63)),
                _buildCartridgeGauge('Y', levels['Y'] ?? 0, const Color(0xFFFFEB3B)),
                _buildCartridgeGauge('K', levels['K'] ?? 0, const Color(0xFF607D8B)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartridgeGauge(String label, double level, Color color) {
    return Column(
      children: [
        SizedBox(
          width: 56,
          height: 56,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: level,
                strokeWidth: 4,
                backgroundColor: AppTheme.bgSurfaceDark,
                valueColor: AlwaysStoppedAnimation(
                  level < 0.3 ? AppTheme.accentNeonPink : color,
                ),
              ),
              Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${(level * 100).toInt()}%',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: level < 0.3 ? AppTheme.accentNeonPink : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
