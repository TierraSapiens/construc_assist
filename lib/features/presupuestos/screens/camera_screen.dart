import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    // Busca las cámaras disponibles en el celular
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      _controller = CameraController(
        cameras![0],
        ResolutionPreset.high,
        enableAudio: false, // Por ahora sin grabar audio durante la foto
      );

      await _controller!.initialize();
      if (!mounted) return;

      setState(() {
        _isReady = true;
      });
    }
  }

  @override
  void dispose() {
    // Apagamos la cámara al salir para no gastar batería
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _tomarFoto() async {
    if (!_controller!.value.isInitialized) return;

    try {
      // Captura la foto
      final image = await _controller!.takePicture();
      if (!mounted) return;

      Navigator.pop(context, image.path);
    } catch (e) {
      debugPrint('Error al tomar la foto: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Tomar Foto de Obra'),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: CameraPreview(_controller!)),
          // foto boton grande abajo en el centro
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: FloatingActionButton.large(
                backgroundColor: Colors.amber,
                onPressed: _tomarFoto,
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.black,
                  size: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
