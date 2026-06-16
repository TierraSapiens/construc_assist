import 'dart:math';

class PowerMath {
  // 1. Potencia Monofásica: P = V * I * FP
  static double calcularPotenciaMonofasica({
    required double voltaje,
    required double corriente,
    double factorPotencia = 0.85,
  }) {
    return voltaje * corriente * factorPotencia;
  }

  // 2. Potencia Trifásica: P = √3 * V * I * FP
  static double calcularPotenciaTrifasica({
    required double voltaje,
    required double corriente,
    double factorPotencia = 0.85,
  }) {
    return sqrt(3) * voltaje * corriente * factorPotencia;
  }

  // 3. Corriente a partir de Potencia (Soporta Mono y Tri)
  static double calcularCorrienteDesdePotencia({
    required double potenciaWatts,
    required double voltaje,
    double factorPotencia = 0.85,
    bool isTrifasica = false,
  }) {
    if (voltaje == 0 || factorPotencia == 0) return 0;
    
    if (isTrifasica) {
      // I = P / (√3 * V * FP)
      return potenciaWatts / (sqrt(3) * voltaje * factorPotencia);
    } else {
      // I = P / (V * FP)
      return potenciaWatts / (voltaje * factorPotencia);
    }
  }
}