import 'package:flutter/material.dart';
import 'package:construc_assist/features/electrician/calculators/power_math.dart';

class PowerCalculatorScreen extends StatefulWidget {
  const PowerCalculatorScreen({super.key});

  @override
  State<PowerCalculatorScreen> createState() => _PowerCalculatorScreenState();
}

class _PowerCalculatorScreenState extends State<PowerCalculatorScreen> {
  // --- CONTROLADORES TAB 1: MONOFÁSICA ---
  final _vMonoController = TextEditingController(text: '220');
  final _iMonoController = TextEditingController();
  double _resultMono = 0.0;

  // --- CONTROLADORES TAB 2: TRIFÁSICA ---
  final _vTriController = TextEditingController(text: '380');
  final _iTriController = TextEditingController();
  double _resultTri = 0.0;

  // --- CONTROLADORES TAB 3: BUSCAR CORRIENTE ---
  final _pCurrentController = TextEditingController();
  final _vCurrentController = TextEditingController(text: '220');
  bool _isTriCurrent = false;
  double _resultCurrent = 0.0;

  // --- MÉTODOS DE CÁLCULO ---
  void _calcularMono() {
    final v = double.tryParse(_vMonoController.text) ?? 0.0;
    final i = double.tryParse(_iMonoController.text) ?? 0.0;
    setState(() {
      _resultMono = PowerMath.calcularPotenciaMonofasica(voltaje: v, corriente: i);
    });
  }

  void _calcularTri() {
    final v = double.tryParse(_vTriController.text) ?? 0.0;
    final i = double.tryParse(_iTriController.text) ?? 0.0;
    setState(() {
      _resultTri = PowerMath.calcularPotenciaTrifasica(voltaje: v, corriente: i);
    });
  }

  void _calcularCorriente() {
    final p = double.tryParse(_pCurrentController.text) ?? 0.0;
    final v = double.tryParse(_vCurrentController.text) ?? 0.0;
    setState(() {
      _resultCurrent = PowerMath.calcularCorrienteDesdePotencia(
        potenciaWatts: p,
        voltaje: v,
        isTrifasica: _isTriCurrent,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Potencia Eléctrica'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Monofásica'),
              Tab(text: 'Trifásica'),
              Tab(text: 'Buscar Corriente'),
            ],
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: TabBarView(
            children: [
              // ---------------- TAB 1: MONOFÁSICA ----------------
              _buildTabContainer([
                _buildTextField(_vMonoController, 'Voltaje Monofásico (V)', (_) => _calcularMono()),
                const SizedBox(height: 16),
                _buildTextField(_iMonoController, 'Corriente / Amperaje (A)', (_) => _calcularMono()),
                const SizedBox(height: 32),
                _buildResultBox('Potencia Activa Estimada', _resultMono, 'W', showKW: true),
              ]),

              // ---------------- TAB 2: TRIFÁSICA ----------------
              _buildTabContainer([
                _buildTextField(_vTriController, 'Voltaje Trifásico (V)', (_) => _calcularTri()),
                const SizedBox(height: 16),
                _buildTextField(_iTriController, 'Corriente por Línea (A)', (_) => _calcularTri()),
                const SizedBox(height: 32),
                _buildResultBox('Potencia Trifásica Estimada', _resultTri, 'W', showKW: true),
              ]),

              // ---------------- TAB 3: BUSCAR CORRIENTE ----------------
              _buildTabContainer([
                _buildTextField(_pCurrentController, 'Potencia de la Carga (W)', (_) => _calcularCorriente()),
                const SizedBox(height: 16),
                _buildTextField(_vCurrentController, 'Voltaje de Red (V)', (_) => _calcularCorriente()),
                const SizedBox(height: 16),
                
                SwitchListTile(
                  title: const Text('¿Es una instalación Trifásica?', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(_isTriCurrent ? 'Cálculo con raíz de 3 (√3)' : 'Cálculo estándar monofásico'),
                  value: _isTriCurrent,
                  activeThumbColor: Theme.of(context).colorScheme.primary,
                  onChanged: (value) {
                    setState(() {
                      _isTriCurrent = value;
                      _vCurrentController.text = value ? '380' : '220';
                    });
                    _calcularCorriente();
                  },
                ),
                const SizedBox(height: 24),
                _buildResultBox('Corriente / Intensidad Requerida', _resultCurrent, 'A'),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // --- COMPONENTES VISUALES REUTILIZABLES ---
  Widget _buildTabContainer(List<Widget> children) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, Function(String) onChanged) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildResultBox(String title, double value, String unit, {bool showKW = false}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(
            '${value.toStringAsFixed(2)} $unit',
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
          ),
          if (showKW) ...[
            const SizedBox(height: 4),
            Text(
              '(${(value / 1000).toStringAsFixed(2)} kW)',
              style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8)),
            ),
          ]
        ],
      ),
    );
  }
}