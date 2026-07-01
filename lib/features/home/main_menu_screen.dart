import 'package:construc_assist/features/electrician/screens/menus/menu_electricidad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construc_assist/core/settings/theme_provider.dart';

class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isObra = ref.watch(isObraModeProvider);

    return Scaffold(
      // 🌑 FONDO GENERAL NEGRO EN MODO OBRA
      backgroundColor: isObra ? Colors.black : Colors.grey.shade50,

      appBar: AppBar(
        // 🟡 HEADER AMARILLO EN MODO OBRA (Afecta título y fondo)
        backgroundColor: isObra ? Colors.amber : Colors.transparent,
        elevation: isObra ? 0 : 0,
        title: Text(
          'MENÚ PRINCIPAL',
          style: TextStyle(
            color: isObra ? Colors.black : Colors.black87, // ⚫ Título Negro
            fontWeight: isObra ? FontWeight.w900 : FontWeight.bold,
            letterSpacing: isObra ? 1.2 : 0,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            // ⚫ ENGRANAJE NEGRO EN MODO OBRA
            icon: Icon(
              Icons.settings,
              size: 28,
              color: isObra ? Colors.black : Colors.black87,
            ),
            tooltip: 'Configuración de Interfaz',
            onPressed: () {
              _showSettingsBottomSheet(context, ref, isObra);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // BÚSQUEDA POR VOZ (Adaptado para que combine bien en negro)
            ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(
                Icons.mic,
                size: 48,
                color: isObra
                    ? Colors.amber
                    : Theme.of(context).scaffoldBackgroundColor,
              ),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Text(
                  'BÚSQUEDA POR VOZ\n"Preguntale a Gemini"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: isObra ? FontWeight.bold : FontWeight.normal,
                    color: isObra
                        ? Colors.amber
                        : Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isObra
                    ? Colors.grey.shade900
                    : Theme.of(context).colorScheme.secondary,
                side: isObra
                    ? const BorderSide(color: Colors.amber, width: 2)
                    : BorderSide.none,
              ),
            ),

            const SizedBox(height: 40),

            // ⚪ TEXTO BÚSQUEDA MANUAL (Blanco resaltado en Obra)
            Text(
              'BÚSQUEDA MANUAL',
              style: TextStyle(
                fontSize: 22,
                fontWeight: isObra ? FontWeight.w900 : FontWeight.bold,
                color: isObra
                    ? Colors.white
                    : Theme.of(context).colorScheme.primary,
                letterSpacing: isObra ? 1.2 : 0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Lista de Gremios
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  // Le pasamos la variable isObra a cada botón
                  _buildGremioButton(
                    context,
                    '⚡',
                    'ELECTRICIDAD',
                    true,
                    isObra,
                  ),
                  _buildGremioButton(context, '🚰', 'PLOMERÍA', false, isObra),
                  _buildGremioButton(
                    context,
                    '🧱',
                    'ALBAÑILERÍA',
                    false,
                    isObra,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsBottomSheet(
    BuildContext context,
    WidgetRef ref,
    bool isObraNow,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Ajusta el tamaño al contenido
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Configuración de Aspecto',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Cambiá el modo visual según dónde estés trabajando:',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Opción Modo Obra
              ListTile(
                leading: const Text('👷', style: TextStyle(fontSize: 24)),
                title: const Text(
                  'Modo Obra',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Alto contraste para exteriores'),
                trailing: isObraNow
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: () {
                  ref.read(isObraModeProvider.notifier).setMode(true);
                  Navigator.pop(context); // Cierra el panel
                },
              ),
              const Divider(),

              // Opción Modo Oficina
              ListTile(
                leading: const Text('👔', style: TextStyle(fontSize: 24)),
                title: const Text(
                  'Modo Oficina',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Diseño elegante para interiores'),
                trailing: !isObraNow
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: () {
                  ref.read(isObraModeProvider.notifier).setMode(false);
                  Navigator.pop(context); // Cierra el panel
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // MOLDE "TANQUE DE GUERRA" PARA LOS BOTONES CUADRADOS
  Widget _buildGremioButton(
    BuildContext context,
    String emoji,
    String title,
    bool isActive,
    bool isObra,
  ) {
    return InkWell(
      onTap: isActive
          ? () {
              if (title == 'ELECTRICIDAD') {
                // Navegamos al nuevo Menú Intermedio de Electricidad
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MenuElectricidad(),
                  ),
                );
              } else {
                // Para los otros gremios que aún no están listos
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('El módulo $title estará disponible pronto.'),
                  ),
                );
              }
            }
          : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          // 🟡 EL AMARILLO EXACTO (Colors.amber) EN OBRA
          color: isObra
              ? (isActive ? Colors.amber : Colors.grey.shade900)
              : (isActive ? Colors.white : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            // ⚫ BORDE NEGRO GRUESO DE 3PX EN OBRA
            color: isObra
                ? (isActive ? Colors.black : Colors.grey.shade800)
                : (isActive ? Colors.blue.shade100 : Colors.transparent),
            width: isObra ? 3 : 2,
          ),
          boxShadow: isObra
              ? null
              : [
                  if (isActive)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: TextStyle(
                fontSize: 48,
                // Si está inactivo en modo obra, lo opacamos un poco
                color: isObra && !isActive ? Colors.white24 : null,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                // ⚫ TEXTO NEGRO Y W900 SI ES OBRA Y ESTA ACTIVO
                color: isObra
                    ? (isActive ? Colors.black : Colors.grey.shade500)
                    : (isActive ? Colors.black87 : Colors.grey),
                fontWeight: isObra && isActive
                    ? FontWeight.w900
                    : FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
