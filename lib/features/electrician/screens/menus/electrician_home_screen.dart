import 'package:construc_assist/features/electrician/screens/calculators/cable_section_screen.dart';
import 'package:construc_assist/features/electrician/screens/calculators/voltage_drop_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construc_assist/core/settings/theme_provider.dart';
import 'package:construc_assist/features/electrician/screens/calculators/ohms_law_screen.dart';
import 'package:construc_assist/features/electrician/screens/calculators/power_calculator_screen.dart';

class ElectricianHomeScreen extends ConsumerWidget {
  const ElectricianHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isObra = ref.watch(isObraModeProvider);

    return Scaffold(
      backgroundColor: isObra ? Colors.black : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: isObra ? Colors.amber : Colors.blue.shade800,
        title: Text(
          'HERRAMIENTAS DE CÁLCULO',
          style: TextStyle(
            color: isObra ? Colors.black : Colors.white,
            fontWeight: isObra ? FontWeight.w900 : FontWeight.bold,
            letterSpacing: isObra ? 1.2 : 0,
          ),
        ),
        iconTheme: IconThemeData(
          color: isObra ? Colors.black : Colors.white,
          size: isObra ? 30 : 24,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildToolCard(
              context,
              isObra: isObra,
              emoji: '⚡',
              title: 'POTENCIA ELÉCTRICA',
              subtitle: 'Calculadora de Watts, Consumo y Costos',
              onTapAction: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PowerCalculatorScreen(),
                ),
              ),
            ),
            _buildToolCard(
              context,
              isObra: isObra,
              emoji: '📐',
              title: 'LEY DE OHM',
              subtitle: 'Calculadora rápida de V, I, R o W',
              onTapAction: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OhmsLawScreen()),
              ),
            ),
            _buildToolCard(
              context,
              isObra: isObra,
              emoji: '📏',
              title: 'SECCIÓN DE CABLES',
              subtitle: 'Cálculo de calibre según consumo y distancia',
              onTapAction: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CableSectionScreen(),
                ),
              ),
            ),
            _buildToolCard(
              context,
              isObra: isObra,
              emoji: '📉',
              title: 'CAÍDA DE TENSIÓN',
              subtitle: 'Verificación de pérdida de voltaje',
              onTapAction: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VoltageDropScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required bool isObra,
    required String emoji,
    required String title,
    required String subtitle,
    required VoidCallback onTapAction,
  }) {
    return InkWell(
      onTap: onTapAction,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // 🟡 FONDO AMARILLO EN OBRA
          color: isObra ? Colors.amber : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            // ⚫ BORDE NEGRO GRUESO
            color: isObra ? Colors.black : Colors.blue.shade100,
            width: isObra ? 3 : 2,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      // ⚫ TEXTO NEGRO Y W900
                      color: isObra ? Colors.black : Colors.black87,
                      fontSize: 18,
                      fontWeight: isObra ? FontWeight.w900 : FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
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
              color: isObra ? Colors.black : Colors.blue.shade300,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
