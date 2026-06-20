import 'package:flutter/material.dart';
import 'package:avtoassist/utils/app_theme.dart';
import 'package:avtoassist/screens/vehicle/add_vehicle_screen.dart';
import 'package:avtoassist/screens/vehicle/vehicle_details_screen.dart';

class MyVehicleScreen extends StatefulWidget {
  const MyVehicleScreen({super.key});

  @override
  State<MyVehicleScreen> createState() => _MyVehicleScreenState();
}

class _MyVehicleScreenState extends State<MyVehicleScreen> {
  // Demo data - real data will come from API
  final List<Map<String, dynamic>> _vehicles = [
    {
      'id': 1,
      'brand': 'Chevrolet',
      'model': 'Gentra',
      'year': 2020,
      'plate_number': '01 A 777 BA',
      'current_mileage': 45000,
      'last_oil_change': DateTime(2024, 5, 15),
      'oil_changes_count': 3,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mening avtomobilim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddVehicleScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _vehicles.isEmpty ? _buildEmptyState() : _buildVehiclesList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Avtomobil qo\'shilmagan',
              style: AppTheme.heading2.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Avtomobilingiz haqida ma\'lumot qo\'shing',
              style: AppTheme.bodyMedium.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddVehicleScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Avtomobil qo\'shish'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehiclesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = _vehicles[index];
        return _VehicleCard(
          vehicle: vehicle,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VehicleDetailsScreen(vehicleId: vehicle['id']),
              ),
            );
          },
        );
      },
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Map<String, dynamic> vehicle;
  final VoidCallback onTap;

  const _VehicleCard({
    required this.vehicle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lastOilChange = vehicle['last_oil_change'] as DateTime?;
    final daysSinceChange = lastOilChange != null
        ? DateTime.now().difference(lastOilChange).inDays
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      color: AppTheme.primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${vehicle['brand']} ${vehicle['model']}',
                          style: AppTheme.heading3,
                        ),
                        if (vehicle['year'] != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${vehicle['year']} yil',
                            style: AppTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kilometraj',
                          style: AppTheme.caption,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${vehicle['current_mileage'].toString().replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (m) => '${m[1]} ',
                              )} km',
                          style: AppTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppTheme.borderColor,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Oxirgi moy',
                            style: AppTheme.caption,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            daysSinceChange != null
                                ? '$daysSinceChange kun oldin'
                                : 'Ma\'lumot yo\'q',
                            style: AppTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: daysSinceChange != null && daysSinceChange > 90
                                  ? AppTheme.errorColor
                                  : AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (vehicle['plate_number'] != null) ...[
                const Divider(height: 24),
                Row(
                  children: [
                    const Icon(
                      Icons.confirmation_number_outlined,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      vehicle['plate_number'],
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
