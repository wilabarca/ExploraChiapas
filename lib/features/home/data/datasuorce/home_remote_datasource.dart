import 'package:injectable/injectable.dart';
import '../../domain/entities/destino_entity.dart';

abstract class IHomeRemoteDatasource {
  Future<List<DestinoEntity>> getDestinos({String? tipo});
}

@Injectable(as: IHomeRemoteDatasource)
class HomeRemoteDatasourceImpl implements IHomeRemoteDatasource {
  // Mock hasta conectar el backend real
  @override
  Future<List<DestinoEntity>> getDestinos({String? tipo}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const [
      DestinoEntity(
        id: '1',
        nombre: 'Cascadas de Agua Azul',
        categoria: 'naturaleza',
        calificacion: 4.9,
        imageUrl:
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80',
        lat: 17.2524,
        lng: -92.1131,
      ),
      DestinoEntity(
        id: '2',
        nombre: 'Zona Arqueológica Palenque',
        categoria: 'cultura',
        calificacion: 4.8,
        imageUrl:
            'https://images.unsplash.com/photo-1518638150340-f706e86654de?w=800&q=80',
        lat: 17.4838,
        lng: -92.0435,
      ),
      DestinoEntity(
        id: '3',
        nombre: 'Cañón del Sumidero',
        categoria: 'naturaleza',
        calificacion: 4.7,
        imageUrl:
            'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800&q=80',
        lat: 16.8560,
        lng: -93.0760,
      ),
    ];
  }
}