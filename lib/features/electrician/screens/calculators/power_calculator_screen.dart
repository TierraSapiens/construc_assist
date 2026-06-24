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

  // --- CONTROLADORES TAB 2: TRIFÁSICA ---
  final _vTriController = TextEditingController(text: '380');
  final _iTriController = TextEditingController();

  // --- CONTROLADORES TAB 3: BUSCAR CORRIENTE ---
  final _pCurrentController = TextEditingController();
  final _vCurrentController = TextEditingController(text: '220');
  bool _isTriCurrent = false;
  double _resultCurrent = 0.0;

  // --- CONTROLADORES COMPARTIDOS (AVANZADOS) ---
  final _fpController = TextEditingController(text: '0.85');
  final _horasController = TextEditingController();
  final _precioController = TextEditingController();

  // --- ESTADOS DE RESULTADOS ---
  Map<String, double> _resultadosMono = {};
  Map<String, double> _resultadosTri = {};

  void _calcularMono() {
    final v = double.tryParse(_vMonoController.text) ?? 0.0;
    final i = double.tryParse(_iMonoController.text) ?? 0.0;
    final fp = double.tryParse(_fpController.text) ?? 0.85;
    final horas = double.tryParse(_horasController.text) ?? 0.0;
    final precio = double.tryParse(_precioController.text) ?? 0.0;

    final pActiva = PowerMath.calcularPotenciaMonofasica(
      voltaje: v,
      corriente: i,
      factorPotencia: fp,
    );
    final pAparente = PowerMath.calcularPotenciaAparente(pActiva, fp);
    final pReactiva = PowerMath.calcularPotenciaReactiva(pActiva, pAparente);
    final consumo = PowerMath.calcularConsumoKWh(
      potenciaWatts: pActiva,
      horasDiarias: horas,
    );
    final costo = PowerMath.calcularCostoMensual(consumo, precio);

    setState(() {
      _resultadosMono = {
        'activa': pActiva,
        'aparente': pAparente,
        'reactiva': pReactiva,
        'consumo': consumo,
        'costo': costo,
      };
    });
  }

  void _calcularTri() {
    final v = double.tryParse(_vTriController.text) ?? 0.0;
    final i = double.tryParse(_iTriController.text) ?? 0.0;
    final fp = double.tryParse(_fpController.text) ?? 0.85;
    final horas = double.tryParse(_horasController.text) ?? 0.0;
    final precio = double.tryParse(_precioController.text) ?? 0.0;

    final pActiva = PowerMath.calcularPotenciaTrifasica(
      voltaje: v,
      corriente: i,
      factorPotencia: fp,
    );
    final pAparente = PowerMath.calcularPotenciaAparente(pActiva, fp);
    final pReactiva = PowerMath.calcularPotenciaReactiva(pActiva, pAparente);
    final consumo = PowerMath.calcularConsumoKWh(
      potenciaWatts: pActiva,
      horasDiarias: horas,
    );
    final costo = PowerMath.calcularCostoMensual(consumo, precio);

    setState(() {
      _resultadosTri = {
        'activa': pActiva,
        'aparente': pAparente,
        'reactiva': pReactiva,
        'consumo': consumo,
        'costo': costo,
      };
    });
  }

  void _calcularCorriente() {
    final p = double.tryParse(_pCurrentController.text) ?? 0.0;
    final v = double.tryParse(_vCurrentController.text) ?? 0.0;
    final fp = double.tryParse(_fpController.text) ?? 0.85;

    setState(() {
      _resultCurrent = PowerMath.calcularCorrienteDesdePotencia(
        potenciaWatts: p,
        voltaje: v,
        factorPotencia: fp,
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
              Tab(text: 'B. Corriente'),
            ],
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: TabBarView(
            children: [
              // ---------------- TAB 1: MONOFÁSICA ----------------
              _buildTabContainer([
                _buildTextField(
                  _vMonoController,
                  'Voltaje Monofásico (V)',
                  (_) => _calcularMono(),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _iMonoController,
                  'Corriente (A)',
                  (_) => _calcularMono(),
                ),
                const Divider(height: 40),
                _buildAdvancedSettings(() => _calcularMono()),
                const SizedBox(height: 24),
                _buildFullResultBox(_resultadosMono),
              ]),

              // ---------------- TAB 2: TRIFÁSICA ----------------
              _buildTabContainer([
                _buildTextField(
                  _vTriController,
                  'Voltaje Trifásico (V)',
                  (_) => _calcularTri(),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _iTriController,
                  'Corriente por Fase (A)',
                  (_) => _calcularTri(),
                ),
                const Divider(height: 40),
                _buildAdvancedSettings(() => _calcularTri()),
                const SizedBox(height: 24),
                _buildFullResultBox(_resultadosTri),
              ]),

              // ---------------- TAB 3: BUSCAR CORRIENTE ----------------
              _buildTabContainer([
                _buildTextField(
                  _pCurrentController,
                  'Potencia (W)',
                  (_) => _calcularCorriente(),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _vCurrentController,
                  'Voltaje (V)',
                  (_) => _calcularCorriente(),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text(
                    '¿Red Trifásica?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
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
                const Divider(height: 40),
                _buildTextField(
                  _fpController,
                  'Factor de Potencia (Cos φ)',
                  (_) => _calcularCorriente(),
                ),
                const SizedBox(height: 24),
                _buildSimpleResultBox(
                  'Corriente Requerida',
                  _resultCurrent,
                  'A',
                ),
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

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    Function(String) onChanged,
  ) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildAdvancedSettings(Function() onUpdate) {
    return ExpansionTile(
      title: const Text(
        'Datos de Consumo y Eficiencia',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: const Text('FP, Horas de uso y Precio kWh'),
      childrenPadding: const EdgeInsets.symmetric(vertical: 8.0),
      children: [
        _buildTextField(
          _fpController,
          'Factor de Potencia (Cos φ) - Ej: 0.85',
          (_) => onUpdate(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                _horasController,
                'Horas / Día',
                (_) => onUpdate(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                _precioController,
                'Precio 1 kWh (\$)',
                (_) => onUpdate(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSimpleResultBox(String title, double value, String unit) {
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
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            '${value.toStringAsFixed(2)} $unit',
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFullResultBox(Map<String, double> resultados) {
    if (resultados.isEmpty) return const SizedBox.shrink();

    final pActiva = resultados['activa'] ?? 0;
    final pAparente = resultados['aparente'] ?? 0;
    final pReactiva = resultados['reactiva'] ?? 0;
    final consumo = resultados['consumo'] ?? 0;
    final costo = resultados['costo'] ?? 0;

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Potencia Activa Estimada',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            '${pActiva.toStringAsFixed(2)} W',
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
          ),
          Text(
            '(${(pActiva / 1000).toStringAsFixed(2)} kW)',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          if (pActiva > 0) ...[
            const Divider(height: 32),
            _buildResultRow(
              'Potencia Aparente (S)',
              '${pAparente.toStringAsFixed(2)} VA',
            ),
            const SizedBox(height: 8),
            _buildResultRow(
              'Potencia Reactiva (Q)',
              '${pReactiva.toStringAsFixed(2)} VAr',
            ),
          ],

          if (consumo > 0) ...[
            const Divider(height: 32),
            _buildResultRow(
              'Consumo Estimado (30 días)',
              '${consumo.toStringAsFixed(2)} kWh',
            ),
            if (costo > 0) ...[
              const SizedBox(height: 8),
              _buildResultRow(
                'Costo Mensual Estimado',
                '\$${costo.toStringAsFixed(2)}',
                isBold: true,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
