import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/providers/presupuesto_provider.dart';
import '../screens/presupuesto_screen.dart'; // Necesario para leer si estamos en Detalle o Resumen

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

  void _compartirPresupuesto() {
    final presupuesto = ref.read(presupuestoProvider);
    final esVistaDetallada = ref.read(vistaDetalladaProvider);

    StringBuffer texto = StringBuffer();
    texto.writeln('📋 *PRESUPUESTO de OBRA* 📋');
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
        backgroundColor: Colors.amber,
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
