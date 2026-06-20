import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('AvtoHelp Provider'),
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
                          _isOnline ? 'Onlaynsiz' : 'Offlaynsiz',
                          style: AppTheme.heading2.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isOnline 
                              ? 'Yangi so\'rovlarni qabul qilasiz'
                              : 'Oflayn rejimda so\'rovlar kelmaydi',
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
          const Text('Statistika', style: AppTheme.heading3),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Bugun',
                  value: '5',
                  subtitle: 'so\'rov',
                  icon: Icons.today,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Jami',
                  value: '156',
                  subtitle: 'so\'rov',
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
                  title: 'Reyting',
                  value: '4.7',
                  subtitle: '⭐ baho',
                  icon: Icons.star,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Daromad',
                  value: '2.5M',
                  subtitle: 'so\'m',
                  icon: Icons.attach_money,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Active orders
          const Text('Faol so\'rovlar', style: AppTheme.heading3),
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
                      'Oflayn rejimda',
                      style: AppTheme.heading3.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Onlayn bo\'lish uchun yuqoridagi tugmani yoqing',
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
                      'Yangi so\'rovlar yo\'q',
                      style: AppTheme.heading3.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'So\'rovlar kelganida xabarnoma olasiz',
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
