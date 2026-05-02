import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      LoginSubmitted(_emailCtrl.text.trim(), _passCtrl.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ BlocProvider wraps everything FIRST
    return BlocProvider(
      create: (_) => getIt<AuthBloc>(),
      child: Builder(  // ✅ Builder gives a new context INSIDE the BlocProvider
        builder: (context) {
          return BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthSuccess) {
                context.go(AppRoutes.home);
              }
              if (state is AuthFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              return Scaffold(
                backgroundColor: Theme.of(context).colorScheme.surface,
                body: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        // Top bar
                        Row(
                          children: [
                            Icon(Icons.school,
                                color: Theme.of(context).colorScheme.primary,
                                size: 32),
                            const SizedBox(width: 12),
                            const Text(
                              "SmartCampus",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),
                        // Hero text
                        const Text("Welcome Back",
                            style: TextStyle(
                                fontSize: 32, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text("Sign in to access your campus dashboard",
                            style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.outline)),
                        const SizedBox(height: 32),
                        // Form
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: "Email",
                                  prefixIcon:
                                      const Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(16)),
                                  filled: true,
                                ),
                                validator: (v) =>
                                    (v == null || !v.contains('@'))
                                        ? "Invalid email"
                                        : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passCtrl,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: "Password",
                                  prefixIcon:
                                      const Icon(Icons.lock_outline),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(16)),
                                  filled: true,
                                ),
                                validator: (v) =>
                                    (v == null || v.length < 6)
                                        ? "Password too short"
                                        : null,
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () => _submit(context),
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                  ),
                                  child: isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white)
                                      : const Text("Sign In",
                                          style: TextStyle(fontSize: 18)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}