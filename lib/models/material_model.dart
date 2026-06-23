class MaterialModel {
  final String id;
  final String nombreEs;
  final String descripcionEs;
  final String categoriaId;
  final String unidadBase;
  final String imagenUrl;

  MaterialModel({
    required this.id,
    required this.nombreEs,
    required this.descripcionEs,
    required this.categoriaId,
    required this.unidadBase,
    required this.imagenUrl,
  });

  // Este es el "conversor" que transforma el mapa del JSON a un objeto Dart
  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['material_id'] ?? '',
      nombreEs: json['nombre']?['es'] ?? 'Sin nombre',
      descripcionEs: json['descripcion']?['es'] ?? '',
      categoriaId: json['categoria_id'] ?? '',
      unidadBase: json['unidad_base'] ?? '',
      imagenUrl: (json['imagenes'] != null && json['imagenes'].isNotEmpty)
          ? json['imagenes'][0]
          : '',
    );
  }
}
