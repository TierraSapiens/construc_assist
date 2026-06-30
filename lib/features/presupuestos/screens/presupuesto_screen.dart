import 'package:share_plus/share_plus.dart';
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
                // BOTONERA DETALLE / RESUMEN
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
                // CONTENIDO DINÁMICO
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
          // CAJA REGISTRADORA INFERIOR
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

// 📝 NUEVO WIDGET: TRANSFORMADO EN BLOC DE NOTAS TOTALMENTE EDITABLE
class _VistaResumidaEditable extends ConsumerStatefulWidget {
  const _VistaResumidaEditable();

  @override
  ConsumerState<_VistaResumidaEditable> createState() =>
      _VistaResumidaEditableState();
}

class _VistaResumidaEditableState
    extends ConsumerState<_VistaResumidaEditable> {
  late TextEditingController _resumenController;

  @override
  void initState() {
    super.initState();
    final textoActual = ref.read(presupuestoProvider).resumenIA ?? '';
    _resumenController = TextEditingController(text: textoActual);
  }

  @override
  void dispose() {
    _resumenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            const Row(
              children: [
                Icon(Icons.edit_note_rounded, color: Colors.amber, size: 36),
                SizedBox(width: 12),
                Text(
                  'PROSA DEL PRESUPUESTO',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // El campo de edición libre
            TextField(
              controller: _resumenController,
              maxLines: null, // Crece hacia abajo infinitamente
              keyboardType: TextInputType.multiline,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
                height: 1.4,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText:
                    'Escribí acá los detalles del trabajo, horarios, formas de pago...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (nuevoTexto) {
                // Guarda la prosa en tiempo real en tu base de datos temporal
                ref
                    .read(presupuestoProvider.notifier)
                    .actualizarResumen(nuevoTexto);
              },
            ),
          ],
        ),
      ),
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

// 🛠️ NUEVA HERRAMIENTA: PANEL EMERGENTE NUMÉRICO PARA LA MANO DE OBRA
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
          bottom: MediaQuery.of(
            context,
          ).viewInsets.bottom, // Evita que el teclado lo tape
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              decoration: InputDecoration(
                prefixText: '\$ ',
                hintText: 'Ej: 50000',
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

class AiInputBar extends ConsumerStatefulWidget {
  const AiInputBar({super.key});

  @override
  ConsumerState<AiInputBar> createState() => _AiInputBarState();
}

class _AiInputBarState extends ConsumerState<AiInputBar> {
  final _controller = TextEditingController();
  bool _isAiThinking = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 🚀 LA REGLA DE COMPARTIR CONFIGURADA SEGÚN TUS CONDICIONES EXACTAS
  void _compartirPresupuesto() {
    final presupuesto = ref.read(presupuestoProvider);
    final esVistaDetallada = ref.read(vistaDetalladaProvider);

    StringBuffer texto = StringBuffer();
    texto.writeln('📋 *PRESUPUESTO DE OBRA* 📋');
    texto.writeln('');

    if (esVistaDetallada) {
      if (presupuesto.items.isEmpty) return;

      texto.writeln('🛠️ *Detalle de tareas / materiales:*');
      for (var item in presupuesto.items) {
        texto.writeln('▪️ ${item.nombre}');
        texto.writeln(
          '   ${item.cantidad} ${item.unidad} x \$${item.precioUnitario.toStringAsFixed(2)} = \$${item.total.toStringAsFixed(2)}',
        );
      }
      texto.writeln('');
      texto.writeln('------------------------');

      // REGLA A: Si mano de obra es 0, no menciona Subtotal ni Mano de obra
      if (presupuesto.manoDeObra == 0) {
        texto.writeln(
          '💰 *TOTAL FINAL: \$${presupuesto.totalFinal.toStringAsFixed(2)}*',
        );
      } else {
        texto.writeln(
          'Subtotal Materiales: \$${presupuesto.subtotal.toStringAsFixed(2)}',
        );
        texto.writeln(
          'Mano de Obra: \$${presupuesto.manoDeObra.toStringAsFixed(2)}',
        );
        texto.writeln(
          '💰 *TOTAL FINAL: \$${presupuesto.totalFinal.toStringAsFixed(2)}*',
        );
      }
      texto.writeln('------------------------');
    } else {
      // REGLA B: MODO RESUMEN (No manda listas ni subtotales, manda tu prosa limpia)
      final prosaPersonalizada = presupuesto.resumenIA ?? '';
      if (prosaPersonalizada.isNotEmpty) {
        texto.writeln(prosaPersonalizada);
      }
      texto.writeln('');
      texto.writeln('------------------------');
      texto.writeln(
        '💰 *TOTAL FINAL: \$${presupuesto.totalFinal.toStringAsFixed(2)}*',
      );
      texto.writeln('------------------------');
    }

    SharePlus.instance.share(ShareParams(text: texto.toString()));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.only(
        left: 12.0,
        right: 12.0,
        top: 16.0,
        bottom: 24.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  enabled: !_isAiThinking,
                  decoration: InputDecoration(
                    hintText: _isAiThinking
                        ? 'Calculando materiales...'
                        : 'Ej: Instalar 3 tomas y 1 ventilador...',
                    hintStyle: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.black26,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: _isAiThinking ? Colors.grey[400] : Colors.amber,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black12, width: 2),
                ),
                child: IconButton(
                  iconSize: 32,
                  icon: _isAiThinking
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 3.5,
                          ),
                        )
                      : const Icon(Icons.arrow_forward, color: Colors.black),
                  onPressed: _isAiThinking
                      ? null
                      : () async {
                          if (_controller.text.isNotEmpty) {
                            setState(() => _isAiThinking = true);
                            await ref
                                .read(presupuestoProvider.notifier)
                                .procesarTrabajoConIA(_controller.text);
                            if (mounted) {
                              setState(() => _isAiThinking = false);
                              _controller.clear();
                            }
                          }
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _BotonHerramienta(
                icono: Icons.camera_alt,
                texto: 'FOTO',
                alPresionar: () => debugPrint("📸 Foto"),
              ),
              _BotonHerramienta(
                icono: Icons.mic,
                texto: 'AUDIO',
                alPresionar: () => debugPrint("🎤 Audio"),
              ),
              _BotonHerramienta(
                icono: Icons.share,
                texto: 'ENVIAR',
                alPresionar: _compartirPresupuesto,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BotonHerramienta extends StatelessWidget {
  final IconData icono;
  final String texto;
  final VoidCallback alPresionar;

  const _BotonHerramienta({
    required this.icono,
    required this.texto,
    required this.alPresionar,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 3,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.black12, width: 2),
        ),
      ),
      onPressed: alPresionar,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 36, color: Colors.black87),
          const SizedBox(height: 6),
          Text(
            texto,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
