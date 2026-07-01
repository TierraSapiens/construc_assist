import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construc_assist/models/repairs_model.dart';

// Estado del flujo de reparación y su navegación entre tarjetas.
class RepairsState {
  final bool isLoading;
  final ReparacionCompletaModel? reparacion;
  final String? currentTarjetaId;
  final List<String> historial; // Para permitir el botón "Volver Atrás"

  RepairsState({
    this.isLoading = true,
    this.reparacion,
    this.currentTarjetaId,
    this.historial = const [],
  });

  RepairsState copyWith({
    bool? isLoading,
    ReparacionCompletaModel? reparacion,
    String? currentTarjetaId,
    List<String>? historial,
  }) {
    return RepairsState(
      isLoading: isLoading ?? this.isLoading,
      reparacion: reparacion ?? this.reparacion,
      currentTarjetaId: currentTarjetaId ?? this.currentTarjetaId,
      historial: historial ?? this.historial,
    );
  }

  // Helper para obtener la tarjeta en la que está parado el usuario actualmente
  TarjetaReparacionModel? get tarjetaActual {
    if (reparacion == null || currentTarjetaId == null) return null;
    return reparacion!.tarjetas[currentTarjetaId];
  }
}

class RepairsNotifier extends StateNotifier<RepairsState> {
  RepairsNotifier() : super(RepairsState());

  // Carga dinámicamente cualquier JSON de reparación desde los assets
  Future<void> cargarGuia(String assetPath) async {
    state = RepairsState(isLoading: true);
    try {
      // Leemos el archivo local offline
      final String response = await rootBundle.loadString(assetPath);
      final data = json.decode(response);

      final guia = ReparacionCompletaModel.fromJson(data);

      // Posicionamos al usuario en la tarjeta inicial configurada en el JSON
      state = RepairsState(
        isLoading: false,
        reparacion: guia,
        currentTarjetaId: guia.tarjetaInicial,
        historial: [],
      );
    } catch (e) {
      // Manejo de error si el JSON está mal formateado o no existe
      state = RepairsState(isLoading: false);
      if (kDebugMode) {
        print("Error cargando la guía de reparación: $e");
      }
    }
  }

  // Avanza hacia la siguiente tarjeta según la decisión tomada
  void avanzar(String siguienteTarjetaId) {
    if (state.currentTarjetaId == null) return;

    // Guardamos la tarjeta actual en el historial antes de saltar a la nueva
    final nuevoHistorial = List<String>.from(state.historial)
      ..add(state.currentTarjetaId!);

    state = state.copyWith(
      currentTarjetaId: siguienteTarjetaId,
      historial: nuevoHistorial,
    );
  }

  // Retrocede al paso anterior recuperándolo del historial
  void retroceder() {
    if (state.historial.isEmpty) return;

    final nuevoHistorial = List<String>.from(state.historial);
    // Removemos el último elemento visitado y lo seteamos como actual
    final tarjetaAnteriorId = nuevoHistorial.removeLast();

    state = state.copyWith(
      currentTarjetaId: tarjetaAnteriorId,
      historial: nuevoHistorial,
    );
  }
}

final repairsProvider = StateNotifierProvider<RepairsNotifier, RepairsState>((
  ref,
) {
  return RepairsNotifier();
});
