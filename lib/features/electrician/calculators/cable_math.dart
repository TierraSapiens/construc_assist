import 'dart:math';

class CableMath {
  // Constantes de resistividad (Ohm * mm² / m) a 20°C aprox.
  static const double rhoCobre = 0.0172;
  static const double rhoAluminio = 0.0282;
  // Secciones comerciales estándar en mm²
  static const List<double> seccionesComerciales = [
    1.5,
    2.5,
    4.0,
    6.0,
    10.0,
    16.0,
    25.0,
    35.0,
    50.0,
    70.0,
    95.0,
    120.0,
  ];
  // 1. Calcular Sección Requerida (mm²)
  static double calcularSeccion({
    required double corriente,
    required double longitud,
    required double voltaje,
    required double caidaPermitidaPorcentaje,
    bool esCobre = true,
    bool esTrifasica = false,
  }) {
    if (voltaje == 0 || caidaPermitidaPorcentaje == 0) return 0.0;

    double rho = esCobre ? rhoCobre : rhoAluminio;
    double caidaVolts = (caidaPermitidaPorcentaje / 100) * voltaje;

    if (esTrifasica) {
      return (sqrt(3) * rho * longitud * corriente) / caidaVolts;
    } else {
      return (2 * rho * longitud * corriente) / caidaVolts;
    }
  }

  // Encontrar la sección comercial superior más cercana
  static double obtenerSeccionComercial(double seccionCalculada) {
    if (seccionCalculada <= 0) return 0.0;
    for (double s in seccionesComerciales) {
      if (s >= seccionCalculada) return s;
    }
    return seccionCalculada;
  }

  // 2. Calcular Caída de Tensión (Volts y Porcentaje)
  static Map<String, double> calcularCaidaTension({
    required double seccion,
    required double corriente,
    required double longitud,
    required double voltaje,
    bool esCobre = true,
    bool esTrifasica = false,
  }) {
    if (seccion == 0 || voltaje == 0) return {'volts': 0.0, 'porcentaje': 0.0};

    double rho = esCobre ? rhoCobre : rhoAluminio;
    double caidaVolts;

    if (esTrifasica) {
      caidaVolts = (sqrt(3) * rho * longitud * corriente) / seccion;
    } else {
      caidaVolts = (2 * rho * longitud * corriente) / seccion;
    }

    return {'volts': caidaVolts, 'porcentaje': (caidaVolts / voltaje) * 100};
  }
}
