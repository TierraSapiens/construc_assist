import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <-- Agregado
import 'package:construc_assist/core/settings/theme_provider.dart'; // <-- Agregado
import 'package:construc_assist/features/electrician/screens/menus/electrician_home_screen.dart';
import 'package:construc_assist/features/electrician/screens/menus/menu_diagnosticos.dart';
import 'package:construc_assist/features/electrician/screens/menus/menu_reparaciones.dart';
import 'package:construc_assist/features/presupuestos/screens/presupuesto_screen.dart';

class MenuElectricidad extends ConsumerWidget {
  // <-- Cambiado a ConsumerWidget
  const MenuElectricidad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // <-- Agregado WidgetRef ref
    final isObra = ref.watch(isObraModeProvider);

    return Scaffold(
      backgroundColor: isObra ? Colors.black : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: isObra ? Colors.grey.shade900 : Colors.blue.shade800,
        title: Text(
          '⚡ Electricidad',
          style: TextStyle(
            color: isObra ? Colors.amber : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: isObra ? Colors.amber : Colors.white),
        centerTitle: true,
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

  // Molde adaptado al Camaleón (manteniendo el borde grueso)
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
          color: isObra ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isObra
                ? Colors.amber.shade600
                : Colors.blue.shade400, // <-- Borde adaptado
            width: 2,
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
              icon,
              size: 36,
              color: isObra ? Colors.amber.shade600 : Colors.blue.shade700,
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
                      fontWeight: FontWeight.bold,
                      color: isObra ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isObra
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isObra ? Colors.amber.shade600 : Colors.blue.shade300,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
