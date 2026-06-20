import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:avtoassist/providers/auth_provider.dart';
import 'package:avtoassist/providers/locale_provider.dart';
import 'package:avtoassist/utils/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _codeSent = false;
  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _sendCode(LocaleProvider loc) async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final result = await auth.forgotPassword(phone);
    if (!mounted) return;
    setState(() => _loading = false);

    if (result != null) {
      setState(() => _codeSent = true);
      final devCode = result['dev_code'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(devCode != null
              ? '${loc.t('code_sent')} (TEST: $devCode)'
              : loc.t('code_sent')),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Xato'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _reset(LocaleProvider loc) async {
    final code = _codeController.text.trim();
    final newPass = _passwordController.text;
    if (code.isEmpty || newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.t('password_min_6'))),
      );
      return;
    }
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.resetPassword(
      phone: _phoneController.text.trim(),
      code: code,
      newPassword: newPass,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.t('password_reset_success'))),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Xato'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(loc.t('reset_password'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            const Icon(Icons.lock_reset, size: 64, color: AppTheme.primaryColor),
            const SizedBox(height: 24),

            // Telefon raqam
            TextField(
              controller: _phoneController,
              enabled: !_codeSent,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: loc.t('phone_number'),
                hintText: '+998901234567',
                prefixIcon: const Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 16),

            if (!_codeSent)
              ElevatedButton(
                onPressed: _loading ? null : () => _sendCode(loc),
                child: _loading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(loc.t('send_code')),
              ),

            // Kod + yangi parol (kod yuborilgandan keyin)
            if (_codeSent) ...[
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: loc.t('verification_code'),
                  prefixIcon: const Icon(Icons.sms),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: loc.t('new_password'),
                  hintText: loc.t('min_6_chars'),
                  prefixIcon: const Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : () => _reset(loc),
                child: _loading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(loc.t('reset_password')),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _loading ? null : () => _sendCode(loc),
                child: Text(loc.t('send_code')),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
