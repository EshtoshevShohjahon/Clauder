import 'package:flutter/material.dart';
import 'package:avtoassist/utils/app_theme.dart';
import 'package:avtoassist/screens/vehicle/oil_change_list_screen.dart';
import 'package:avtoassist/screens/vehicle/add_oil_change_screen.dart';

class VehicleDetailsScreen extends StatefulWidget {
  final int vehicleId;

  const VehicleDetailsScreen({super.key, required this.vehicleId});

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  // Demo data
  final _vehicle = {
    'brand': 'Chevrolet',
    'model': 'Gentra',
    'year': 2020,
    'plate_number': '01 A 777 BA',
    'current_mileage': 45000,
  };

  final _reminders = [
    {
      'id': 1,
      'title': 'Moy almashtirish vaqti',
      'remaining_km': 500,
      'is_urgent': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_vehicle['brand']} ${_vehicle['model']}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Edit vehicle
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Vehicle info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      size: 40,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${_vehicle['brand']} ${_vehicle['model']}',
                    style: AppTheme.heading2,
                  ),
                  if (_vehicle['year'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${_vehicle['year']} yil',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                  if (_vehicle['plate_number'] != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Text(
                        _vehicle['plate_number'].toString(),
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.speed,
                        color: AppTheme.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_vehicle['current_mileage'].toString().replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (m) => '${m[1]} ',
                            )} km',
                        style: AppTheme.heading3.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Reminders
          if (_reminders.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Eslatmalar', style: AppTheme.heading3),
                TextButton(
                  onPressed: () {
                    // TODO: View all reminders
                  },
                  child: const Text('Barchasi'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._reminders.map((reminder) => _ReminderCard(reminder: reminder)),
            const SizedBox(height: 24),
          ],

          // Quick actions
          const Text('Tezkor harakatlar', style: AppTheme.heading3),
          const SizedBox(height: 12),
          
          _ActionCard(
            icon: Icons.oil_barrel,
            title: 'Moy almashtirish qo\'shish',
            subtitle: 'Oxirgi moy almashtirish ma\'lumotini kiriting',
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddOilChangeScreen(vehicleId: widget.vehicleId),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          
          _ActionCard(
            icon: Icons.history,
            title: 'Moy almashtirish tarixi',
            subtitle: 'Barcha moy almashtirishlar tarixi',
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OilChangeListScreen(vehicleId: widget.vehicleId),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          
          _ActionCard(
            icon: Icons.notifications_active,
            title: 'Eslatma qo\'shish',
            subtitle: 'Yangi texnik xizmat eslatmasi',
            color: Colors.purple,
            onTap: () {
              // TODO: Add reminder
            },
          ),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final Map<String, dynamic> reminder;

  const _ReminderCard({required this.reminder});

  @override
  Widget build(BuildContext context) {
    final isUrgent = reminder['is_urgent'] as bool;
    final remainingKm = reminder['remaining_km'] as int;

    return Card(
      color: isUrgent ? AppTheme.errorColor.withOpacity(0.1) : null,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isUrgent
                ? AppTheme.errorColor.withOpacity(0.2)
                : AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.notification_important,
            color: isUrgent ? AppTheme.errorColor : AppTheme.primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          reminder['title'] as String,
          style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Yana $remainingKm km qoldi',
          style: AppTheme.bodySmall,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isUrgent ? AppTheme.errorColor : AppTheme.textSecondary,
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle, style: AppTheme.bodySmall),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
