import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final bool isPrimary;
  final VoidCallback onPressed;

  const AuthButton({
    super.key,
    required this.text,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // ConstrainedBox garantiza altura minima accesible y ancho flexible
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 52,
        minWidth: double.infinity,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? const Color(0xFF008F45)
              : Colors.transparent,
          elevation: 0,
          side: isPrimary
              ? null
              : const BorderSide(color: Colors.white38, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                fontSize: 15,
              ),
            ),
            if (isPrimary)
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Icon(Icons.arrow_forward, color: Colors.white, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}
