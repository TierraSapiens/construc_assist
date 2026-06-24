import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <-- IMPORTANTE: Agregamos Riverpod
import 'package:construc_assist/core/settings/theme_provider.dart'; // <-- Importamos tu interruptor maestro
import 'package:construc_assist/screens/pantalla_diagnostico.dart';

// Cambiamos StatelessWidget por ConsumerWidget
class MenuDiagnosticos extends ConsumerWidget {
  const MenuDiagnosticos({super.key});

  @override
  // Agregamos el WidgetRef ref
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos en qué modo estamos
    final isObra = ref.watch(isObraModeProvider);

    return Scaffold(
      // EL CAMALEÓN EN ACCIÓN: Si es obra, negro. Si es oficina, blanco/gris muy claro.
      backgroundColor: isObra ? Colors.black : Colors.grey.shade50,

      appBar: AppBar(
        backgroundColor: isObra ? Colors.grey.shade900 : Colors.blue.shade800,
        title: Text(
          'Asistente de Fallas',
          style: TextStyle(
            color: isObra ? Colors.amber : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: isObra ? Colors.amber : Colors.white),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildDiagnosticoCard(
            context,
            isObra: isObra, // Le pasamos el dato al molde
            titulo: 'Salto de Térmica/Disyuntor',
            subtitulo: 'Fallas en protecciones del tablero',
            icono: Icons.warning_amber_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PantallaDiagnosticoBreaker(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildDiagnosticoCard(
            context,
            isObra: isObra,
            titulo: 'Fuga a Tierra',
            subtitulo: 'Problemas de aislación y descargas',
            icono: Icons.electric_bolt,
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Próximamente...')));
            },
          ),
          const SizedBox(height: 16),
          _buildDiagnosticoCard(
            context,
            isObra: isObra,
            titulo: 'Caída de Tensión',
            subtitulo: 'Luces que parpadean o baja potencia',
            icono: Icons.trending_down,
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Próximamente...')));
            },
          ),
        ],
      ),
    );
  }

  // Molde adaptado para recibir el "isObra"
  Widget _buildDiagnosticoCard(
    BuildContext context, {
    required bool isObra,
    required String titulo,
    required String subtitulo,
    required IconData icono,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Fondo de la tarjeta
          color: isObra ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          // Borde de la tarjeta
          border: Border.all(
            color: isObra ? Colors.grey.shade800 : Colors.blue.shade100,
            width: 1.5,
          ),
          // Sombreado suave solo para el modo oficina
          boxShadow: isObra
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Icono
            Icon(
              icono,
              color: isObra ? Colors.amber : Colors.blue.shade700,
              size: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    titulo,
                    style: TextStyle(
                      color: isObra ? Colors.white : Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Subtítulo
                  Text(
                    subtitulo,
                    style: TextStyle(
                      color: isObra
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isObra ? Colors.grey : Colors.blue.shade300,
            ),
          ],
        ),
      ),
    );
  }
}
