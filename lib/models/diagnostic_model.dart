// Helper para extraer texto ya sea un String directo o un Mapa de idiomas { "es": "...", "en": "..." }
String _extraerTextoEs(dynamic textoObj) {
  if (textoObj is String) return textoObj;
  if (textoObj is Map) return textoObj['es'] ?? 'Texto no disponible';
  return '';
}

class RespuestaModel {
  final String valor;
  final String texto;
  final String siguiente;

  RespuestaModel({
    required this.valor,
    required this.texto,
    required this.siguiente,
  });

  factory RespuestaModel.fromJson(Map<String, dynamic> json) {
    return RespuestaModel(
      valor: json['valor'] ?? '',
      texto: _extraerTextoEs(json['texto']),
      siguiente: json['siguiente'] ?? '',
    );
  }
}

class NodoModel {
  final String id;
  final String tipo; // seguridad, pregunta, prueba, causa
  final String textoEs;
  final List<RespuestaModel> respuestas;
  final List<String> solucionesIds;

  NodoModel({
    required this.id,
    required this.tipo,
    required this.textoEs,
    required this.respuestas,
    required this.solucionesIds,
  });

  factory NodoModel.fromJson(Map<String, dynamic> json) {
    var listaResp = json['respuestas'] as List? ?? [];
    var listaSol = json['soluciones'] as List? ?? [];

    return NodoModel(
      id: json['id'] ?? '',
      tipo: json['tipo'] ?? '',
      textoEs: _extraerTextoEs(json['texto']),
      respuestas: listaResp.map((r) => RespuestaModel.fromJson(r)).toList(),
      solucionesIds: listaSol.map((s) => s.toString()).toList(),
    );
  }
}

class SolucionModel {
  final String id;
  final String textoEs;
  final bool requiereProfesional;

  SolucionModel({
    required this.id,
    required this.textoEs,
    required this.requiereProfesional,
  });

  factory SolucionModel.fromJson(Map<String, dynamic> json) {
    return SolucionModel(
      id: json['id'] ?? '',
      textoEs: _extraerTextoEs(json['texto']),
      requiereProfesional: json['requiere_profesional'] ?? false,
    );
  }
}

class DiagnosticoCompletoModel {
  final String id;
  final String tituloEs;
  final String nodoInicio;
  final List<NodoModel> nodos;
  final List<SolucionModel> soluciones;

  DiagnosticoCompletoModel({
    required this.id,
    required this.tituloEs,
    required this.nodoInicio,
    required this.nodos,
    required this.soluciones,
  });

  factory DiagnosticoCompletoModel.fromJson(Map<String, dynamic> json) {
    var flujo = json['flujo_diagnostico'] ?? {};
    var listaNodos = flujo['nodos'] as List? ?? [];
    var listaSol = json['soluciones'] as List? ?? [];

    return DiagnosticoCompletoModel(
      id: json['diagnostic_id'] ?? '',
      tituloEs: _extraerTextoEs(json['averia']?['nombre']),
      nodoInicio: flujo['inicio'] ?? '',
      nodos: listaNodos.map((n) => NodoModel.fromJson(n)).toList(),
      soluciones: listaSol.map((s) => SolucionModel.fromJson(s)).toList(),
    );
  }
}
