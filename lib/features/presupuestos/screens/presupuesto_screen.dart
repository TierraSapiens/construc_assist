import 'package:construc_assist/features/presupuestos/widgets/presupuesto_action_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/presupuesto_provider.dart';

final vistaDetalladaProvider = StateProvider<bool>((ref) => true);

class PresupuestoScreen extends ConsumerWidget {
  const PresupuestoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presupuesto = ref.watch(presupuestoProvider);
    final esVistaDetallada = ref.watch(vistaDetalladaProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text(
          'Presupuesto de Obra',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: esVistaDetallada
                                ? Colors.amber
                                : Colors.grey[300],
                            foregroundColor: Colors.black,
                            elevation: esVistaDetallada ? 3 : 0,
                          ),
                          onPressed: () =>
                              ref.read(vistaDetalladaProvider.notifier).state =
                                  true,
                          child: const Text(
                            'DETALLE',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: !esVistaDetallada
                                ? Colors.amber
                                : Colors.grey[300],
                            foregroundColor: Colors.black,
                            elevation: !esVistaDetallada ? 3 : 0,
                          ),
                          onPressed: () =>
                              ref.read(vistaDetalladaProvider.notifier).state =
                                  false,
                          child: const Text(
                            'RESUMEN',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: esVistaDetallada
                      ? (presupuesto.items.isEmpty
                            ? const Center(
                                child: Text(
                                  'El detalle está vacío.',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )
                            : ListView.builder(
                                itemCount: presupuesto.items.length,
                                itemBuilder: (context, index) {
                                  final item = presupuesto.items[index];
                                  return Card(
                                    color: Colors.white,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                        color: Colors.black12,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        item.nombre,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 13,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${item.cantidad} ${item.unidad} x \$${item.precioUnitario}',
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '\$${item.total.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 14,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                            onPressed: () => ref
                                                .read(
                                                  presupuestoProvider.notifier,
                                                )
                                                .eliminarItem(item.id),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ))
                      : const SingleChildScrollView(
                          child: _VistaResumidaEditable(),
                        ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.amber, width: 4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                _FilaTotal(
                  titulo: 'Subtotal Materiales:',
                  valor: presupuesto.subtotal,
                ),
                InkWell(
                  onTap: () => mostrarAjusteManoDeObra(
                    context,
                    ref,
                    presupuesto.manoDeObra,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: _FilaTotal(
                      titulo: 'Mano de Obra: ✏️',
                      valor: presupuesto.manoDeObra,
                    ),
                  ),
                ),
                const Divider(color: Colors.black26),
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: const AiInputBar(),
        ),
      ),
    );
  }
}

class _VistaResumidaEditable extends ConsumerWidget {
  const _VistaResumidaEditable();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presupuesto = ref.watch(presupuestoProvider);
    final textoActual = presupuesto.resumenIA ?? '';

    final tieneManoDeObraManual = presupuesto.manoDeObra > 0;
    final mencionaManoDeObraEnTexto = textoActual.toLowerCase().contains(
      'mano de obra',
    );
    final mostrarAdvertencia =
        tieneManoDeObraManual && mencionaManoDeObraEnTexto;

    return Card(
      color: Colors.white,
      elevation: 3,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black12, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.edit_note_rounded,
                      color: Colors.amber,
                      size: 36,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'MODIFICAR PRESUPUESTO',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black87),
                  tooltip: 'Editar texto',
                  onPressed: () => _abrirEditor(context, ref, textoActual),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (mostrarAdvertencia) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber, width: 2),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 28,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Atención: Agregaste un valor manual de "Mano de Obra" abajo, pero este texto dice que ya está incluida. Corregí la redacción para evitar confusiones al cliente.',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            InkWell(
              onTap: () => _abrirEditor(context, ref, textoActual),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black12),
                ),
                child: Text(
                  textoActual.isEmpty
                      ? 'Toca aquí para escribir los detalles del trabajo...'
                      : textoActual,
                  style: TextStyle(
                    color: textoActual.isEmpty
                        ? Colors.black54
                        : Colors.black87,
                    fontSize: 15,
                    height: 1.4,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _abrirEditor(BuildContext context, WidgetRef ref, String textoActual) {
    final controller = TextEditingController(text: textoActual);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Editar Redacción',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 8,
                minLines: 4,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  height: 1.4,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber, // Fondo Amarillo
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    ref
                        .read(presupuestoProvider.notifier)
                        .actualizarResumen(controller.text);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'GUARDAR TEXTO',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.black, // Letra Negra Gruesa
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

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
              color: Colors.black,
              fontSize: esTotal ? 18 : 14,
              fontWeight: esTotal ? FontWeight.w900 : FontWeight.bold,
            ),
          ),
          Text(
            '\$${valor.toStringAsFixed(2)}',
            style: TextStyle(
              color: esTotal ? Colors.green[700] : Colors.black,
              fontSize: esTotal ? 22 : 14,
              fontWeight: esTotal ? FontWeight.w900 : FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

void mostrarAjusteManoDeObra(
  BuildContext context,
  WidgetRef ref,
  double montoActual,
) {
  final controller = TextEditingController(
    text: montoActual == 0 ? '' : montoActual.toStringAsFixed(0),
  );

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingresar Mano de Obra',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                prefixText: '\$ ',
                hintText: 'Ej: 50000',
                hintStyle: const TextStyle(color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final monto = double.tryParse(controller.text) ?? 0.0;
                  ref
                      .read(presupuestoProvider.notifier)
                      .actualizarManoDeObra(monto);
                  Navigator.pop(context);
                },
                child: const Text(
                  'GUARDAR IMPORTE',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    },
  );
}
