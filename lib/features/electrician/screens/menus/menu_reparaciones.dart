import 'package:construc_assist/features/electrician/providers/repairs_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construc_assist/core/settings/theme_provider.dart';
import 'package:construc_assist/features/electrician/screens/repairs/guia_interactiva_screen.dart';

class MenuReparaciones extends ConsumerWidget {
  const MenuReparaciones({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isObra = ref.watch(isObraModeProvider);

    return Scaffold(
      backgroundColor: isObra
          ? Colors.black
          : Colors.grey.shade50, // <-- Camaleón
      appBar: AppBar(
        backgroundColor: isObra ? Colors.grey.shade900 : Colors.blue.shade800,
        title: Text(
          'Reparaciones',
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
          _buildReparacionCard(
            context,
            isObra: isObra,
            titulo: 'Cambio de Tomacorriente',
            subtitulo: 'Guía paso a paso segura',
            icono: Icons.outlet,
            onTap: () async {
              // 1. Cargamos el JSON a través del provider
              await ref
                  .read(repairsProvider.notifier)
                  .cargarGuia(
                    'assets/2_repairs/electrician/reemplazo_tomacorriente.json',
                  );

              // 2. Verificamos que el contexto siga vivo después del await (Buena práctica de Flutter)
              if (context.mounted) {
                // 3. Navegamos a la pantalla dinámica
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const GuiaInteractivaScreen(),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 16),
          _buildReparacionCard(
            context,
            isObra: isObra,
            titulo: 'Instalación de Ventilador',
            subtitulo: 'Conexión de techo y variador',
            icono: Icons.mode_fan_off,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Guía de Ventilador: Próximamente...'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Molde adaptado al Camaleón
  Widget _buildReparacionCard(
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
          color: isObra ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isObra ? Colors.grey.shade800 : Colors.blue.shade100,
          ),
          // Sombreado elegante sin errores (usando withValues)
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
              color: isObra ? Colors.amber : Colors.blue.shade700,
              size: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      color: isObra ? Colors.white : Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
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
