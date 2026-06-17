import 'package:construc_assist/features/electrician/calculators/cable_section_screen.dart';
import 'package:construc_assist/features/electrician/calculators/voltage_drop_screen.dart';
import 'package:flutter/material.dart';
import 'package:construc_assist/features/electrician/calculators/ohms_law_screen.dart';
import 'package:construc_assist/features/electrician/calculators/power_calculator_screen.dart';

class ElectricianHomeScreen extends StatelessWidget {
  const ElectricianHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚡ Electricidad'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Herramientas de Cálculo',
              style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // Lista de Herramientas
            Expanded(
              child: ListView(
                children: [
                  // 1. Potencia Eléctrica
                  _buildToolCard(
                    context, 
                    '⚡', 
                    'Potencia Eléctrica', 
                    'Calculadora de Watts, Consumo y Costos',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PowerCalculatorScreen()),
                      );
                    }
                  ),
                  // 2. Ley de Ohm
                  _buildToolCard(
                    context, 
                    '📐', 
                    'Ley de Ohm', 
                    'Calculadora rápida de V, I, R o W',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OhmsLawScreen()),
                      );
                    }
                  ),
                  // 3. Sección de Cables
                  _buildToolCard(
                    context, 
                    '📏', 
                    'Sección de Cables', 
                    'Cálculo de calibre según consumo y distancia',
                    () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CableSectionScreen()));
                    }
                  ),
                  // 4. Caída de Tensión
                  _buildToolCard(
                    context, 
                    '📉', 
                    'Caída de Tensión', 
                    'Verificación de pérdida de voltaje',
                    () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const VoltageDropScreen()));
                    }
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Molde MODIFICADO: Ahora recibe la acción "onTap" como un parámetro extra (VoidCallback)
  Widget _buildToolCard(BuildContext context, String emoji, String title, String subtitle, VoidCallback onTapAction) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Text(emoji, style: const TextStyle(fontSize: 32)),
        title: Text(
          title, 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(subtitle),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios, 
          color: Theme.of(context).colorScheme.primary
        ),
        // Aquí se ejecuta la acción específica que le pasamos a cada tarjeta
        onTap: onTapAction,
      ),
    );
  }
}