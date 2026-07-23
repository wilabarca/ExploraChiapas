import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';

/// Overlay de carga no descartable mientras se elimina la cuenta. Quien
/// invoca esta función es responsable de cerrarlo con `Navigator.pop`
/// una vez llega la respuesta del backend (éxito o error).
Future<void> mostrarEliminandoCuentaDialog(BuildContext context) {
  final lang = context.read<LocaleProvider>().langCode;
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: '',
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, _, __) => const SizedBox.shrink(),
    transitionBuilder: (context, animation, _, child) {
      // canPop: false — el botón "Atrás" del sistema no debe poder cerrar
      // este overlay mientras la eliminación está en curso: quien invoca
      // esta función controla su cierre explícitamente con Navigator.pop
      // una vez llega la respuesta del backend, y un cierre prematuro por
      // fuera de ese control dejaría la navegación en un estado inválido.
      return PopScope(
        canPop: false,
        child: _PopTransition(
          animation: animation,
          child: _DialogCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primary(context)),
                const SizedBox(height: 18),
                Text(
                  AppStrings.tr('eliminando_cuenta', lang),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Diálogo de error no bloqueante tras un intento fallido de eliminar la
/// cuenta. Devuelve `true` si el usuario elige reintentar.
Future<bool> mostrarErrorEliminarCuentaDialog(
  BuildContext context, {
  required String mensaje,
}) async {
  final lang = context.read<LocaleProvider>().langCode;
  final reintentar = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, _, __) => const SizedBox.shrink(),
    transitionBuilder: (context, animation, _, child) {
      return _PopTransition(
        animation: animation,
        child: _DialogCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.errorContainer(context),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  color: AppColors.error(context),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                mensaje,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary(context),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(AppStrings.tr('cancelar', lang)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary(context),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        AppStrings.tr('reintentar', lang),
                        style: TextStyle(color: AppColors.onPrimary(context)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  return reintentar ?? false;
}

/// Bottom sheet de confirmación tras eliminar la cuenta exitosamente. Solo
/// se puede cerrar con el botón "Continuar" (sin swipe ni tap-fuera): la
/// sesión ya fue cerrada, así que no debe quedar una vía para "quedarse"
/// en esta pantalla — el único desenlace posible es ir al Login.
Future<void> mostrarCuentaEliminadaSheet(BuildContext context) {
  final lang = context.read<LocaleProvider>().langCode;
  return showModalBottomSheet<void>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _CuentaEliminadaSheetContent(lang: lang),
  );
}

class _CuentaEliminadaSheetContent extends StatelessWidget {
  final String lang;
  const _CuentaEliminadaSheetContent({required this.lang});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: AppColors.isDark(context) ? 0.4 : 0.12,
              ),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutBack,
              builder: (context, value, child) =>
                  Transform.scale(scale: value, child: child),
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer(context),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.primary(context),
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 20),
            AnimatedOpacity(
              opacity: 1,
              duration: const Duration(milliseconds: 320),
              child: Text(
                AppStrings.tr('cuenta_eliminada_titulo', lang),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              AppStrings.tr('cuenta_eliminada_msg', lang),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary(context),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppStrings.tr('continuar', lang),
                  style: TextStyle(
                    color: AppColors.onPrimary(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta compartida por los diálogos de carga y error de este flujo:
/// mismas esquinas, sombra y color de superficie.
class _DialogCard extends StatelessWidget {
  final Widget child;
  const _DialogCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: AppColors.isDark(context) ? 0.4 : 0.12,
              ),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// Fade + scale de entrada compartido por los diálogos de este flujo.
class _PopTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  const _PopTransition({required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutBack,
    );
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween(begin: 0.85, end: 1.0).animate(curved),
        child: child,
      ),
    );
  }
}
