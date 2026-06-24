import 'package:flutter/material.dart';
import 'package:construc_assist/features/electrician/calculators/cable_math.dart';

class CableSectionScreen extends StatefulWidget {
  const CableSectionScreen({super.key});

  @override
  State<CableSectionScreen> createState() => _CableSectionScreenState();
}

class _CableSectionScreenState extends State<CableSectionScreen> {
  final _corrienteController = TextEditingController();
  final _longitudController = TextEditingController();
  final _voltajeController = TextEditingController(text: '220');
  final _caidaController = TextEditingController(text: '3.0');

  bool _esCobre = true;
  bool _esTrifasica = false;

  double _seccionExacta = 0.0;
  double _seccionComercial = 0.0;

  void _calcular() {
    final i = double.tryParse(_corrienteController.text) ?? 0.0;
    final l = double.tryParse(_longitudController.text) ?? 0.0;
    final v = double.tryParse(_voltajeController.text) ?? 0.0;
    final caida = double.tryParse(_caidaController.text) ?? 0.0;

    final exacta = CableMath.calcularSeccion(
      corriente: i,
      longitud: l,
      voltaje: v,
      caidaPermitidaPorcentaje: caida,
      esCobre: _esCobre,
      esTrifasica: _esTrifasica,
    );

    setState(() {
      _seccionExacta = exacta;
      _seccionComercial = CableMath.obtenerSeccionComercial(exacta);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sección de Cables')),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildSwitch(
                      'Material',
                      _esCobre ? 'Cobre' : 'Aluminio',
                      _esCobre,
                      (v) => setState(() {
                        _esCobre = v;
                        _calcular();
                      }),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSwitch(
                      'Red',
                      _esTrifasica ? 'Trifásica' : 'Monofásica',
                      _esTrifasica,
                      (v) => setState(() {
                        _esTrifasica = v;
                        _voltajeController.text = v ? '380' : '220';
                        _calcular();
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildTextField(_corrienteController, 'Corriente estimada (A)'),
              const SizedBox(height: 16),
              _buildTextField(
                _longitudController,
                'Longitud de la línea (Metros)',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(_voltajeController, 'Voltaje (V)'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(_caidaController, 'Caída máx (%)'),
                  ),
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

  Widget _buildSwitch(
    String label,
    String value,
    bool state,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          SwitchListTile(
            title: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
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
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      onChanged: (_) => _calcular(),
    );
  }

  Widget _buildResultBox() {
    if (_seccionExacta == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Sección Comercial Sugerida',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '${_seccionComercial.toStringAsFixed(1)} mm²',
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 32),
          Text(
            'Cálculo matemático exacto: ${_seccionExacta.toStringAsFixed(2)} mm²',
          ),
        ],
      ),
    );
  }
}
