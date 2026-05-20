import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

class OrbitPinField extends StatelessWidget {
  final int length;
  final TextEditingController controller;
  final Function(String)? onCompleted;

  const OrbitPinField({
    super.key,
    this.length = 6,
    required this.controller,
    this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultPinTheme = PinTheme(
      width: 50,
      height: 56,
      textStyle: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1.5,
        ),
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(color: theme.colorScheme.primary, width: 2),
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
      ),
    );

    // ويدجيت لمراقبة اختصارات الكيبورد (خاصة للويندوز)
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyV, control: true): () async {
          ClipboardData? data = await Clipboard.getData('text/plain');
          if (data?.text != null) {
            String text = data!.text!.replaceAll(RegExp(r'[^0-9]'), '');
            if (text.length > length) text = text.substring(0, length);
            controller.text = text;
            if (text.length == length) onCompleted?.call(text);
          }
        },
      },
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Pinput(
          length: length,
          controller: controller,
          defaultPinTheme: defaultPinTheme,
          focusedPinTheme: focusedPinTheme,
          submittedPinTheme: submittedPinTheme,
          onCompleted: onCompleted,
          hapticFeedbackType: HapticFeedbackType.lightImpact,
          showCursor: true,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
      ),
    );
  }
}
