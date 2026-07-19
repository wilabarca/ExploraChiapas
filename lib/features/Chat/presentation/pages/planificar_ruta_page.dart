import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/chat_provider.dart';

class PlanificarRutaPage extends StatefulWidget {
  const PlanificarRutaPage({super.key});

  @override
  State<PlanificarRutaPage> createState() => _PlanificarRutaPageState();
}

class _PlanificarRutaPageState extends State<PlanificarRutaPage> {
  final Set<String> _tiposSeleccionados = {};
  String _presupuesto = 'Moderado';
  String _tiempo = '1 día';
  bool _generando = false;

  static const _tipos = [
    {'label': 'Naturaleza', 'icon': Icons.eco_outlined},
    {'label': 'Cultura', 'icon': Icons.account_balance_outlined},
    {'label': 'Gastronomía', 'icon': Icons.restaurant_outlined},
    {'label': 'Aventura', 'icon': Icons.kayaking_outlined},
    {'label': 'Descanso', 'icon': Icons.spa_outlined},
    {'label': 'Familiar', 'icon': Icons.family_restroom_outlined},
    {'label': 'Fotografía', 'icon': Icons.camera_alt_outlined},
    {'label': 'Eventos', 'icon': Icons.celebration_outlined},
  ];

  static const _presupuestos = ['Económico', 'Moderado', 'Premium'];
  static const _tiempos = ['Medio día', '1 día', '2 días', '1 semana'];

  static const _iconosPresupuesto = [
    Icons.savings_outlined,
    Icons.account_balance_wallet_outlined,
    Icons.diamond_outlined,
  ];

  Future<void> _generarRuta() async {
    if (_tiposSeleccionados.isEmpty) return;
    setState(() => _generando = true);

    final tipos = _tiposSeleccionados.join(', ');
    final mensaje =
        'Quiero una ruta de turismo de $tipos en Chiapas, '
        'con presupuesto $_presupuesto, disponible por $_tiempo. '
        'Recomiéndame lugares, restaurantes y actividades.';

    await context.read<ChatProvider>().enviarMensaje(mensaje);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/chat');
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.borderSubtle(context)),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Planifica tu aventura',
          style: TextStyle(
            color: AppColors.primary(context),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenW < 400 ? 16 : 20,
          vertical: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel(
              icon: Icons.explore_outlined,
              text: '¿Qué tipo de experiencia buscas?',
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _tipos.map((t) {
                final label = t['label'] as String;
                final icon = t['icon'] as IconData;
                final isSelected = _tiposSeleccionados.contains(label);
                return _SelectChip(
                  label: label,
                  icon: icon,
                  isSelected: isSelected,
                  onTap: () => setState(() {
                    if (isSelected) {
                      _tiposSeleccionados.remove(label);
                    } else {
                      _tiposSeleccionados.add(label);
                    }
                  }),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            _SectionLabel(
              icon: Icons.account_balance_wallet_outlined,
              text: 'Presupuesto aproximado',
            ),
            const SizedBox(height: 12),

            Row(
              children: List.generate(_presupuestos.length, (i) {
                final p = _presupuestos[i];
                final isSelected = _presupuesto == p;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: i < _presupuestos.length - 1 ? 10 : 0,
                    ),
                    child: GestureDetector(
                      onTap: () => setState(() => _presupuesto = p),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryContainer(context)
                              : AppColors.surface(context),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary(context)
                                : AppColors.borderSubtle(context),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _iconosPresupuesto[i],
                              color: isSelected
                                  ? AppColors.primary(context)
                                  : AppColors.textSecondary(context),
                              size: 22,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              p,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppColors.primary(context)
                                    : AppColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 28),

            _SectionLabel(
              icon: Icons.schedule_outlined,
              text: 'Tiempo disponible',
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _tiempos.map((t) {
                final isSelected = _tiempo == t;
                return GestureDetector(
                  onTap: () => setState(() => _tiempo = t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary(context)
                          : AppColors.surface(context),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary(context)
                            : AppColors.borderSubtle(context),
                      ),
                    ),
                    child: Text(
                      t,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? (AppColors.isDark(context)
                                ? Colors.black
                                : Colors.white)
                            : AppColors.textPrimary(context),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    (_tiposSeleccionados.isEmpty || _generando)
                        ? null
                        : _generarRuta,
                icon: _generando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Icon(
                        Icons.smart_toy_outlined,
                        color: Colors.white,
                      ),
                label: Text(
                  _generando ? 'Generando ruta...' : 'Generar mi ruta',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary(context),
                  disabledBackgroundColor: const Color(0xFFB0BEC5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),

            if (_tiposSeleccionados.isEmpty) ...[
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Selecciona al menos un tipo de experiencia',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textHint(context),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String text;
  const _SectionLabel({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary(context)),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }
}

class _SelectChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary(context)
              : AppColors.surface(context),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? AppColors.primary(context)
                : AppColors.borderSubtle(context),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? (AppColors.isDark(context) ? Colors.black : Colors.white)
                  : AppColors.primary(context),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? (AppColors.isDark(context) ? Colors.black : Colors.white)
                    : AppColors.textPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
