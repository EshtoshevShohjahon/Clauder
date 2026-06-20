import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:avtoassist/providers/auth_provider.dart';
import 'package:avtoassist/screens/home/home_screen.dart';
import 'package:avtoassist/utils/app_theme.dart';
import 'package:avtoassist/utils/app_icons.dart';
import 'package:avtoassist/utils/constants.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;
  String? _selectedServiceType;

  final List<Map<String, dynamic>> _serviceTypes = [
    {'type': AppConstants.serviceMechanic, 'name': 'Texnik yordam', 'icon': Icons.build},
    {'type': AppConstants.serviceFuelDelivery, 'name': 'Yoqilg\'i quyish', 'icon': Icons.local_gas_station},
    {'type': AppConstants.serviceCarWash, 'name': 'Avtomobil yuvish', 'icon': Icons.local_car_wash},
    {'type': AppConstants.serviceTowTruck, 'name': 'Evakuator', 'icon': Icons.local_shipping},
  ];

  Future<void> _selectRole() async {
    if (_selectedRole == null) return;
    if (_selectedRole == 'provider' && _selectedServiceType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xizmat turini tanlang')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.selectRole(
      _selectedRole!,
      serviceType: _selectedServiceType,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Men kimman?'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Rolni tanlang',
              style: AppTheme.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Client Card
            _buildRoleCard(
              role: 'client',
              title: 'Mijoz',
              description: 'Xizmat olish',
              icon: Icons.person,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 16),
            
            // Provider Card
            _buildRoleCard(
              role: 'provider',
              title: 'Xizmat ko\'rsatuvchi',
              description: 'Xizmat taqdim etish',
              icon: Icons.work,
              color: AppTheme.secondaryColor,
            ),
            
            // Service type selection (if provider)
            if (_selectedRole == 'provider') ...[
              const SizedBox(height: 24),
              const Text(
                'Xizmat turini tanlang',
                style: AppTheme.heading3,
              ),
              const SizedBox(height: 16),
              ..._serviceTypes.map((service) => 
                _buildServiceTypeCard(service),
              ),
            ],
            
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _selectedRole == null ? null : _selectRole,
              child: const Text('Davom etish'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String role,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedRole == role;
    
    return Card(
      elevation: isSelected ? 8 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? color : AppTheme.borderColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedRole = role;
            if (role == 'client') _selectedServiceType = null;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTheme.heading3),
                    Text(
                      description,
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: color, size: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceTypeCard(Map<String, dynamic> service) {
    final isSelected = _selectedServiceType == service['type'];
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedServiceType = service['type'];
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  service['icon'] as IconData,
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                ),
                const SizedBox(width: 16),
                Text(
                  service['name'] as String,
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  const Icon(Icons.check_circle, color: AppTheme.primaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
