import 'dart:async';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/promocion.dart';
import '../../domain/usecases/get_promociones_usecase.dart';

enum PromocionesStatus { idle, loading, success, error }

// Filtro de fecha aplicado sobre la lista ya cargada.
enum PromocionesFiltro { activas, proximas, finalizadas }

@injectable
class PromocionesProvider extends ChangeNotifier {
  final GetPromocionesUseCase _getPromociones;

  PromocionesProvider(this._getPromociones) {
    // ✅ Revisa cada minuto si alguna promoción venció mientras el usuario
    // tenía la pantalla abierta, y refresca la UI para que desaparezca
    // de la vista sin necesidad de recargar manualmente.
    _expiracionTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => notifyListeners(),
    );
  }

  Timer? _expiracionTimer;

  PromocionesStatus _status = PromocionesStatus.idle;
  PromocionesStatus get status => _status;

  List<PromocionEntity> _promociones = const [];

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Por defecto se aterriza en "activas" (vigentes), no en "todas",
  // para que lo vencido nunca sea lo primero que ve el usuario.
  PromocionesFiltro _filtro = PromocionesFiltro.activas;
  PromocionesFiltro get filtro => _filtro;

  // ── Lista SIEMPRE excluye finalizadas salvo que el usuario pida verlas
  // explícitamente en la pestaña "Finalizadas" (historial). ────────────
  List<PromocionEntity> get promocionesFiltradas {
    switch (_filtro) {
      case PromocionesFiltro.activas:
        return _promociones
            .where((p) => p.estado == PromocionEstado.vigente)
            .toList();
      case PromocionesFiltro.proximas:
        return _promociones
            .where((p) => p.estado == PromocionEstado.proxima)
            .toList();
      case PromocionesFiltro.finalizadas:
        return _promociones
            .where((p) => p.estado == PromocionEstado.finalizada)
            .toList();
    }
  }

  // ── Promociones vigentes, SIN depender del filtro que el usuario haya
  // elegido en la vista completa de Promociones (que comparte esta misma
  // instancia del provider). El Home siempre debe mostrar "activas". ─────
  List<PromocionEntity> get promocionesActivas =>
      _promociones.where((p) => p.estado == PromocionEstado.vigente).toList();

  void cambiarFiltro(PromocionesFiltro nuevoFiltro) {
    _filtro = nuevoFiltro;
    notifyListeners();
  }

  Future<bool> cargarPromociones({String? negocioId}) async {
    _status = PromocionesStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _getPromociones(negocioId: negocioId);

    return result.fold(
      (failure) {
        _status = PromocionesStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (items) {
        _promociones = items;
        _status = PromocionesStatus.success;
        notifyListeners();
        return true;
      },
    );
  }

  @override
  void dispose() {
    _expiracionTimer?.cancel();
    super.dispose();
  }
}
