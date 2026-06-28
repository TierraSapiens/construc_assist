import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/presupuesto_provider.dart';

class PresupuestoScreen extends ConsumerWidget {
  const PresupuestoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presupuesto = ref.watch(presupuestoProvider);

    return Scaffold(
      backgroundColor: Colors.white, // ☀️ MODO OBRA: Fondo blanco puro
      appBar: AppBar(
        backgroundColor: Colors.amber, // ☀️ MODO OBRA: Techo amarillo
        title: const Text(
          'Presupuesto de Obra',
          style: TextStyle(
            color: Colors.black, // Letra negra
            fontWeight: FontWeight.w900, // Letra extra gruesa
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ), // Flecha de volver negra
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
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight:
                            FontWeight.bold, // ☀️ Letras visibles sin datos
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: presupuesto.items.length,
                    itemBuilder: (context, index) {
                      final item = presupuesto.items[index];
                      return Card(
                        color: Colors.white, // Fondo de la tarjeta blanco
                        elevation: 2, // Sombra suave para despegarla del fondo
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            color: Colors.black12,
                            width: 1,
                          ), // Borde gris sutil
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 0,
                          ),
                          title: Text(
                            item.nombre,
                            style: const TextStyle(
                              color: Colors.black, // ☀️ MODO OBRA
                              fontWeight: FontWeight.w900, // Extra negro
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
                                  fontWeight: FontWeight.w900, // Extra negro
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
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Colors.amber,
                  width: 4,
                ), // ☀️ MODO OBRA: Línea amarilla gruesa arriba
              ),
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
                const Divider(color: Colors.black26), // Divisor más oscuro
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
              color: Colors.black, // ☀️ MODO OBRA
              fontSize: esTotal ? 18 : 14,
              fontWeight: esTotal ? FontWeight.w900 : FontWeight.bold,
            ),
          ),
          Text(
            '\$${valor.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.black, // ☀️ MODO OBRA
              fontSize: esTotal ? 20 : 14,
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
                // El número gigante que cambia al mover la barra
                Text(
                  '${valorTemporal.toInt()}%',
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: Colors.amber,
                  ),
                ),
                // La barra deslizable (apta para guantes)
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
                    max: 100, // Podés subirlo a 200 si hace falta
                    divisions: 20, // Salta de a 5% (5, 10, 15...)
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
                // Botón gigante para confirmar
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
                      // Acá le avisamos al Provider (el motor) que guarde el nuevo número
                      ref
                          .read(presupuestoProvider.notifier)
                          .actualizarGanancia(valorTemporal);
                      Navigator.pop(context); // Cierra el panel
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

  @override
  Widget build(BuildContext context) {
    return Container(
      // Fondo gris clarito tipo chapa para que resalte la zona de control
      color: Colors.grey[200],
      padding: const EdgeInsets.only(
        left: 12.0,
        right: 12.0,
        top: 16.0,
        bottom: 24.0, // Más espacio abajo para los dedos/guantes
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Que la caja ocupe solo lo necesario
        children: [
          // FILA 1: La caja de texto y el botón de enviar (Lo que ya teníamos)
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
                    fillColor: Colors.white, // Fondo blanco para que contraste
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
                  border: Border.all(
                    color: Colors.black12,
                    width: 2,
                  ), // Borde resistente
                ),
                child: IconButton(
                  iconSize: 32, // ☀️ MODO OBRA: Botón de flecha más grande
                  icon: _isAiThinking
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 3.5, // Ruedita más gruesa
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

          const SizedBox(
            height: 16,
          ), // Espacio entre el texto y los botones nuevos
          // FILA 2: LOS BOTONES GIGANTES DE HERRAMIENTAS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _BotonHerramienta(
                icono: Icons.camera_alt,
                texto: 'FOTO',
                alPresionar: () {
                  debugPrint("📸 Botón CÁMARA presionado (Próximamente)");
                },
              ),
              _BotonHerramienta(
                icono: Icons.mic,
                texto: 'AUDIO',
                alPresionar: () {
                  debugPrint("🎤 Botón MICRÓFONO presionado (Próximamente)");
                },
              ),
              _BotonHerramienta(
                icono: Icons
                    .share, // Ícono temporal hasta que pongamos el de WhatsApp
                texto: 'ENVIAR',
                alPresionar: () {
                  debugPrint("📤 Botón ENVIAR presionado (Próximamente)");
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- MINI MOLDURA PARA FABRICAR BOTONES GIGANTES ---
// Usamos esto para no repetir código 3 veces.
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
        backgroundColor: Colors.white, // Fondo del botón
        foregroundColor: Colors.black, // Color cuando lo apretás
        elevation: 3, // Sombrita
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Colors.black12,
            width: 2,
          ), // Borde fuerte
        ),
      ),
      onPressed: alPresionar,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 36, color: Colors.black87), // Ícono GIGANTE
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
