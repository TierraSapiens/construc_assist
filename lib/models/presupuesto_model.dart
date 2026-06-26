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

  // TRADUCTOR: Recibe el JSON de Gemini y lo transforma en código de Flutter
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

  // TRADUCTOR: Pasa el objeto a JSON por si queremos guardarlo o enviarlo
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
  final List<String> imagenes; // Rutas de las fotos capturadas
  final double porcentajeGananciaExtra; // Ajuste manual de ganancia
  final double descuentoManual; // Ajuste manual para redondear precios
  final String? resumenIA; // Texto explicativo de Gemini

  Presupuesto({
    required this.id,
    required this.fecha,
    required this.cliente,
    required this.items,
    this.imagenes = const [],
    this.porcentajeGananciaExtra = 0.0,
    this.descuentoManual = 0.0,
    this.resumenIA,
  });

  // MATEMÁTICA INTERNA AUTOMÁTICA
  double get subtotal => items.fold(0, (suma, item) => suma + item.total);
  double get montoGanancia => subtotal * (porcentajeGananciaExtra / 100);
  double get totalFinal => (subtotal + montoGanancia) - descuentoManual;

  // TRADUCTOR GLOBAL: Pasa un presupuesto entero de JSON a Dart
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
      porcentajeGananciaExtra:
          (json['porcentajeGananciaExtra'] as num?)?.toDouble() ?? 0.0,
      descuentoManual: (json['descuentoManual'] as num?)?.toDouble() ?? 0.0,
      resumenIA: json['resumenIA'],
    );
  }

  // TRADUCTOR GLOBAL: Convierte todo el presupuesto listo para guardar en el celu
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha': fecha.toIso8601String(),
      'cliente': cliente,
      'items': items.map((item) => item.toJson()).toList(),
      'imagenes': imagenes,
      'porcentajeGananciaExtra': porcentajeGananciaExtra,
      'descuentoManual': descuentoManual,
      'resumenIA': resumenIA,
    };
  }
}
