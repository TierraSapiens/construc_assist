import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/material_model.dart';
import '../models/diagnostic_model.dart'; // <-- Agregamos el import de tu nuevo molde

class DataService {
  Future<List<MaterialModel>> obtenerMaterialesElectricista() async {
    try {
      final String respuesta = await rootBundle.loadString(
        'assets/3_reference_data/electrician/materials.json',
      );

      final List<dynamic> datosDecodificados = json.decode(respuesta);

      return datosDecodificados
          .map((item) => MaterialModel.fromJson(item))
          .toList();
    } catch (e) {
      debugPrint("Error cargando materiales: $e");
      return [];
    }
  }

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
