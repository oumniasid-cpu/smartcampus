// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/app_localization.dart';
import '../../../../core/router/app_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _loading = false);
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: colorScheme.surface, // Background follows theme
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildTopBar(colorScheme),
              const SizedBox(height: 48),
              _buildHeroText(colorScheme),
              const SizedBox(height: 16),
              _buildLoginCard(theme, colorScheme), // Updated to use theme
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.school_outlined, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          'SmartCampus',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroText(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back,',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: colorScheme.primary,
            height: 1.1,
          ),
        ),
        Text(
          'Scholar.',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: colorScheme.secondary,
            height: 1.1,
          ),
        ),
      ],
    );
  }

 

  Widget _buildLoginCard(ThemeData theme, ColorScheme colorScheme) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 52, 24, 28),
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? theme.cardColor, // Dynamic card color
            borderRadius: BorderRadius.circular(20),
            border: theme.brightness == Brightness.dark 
                ? Border.all(color: theme.dividerColor) 
                : null,
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.1),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('UNIVERSITY EMAIL', theme),
                const SizedBox(height: 8),
                _buildTextField(
                  theme: theme,
                  controller: _emailCtrl,
                  hintText: 'u.name@university.edu',
                  icon: Icons.alternate_email_rounded,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLabel('SECURITY KEY', theme),
                    TextButton(
                      onPressed: () {},
                      child: Text('Forgot Password?',
                        style: TextStyle(color: colorScheme.secondary)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  theme: theme,
                  controller: _passCtrl,
                  hintText: '••••••••••••',
                  icon: Icons.vpn_key_outlined,
                  isPassword: true,
                ),
                const SizedBox(height: 32),
                _buildSignInButton(colorScheme),
                const SizedBox(height: 24),
                _buildOrDivider(theme),
                const SizedBox(height: 24),
                _buildBiometricButton(colorScheme),
              ],
            ),
          ),
        ),
        _buildFloatingIcon(colorScheme, theme),
      ],
    );
  }

  Widget _buildFloatingIcon(ColorScheme colorScheme, ThemeData theme) {
    return Positioned(
      top: -30,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.lock_rounded, color: colorScheme.secondary, size: 24),
        ),
      ),
    );
  }

  Widget _buildTextField({
  required ThemeData theme,
  required TextEditingController controller,
  required String hintText,
  required IconData icon,
  bool isPassword = false,
}) {
  return Container(
    // This decoration ensures the height is consistent
    decoration: BoxDecoration(
      color: theme.brightness == Brightness.dark 
          ? Colors.white.withOpacity(0.05) 
          : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(12),
    ),
    child: IntrinsicHeight( // Ensures the vertical bar stretches to full height
      child: Row(
        children: [
          // The "Blue Style" accent bar at the left
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary, // The accent color
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
          
          // The actual Input
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: isPassword,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: theme.hintColor.withOpacity(0.5)),
                prefixIcon: Icon(icon, color: theme.colorScheme.primary, size: 20),
                border: InputBorder.none, // Hide default border
                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildLabel(String label, ThemeData theme) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: theme.textTheme.labelSmall?.color?.withOpacity(0.7),
      ),
    );
  }

  Widget _buildSignInButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _loading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _loading 
            ? const CircularProgressIndicator(color: Colors.white) 
            : const Text('Sign In'),
      ),
    );
  }

  Widget _buildBiometricButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.fingerprint),
        label: const Text('Unlock with Biometrics'),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.secondaryContainer,
          foregroundColor: colorScheme.onSecondaryContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildOrDivider(ThemeData theme) {
    return Row(
      children: [
        Expanded(child: Divider(color: theme.dividerColor)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text('OR SECURE LOGIN', style: TextStyle(fontSize: 10)),
        ),
        Expanded(child: Divider(color: theme.dividerColor)),
      ],
    );
  }

  
}