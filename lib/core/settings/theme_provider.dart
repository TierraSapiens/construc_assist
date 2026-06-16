import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:construc_assist/core/settings/app_themes.dart';

// 1. Proveedor que contendrá la memoria del teléfono
final sharedPrefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

// 2. Notificador que controla el tema y lo guarda
class ThemeNotifier extends Notifier<bool> {
  @override
  bool build() {
    // Leemos si hay algo guardado al arrancar. Por defecto arranca en true (Obra)
    final prefs = ref.watch(sharedPrefsProvider);
    return prefs.getBool('isObraMode') ?? true;
  }

  void setMode(bool isObra) {
    state = isObra; // Actualizamos la pantalla instantáneamente
    ref.read(sharedPrefsProvider).setBool('isObraMode', isObra); // Lo guardamos en el disco
  }
}

final isObraModeProvider = NotifierProvider<ThemeNotifier, bool>(() => ThemeNotifier());

// 3. Proveedor que devuelve el Tema correspondiente para pintar la app
final themeProvider = Provider<ThemeData>((ref) {
  final isObra = ref.watch(isObraModeProvider);
  return isObra ? AppThemes.obraTheme : AppThemes.oficinaTheme;
});