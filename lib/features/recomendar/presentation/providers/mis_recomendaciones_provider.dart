import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/propuesta_destino.dart';
import '../../domain/usecases/eliminar_imagen_propuesta_usecase.dart';
import '../../domain/usecases/get_mis_propuestas_usecase.dart';

enum MisRecomendacionesStatus { idle, loading, success, error }

@injectable
class MisRecomendacionesProvider extends ChangeNotifier {
  final GetMisPropuestasUseCase _getMisPropuestas;
  final EliminarImagenPropuestaUseCase _eliminarImagen;

  MisRecomendacionesProvider(this._getMisPropuestas, this._eliminarImagen);

  MisRecomendacionesStatus _status = MisRecomendacionesStatus.idle;
  MisRecomendacionesStatus get status => _status;

  List<PropuestaDestino> _propuestas = const [];
  List<PropuestaDestino> get propuestas => _propuestas;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> cargar() async {
    _status = MisRecomendacionesStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final resultado = await _getMisPropuestas();

    resultado.fold(
      (failure) {
        _status = MisRecomendacionesStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (propuestas) {
        // Más recientes primero.
        _propuestas = [...propuestas]
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _status = MisRecomendacionesStatus.success;
        notifyListeners();
      },
    );
  }

  /// Elimina una foto de una propuesta todavía pendiente y actualiza la
  /// copia local sin necesidad de recargar toda la lista.
  Future<bool> eliminarImagen({
    required String proposalId,
    required String imageId,
  }) async {
    final resultado = await _eliminarImagen(
      proposalId: proposalId,
      imageId: imageId,
    );

    return resultado.fold((failure) => false, (_) {
      _propuestas = _propuestas.map((p) {
        if (p.id != proposalId) return p;
        return PropuestaDestino(
          id: p.id,
          userId: p.userId,
          name: p.name,
          description: p.description,
          categoryId: p.categoryId,
          categoryName: p.categoryName,
          locationId: p.locationId,
          location: p.location,
          status: p.status,
          rejectionReason: p.rejectionReason,
          reviewedBy: p.reviewedBy,
          reviewedAt: p.reviewedAt,
          createdDestinationId: p.createdDestinationId,
          createdAt: p.createdAt,
          updatedAt: p.updatedAt,
          images: p.images.where((img) => img.id != imageId).toList(),
        );
      }).toList();
      notifyListeners();
      return true;
    });
  }
}
