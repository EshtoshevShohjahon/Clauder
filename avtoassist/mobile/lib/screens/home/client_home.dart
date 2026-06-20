import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:avtoassist/providers/locale_provider.dart';
import 'package:avtoassist/utils/app_theme.dart';
import 'package:avtoassist/utils/constants.dart';
import 'package:avtoassist/screens/services/services_map_screen.dart';

class ClientHomePage extends StatelessWidget {
  const ClientHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('AvtoHelp'),
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
                    loc.t('greeting'),
                    style: AppTheme.heading2.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.t('search_hint'),
                    style: AppTheme.bodyMedium.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Services grid
          Text(loc.t('services'), style: AppTheme.heading3),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: AppConstants.services.length,
            itemBuilder: (context, index) {
              final service = AppConstants.services[index];
              final serviceId = service['id'] as String;
              final serviceName = loc.t('service_$serviceId');
              return _ServiceCard(
                icon: service['icon'] as IconData,
                title: serviceName,
                color: _getServiceColor(serviceId),
                onTap: () => _handleServiceTap(
                  context,
                  serviceId,
                  serviceName,
                  service['has_map'] as bool,
                  service['place_type'] as String?,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getServiceColor(String serviceId) {
    switch (serviceId) {
      case 'mechanic':
        return Colors.blue;
      case 'fuel_delivery':
        return Colors.orange;
      case 'car_wash':
        return Colors.cyan;
      case 'evacuator':
        return Colors.red;
      case 'workshop':
        return Colors.green;
      case 'auto_parts':
        return Colors.brown;
      case 'gas_stations':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  void _handleServiceTap(
    BuildContext context,
    String serviceId,
    String serviceName,
    bool hasMap,
    String? placeType,
  ) {
    if (hasMap && placeType != null) {
      // Xarita bilan xizmatlar
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ServicesMapScreen(
            serviceType: placeType,
            title: serviceName,
          ),
        ),
      );
    } else {
      // Oddiy so'rov xizmatlari
      _showOrderDialog(context, serviceId, serviceName);
    }
  }

  void _showOrderDialog(BuildContext context, String serviceType, String serviceName) {
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
        child: OrderFormSheet(
          serviceType: serviceType,
          serviceName: serviceName,
        ),
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
  final String serviceName;

  const OrderFormSheet({
    super.key,
    required this.serviceType,
    required this.serviceName,
  });

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
    final loc = context.watch<LocaleProvider>();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.serviceName,
            style: AppTheme.heading2,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    loc.t('coming_soon'),
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.amber.shade900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            loc.t('coming_soon_desc'),
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.t('close')),
          ),
        ],
      ),
    );
  }
}
