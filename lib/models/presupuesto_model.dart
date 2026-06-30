enum TipoItem { material, manoDeObra, traslado }

class ItemPresupuesto {
  final String id;
  final String nombre; // Ej: "Tomacorriente doble 10A"
  final double cantidad; // Ej: 3
  final String unidad; // Ej: "u", "m", "hs"
  final double precioUnitario; // Tu APU
  final TipoItem tipo;
  final String? descripcion; // Nota aclaratoria de la IA

  ItemPresupuesto({
    required this.id,
    required this.nombre,
    required this.cantidad,
    required this.unidad,
    required this.precioUnitario,
    required this.tipo,
    this.descripcion,
  });

  // Cálculo automático por línea
  double get total => cantidad * precioUnitario;

  factory ItemPresupuesto.fromJson(Map<String, dynamic> json) {
    return ItemPresupuesto(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      cantidad: (json['cantidad'] as num).toDouble(),
      unidad: json['unidad'] ?? 'u',
      precioUnitario: (json['precioUnitario'] as num).toDouble(),
      tipo: TipoItem.values.firstWhere(
        (e) => e.name == json['tipo'],
        orElse: () => TipoItem.material,
      ),
      descripcion: json['descripcion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'cantidad': cantidad,
      'unidad': unidad,
      'precioUnitario': precioUnitario,
      'tipo': tipo.name,
      'descripcion': descripcion,
    };
  }
}

class Presupuesto {
  final String id;
  final DateTime fecha;
  final String cliente;
  final List<ItemPresupuesto> items;
  final List<String> imagenes;
  final double manoDeObra; // 🛠️ CAMBIO: Ahora es un monto fijo en pesos
  final double descuentoManual;
  final String? resumenIA; // Este será el texto editable de la prosa

  Presupuesto({
    required this.id,
    required this.fecha,
    required this.cliente,
    required this.items,
    this.imagenes = const [],
    this.manoDeObra = 0.0,
    this.descuentoManual = 0.0,
    this.resumenIA,
  });

  // MATEMÁTICA INTERNA CORREGIDA
  double get subtotal => items.fold(0, (suma, item) => suma + item.total);
  double get totalFinal => (subtotal + manoDeObra) - descuentoManual;

  factory Presupuesto.fromJson(Map<String, dynamic> json) {
    return Presupuesto(
      id: json['id'] ?? '',
      fecha: DateTime.parse(json['fecha'] ?? DateTime.now().toIso8601String()),
      cliente: json['cliente'] ?? '',
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (item) =>
                    ItemPresupuesto.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      imagenes: List<String>.from(json['imagenes'] ?? []),
      manoDeObra: (json['manoDeObra'] as num?)?.toDouble() ?? 0.0,
      descuentoManual: (json['descuentoManual'] as num?)?.toDouble() ?? 0.0,
      resumenIA: json['resumenIA'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha': fecha.toIso8601String(),
      'cliente': cliente,
      'items': items.map((item) => item.toJson()).toList(),
      'imagenes': imagenes,
      'manoDeObra': manoDeObra,
      'descuentoManual': descuentoManual,
      'resumenIA': resumenIA,
    };
  }
}
