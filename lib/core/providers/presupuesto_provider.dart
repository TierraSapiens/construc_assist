import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/presupuesto_model.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:construc_assist/ai/ai_service.dart';

class PresupuestoNotifier extends StateNotifier<Presupuesto> {
  PresupuestoNotifier() : super(_presupuestoInicial());
  final _aiService = AiService();

  static Presupuesto _presupuestoInicial() {
    return Presupuesto(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fecha: DateTime.now(),
      cliente: 'Consumidor Final',
      items: [],
      resumenIA:
          'Ejecución de trabajos según lo presupuestado. Este importe incluye la provisión completa de materiales, insumos y la mano de obra especializada necesaria para la finalización de las tareas solicitadas.',
    );
  }

  void agregarItem(ItemPresupuesto nuevoItem) {
    state = Presupuesto(
      id: state.id,
      fecha: state.fecha,
      cliente: state.cliente,
      items: [...state.items, nuevoItem],
      imagenes: state.imagenes,
      manoDeObra: state.manoDeObra,
      descuentoManual: state.descuentoManual,
      resumenIA: state.resumenIA,
    );
  }

  void eliminarItem(String idItem) {
    state = Presupuesto(
      id: state.id,
      fecha: state.fecha,
      cliente: state.cliente,
      items: state.items.where((item) => item.id != idItem).toList(),
      imagenes: state.imagenes,
      manoDeObra: state.manoDeObra,
      descuentoManual: state.descuentoManual,
      resumenIA: state.resumenIA,
    );
  }

  // 🛠️ NUEVO: Modificar el valor de mano de obra manualmente
  void actualizarManoDeObra(double nuevoMonto) {
    state = Presupuesto(
      id: state.id,
      fecha: state.fecha,
      cliente: state.cliente,
      items: state.items,
      imagenes: state.imagenes,
      manoDeObra: nuevoMonto,
      descuentoManual: state.descuentoManual,
      resumenIA: state.resumenIA,
    );
  }

  // 📝 NUEVO: Guarda el texto dinámico a medida que el usuario escribe su prosa
  void actualizarResumen(String nuevoTexto) {
    state = Presupuesto(
      id: state.id,
      fecha: state.fecha,
      cliente: state.cliente,
      items: state.items,
      imagenes: state.imagenes,
      manoDeObra: state.manoDeObra,
      descuentoManual: state.descuentoManual,
      resumenIA: nuevoTexto,
    );
  }

  Future<void> procesarTrabajoConIA(String promptDelUsuario) async {
    debugPrint("Enviando a la IA: $promptDelUsuario");
    try {
      final respuestaString = await _aiService.generarPresupuesto(
        promptDelUsuario,
      );

      if (respuestaString != null &&
          (respuestaString.contains('ERROR') ||
              respuestaString.contains('503') ||
              respuestaString.contains('Exception'))) {
        return;
      }

      if (respuestaString != null && respuestaString.isNotEmpty) {
        final cleanJson = respuestaString
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();

        final List<dynamic> datosDecodificados = jsonDecode(cleanJson);

        final nuevosItems = datosDecodificados.map((dato) {
          dato['id'] = DateTime.now().microsecondsSinceEpoch.toString();
          return ItemPresupuesto.fromJson(dato as Map<String, dynamic>);
        }).toList();

        final presupuestoActualizado = state.items.toList()
          ..addAll(nuevosItems);

        state = Presupuesto(
          id: state.id,
          fecha: state.fecha,
          cliente: state.cliente,
          items: presupuestoActualizado,
          manoDeObra: state.manoDeObra,
          descuentoManual: state.descuentoManual,
          resumenIA: state.resumenIA, // Mantiene la prosa que ya tenías
        );
      }
    } catch (e) {
      debugPrint("Error al procesar el JSON de la IA: $e");
    }
  }
}

final presupuestoProvider =
    StateNotifierProvider<PresupuestoNotifier, Presupuesto>((ref) {
      return PresupuestoNotifier();
    });
