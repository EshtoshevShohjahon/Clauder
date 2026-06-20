import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:avtoassist/providers/locale_provider.dart';
import 'package:avtoassist/utils/app_theme.dart';

/// Usta qidirish ekrani (mockup uslubidagi radar animatsiyasi)
/// Radar pulslanadi -> usta "topiladi" -> ma'lumot paneli ko'rinadi
class SearchingScreen extends StatefulWidget {
  final String serviceName;

  const SearchingScreen({super.key, required this.serviceName});

  @override
  State<SearchingScreen> createState() => _SearchingScreenState();
}

class _SearchingScreenState extends State<SearchingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _found = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    // 3 soniyadan keyin "topildi" holatiga o'tish
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _found = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(widget.serviceName)),
      body: Stack(
        children: [
          // Markaziy radar yoki "topildi"
          Center(
            child: _found ? _buildFound(loc) : _buildRadar(loc),
          ),

          // Pastdagi usta paneli (topilganda)
          if (_found) _buildProviderSheet(loc),
        ],
      ),
    );
  }

  Widget _buildRadar(LocaleProvider loc) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 180,
          height: 180,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  _ring(_controller.value),
                  _ring((_controller.value + 0.33) % 1.0),
                  _ring((_controller.value + 0.66) % 1.0),
                  // Markaziy doira
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.45),
                          blurRadius: 26,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.directions_car,
                        color: Color(0xFF1A1100), size: 30),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        Text(loc.t('searching'), style: AppTheme.heading3),
        const SizedBox(height: 6),
        Text(loc.t('searching_sub'), style: AppTheme.bodySmall),
      ],
    );
  }

  // Bitta pulslanuvchi halqa
  Widget _ring(double t) {
    final size = 60.0 + (120.0 * t);
    return Opacity(
      opacity: (1.0 - t) * 0.7,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.primaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildFound(LocaleProvider loc) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppTheme.secondaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.secondaryColor.withOpacity(0.4),
                blurRadius: 26,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.check, color: Color(0xFF06231B), size: 32),
        ),
        const SizedBox(height: 16),
        Text(loc.t('provider_found'), style: AppTheme.heading3),
      ],
    );
  }

  Widget _buildProviderSheet(LocaleProvider loc) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppTheme.darkCardColor : AppTheme.cardColor;
    final borderC = isDark ? AppTheme.darkBorderColor : AppTheme.borderColor;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderC),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.16),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: AppTheme.primaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sardor A.',
                          style: AppTheme.bodyLarge
                              .copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              size: 13, color: AppTheme.accentColor),
                          const SizedBox(width: 3),
                          Text('4.9', style: AppTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('8 daq',
                        style: AppTheme.bodyLarge.copyWith(
                            color: AppTheme.secondaryColor,
                            fontWeight: FontWeight.bold)),
                    Text(loc.t('arrives'), style: AppTheme.caption),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.phone, size: 18),
                    label: Text(loc.t('call')),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: Text(loc.t('message')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
