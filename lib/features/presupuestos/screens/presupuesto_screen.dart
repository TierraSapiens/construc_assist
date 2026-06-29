import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/presupuesto_provider.dart';

// --- NUEVO: ESTE ES EL INTERRUPTOR PARA CAMBIAR DE LENTE (A o B) ---
final vistaDetalladaProvider = StateProvider<bool>((ref) => true);

class PresupuestoScreen extends ConsumerWidget {
  const PresupuestoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presupuesto = ref.watch(presupuestoProvider);
    // Leemos en qué modo estamos (True = A, False = B)
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
          // ZONA SUPERIOR: La lista o el resumen
          Expanded(
            child: presupuesto.items.isEmpty
                ? const Center(
                    child: Text(
                      'El presupuesto está vacío.\nAgregá ítems o usá la I.A.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      // --- NUEVA BOTONERA A / B ---
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
                                onPressed: () {
                                  // Cambiamos a la Vista A
                                  ref
                                          .read(vistaDetalladaProvider.notifier)
                                          .state =
                                      true;
                                },
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
                                onPressed: () {
                                  // Cambiamos a la Vista B
                                  ref
                                          .read(vistaDetalladaProvider.notifier)
                                          .state =
                                      false;
                                },
                                child: const Text(
                                  'RESUMEN',
                                  style: TextStyle(fontWeight: FontWeight.w900),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // --- CONTENIDO SEGÚN EL LENTE ELEGIDO ---
                      Expanded(
                        child: esVistaDetallada
                            // VISTA A: LA LISTA DE SIEMPRE
                            ? ListView.builder(
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 0,
                                          ),
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
                                            onPressed: () {
                                              ref
                                                  .read(
                                                    presupuestoProvider
                                                        .notifier,
                                                  )
                                                  .eliminarItem(item.id);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              )
                            // VISTA B: LA NUEVA TARJETA GLOBAL
                            // VISTA B: LA NUEVA TARJETA GLOBAL (Ahora con Scroll para evitar desbordes)
                            : SingleChildScrollView(
                                child: _VistaResumida(
                                  subtotal: presupuesto.subtotal,
                                ),
                              ),
                      ),
                    ],
                  ),
          ),

          // ZONA INFERIOR: Los Totales (La caja registradora)
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
                _FilaTotal(titulo: 'Subtotal:', valor: presupuesto.subtotal),
                InkWell(
                  onTap: () {
                    mostrarAjusteGanancia(
                      context,
                      ref,
                      presupuesto.porcentajeGananciaExtra,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: _FilaTotal(
                      titulo:
                          'Ganancia Extra (${presupuesto.porcentajeGananciaExtra.toInt()}%): ✏️',
                      valor: presupuesto.montoGanancia,
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

// --- NUEVO WIDGET: EL DISEÑO DE LA VISTA RESUMIDA (B) ---
class _VistaResumida extends StatelessWidget {
  final double subtotal;

  const _VistaResumida({required this.subtotal});

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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Se adapta al texto
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.assignment_turned_in, color: Colors.amber, size: 36),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'SERVICIOS DE OBRA',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Ejecución de trabajos según lo presupuestado. Este importe incluye la provisión completa de materiales, insumos y la mano de obra especializada necesaria para la finalización de las tareas solicitadas.',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 15,
                height: 1.5, // Le da aire a las líneas del texto
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(color: Colors.black26, thickness: 2),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subtotal global:',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '\$${subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ],
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
              color: Colors.black,
              fontSize: esTotal ? 18 : 14,
              fontWeight: esTotal ? FontWeight.w900 : FontWeight.bold,
            ),
          ),
          Text(
            '\$${valor.toStringAsFixed(2)}',
            style: TextStyle(
              color: esTotal
                  ? Colors.green[700]
                  : Colors
                        .black, // Le dimos un toque verde al total final para resaltar
              fontSize: esTotal ? 22 : 14,
              fontWeight: esTotal ? FontWeight.w900 : FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// --- HERRAMIENTA: PANEL EMERGENTE DE GANANCIA ---
void mostrarAjusteGanancia(
  BuildContext context,
  WidgetRef ref,
  double gananciaActual,
) {
  double valorTemporal = gananciaActual;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateBottomSheet) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ajustar Ganancia Extra',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${valorTemporal.toInt()}%',
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: Colors.amber,
                  ),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 16.0,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 18.0,
                    ),
                  ),
                  child: Slider(
                    value: valorTemporal,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    activeColor: Colors.amber,
                    inactiveColor: Colors.grey[300],
                    onChanged: (nuevoValor) {
                      setStateBottomSheet(() {
                        valorTemporal = nuevoValor;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      ref
                          .read(presupuestoProvider.notifier)
                          .actualizarGanancia(valorTemporal);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'APLICAR GANANCIA',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      );
    },
  );
}

// --- FÁBRICA DE LA SÚPER CAJA DE HERRAMIENTAS (PUNTO 8) ---
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

  // --- NUEVO CABLEADO: LA FUNCIÓN DE COMPARTIR ---
  void _compartirPresupuesto() {
    // Leemos los datos actuales
    final presupuesto = ref.read(presupuestoProvider);
    final esVistaDetallada = ref.read(vistaDetalladaProvider);

    // Si no hay nada, no hacemos nada
    if (presupuesto.items.isEmpty) return;

    // Empezamos a redactar el mensaje de WhatsApp usando un StringBuffer
    StringBuffer texto = StringBuffer();
    texto.writeln('📋 *PRESUPUESTO DE OBRA* 📋');
    texto.writeln('');

    if (esVistaDetallada) {
      // SI ESTÁ EN MODO "A": Mandamos todos los materiales y mano de obra
      texto.writeln('🛠️ *Detalle de ítems:*');
      for (var item in presupuesto.items) {
        texto.writeln('▪️ ${item.nombre}');
        texto.writeln(
          '   ${item.cantidad} ${item.unidad} x \$${item.precioUnitario} = \$${item.total.toStringAsFixed(2)}',
        );
      }
    } else {
      // SI ESTÁ EN MODO "B": Mandamos el texto profesional y cerrado
      texto.writeln('✅ *SERVICIOS DE OBRA*');
      texto.writeln(
        'Ejecución de trabajos según lo presupuestado. Incluye la provisión completa de materiales, insumos y la mano de obra especializada necesaria.',
      );
    }

    texto.writeln('');
    texto.writeln('------------------------');
    texto.writeln('Subtotal: \$${presupuesto.subtotal.toStringAsFixed(2)}');

    // Si agregaste ganancia extra, la mostramos sutilmente como un "Ajuste"
    if (presupuesto.montoGanancia > 0) {
      texto.writeln(
        'Ajuste: \$${presupuesto.montoGanancia.toStringAsFixed(2)}',
      );
    }

    texto.writeln(
      '💰 *TOTAL FINAL: \$${presupuesto.totalFinal.toStringAsFixed(2)}*',
    );
    texto.writeln('------------------------');

    // ¡Acá disparamos la ventana de compartir nativa del celular!
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
                            setState(() {
                              _isAiThinking = true;
                            });
                            await ref
                                .read(presupuestoProvider.notifier)
                                .procesarTrabajoConIA(_controller.text);
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _BotonHerramienta(
                icono: Icons.camera_alt,
                texto: 'FOTO',
                alPresionar: () {
                  debugPrint("📸 Botón CÁMARA presionado");
                },
              ),
              _BotonHerramienta(
                icono: Icons.mic,
                texto: 'AUDIO',
                alPresionar: () {
                  debugPrint("🎤 Botón MICRÓFONO presionado");
                },
              ),
              _BotonHerramienta(
                icono: Icons.share,
                texto: 'ENVIAR',
                // --- ACÁ CONECTAMOS EL CABLE AL BOTÓN ---
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
