import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construc_assist/core/settings/theme_provider.dart';
import 'package:construc_assist/features/electrician/screens/menus/diagnostics/pantalla_diagnostico.dart';

class MenuDiagnosticos extends ConsumerWidget {
  const MenuDiagnosticos({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isObra = ref.watch(isObraModeProvider);

    return Scaffold(
      // 🌑 FONDO GENERAL NEGRO EN MODO OBRA
      backgroundColor: isObra ? Colors.black : Colors.grey.shade50,
      appBar: AppBar(
        // 🟡 HEADER AMARILLO EN MODO OBRA
        backgroundColor: isObra ? Colors.amber : Colors.blue.shade800,
        title: Text(
          'ASISTENTE DE FALLAS',
          style: TextStyle(
            color: isObra ? Colors.black : Colors.white, // Letra Negra en Obra
            fontWeight: isObra
                ? FontWeight.w900
                : FontWeight.bold, // Máximo grosor
            letterSpacing: isObra ? 1.2 : 0,
          ),
        ),
        iconTheme: IconThemeData(
          color: isObra ? Colors.black : Colors.white,
          size: isObra ? 30 : 24, // Flecha más grande y visible
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildDiagnosticoCard(
            context,
            isObra: isObra,
            titulo: 'SALTO DE TÉRMICA/DISYUNTOR',
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
            titulo: 'FUGA A TIERRA',
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
            titulo: 'CAÍDA DE TENSIÓN',
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // 🟡 FONDO: Amarillo en Obra, Blanco en Oficina
          color: isObra ? Colors.amber : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            // ⚫ BORDE: Negro grueso en Obra
            color: isObra ? Colors.black : Colors.blue.shade100,
            width: isObra ? 3 : 2,
          ),
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
            Icon(
              icono,
              // ⚫ ÍCONO: Negro en Obra
              color: isObra ? Colors.black : Colors.blue.shade700,
              size: 36,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      // ⚫ TÍTULO: Negro y w900 en Obra
                      color: isObra ? Colors.black : Colors.black87,
                      fontSize: 18,
                      fontWeight: isObra ? FontWeight.w900 : FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitulo,
                    style: TextStyle(
                      // ⚫ SUBTÍTULO: Negro fuerte en Obra
                      color: isObra ? Colors.black87 : Colors.grey.shade600,
                      fontSize: 13,
                      fontWeight: isObra ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              // ⚫ FLECHA: Negra en Obra
              color: isObra ? Colors.black : Colors.blue.shade300,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
