import 'package:flutter/material.dart';

Future<T?> showStyledDialog<T>({
  required BuildContext context,
  required String title,
  required String message,
  required String primaryLabel,
  required VoidCallback onPrimary,
  Color primaryColor = const Color(0xFF00623A),
  IconData icon = Icons.check_circle_rounded,
  Color iconColor = const Color(0xFF00623A),
  Color gradientTop = const Color(0xFFEFF9FF),
  Color gradientBottom = Colors.white,
  String? secondaryLabel,
  VoidCallback? onSecondary,
}) {
  return showDialog<T>(
    context: context,
    useRootNavigator: true,
    builder: (ctx) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [gradientTop, gradientBottom],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 42,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPrimary,
                  style: ElevatedButton.styleFrom(
                    elevation: 4,
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    primaryLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              if (secondaryLabel != null && onSecondary != null) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: onSecondary,
                  child: Text(
                    secondaryLabel,
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.65),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}
