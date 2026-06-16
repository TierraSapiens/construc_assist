import 'package:flutter/material.dart';

class AppThemes {
  // [MODO OBRA] - Alto contraste: Fondo negro, acentos amarillos, letras grandes.
  static final ThemeData obraTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    primaryColor: Colors.amberAccent,
    colorScheme: const ColorScheme.dark(
      primary: Colors.amberAccent,
      secondary: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amberAccent,
        foregroundColor: Colors.black,
        textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        padding: const EdgeInsets.symmetric(vertical: 30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  // [MODO OFICINA] - Elegante: Fondo claro, colores sobrios, letras moderadas.
  static final ThemeData oficinaTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Un gris muy clarito
    primaryColor: Colors.blueGrey,
    colorScheme: const ColorScheme.light(
      primary: Colors.blueGrey,
      secondary: Colors.blueAccent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}