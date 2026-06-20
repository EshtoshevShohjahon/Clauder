import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:avtoassist/providers/locale_provider.dart';
import 'package:avtoassist/utils/app_theme.dart';

class OilChangeListScreen extends StatelessWidget {
  final int vehicleId;

  const OilChangeListScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    // Demo data
    final oilChanges = [
      {
        'id': 1,
        'oil_type': '10W-40',
        'oil_brand': 'Shell Helix',
        'mileage': 45000,
        'next_change_mileage': 55000,
        'location': 'Yunusobod tumani',
        'workshop_name': 'AvtoServis №1',
        'price': 250000.0,
        'changed_at': DateTime(2024, 5, 15),
      },
      {
        'id': 2,
        'oil_type': '10W-40',
        'oil_brand': 'Mobil Super',
        'mileage': 35000,
        'location': 'Chilonzor',
        'price': 220000.0,
        'changed_at': DateTime(2024, 1, 20),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(context.read<LocaleProvider>().t('oil_change_history')),
      ),
      body: oilChanges.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: oilChanges.length,
              itemBuilder: (context, index) {
                return _OilChangeCard(oilChange: oilChanges[index]);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final loc = context.read<LocaleProvider>();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.oil_barrel, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            loc.t('no_oil_history'),
            style: AppTheme.heading3.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _OilChangeCard extends StatelessWidget {
  final Map<String, dynamic> oilChange;

  const _OilChangeCard({required this.oilChange});

  @override
  Widget build(BuildContext context) {
    final loc = context.read<LocaleProvider>();
    final date = oilChange['changed_at'] as DateTime;
    final mileage = oilChange['mileage'] as int;
    final nextMileage = oilChange['next_change_mileage'] as int?;
    final price = oilChange['price'] as double?;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.oil_barrel, color: Colors.orange),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${oilChange['oil_type']}${oilChange['oil_brand'] != null ? ' - ${oilChange['oil_brand']}' : ''}',
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${date.day}.${date.month}.${date.year}',
                        style: AppTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _InfoRow(
              icon: Icons.speed,
              label: loc.t('mileage'),
              value: '${mileage.toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (m) => '${m[1]} ',
                  )} km',
            ),
            if (nextMileage != null) ...[
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.event,
                label: loc.t('next_change'),
                value: '${nextMileage.toString().replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (m) => '${m[1]} ',
                    )} km',
              ),
            ],
            if (oilChange['location'] != null) ...[
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.location_on,
                label: loc.t('address'),
                value: oilChange['location'] as String,
              ),
            ],
            if (price != null) ...[
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.attach_money,
                label: loc.t('price'),
                value: '${price.toStringAsFixed(0)} ${loc.t('sum_unit')}',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTheme.bodySmall,
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
