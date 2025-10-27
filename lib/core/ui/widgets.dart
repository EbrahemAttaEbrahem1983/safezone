import 'package:flutter/material.dart';
import 'tokens.dart';

class ThemedScaffold extends StatelessWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget body;
  final Widget? floating;
  const ThemedScaffold({
    super.key,
    this.title,
    this.actions,
    required this.body,
    this.floating,
  });
  @override
  Widget build(BuildContext context) {
    final t = AppTokens(context);
    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        title: title != null ? Text(title!) : null,
        actions: actions,
      ),
      body: Padding(padding: const EdgeInsets.all(12), child: body),
      floatingActionButton: floating,
    );
  }
}

class ThemedCard extends StatelessWidget {
  final Widget child;
  const ThemedCard({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    final t = AppTokens(context);
    return Container(
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.border),
      ),
      padding: const EdgeInsets.all(12),
      child: child,
    );
  }
}

class ThemedField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final Widget? prefix;
  final Widget? suffix;
  final int maxLines;
  const ThemedField({
    super.key,
    this.controller,
    this.hint,
    this.prefix,
    this.suffix,
    this.maxLines = 1,
  });
  @override
  Widget build(BuildContext context) {
    final t = AppTokens(context);
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefix,
        suffixIcon: suffix,
        filled: true,
        fillColor: t.fieldBg,
        hintStyle: TextStyle(color: t.fieldHint),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: t.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: t.border, width: 1.2),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });
  @override
  Widget build(BuildContext context) {
    final t = AppTokens(context);
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null
            ? Icon(icon, color: t.primaryBtnFg)
            : const SizedBox.shrink(),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: t.primaryBtnBg,
          foregroundColor: t.primaryBtnFg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });
  @override
  Widget build(BuildContext context) {
    final t = AppTokens(context);
    return SizedBox(
      height: 48,
      child: FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: t.secondaryBtnBg,
          foregroundColor: t.secondaryBtnFg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
