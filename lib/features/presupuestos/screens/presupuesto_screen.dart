import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/presupuesto_provider.dart';
import '../../../models/presupuesto_model.dart';

class PresupuestoScreen extends ConsumerWidget {
  const PresupuestoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Aquí nos conectamos al "cerebro".
    // Cada vez que cambie algo, esta variable 'presupuesto' se actualiza y redibuja la pantalla.
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

      // BOTÓN DE PRUEBA TEMPORAL: Para ver si la matemática funciona
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Creamos un ítem falso y se lo mandamos al provider
          final itemDePrueba = ItemPresupuesto(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            nombre: 'Toma Corriente 10A + Instalación',
            cantidad: 2,
            unidad: 'u',
            precioUnitario: 15000, // 15 mil por boca
            tipo: TipoItem.manoDeObra,
          );
          ref.read(presupuestoProvider.notifier).agregarItem(itemDePrueba);
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar Prueba'),
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
