import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'viewer_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<AssetEntity> _assets = [];

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final PermissionState ps = await PhotoManager.requestPermissionExtend();

      if (ps.isAuth || ps == PermissionState.limited) {
        final List<AssetPathEntity> albums =
            await PhotoManager.getAssetPathList(
          type: RequestType.image,
          onlyAll: true,
        );

        if (albums.isNotEmpty) {
          // Cargamos las primeras 80 fotos
          final List<AssetEntity> photos = await albums[0].getAssetListRange(
            start: 0,
            end: 80,
          );

          setState(() {
            _assets = photos;
            _isLoading = false;
          });
        } else {
          setState(() {
            _assets = [];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = "Acceso denegado. Revisa los ajustes del Samsung.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Galería Real"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, textAlign: TextAlign.center),
            ElevatedButton(
              onPressed: _loadPhotos,
              child: const Text("Reintentar"),
            )
          ],
        ),
      );
    }

    if (_assets.isEmpty) {
      return const Center(child: Text("No hay fotos para mostrar"));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _assets.length,
      itemBuilder: (context, index) {
        final AssetEntity entity = _assets[index];

        return GestureDetector(
          onTap: () {
            // ACTUALIZACIÓN CLAVE: Enviamos el Map con la lista y el índice
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ViewerScreen(),
                settings: RouteSettings(
                  arguments: {
                    'assets': _assets, // Pasamos toda la lista
                    'index': index, // Pasamos la posición de la foto tocada
                  },
                ),
              ),
            );
          },
          child: AssetEntityImage(
            entity,
            isOriginal: false, // Miniatura para el Grid
            thumbnailSize: const ThumbnailSize.square(250),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Center(child: Icon(Icons.error, color: Colors.red));
            },
          ),
        );
      },
    );
  }
}
