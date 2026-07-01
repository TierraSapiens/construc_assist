import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <-- Agregado
import 'package:construc_assist/core/settings/theme_provider.dart'; // <-- Agregado
import 'package:construc_assist/features/electrician/screens/menus/electrician_home_screen.dart';
import 'package:construc_assist/features/electrician/screens/menus/menu_diagnosticos.dart';
import 'package:construc_assist/features/electrician/screens/menus/menu_reparaciones.dart';
import 'package:construc_assist/features/presupuestos/screens/presupuesto_screen.dart';

class MenuElectricidad extends ConsumerWidget {
  const MenuElectricidad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isObra = ref.watch(isObraModeProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.amber, // Fondo amarillo del header
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.black,
          size: 30,
        ), // Flecha de volver en negro y grande
        title: const Text(
          'ELECTRICIDAD',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900, // w900 es el máximo grosor de letra
            fontSize: 22,
            letterSpacing:
                1.2, // Un poco de espacio entre letras para leer mejor al sol
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),

            // OPCION A: REPARACIONES
            _buildMenuCard(
              context: context,
              isObra: isObra,
              title: 'REPARACIONES',
              subtitle: 'Guías de cambio y mantenimiento',
              icon: Icons.gavel_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MenuReparaciones(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // OPCION B: DIAGNÓSTICOS
            _buildMenuCard(
              context: context,
              isObra: isObra,
              title: 'DIAGNÓSTICOS',
              subtitle: 'Asistente interactivo de fallas',
              icon: Icons.youtube_searched_for_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MenuDiagnosticos(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // OPCION C: HERRAMIENTAS
            _buildMenuCard(
              context: context,
              isObra: isObra,
              title: 'HERRAMIENTAS',
              subtitle: 'Cálculo de cables, tensión, Ley de Ohm',
              icon: Icons.calculate_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ElectricianHomeScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // OPCION C: HERRAMIENTAS
            _buildMenuCard(
              context: context,
              isObra: isObra,
              title: 'PRESUPUESTOS',
              subtitle: 'Estimación del coste total de un servicio',
              icon: Icons.calculate_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PresupuestoScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required bool isObra,
    required String title,
    required String subtitle,
    required IconData icon,
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
            // ⚫ BORDE: Negro en Obra, Azul en Oficina
            color: isObra ? Colors.black : Colors.blue.shade400,
            width: isObra ? 3 : 2, // Borde más grueso en Obra
          ),
          boxShadow: isObra
              ? null // Sin sombra en Obra para mantenerlo plano e industrial
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
              icon,
              size: 36,
              // ⚫ ÍCONO: Negro en Obra, Azul en Oficina
              color: isObra ? Colors.black : Colors.blue.shade700,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      // ⚫ TEXTO PRINCIPAL: Negro y Súper Grueso (w900) en Obra
                      fontWeight: isObra ? FontWeight.w900 : FontWeight.bold,
                      color: isObra ? Colors.black : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      // ⚫ SUBTÍTULO: Negro fuerte en Obra, Gris en Oficina
                      color: isObra ? Colors.black87 : Colors.grey.shade600,
                      fontWeight: isObra ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              // ⚫ FLECHA: Negra en Obra, Azul clarito en Oficina
              color: isObra ? Colors.black : Colors.blue.shade300,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
