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
      backgroundColor: isObra ? Colors.black : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: isObra ? Colors.amber : Colors.blue.shade800,
        title: Text(
          'REPARACIONES',
          style: TextStyle(
            color: isObra ? Colors.black : Colors.white, // Letra Negra en Obra
            fontWeight: isObra
                ? FontWeight.w900
                : FontWeight.bold, // Máximo grosor en Obra
            letterSpacing: isObra ? 1.2 : 0, // Espaciado extra para legibilidad
          ),
        ),
        iconTheme: IconThemeData(
          color: isObra ? Colors.black : Colors.white,
          size: isObra ? 30 : 24, // Ícono de volver un poco más grande
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildReparacionCard(
            context,
            isObra: isObra,
            titulo: 'CAMBIO DE TOMACORRIENTE',
            subtitulo: 'Guía paso a paso segura',
            icono: Icons.outlet,
            onTap: () async {
              await ref
                  .read(repairsProvider.notifier)
                  .cargarGuia(
                    'assets/2_repairs/electrician/reemplazo_tomacorriente.json',
                  );

              if (context.mounted) {
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
            titulo: 'INSTALACIÓN DE VENTILADOR',
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // 🟡 FONDO: Amarillo en Obra, Blanco en Oficina
          color: isObra ? Colors.amber : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            // ⚫ BORDE: Negro grueso en Obra, Azulito en Oficina
            color: isObra ? Colors.black : Colors.blue.shade100,
            width: isObra ? 3 : 2,
          ),
          // Sombra solo en Modo Oficina
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
                      fontSize: 14,
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
