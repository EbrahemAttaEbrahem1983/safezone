import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:safe_zone/auth/rbac_controller.dart';
import 'package:safe_zone/core/rbac/roles.dart';
import 'package:safe_zone/core/router/route_names.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final emailCtrl = TextEditingController();
  final passCtrl  = TextEditingController();
  final rbac = Get.find<RBACController>();

  Future<void> _login() async {
    final email = emailCtrl.text.trim();
    final pass  = passCtrl.text;

    if (email.isEmpty || pass.isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال البريد وكلمة المرور',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // خريطة بسيطة لتعيين الدور حسب الإيميل (مؤقتًا للتجربة)
    Role role;
    if (email == 'admin@safezone.com') {
      role = Role.admin;
    } else if (email == 'manager@safezone.com') {
      role = Role.manager;
    } else if (email == 'supervisor@safezone.com') {
      role = Role.supervisor;
    } else if (email == 'supersuper@safezone.com') {
      role = Role.superSupervisor;
    } else {
      role = Role.individual; // الافتراضي
    }

    await rbac.setRole(role);
    Get.offAllNamed(R.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  const Text('تسجيل الدخول',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 32),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'البريد الإلكتروني',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'كلمة المرور',
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _login,
                    child: const Text('دخول'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
