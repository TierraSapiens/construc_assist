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
      appBar: AppBar(
        title: const Text('Menú Principal'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, size: 28),
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
            ElevatedButton.icon(
              onPressed: () {
              },
              icon: const Icon(Icons.mic, size: 48),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Text(
                  'BÚSQUEDA POR VOZ\n"Preguntale a Gemini"',
                  textAlign: TextAlign.center,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),

            const SizedBox(height: 40),

            Text(
              'Búsqueda Manual',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
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
                  _buildGremioButton(context, '⚡', 'Electricidad', true),
                  _buildGremioButton(context, '🚰', 'Plomería', false),
                  _buildGremioButton(context, '🧱', 'Albañilería', false),
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

  Widget _buildGremioButton(
    BuildContext context,
    String emoji,
    String title,
    bool isActive,
  ) {
    return ElevatedButton(
      onPressed: isActive
          ? () {
              if (title == 'Electricidad') {
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
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
