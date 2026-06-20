import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:avtoassist/providers/auth_provider.dart';
import 'package:avtoassist/providers/theme_provider.dart';
import 'package:avtoassist/providers/locale_provider.dart';
import 'package:avtoassist/services/api_service.dart';
import 'package:avtoassist/l10n/app_strings.dart';
import 'package:avtoassist/screens/home/client_home.dart';
import 'package:avtoassist/screens/home/provider_home.dart';
import 'package:avtoassist/screens/vehicle/my_vehicle_screen.dart';
import 'package:avtoassist/utils/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final loc = context.watch<LocaleProvider>();
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isClient = user.isClient;

    final List<Widget> pages = isClient
        ? [
            const ClientHomePage(),
            const OrdersListPage(),
            const MyVehicleNavigatorPage(),
            const ProfilePage(),
          ]
        : [
            const ProviderHomePage(),
            const ProviderOrdersPage(),
            const MyVehicleNavigatorPage(),
            const ProfilePage(),
          ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppTheme.primaryColor,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: loc.t('nav_home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.list_alt),
            label: loc.t('nav_orders'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.directions_car),
            label: loc.t('nav_vehicle'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: loc.t('nav_profile'),
          ),
        ],
      ),
    );
  }
}

// Placeholder pages
class OrdersListPage extends StatelessWidget {
  const OrdersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(loc.t('my_orders'))),
      body: Center(child: Text(loc.t('my_orders'))),
    );
  }
}

class ProviderOrdersPage extends StatelessWidget {
  const ProviderOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(loc.t('new_orders'))),
      body: Center(child: Text(loc.t('new_orders'))),
    );
  }
}

// Vehicle Navigator Page (wrapper for maintaining navigation state)
class MyVehicleNavigatorPage extends StatelessWidget {
  const MyVehicleNavigatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyVehicleScreen();
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final loc = context.watch<LocaleProvider>();
    final user = authProvider.user;
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(title: Text(loc.t('profile'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user?.fullName ?? loc.t('profile'), style: AppTheme.heading2),
                  const SizedBox(height: 8),
                  Text(user?.phone ?? '', style: AppTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(user?.isClient == true ? loc.t('client') : loc.t('provider')),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Til tanlash
          Card(
            child: ListTile(
              leading: const Icon(Icons.language, color: AppTheme.primaryColor),
              title: Text(loc.t('language')),
              subtitle: Text(loc.currentLanguageName),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLanguageDialog(context, loc),
            ),
          ),
          const SizedBox(height: 16),

          // Server manzili
          Card(
            child: ListTile(
              leading: const Icon(Icons.dns, color: AppTheme.primaryColor),
              title: Text(loc.t('server_url')),
              subtitle: Text(ApiService().baseUrl),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showServerUrlDialog(context, loc),
            ),
          ),
          const SizedBox(height: 16),

          // Tungi rejim
          Card(
            child: SwitchListTile(
              secondary: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: AppTheme.primaryColor,
              ),
              title: Text(loc.t('dark_mode')),
              subtitle: Text(isDark ? loc.t('on') : loc.t('off')),
              value: isDark,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
            ),
          ),
          const SizedBox(height: 16),

          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(loc.t('logout')),
            onTap: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, LocaleProvider loc) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(loc.t('choose_language')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppStrings.languageNames.entries.map((entry) {
              return RadioListTile<String>(
                title: Text(entry.value),
                value: entry.key,
                groupValue: loc.code,
                activeColor: AppTheme.primaryColor,
                onChanged: (value) {
                  if (value != null) {
                    loc.setLanguage(value);
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showServerUrlDialog(BuildContext context, LocaleProvider loc) {
    final controller = TextEditingController(text: ApiService().baseUrl);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(loc.t('server_url')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType: TextInputType.url,
                autocorrect: false,
                decoration: InputDecoration(
                  hintText: loc.t('server_url_hint'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(loc.t('close')),
            ),
            ElevatedButton(
              onPressed: () async {
                await ApiService().setServerUrl(controller.text);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.t('server_url_saved'))),
                  );
                }
              },
              child: Text(loc.t('save')),
            ),
          ],
        );
      },
    );
  }
}
