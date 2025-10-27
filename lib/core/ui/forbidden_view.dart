// lib/core/views/forbidden_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_zone/core/router/route_names.dart';

class ForbiddenView extends StatelessWidget {
  const ForbiddenView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ممنوع'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.block, size: 64, color: Colors.redAccent),
              const SizedBox(height: 16),
              const Text(
                'ليس لديك صلاحية للوصول إلى هذه الصفحة.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () {
                  Get.offAllNamed(R.root); // رجوع للواجهة الرئيسية
                },
                child: const Text('العودة للرئيسية'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
