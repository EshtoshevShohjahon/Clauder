import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:avtoassist/providers/auth_provider.dart';
import 'package:avtoassist/providers/locale_provider.dart';
import 'package:avtoassist/utils/app_theme.dart';
import 'package:avtoassist/utils/constants.dart';
import 'package:avtoassist/screens/services/services_map_screen.dart';

class ClientHomePage extends StatelessWidget {
  const ClientHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final user = context.watch<AuthProvider>().user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.darkCardColor : AppTheme.cardColor;
    final borderC = isDark ? AppTheme.darkBorderColor : AppTheme.borderColor;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          children: [
            // Greeting row
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.t('greeting'),
                          style: AppTheme.bodySmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.fullName ?? user?.phone ?? 'AvtoHelp',
                          style: AppTheme.heading3,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: cardBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: borderC),
                    ),
                    child: const Icon(Icons.person, size: 20),
                  ),
                ],
              ),
            ),

            // Search bar (dekorativ)
            Container(
              margin: const EdgeInsets.only(bottom: 18),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderC),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 18, color: AppTheme.textSecondary),
                  const SizedBox(width: 9),
                  Text(
                    loc.t('search_hint'),
                    style: AppTheme.bodySmall,
                  ),
                ],
              ),
            ),

            // Services title
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(loc.t('services'), style: AppTheme.heading3),
            ),

            // Services grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.15,
              ),
              itemCount: AppConstants.services.length,
              itemBuilder: (context, index) {
                final service = AppConstants.services[index];
                final serviceId = service['id'] as String;
                final serviceName = loc.t('service_$serviceId');
                final accent = _accentColor(serviceId);
                return _ServiceCard(
                  icon: service['icon'] as IconData,
                  title: serviceName,
                  accent: accent,
                  cardBg: cardBg,
                  borderC: borderC,
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
      ),
    );
  }

  // Mockup uslubi: do'kon/yuvish - teal, qolganlar - amber
  Color _accentColor(String serviceId) {
    switch (serviceId) {
      case 'car_wash':
      case 'auto_parts':
        return AppTheme.secondaryColor; // teal
      default:
        return AppTheme.primaryColor; // amber
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
      _showOrderDialog(context, serviceId, serviceName);
    }
  }

  void _showOrderDialog(BuildContext context, String serviceType, String serviceName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
  final Color accent;
  final Color cardBg;
  final Color borderC;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.accent,
    required this.cardBg,
    required this.borderC,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderC),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.16),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: accent, size: 20),
            ),
            Text(
              title,
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
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
  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppTheme.darkCardColor : AppTheme.cardColor;

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(widget.serviceName, style: AppTheme.heading2),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.accentColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    loc.t('coming_soon'),
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            loc.t('coming_soon_desc'),
            style: AppTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.t('close')),
          ),
        ],
      ),
    );
  }
}
