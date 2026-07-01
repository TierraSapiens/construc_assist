import 'package:construc_assist/features/electrician/providers/repairs_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construc_assist/models/repairs_model.dart';

class GuiaInteractivaScreen extends ConsumerWidget {
  const GuiaInteractivaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repairsState = ref.watch(repairsProvider);
    final repairsNotifier = ref.read(repairsProvider.notifier);

    final isObraMode = true;

    final backgroundColor = const Color(0xFF1A1A1A);
    final cardColor = const Color(0xFF262626);
    final textColor = Colors.white;
    final accentColor = const Color(0xFFFFB300); // Ámbar vs Azul
    final borderColor = const Color(0xFF404040);

    if (repairsState.isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final tarjeta = repairsState.tarjetaActual;

    if (tarjeta == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Text(
            "No se pudo cargar la tarjeta de reparación.",
            style: TextStyle(color: textColor),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: Text(
          repairsState.reparacion?.categoria.toUpperCase() ?? "REPARACIÓN",
          style: TextStyle(
            color: accentColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        leading: repairsState.historial.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => repairsNotifier.retroceder(),
              )
            : null,
      ),
      body: Column(
        children: [
          _buildHeaderRiesgo(tarjeta.riesgo, isObraMode, accentColor),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    tarjeta.titulo,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    tarjeta.mensaje,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[400],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (tarjeta.multimedia != null)
                    _buildMultimediaPlaceholder(
                      tarjeta.multimedia!,
                      borderColor,
                      isObraMode,
                    ),

                  const SizedBox(height: 20),

                  if (tarjeta.items != null)
                    _buildDynamicList(
                      tarjeta.items!,
                      cardColor,
                      borderColor,
                      textColor,
                      isObraMode,
                      accentColor,
                    ),
                ],
              ),
            ),
          ),

          _buildActionArea(
            tarjeta,
            repairsNotifier,
            context,
            isObraMode,
            accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRiesgo(
    String? riesgo,
    bool isObraMode,
    Color accentColor,
  ) {
    if (riesgo == null) return const SizedBox.shrink();
    Color colorRiesgo = Colors.green;
    if (riesgo == "medio") colorRiesgo = Colors.orange;
    if (riesgo == "alto") colorRiesgo = Colors.red;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      color: colorRiesgo.withValues(alpha: 0.2),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 16, color: colorRiesgo),
          const SizedBox(width: 8),
          Text(
            "RIESGO ${riesgo.toUpperCase()}",
            style: TextStyle(
              color: colorRiesgo,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultimediaPlaceholder(
    List<Map<String, dynamic>> media,
    Color borderColor,
    bool isObraMode,
  ) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: isObraMode ? const Color(0xFF333333) : Colors.grey[200],
        borderRadius: BorderRadius.circular(isObraMode ? 0 : 8),
        border: Border.all(color: borderColor, width: isObraMode ? 2 : 1),
      ),
      child: Center(
        child: Icon(
          media.first['tipo'] == 'video'
              ? Icons.play_circle_outline
              : Icons.image_outlined,
          size: 48,
          color: isObraMode ? Colors.grey[500] : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildDynamicList(
    List<String> items,
    Color cardColor,
    Color borderColor,
    Color textColor,
    bool isObraMode,
    Color accentColor,
  ) {
    return Column(
      children: items.map((item) {
        return Card(
          color: cardColor,
          elevation: isObraMode ? 0 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isObraMode ? 0 : 6),
            side: BorderSide(color: borderColor, width: isObraMode ? 1.5 : 1),
          ),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Icon(
                  Icons.check_box_outline_blank,
                  color: accentColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(color: textColor, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionArea(
    TarjetaReparacionModel tarjeta,
    RepairsNotifier notifier,
    BuildContext context,
    bool isObraMode,
    Color accentColor,
  ) {
    final padding = const EdgeInsets.all(16.0);
    final background = isObraMode ? const Color(0xFF121212) : Colors.white;

    return Container(
      padding: padding,
      color: background,
      child: SafeArea(
        top: false,
        child: _buildButtonsByInteraction(
          tarjeta,
          notifier,
          context,
          isObraMode,
          accentColor,
        ),
      ),
    );
  }

  Widget _buildButtonsByInteraction(
    TarjetaReparacionModel tarjeta,
    RepairsNotifier notifier,
    BuildContext context,
    bool isObraMode,
    Color accentColor,
  ) {
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(isObraMode ? 0 : 8),
    );

    // CASO A: Interacción de tipo SI / NO
    if (tarjeta.tipoInteraccion == "si_no" && tarjeta.opciones != null) {
      final idSi = tarjeta.opciones!['si']!;
      final idNo = tarjeta.opciones!['no']!;

      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: buttonShape,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => notifier.avanzar(idNo),
              child: const Text(
                "NO",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isObraMode
                    ? accentColor
                    : const Color(0xFF4CAF50),
                foregroundColor: isObraMode ? Colors.black : Colors.white,
                shape: buttonShape,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: isObraMode ? 0 : 2,
              ),
              onPressed: () => notifier.avanzar(idSi),
              child: const Text(
                "SÍ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );
    }

    // CASO B: Interacción de tipo CONFIRMAR / CONTINUAR
    if (tarjeta.tipoInteraccion == "confirmar" && tarjeta.opciones != null) {
      final idSiguiente = tarjeta.opciones!['confirmar']!;

      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: isObraMode ? Colors.black : Colors.white,
          shape: buttonShape,
          padding: const EdgeInsets.symmetric(vertical: 16),
          minimumSize: const Size(double.infinity, 0),
        ),
        onPressed: () => notifier.avanzar(idSiguiente),
        child: const Text(
          "ENTENDIDO / CONTINUAR",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }

    // CASO C: Interacción de tipo FINALIZAR / DETENER
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: tarjeta.tipo == "fin" ? Colors.green : Colors.red,
        foregroundColor: Colors.white,
        shape: buttonShape,
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(double.infinity, 0),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Text(
        tarjeta.tipo == "fin" ? "FINALIZAR TAREA" : "SALIR DE LA GUÍA",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
