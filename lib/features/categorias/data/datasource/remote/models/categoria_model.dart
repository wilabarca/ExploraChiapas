import '../../../../domain/entities/categoria.dart';

class CategoriaModel extends Categoria {
  const CategoriaModel({
    required super.id,
    required super.nombre,
    required super.icono,
    required super.aplicaAEventos,
    required super.aplicaADestinos,
  });

  factory CategoriaModel.fromJson(Map<String, dynamic> json) {
    return CategoriaModel(
      id: json['id'].toString(),
      nombre: json['nombre'].toString(),
      icono: json['icono']?.toString() ?? '',
      aplicaAEventos: json['aplicaAEventos'] == true,
      aplicaADestinos: json['aplicaADestinos'] == true,
    );
  }
}
