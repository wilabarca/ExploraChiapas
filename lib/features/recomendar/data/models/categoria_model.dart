import '../../domain/entities/categoria.dart';

class CategoriaModel extends Categoria {
  const CategoriaModel({
    required super.id,
    required super.nombre,
    super.icono,
  });

  factory CategoriaModel.fromJson(Map<String, dynamic> json) {
    return CategoriaModel(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? json['name']?.toString() ?? '',
      icono: json['icono']?.toString() ?? json['icon']?.toString(),
    );
  }
}
