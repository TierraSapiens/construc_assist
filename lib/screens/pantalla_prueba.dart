import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/material_model.dart';

class PantallaPruebaMateriales extends StatelessWidget {
  final DataService _dataService = DataService();

  // Constructor corregido (sin el @class)
  PantallaPruebaMateriales({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo de Electricidad')),
      body: FutureBuilder<List<MaterialModel>>(
        future: _dataService
            .obtenerMaterialesElectricista(), // Llama al servicio
        builder: (context, snapshot) {
          // Si está cargando el archivo físico...
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Si hubo un error...
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(child: Text('No se encontraron materiales.'));
          }

          final materiales = snapshot.data!;

          // Si todo salió bien, dibuja la lista
          return ListView.builder(
            itemCount: materiales.length,
            itemBuilder: (context, index) {
              final material = materiales[index];
              return ListTile(
                leading: material.imagenUrl.isNotEmpty
                    ? Image.network(
                        material.imagenUrl,
                        width: 50,
                        errorBuilder: (c, o, s) => const Icon(Icons.build),
                      )
                    : const Icon(Icons.build),
                title: Text(material.nombreEs),
                subtitle: Text(
                  "ID: ${material.id} | Unidad: ${material.unidadBase}",
                ),
              );
            },
          );
        },
      ),
    );
  }
}
