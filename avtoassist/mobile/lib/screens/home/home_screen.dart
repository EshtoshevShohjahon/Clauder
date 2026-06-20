import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:avtoassist/providers/auth_provider.dart';
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Asosiy',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'So\'rovlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Avtomobil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
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
    return Scaffold(
      appBar: AppBar(title: const Text('Mening so\'rovlarim')),
      body: const Center(child: Text('So\'rovlar ro\'yxati')),
    );
  }
}

class ProviderOrdersPage extends StatelessWidget {
  const ProviderOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('So\'rovlar')),
      body: const Center(child: Text('Yangi so\'rovlar')),
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
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user?.fullName ?? 'Foydalanuvchi', style: AppTheme.heading2),
                  const SizedBox(height: 8),
                  Text(user?.phone ?? '', style: AppTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(user?.isClient == true ? 'Mijoz' : 'Xizmat ko\'rsatuvchi'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Chiqish'),
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
}
