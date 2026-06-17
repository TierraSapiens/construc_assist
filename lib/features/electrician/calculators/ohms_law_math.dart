import 'dart:math';

class OhmsLawMath {
  /// Recibe los 4 parámetros (2 con valor, 2 nulos).
  /// Retorna un mapa con los 4 valores resueltos, o un mensaje de error.
  static Map<String, dynamic> calcularValores({
    double? v,
    double? i,
    double? r,
    double? p,
  }) {
    // Contamos cuántos valores ingresó el usuario
    int knowns = [v, i, r, p].where((e) => e != null).length;

    if (knowns != 2) {
      return {'error': 'Por favor, ingresá exactamente 2 valores para calcular el resto.'};
    }

    double outV = v ?? 0.0;
    double outI = i ?? 0.0;
    double outR = r ?? 0.0;
    double outP = p ?? 0.0;

    // 1. Conocemos Voltaje (V) y Corriente (I)
    if (v != null && i != null) {
      outR = i != 0 ? v / i : 0.0;
      outP = v * i;
    } 
    // 2. Conocemos Voltaje (V) y Resistencia (R)
    else if (v != null && r != null) {
      outI = r != 0 ? v / r : 0.0;
      outP = r != 0 ? (v * v) / r : 0.0;
    } 
    // 3. Conocemos Voltaje (V) y Potencia (P)
    else if (v != null && p != null) {
      outI = v != 0 ? p / v : 0.0;
      outR = p != 0 ? (v * v) / p : 0.0;
    } 
    // 4. Conocemos Corriente (I) y Resistencia (R)
    else if (i != null && r != null) {
      outV = i * r;
      outP = (i * i) * r;
    } 
    // 5. Conocemos Corriente (I) y Potencia (P)
    else if (i != null && p != null) {
      outV = i != 0 ? p / i : 0.0;
      outR = i != 0 ? p / (i * i) : 0.0;
    } 
    // 6. Conocemos Resistencia (R) y Potencia (P)
    else if (r != null && p != null) {
      outV = sqrt(p * r);
      outI = r != 0 ? sqrt(p / r) : 0.0;
    }

    return {
      'v': outV,
      'i': outI,
      'r': outR,
      'p': outP,
    };
  }
}