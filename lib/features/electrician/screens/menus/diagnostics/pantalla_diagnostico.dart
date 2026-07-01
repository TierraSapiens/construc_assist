import 'package:flutter/material.dart';
import '../../../../../services/data_service.dart';
import '../../../../../models/diagnostic_model.dart';

class PantallaDiagnosticoBreaker extends StatefulWidget {
  const PantallaDiagnosticoBreaker({super.key});

  @override
  State<PantallaDiagnosticoBreaker> createState() =>
      _PantallaDiagnosticoBreakerState();
}

class _PantallaDiagnosticoBreakerState
    extends State<PantallaDiagnosticoBreaker> {
  final DataService _dataService = DataService();

  DiagnosticoCompletoModel? _diagnostico;
  String? _nodoActualId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asistente de Diagnóstico')),
      body: FutureBuilder<DiagnosticoCompletoModel?>(
        future: _dataService.obtenerDiagnosticoBreaker(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text('Error al cargar el diagnóstico. Revise el JSON.'),
            );
          }

          if (_diagnostico == null) {
            _diagnostico = snapshot.data;
            _nodoActualId = _diagnostico!.nodoInicio;
          }

          final nodoActual = _diagnostico!.nodos.firstWhere(
            (n) => n.id == _nodoActualId,
            orElse: () => _diagnostico!.nodos.first,
          );

          if (nodoActual.tipo == 'causa') {
            return _buildPantallaSolucion(nodoActual);
          }

          return _buildPantallaPregunta(nodoActual);
        },
      ),
    );
  }

  Widget _buildPantallaPregunta(NodoModel nodo) {
    Color colorDestacado = nodo.tipo == 'seguridad'
        ? Colors.red.shade700
        : Colors.blueGrey;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _diagnostico!.tituloEs,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Icon(
            nodo.tipo == 'seguridad'
                ? Icons.warning_amber_rounded
                : Icons.construction,
            size: 50,
            color: colorDestacado,
          ),
          const SizedBox(height: 20),
          Text(
            nodo.textoEs,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ...nodo.respuestas.map((opcion) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor:
                      nodo.tipo == 'seguridad' && opcion.valor == 'si'
                      ? Colors.red
                      : null,
                  foregroundColor:
                      nodo.tipo == 'seguridad' && opcion.valor == 'si'
                      ? Colors.white
                      : null,
                ),
                onPressed: () {
                  setState(() {
                    _nodoActualId =
                        opcion.siguiente; // Avanzamos al siguiente nodo
                  });
                },
                child: Text(opcion.texto, style: const TextStyle(fontSize: 16)),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPantallaSolucion(NodoModel causa) {
    final idSolucion = causa.solucionesIds.isNotEmpty
        ? causa.solucionesIds.first
        : '';
    final solucionReal = _diagnostico!.soluciones.firstWhere(
      (s) => s.id == idSolucion,
      orElse: () => SolucionModel(
        id: '',
        textoEs: 'Solución no encontrada',
        requiereProfesional: false,
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            solucionReal.requiereProfesional
                ? Icons.engineering
                : Icons.check_circle_outline,
            color: solucionReal.requiereProfesional
                ? Colors.orange
                : Colors.green,
            size: 80,
          ),
          const SizedBox(height: 20),
          Text(
            causa.textoEs,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueGrey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blueGrey.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Text(
                  "ACCIÓN RECOMENDADA",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  solucionReal.textoEs,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _nodoActualId = _diagnostico!.nodoInicio; // Volvemos a empezar
              });
            },
            child: const Text('Reiniciar Diagnóstico'),
          ),
        ],
      ),
    );
  }
}
