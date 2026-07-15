import 'package:flutter/material.dart';

class RegisterField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextInputType keyboardType;

  const RegisterField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<RegisterField> createState() => _RegisterFieldState();
}

class _RegisterFieldState extends State<RegisterField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    // ConstrainedBox garantiza altura minima accesible para el campo
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 52),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEAF7EA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFB2DFDB), width: 1),
        ),
        child: TextField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscure : false,
          keyboardType: widget.keyboardType,
          style: const TextStyle(fontSize: 15, color: Color(0xFF2E7D32)),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(color: Color(0xFF81C784)),
            prefixIcon: Icon(widget.icon, color: const Color(0xFF4CAF50), size: 20),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF4CAF50),
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }
}
