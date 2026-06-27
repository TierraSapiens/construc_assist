import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/presupuesto_provider.dart';

class PresupuestoScreen extends ConsumerWidget {
  const PresupuestoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Aquí nos conectamos al "cerebro".
    final presupuesto = ref.watch(presupuestoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Presupuesto de Obra'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ZONA SUPERIOR: La lista de materiales/mano de obra
          Expanded(
            child: presupuesto.items.isEmpty
                ? const Center(
                    child: Text(
                      'El presupuesto está vacío.\nAgregá ítems o usá la I.A.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: presupuesto.items.length,
                    itemBuilder: (context, index) {
                      final item = presupuesto.items[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: ListTile(
                          title: Text(
                            item.nombre,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${item.cantidad} ${item.unidad} x \$${item.precioUnitario}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '\$${item.total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  // Le avisamos al cerebro que borre este ítem
                                  ref
                                      .read(presupuestoProvider.notifier)
                                      .eliminarItem(item.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // ZONA INFERIOR: Los Totales (La caja registradora)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                _FilaTotal(titulo: 'Subtotal:', valor: presupuesto.subtotal),
                _FilaTotal(
                  titulo:
                      'Ganancia Extra (${presupuesto.porcentajeGananciaExtra}%):',
                  valor: presupuesto.montoGanancia,
                ),
                const Divider(),
                _FilaTotal(
                  titulo: 'TOTAL FINAL:',
                  valor: presupuesto.totalFinal,
                  esTotal: true,
                ),
              ],
            ),
          ),
        ],
      ),
      // ACÁ ABAJO ESTÁ LA MAGIA, BIEN ACOMODADA AL FINAL DEL SCAFFOLD:
      bottomNavigationBar: SafeArea(
        child: Padding(
          // Esto ayuda a que el teclado del celu no tape la caja de texto
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: const AiInputBar(),
        ),
      ),
    );
  }
}

// Un widget chiquito para no repetir código al mostrar las filas de subtotales
class _FilaTotal extends StatelessWidget {
  final String titulo;
  final double valor;
  final bool esTotal;

  const _FilaTotal({
    required this.titulo,
    required this.valor,
    this.esTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontSize: esTotal ? 18 : 14,
              fontWeight: esTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${valor.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: esTotal ? 20 : 14,
              fontWeight: esTotal ? FontWeight.bold : FontWeight.normal,
              color: esTotal ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }
}

// --- DESDE ACÁ EMPIEZA LA FÁBRICA DE LA BARRA DE IA (AHORA CON RUEDITA) ---
class AiInputBar extends ConsumerStatefulWidget {
  const AiInputBar({super.key});

  @override
  ConsumerState<AiInputBar> createState() => _AiInputBarState();
}

class _AiInputBarState extends ConsumerState<AiInputBar> {
  final _controller = TextEditingController();
  bool _isAiThinking = false; // Variable para saber si la IA está trabajando

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      color: Colors.grey[900],
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              enabled: !_isAiThinking, // Bloqueamos el texto si está pensando
              decoration: InputDecoration(
                hintText: _isAiThinking
                    ? 'Calculando materiales y mano de obra...'
                    : 'Ej: Instalar 3 tomas y 1 ventilador...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.black,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: _isAiThinking ? Colors.grey : Colors.amber,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: _isAiThinking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Icon(Icons.auto_awesome, color: Colors.black),
              onPressed: _isAiThinking
                  ? null
                  : () async {
                      if (_controller.text.isNotEmpty) {
                        // 1. Prendemos la ruedita
                        setState(() {
                          _isAiThinking = true;
                        });

                        // 2. Llamamos a Gemini y esperamos
                        await ref
                            .read(presupuestoProvider.notifier)
                            .procesarTrabajoConIA(_controller.text);

                        // 3. Apagamos la ruedita y limpiamos
                        if (mounted) {
                          setState(() {
                            _isAiThinking = false;
                          });
                          _controller.clear();
                        }
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }
}
