import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:motoriders_app/utils/app_colors.dart';

class RadarMapScreen extends StatefulWidget {
  const RadarMapScreen({Key? key}) : super(key: key);

  @override
  State<RadarMapScreen> createState() => _RadarMapScreenState();
}

class _RadarMapScreenState extends State<RadarMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Location _location = Location();
  
  // Ubicación por defecto (CDMX) por si falla el GPS al inicio
  static const CameraPosition _kDefaultLocation = CameraPosition(
    target: LatLng(19.4326, -99.1332),
    zoom: 14.4746,
  );

  bool _isLoading = true;
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndLocate();
  }

  // ✅ FUNCIÓN SEGURA: Verifica permisos y obtiene ubicación
  Future<void> _checkPermissionsAndLocate() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
    }

    // Obtener ubicación actual
    try {
      final locationData = await _location.getLocation();
      
      // 🛑 PROTECCIÓN CRÍTICA: Si el usuario cambió de pantalla, detenemos aquí
      if (!mounted) return;

      setState(() {
        _currentPosition = LatLng(locationData.latitude!, locationData.longitude!);
        _isLoading = false;
      });

      // Mover cámara si ya está listo el mapa
      final GoogleMapController controller = await _controller.future;
      // 🛑 OTRA PROTECCIÓN ANTES DE USAR CONTROLLER
      if (!mounted) return;
      
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentPosition!,
          zoom: 16,
        ),
      ));
    } catch (e) {
      print("Error obteniendo ubicación: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ✅ FUNCIÓN QUE CAUSABA EL CRASH (CORREGIDA)
  Future<void> _goToMe() async {
    try {
      final GoogleMapController controller = await _controller.future;
      final locationData = await _location.getLocation();

      // 🛑 ESTO ES LO QUE FALTABA: Verificar si el widget sigue vivo
      if (!mounted) return;

      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(locationData.latitude!, locationData.longitude!),
          zoom: 17, // Zoom más cercano al centrar
        ),
      ));
    } catch (e) {
      print("Error al centrar mapa: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se pudo obtener tu ubicación")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // 1. EL MAPA
          GoogleMap(
            mapType: isDark ? MapType.hybrid : MapType.normal, // Cambia según tema
            initialCameraPosition: _kDefaultLocation,
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // Usamos nuestro propio botón
            zoomControlsEnabled: false,     // Quitamos controles feos por defecto
            onMapCreated: (GoogleMapController controller) {
              if (!_controller.isCompleted) {
                _controller.complete(controller);
              }
              // Si ya teníamos ubicación, movemos la cámara al crear el mapa
              if (_currentPosition != null) {
                controller.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
              }
            },
          ),

          // 2. INDICADOR DE CARGA (Si está buscando GPS)
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.teslaRed),
              ),
            ),

          // 3. BOTÓN FLOTANTE PERSONALIZADO (Abajo a la derecha)
          Positioned(
            bottom: 100, // Ajustado para no chocar con el menú inferior
            right: 20,
            child: FloatingActionButton(
              onPressed: _goToMe,
              backgroundColor: AppColors.teslaRed,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
          
          // 4. BARRA SUPERIOR FLOTANTE (Título)
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: isDark ? Colors.black87 : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.radar, color: AppColors.teslaRed),
                  const SizedBox(width: 10),
                  Text(
                    "Radar de Riders",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  const Text("LIVE", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}