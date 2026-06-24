import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/material_model.dart';
import '../models/diagnostic_model.dart'; // <-- Agregamos el import de tu nuevo molde

class DataService {
  // Función asíncrona para leer los materiales (La que ya tenías)
  Future<List<MaterialModel>> obtenerMaterialesElectricista() async {
    try {
      // 1. Lee el archivo físico como una cadena de texto
      final String respuesta = await rootBundle.loadString(
        'assets/3_reference_data/electrician/materials.json',
      );

      // 2. Convierte ese texto en una lista dinámica de JSON
      final List<dynamic> datosDecodificados = json.decode(respuesta);

      // 3. Pasa cada elemento por el molde (Model) y devuelve la lista limpia
      return datosDecodificados
          .map((item) => MaterialModel.fromJson(item))
          .toList();
    } catch (e) {
      debugPrint("Error cargando materiales: $e");
      return [];
    }
  }

  // ¡NUEVA FUNCIÓN! Para leer el árbol de diagnóstico interactivo
  Future<DiagnosticoCompletoModel?> obtenerDiagnosticoBreaker() async {
    try {
      final String respuesta = await rootBundle.loadString(
        'assets/diagnostics/electrician/protecciones/breaker_trip.json',
      );

      final Map<String, dynamic> datosDecodificados = json.decode(respuesta);
      return DiagnosticoCompletoModel.fromJson(datosDecodificados);
    } catch (e) {
      debugPrint("Error cargando diagnóstico: $e");
      return null;
    }
  }
}
