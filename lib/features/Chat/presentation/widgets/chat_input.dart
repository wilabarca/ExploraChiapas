import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const ChatInput({super.key, required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: AppColors.isDark(context) ? 0.3 : 0.06,
            ),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer(context),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: controller,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary(context),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Escribe tu consulta aquí...',
                    hintStyle: TextStyle(
                      color: AppColors.textHint(context),
                      fontSize: 15,
                    ),
                    // Sin esto, el TextField hereda "filled: true" del
                    // InputDecorationTheme global y pinta su propio
                    // rectángulo de fondo (de esquinas cuadradas, sin
                    // redondear) por debajo del texto — se ve como un
                    // cuadro extra asomando dentro de esta píldora
                    // redondeada. El único fondo debe ser el de este
                    // Container (AppColors.surfaceContainer).
                    filled: false,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onSend,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary(context),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: AppColors.onPrimary(context),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
