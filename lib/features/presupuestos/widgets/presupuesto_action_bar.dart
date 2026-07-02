import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../screens/camera_screen.dart';
import '../../../core/providers/presupuesto_provider.dart';
import '../screens/presupuesto_screen.dart';

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

  // =====================================================================
  // FUNCIONES DE LA CÁMARA E INTELIGENCIA ARTIFICIAL (GEMINI MULTIMODAL)
  // =====================================================================

  Future<String?> _preguntarInstruccion(BuildContext context) {
    final TextEditingController controlador = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          '¿Qué hacemos con la foto?',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controlador,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Ej: Calcular pintura para esta pared de 28m2...',
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.amber),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.amber),
            ),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controlador.text),
            child: const Text(
              'Enviar a IA',
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _enviarFotoAGemini(
    String rutaFoto,
    String instruccionUsuario,
  ) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      debugPrint("❌ ERROR: No se encontró GEMINI_API_KEY en el archivo .env");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No se encontró la API Key en el .env'),
          ),
        );
      }
      return;
    }

    try {
      debugPrint("🚀 Enviando foto e instrucciones a Gemini...");

      final bytesFoto = await File(rutaFoto).readAsBytes();

      final model = GenerativeModel(model: 'gemini-3.5-flash', apiKey: apiKey);

      final prompt = [
        Content.multi([
          TextPart(instruccionUsuario),
          DataPart('image/jpeg', bytesFoto),
        ]),
      ];

      final response = await model.generateContent(prompt);

      debugPrint("RESPUESTA DE LA IA:");
      debugPrint(response.text);

      if (response.text != null && mounted) {
        final textoActual = ref.read(presupuestoProvider).resumenIA ?? '';
        final textoNuevo =
            '$textoActual\n\n📸 Análisis de Foto:\n${response.text!}'.trim();

        ref.read(presupuestoProvider.notifier).actualizarResumen(textoNuevo);
        ref.read(vistaDetalladaProvider.notifier).state = false;
      }
    } catch (e) {
      debugPrint("❌ Ocurrió un error con la IA: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar la imagen: $e')),
        );
      }
    }
  }
  // =====================================================================

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
                alPresionar: () async {
                  final imagePath = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CameraScreen(),
                    ),
                  );

                  if (imagePath != null) {
                    if (!context.mounted) return;
                    final instruccion = await _preguntarInstruccion(context);
                    if (instruccion != null && instruccion.isNotEmpty) {
                      setState(() => _isAiThinking = true);
                      await _enviarFotoAGemini(imagePath, instruccion);
                      if (mounted) {
                        setState(() => _isAiThinking = false);
                      }
                    }
                  }
                },
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
