class TarjetaReparacionModel {
  final String id;
  final String
  tipo; // checklist, pregunta, advertencia, instruccion, medicion, fin, etc.
  final String titulo;
  final String mensaje;
  final List<String>? items;
  final String? riesgo;
  final String? tipoInteraccion;
  final Map<String, String>?
  opciones; // Saltos condicionales: {'si': 'id_siguiente', 'no': 'id_otro'}
  final List<Map<String, dynamic>>? multimedia;
  final Map<String, String>?
  notasPais; // Para las advertencias específicas por país (AR, CL, MX, etc.)

  TarjetaReparacionModel({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    this.items,
    this.riesgo,
    this.tipoInteraccion,
    this.opciones,
    this.multimedia,
    this.notasPais,
  });

  factory TarjetaReparacionModel.fromJson(Map<String, dynamic> json) {
    return TarjetaReparacionModel(
      id: json['id'] ?? '',
      tipo: json['tipo'] ?? '',
      titulo: json['titulo'] ?? '',
      mensaje: json['mensaje'] ?? '',
      items: json['items'] != null ? List<String>.from(json['items']) : null,
      riesgo: json['riesgo'],
      tipoInteraccion: json['tipo_interaccion'],
      opciones: json['opciones'] != null
          ? Map<String, String>.from(json['opciones'])
          : null,
      multimedia: json['multimedia'] != null
          ? List<Map<String, dynamic>>.from(json['multimedia'])
          : null,
      notasPais: json['notas_pais'] != null
          ? Map<String, String>.from(json['notas_pais'])
          : null,
    );
  }
}

class ReparacionCompletaModel {
  final String idTarea;
  final String gremio;
  final String categoria;
  final List<String> tags;
  final List<String> nivelUsuario;
  final int duracionEstimadaMin;
  final String tarjetaInicial;
  final Map<String, TarjetaReparacionModel> tarjetas;

  ReparacionCompletaModel({
    required this.idTarea,
    required this.gremio,
    required this.categoria,
    required this.tags,
    required this.nivelUsuario,
    required this.duracionEstimadaMin,
    required this.tarjetaInicial,
    required this.tarjetas,
  });

  factory ReparacionCompletaModel.fromJson(Map<String, dynamic> json) {
    var tarjetasMap = json['tarjetas'] as Map<String, dynamic>? ?? {};
    Map<String, TarjetaReparacionModel> parsedTarjetas = tarjetasMap.map(
      (key, value) => MapEntry(key, TarjetaReparacionModel.fromJson(value)),
    );

    return ReparacionCompletaModel(
      idTarea: json['id_tarea'] ?? '',
      gremio: json['gremio'] ?? '',
      categoria: json['categoria'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      nivelUsuario: List<String>.from(json['nivel_usuario'] ?? []),
      duracionEstimadaMin: json['duracion_estimada_min'] ?? 0,
      tarjetaInicial: json['tarjeta_inicial'] ?? '',
      tarjetas: parsedTarjetas,
    );
  }
}
