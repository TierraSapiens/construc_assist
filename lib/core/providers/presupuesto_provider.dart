import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/presupuesto_model.dart';
import 'package:flutter/foundation.dart'; // <-- Esto trae el debugPrint

class PresupuestoNotifier extends StateNotifier<Presupuesto> {
  // 1. EL ARRANQUE: Cuando la app abre esta pantalla, arranca con un presupuesto vacío.
  PresupuestoNotifier() : super(_presupuestoInicial());

  static Presupuesto _presupuestoInicial() {
    return Presupuesto(
      id: DateTime.now().millisecondsSinceEpoch
          .toString(), // Un ID único basado en la hora
      fecha: DateTime.now(),
      cliente: 'Consumidor Final', // Nombre por defecto
      items: [], // Lista vacía, lista para llenarse
    );
  }

  // 2. AGREGAR ÍTEM: Recibe un material o mano de obra y lo suma a la lista
  void agregarItem(ItemPresupuesto nuevoItem) {
    // En Riverpod no podemos "mutar" el estado directo, creamos una copia exacta con el nuevo ítem
    state = Presupuesto(
      id: state.id,
      fecha: state.fecha,
      cliente: state.cliente,
      items: [
        ...state.items,
        nuevoItem,
      ], // Los 3 puntos copian lo que ya había y le sumamos lo nuevo
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

  Future<void> procesarTrabajoConIA(String promptDelUsuario) async {
    // Usamos debugPrint en lugar de print
    debugPrint("Enviando a la IA: $promptDelUsuario");
  }
}

// 6. EL PUENTE: Esta variable es la que van a "escuchar" tus pantallas.
final presupuestoProvider =
    StateNotifierProvider<PresupuestoNotifier, Presupuesto>((ref) {
      return PresupuestoNotifier();
    });
