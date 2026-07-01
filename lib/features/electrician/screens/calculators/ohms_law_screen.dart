import 'package:flutter/material.dart';
import 'package:construc_assist/features/electrician/calculators/ohms_law_math.dart';

class OhmsLawScreen extends StatefulWidget {
  const OhmsLawScreen({super.key});

  @override
  State<OhmsLawScreen> createState() => _OhmsLawScreenState();
}

class _OhmsLawScreenState extends State<OhmsLawScreen> {
  final _vController = TextEditingController();
  final _iController = TextEditingController();
  final _rController = TextEditingController();
  final _pController = TextEditingController();

  String? _errorMsg;

  void _calcular() {
    FocusScope.of(context).unfocus();

    final v = double.tryParse(_vController.text);
    final i = double.tryParse(_iController.text);
    final r = double.tryParse(_rController.text);
    final p = double.tryParse(_pController.text);

    final result = OhmsLawMath.calcularValores(v: v, i: i, r: r, p: p);

    setState(() {
      if (result.containsKey('error')) {
        _errorMsg = result['error'];
      } else {
        _errorMsg = null;
        _vController.text = result['v'].toStringAsFixed(2);
        _iController.text = result['i'].toStringAsFixed(2);
        _rController.text = result['r'].toStringAsFixed(2);
        _pController.text = result['p'].toStringAsFixed(2);
      }
    });
  }

  void _limpiar() {
    setState(() {
      _errorMsg = null;
      _vController.clear();
      _iController.clear();
      _rController.clear();
      _pController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ley de Ohm y Watt')),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 28),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Ingresá únicamente los 2 valores que conocés. Dejá en blanco los otros 2 y el sistema los calculará automáticamente.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Inputs
              _buildTextField(_vController, 'Voltaje / Tensión (V)'),
              const SizedBox(height: 16),
              _buildTextField(_iController, 'Corriente / Amperaje (A)'),
              const SizedBox(height: 16),
              _buildTextField(_rController, 'Resistencia (Ω)'),
              const SizedBox(height: 16),
              _buildTextField(_pController, 'Potencia (W)'),

              if (_errorMsg != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMsg!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 32),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _limpiar,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Limpiar',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _calcular,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Calcular Faltantes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
        filled: true,
      ),
    );
  }
}
