import 'package:flutter/material.dart';
import 'package:avtoassist/utils/app_theme.dart';
import 'package:avtoassist/utils/app_icons.dart';
import 'package:avtoassist/utils/constants.dart';

class ClientHomePage extends StatelessWidget {
  const ClientHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AvtoAssist'),
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
          // Welcome card
          Card(
            color: AppTheme.primaryColor,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Qanday yordam kerak?',
                    style: AppTheme.heading2.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kerakli xizmatni tanlang',
                    style: AppTheme.bodyMedium.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Services grid
          const Text('Xizmatlar', style: AppTheme.heading3),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _ServiceCard(
                icon: AppIcons.mechanic,
                title: 'Texnik yordam',
                color: Colors.blue,
                onTap: () => _showOrderDialog(context, AppConstants.serviceMechanic),
              ),
              _ServiceCard(
                icon: AppIcons.fuelDelivery,
                title: 'Yoqilg\'i quyish',
                color: Colors.orange,
                onTap: () => _showOrderDialog(context, AppConstants.serviceFuelDelivery),
              ),
              _ServiceCard(
                icon: AppIcons.carWash,
                title: 'Avtoyuv',
                color: Colors.cyan,
                onTap: () => _showOrderDialog(context, AppConstants.serviceCarWash),
              ),
              _ServiceCard(
                icon: AppIcons.towTruck,
                title: 'Evakuator',
                color: Colors.red,
                onTap: () => _showOrderDialog(context, AppConstants.serviceTowTruck),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Catalog section
          const Text('Kataloglar', style: AppTheme.heading3),
          const SizedBox(height: 16),
          _CatalogCard(
            icon: AppIcons.partsSeller,
            title: 'Ehtiyot qismlar',
            subtitle: 'Do\'konlar va narxlar',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _CatalogCard(
            icon: AppIcons.workshop,
            title: 'Ustaxonalar',
            subtitle: 'Yaqin atrofdagi servislar',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  void _showOrderDialog(BuildContext context, String serviceType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: OrderFormSheet(serviceType: serviceType),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CatalogCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CatalogCard({
    required this.icon,
    required this.title,
    required this.subtitle,
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
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(title, style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: AppTheme.bodySmall),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class OrderFormSheet extends StatefulWidget {
  final String serviceType;

  const OrderFormSheet({super.key, required this.serviceType});

  @override
  State<OrderFormSheet> createState() => _OrderFormSheetState();
}

class _OrderFormSheetState extends State<OrderFormSheet> {
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppIcons.getServiceName(widget.serviceType),
            style: AppTheme.heading2,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Muammo tavsifi (ixtiyoriy)',
              hintText: 'Masalan: Dvigatel ishlamayapti',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // TODO: Create order
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('So\'rov yaratildi')),
              );
            },
            child: const Text('So\'rov yuborish'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
        ],
      ),
    );
  }
}
