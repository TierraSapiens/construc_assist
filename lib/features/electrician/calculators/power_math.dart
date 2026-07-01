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

  // 3. Corriente a partir de Potencia
  static double calcularCorrienteDesdePotencia({
    required double potenciaWatts,
    required double voltaje,
    double factorPotencia = 0.85,
    bool isTrifasica = false,
  }) {
    if (voltaje == 0 || factorPotencia == 0) return 0;
    
    if (isTrifasica) {
      return potenciaWatts / (sqrt(3) * voltaje * factorPotencia);
    } else {
      return potenciaWatts / (voltaje * factorPotencia);
    }
  }

  // Potencia aparente y reactiva.
  // Potencia Aparente (S) en VA
  static double calcularPotenciaAparente(double potenciaActiva, double factorPotencia) {
    if (factorPotencia <= 0) return 0;
    return potenciaActiva / factorPotencia;
  }

  // Potencia Reactiva (Q) en VAr
  static double calcularPotenciaReactiva(double potenciaActiva, double potenciaAparente) {
    if (potenciaAparente < potenciaActiva) return 0;
    return sqrt(pow(potenciaAparente, 2) - pow(potenciaActiva, 2));
  }

  // Consumo Mensual (kWh)
  static double calcularConsumoKWh({
    required double potenciaWatts, 
    required double horasDiarias, 
    double diasMensuales = 30,
  }) {
    return (potenciaWatts / 1000) * horasDiarias * diasMensuales;
  }

  // Costo Monetario Estimado
  static double calcularCostoMensual(double consumoKWh, double precioPorKWh) {
    return consumoKWh * precioPorKWh;
  }
}