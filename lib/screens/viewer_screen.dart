import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class ViewerScreen extends StatefulWidget {
  const ViewerScreen({super.key});

  @override
  State<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {
  PageController? _pageController;

  // Estado para rastrear la página y controlar la inicialización
  int _currentPage = 0;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Inicializamos el controlador solo la primera vez que se cargan los argumentos
    if (!_isInitialized) {
      final Map<String, dynamic> args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

      final int initialIndex = args['index'];

      // Sincronizamos el contador y el controlador con la foto seleccionada
      _currentPage = initialIndex;
      _pageController = PageController(initialPage: initialIndex);
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Recuperamos la lista de fotos de los argumentos
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final List<AssetEntity> assets = args['assets'];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        elevation: 0,
        // Título dinámico que muestra el progreso (Ej: Foto 5 de 80)
        title: Text(
          "Foto ${_currentPage + 1} de ${assets.length}",
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: assets.length,
        // Actualiza el contador en el AppBar al deslizar
        onPageChanged: (int index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          final AssetEntity asset = assets[index];

          return Center(
            // --- RETO A: ZOOM (InteractiveViewer) ---
            child: InteractiveViewer(
              clipBehavior: Clip.none, // Permite ampliar más allá de los bordes
              minScale: 1.0, // Escala normal
              maxScale: 4.0, // Zoom máximo de 4x
              child: AssetEntityImage(
                asset,
                isOriginal: true, // Carga la foto nítida
                fit: BoxFit.contain, // No recorta la imagen
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child:
                        Icon(Icons.broken_image, color: Colors.white, size: 50),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
