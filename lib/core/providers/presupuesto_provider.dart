import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/presupuesto_model.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert'; // <-- Necesario para decodificar el JSON de la IA
import 'package:construc_assist/ai/ai_service.dart'; // <-- Ajustá la ruta si tu carpeta ai está en otro lado

class PresupuestoNotifier extends StateNotifier<Presupuesto> {
  PresupuestoNotifier() : super(_presupuestoInicial());
  final _aiService = AiService();

  static Presupuesto _presupuestoInicial() {
    return Presupuesto(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fecha: DateTime.now(),
      cliente: 'Consumidor Final',
      items: [],
    );
  }

  // 2. AGREGAR ÍTEM: Recibe un material o mano de obra y lo suma a la lista
  void agregarItem(ItemPresupuesto nuevoItem) {
    state = Presupuesto(
      id: state.id,
      fecha: state.fecha,
      cliente: state.cliente,
      items: [...state.items, nuevoItem],
      imagenes: state.imagenes,
      porcentajeGananciaExtra: state.porcentajeGananciaExtra,
      descuentoManual: state.descuentoManual,
      resumenIA: state.resumenIA,
    );
  }

  // 3. ELIMINAR ÍTEM: Si el trabajador se arrepiente y quiere borrar un material
  void eliminarItem(String idItem) {
    state = Presupuesto(
      id: state.id,
      fecha: state.fecha,
      cliente: state.cliente,
      items: state.items
          .where((item) => item.id != idItem)
          .toList(), // Filtra y deja todos menos el borrado
      imagenes: state.imagenes,
      porcentajeGananciaExtra: state.porcentajeGananciaExtra,
      descuentoManual: state.descuentoManual,
      resumenIA: state.resumenIA,
    );
  }

  // 4. AJUSTAR GANANCIA: El control manual del usuario
  void actualizarGanancia(double nuevoPorcentaje) {
    state = Presupuesto(
      id: state.id,
      fecha: state.fecha,
      cliente: state.cliente,
      items: state.items,
      imagenes: state.imagenes,
      porcentajeGananciaExtra: nuevoPorcentaje, // Actualizamos solo este valor
      descuentoManual: state.descuentoManual,
      resumenIA: state.resumenIA,
    );
  }

  // 5. LA PUERTA A LA I.A.: Conectado a Gemini
  Future<void> procesarTrabajoConIA(String promptDelUsuario) async {
    debugPrint("Enviando a la IA: $promptDelUsuario");

    // Opcional: Acá podrías activar una variable de estado "isLoading = true" para mostrar una ruedita de carga en la pantalla

    try {
      // 1. Llamamos a Gemini
      final respuestaString = await _aiService.generarPresupuesto(
        promptDelUsuario,
      );

      // --- 🛡️ NUEVO ESCUDO DE SEGURIDAD ACÁ 🛡️ ---
      // Si la respuesta contiene un mensaje de error o el servidor está saturado, frenamos todo.
      if (respuestaString != null &&
          (respuestaString.contains('ERROR') ||
              respuestaString.contains('503') ||
              respuestaString.contains('Exception'))) {
        debugPrint(
          'Aviso: El servidor de la IA está saturado o hubo un error de conexión. Reintentá en unos segundos.',
        );
        return; // Este 'return' corta la función acá mismo para que no intente leer el JSON.
      }
      // ----------------------------------------------

      if (respuestaString != null && respuestaString.isNotEmpty) {
        // 2. Limpieza de seguridad: Quitamos las comillas invertidas (Markdown) si Gemini las envía
        final cleanJson = respuestaString
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();

        debugPrint("Respuesta limpia de Gemini: $cleanJson");

        // 3. Convertimos el texto puro a una lista de diccionarios
        final List<dynamic> datosDecodificados = jsonDecode(cleanJson);

        // 4. Transformamos cada diccionario en un ItemPresupuesto
        final nuevosItems = datosDecodificados.map((dato) {
          // La IA no nos da un 'id', así que le inyectamos uno único basado en la hora exacta
          dato['id'] = DateTime.now().microsecondsSinceEpoch.toString();

          return ItemPresupuesto.fromJson(dato as Map<String, dynamic>);
        }).toList();

        // 5. Metemos los nuevos ítems al presupuesto actual
        final presupuestoActualizado = state.items.toList()
          ..addAll(nuevosItems);

        state = Presupuesto(
          id: state.id,
          fecha: state.fecha,
          cliente: state.cliente,
          items: presupuestoActualizado, // Acá va la lista fusionada
          porcentajeGananciaExtra: state.porcentajeGananciaExtra,
          descuentoManual: state.descuentoManual,
          resumenIA: "Generado por Asistente IA",
        );

        debugPrint("¡Ítems agregados con éxito!");
      }
    } catch (e) {
      debugPrint("Error al procesar el JSON de la IA: $e");
    } finally {
      // Opcional: Acá apagarías la ruedita de carga "isLoading = false"
    }
  }
}

// 6. EL PUENTE: Esta variable es la que van a "escuchar" tus pantallas.
final presupuestoProvider =
    StateNotifierProvider<PresupuestoNotifier, Presupuesto>((ref) {
      return PresupuestoNotifier();
    });
