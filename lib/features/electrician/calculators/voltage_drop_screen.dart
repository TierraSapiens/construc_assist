import 'package:flutter/material.dart';
import 'package:construc_assist/features/electrician/calculators/cable_math.dart';

class VoltageDropScreen extends StatefulWidget {
  const VoltageDropScreen({super.key});

  @override
  State<VoltageDropScreen> createState() => _VoltageDropScreenState();
}

class _VoltageDropScreenState extends State<VoltageDropScreen> {
  final _seccionController = TextEditingController();
  final _corrienteController = TextEditingController();
  final _longitudController = TextEditingController();
  final _voltajeController = TextEditingController(text: '220');

  bool _esCobre = true;
  bool _esTrifasica = false;
  
  double _caidaVolts = 0.0;
  double _caidaPorcentaje = 0.0;

  void _calcular() {
    final s = double.tryParse(_seccionController.text) ?? 0.0;
    final i = double.tryParse(_corrienteController.text) ?? 0.0;
    final l = double.tryParse(_longitudController.text) ?? 0.0;
    final v = double.tryParse(_voltajeController.text) ?? 0.0;

    final resultado = CableMath.calcularCaidaTension(
      seccion: s,
      corriente: i,
      longitud: l,
      voltaje: v,
      esCobre: _esCobre,
      esTrifasica: _esTrifasica,
    );

    setState(() {
      _caidaVolts = resultado['volts'] ?? 0.0;
      _caidaPorcentaje = resultado['porcentaje'] ?? 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Caída de Tensión')),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: _buildSwitch('Material', _esCobre ? 'Cobre' : 'Aluminio', _esCobre, (v) => setState(() { _esCobre = v; _calcular(); }))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSwitch('Red', _esTrifasica ? 'Trifásica' : 'Monofásica', _esTrifasica, (v) => setState(() { _esTrifasica = v; _voltajeController.text = v ? '380' : '220'; _calcular(); }))),
                ],
              ),
              const SizedBox(height: 24),
              _buildTextField(_seccionController, 'Sección del cable (mm²)'),
              const SizedBox(height: 16),
              _buildTextField(_corrienteController, 'Corriente de carga (A)'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField(_longitudController, 'Longitud (m)')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_voltajeController, 'Voltaje (V)')),
                ],
              ),
              const SizedBox(height: 32),
              _buildResultBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitch(String label, String value, bool state, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          SwitchListTile(
            title: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            value: state,
            onChanged: onChanged,
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
      onChanged: (_) => _calcular(),
    );
  }

  Widget _buildResultBox() {
    if (_seccionController.text.isEmpty || _corrienteController.text.isEmpty || _longitudController.text.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Alerta visual si la caída supera el 3% o 5%
    Color colorResultado = Theme.of(context).colorScheme.primary;
    if (_caidaPorcentaje > 5.0) {
      colorResultado = Colors.red;
    } else if (_caidaPorcentaje > 3.0) {
      colorResultado = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorResultado.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorResultado.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Text('Caída de Tensión Total', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text('${_caidaVolts.toStringAsFixed(2)} V', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: colorResultado)),
          Text('(${_caidaPorcentaje.toStringAsFixed(2)} %)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorResultado)),
          if (_caidaPorcentaje > 5.0)
            const Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Text('⚠️ Caída severa. Aumentá la sección del cable.', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            )
        ],
      ),
    );
  }
}