import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:avtoassist/providers/locale_provider.dart';
import 'package:avtoassist/utils/app_theme.dart';

class ProviderHomePage extends StatefulWidget {
  const ProviderHomePage({super.key});

  @override
  State<ProviderHomePage> createState() => _ProviderHomePageState();
}

class _ProviderHomePageState extends State<ProviderHomePage> {
  bool _isOnline = false;

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('provider_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status Card
          Card(
            color: _isOnline ? AppTheme.successColor : Colors.grey,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isOnline ? loc.t('online') : loc.t('offline'),
                          style: AppTheme.heading2.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isOnline
                              ? loc.t('online_desc')
                              : loc.t('offline_desc'),
                          style: AppTheme.bodySmall.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isOnline,
                    onChanged: (value) {
                      setState(() {
                        _isOnline = value;
                      });
                    },
                    activeColor: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Stats
          Text(loc.t('statistics'), style: AppTheme.heading3),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: loc.t('today'),
                  value: '5',
                  subtitle: loc.t('requests_unit'),
                  icon: Icons.today,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: loc.t('total'),
                  value: '156',
                  subtitle: loc.t('requests_unit'),
                  icon: Icons.assignment,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: loc.t('rating'),
                  value: '4.7',
                  subtitle: loc.t('rating_unit'),
                  icon: Icons.star,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: loc.t('income'),
                  value: '2.5M',
                  subtitle: loc.t('sum_unit'),
                  icon: Icons.attach_money,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Active orders
          Text(loc.t('active_requests'), style: AppTheme.heading3),
          const SizedBox(height: 16),
          if (!_isOnline)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_off,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      loc.t('offline'),
                      style: AppTheme.heading3.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.t('turn_on_to_online'),
                      style: AppTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.hourglass_empty,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      loc.t('no_new_requests'),
                      style: AppTheme.heading3.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.t('notify_on_request'),
                      style: AppTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: AppTheme.caption),
                Icon(icon, size: 20, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTheme.heading2.copyWith(color: color),
            ),
            Text(subtitle, style: AppTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
