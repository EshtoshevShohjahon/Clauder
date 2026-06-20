import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:avtoassist/providers/auth_provider.dart';
import 'package:avtoassist/providers/locale_provider.dart';
import 'package:avtoassist/services/api_service.dart';
import 'package:avtoassist/screens/auth/register_screen.dart';
import 'package:avtoassist/screens/auth/forgot_password_screen.dart';
import 'package:avtoassist/screens/home/home_screen.dart';
import 'package:avtoassist/utils/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      phone: _phoneController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? context.read<LocaleProvider>().t('login_error')),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Server manzili sozlamasi (ro'yxatdan o'tishdan oldin ham)
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.dns_outlined),
                    tooltip: loc.t('server_url'),
                    onPressed: () => _showServerUrlDialog(context, loc),
                  ),
                ),
                const SizedBox(height: 20),
                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.directions_car,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'AvtoHelp',
                  style: AppTheme.heading1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  loc.t('app_subtitle'),
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                
                // Phone field
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: loc.t('phone_number'),
                    hintText: '+998901234567',
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return loc.t('enter_phone');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Password field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: loc.t('password'),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return loc.t('enter_password');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Login button
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return ElevatedButton(
                      onPressed: auth.isLoading ? null : _login,
                      child: auth.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(loc.t('login')),
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Parolni unutdingizmi?
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: Text(loc.t('forgot_password')),
                ),
                
                // Register link
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: Text(loc.t('register')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
