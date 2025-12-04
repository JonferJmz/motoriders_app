
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:motoriders_app/models/club_model.dart';
import 'package:motoriders_app/services/club_service.dart';
import 'package:motoriders_app/services/places_service.dart';

class RadarMapScreen extends StatefulWidget {
  const RadarMapScreen({super.key});

  @override
  State<RadarMapScreen> createState() => _RadarMapScreenState();
}

class _RadarMapScreenState extends State<RadarMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final ClubService _clubService = ClubService();
  final PlacesService _placesService = PlacesService("AIzaSyAPng8w_Jn6xxdFHdSI-E_Wy9L33mL80WM");

  String? _mapStyle;
  Set<Marker> _clubMarkers = {};
  Set<Marker> _placeMarkers = {};

  static const CameraPosition _kDefaultLocation = CameraPosition(
    target: LatLng(20.659698, -103.349609),
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _loadClubMarkers();
    _goToMe(); 
  }

  Future<void> _loadMapStyle() async {
    try {
      _mapStyle = await rootBundle.loadString('lib/utils/map_style.json');
    } catch (e) {
      print("Error cargando el estilo del mapa: $e");
    }
  }

  Future<void> _loadClubMarkers() async {
    final clubs = await _clubService.getMyClubs();
    setState(() {
      _clubMarkers = clubs.map((club) {
        return Marker(
          markerId: MarkerId('club_${club.id}'),
          position: LatLng(club.latitude, club.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: club.name,
            snippet: club.description,
          ),
        );
      }).toSet();
    });
  }

  Future<void> _findNearbyPlaces(String placeType) async {
    try {
      Position position = await _determinePosition();
      final places = await _placesService.findPlaces(position.latitude, position.longitude, placeType);
      final newMarkers = places.map((place) {
        return Marker(
          markerId: MarkerId(place.placeId),
          position: LatLng(place.latitude, place.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(title: place.name),
        );
      }).toSet();
      setState(() {
        _placeMarkers = newMarkers;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error buscando lugares: $e")),
      );
    }
  }

  Future<void> _goToMe() async {
    try {
      final position = await _determinePosition();
      final GoogleMapController controller = await _controller.future;
      await controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14.5,
        ),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error obteniendo ubicación: $e")),
      );
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Los servicios de ubicación están desactivados.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Los permisos de ubicación fueron denegados');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Los permisos de ubicación están permanentemente denegados, no podemos solicitar la ubicación.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _onMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);
    if (_mapStyle != null) {
      await controller.setMapStyle(_mapStyle);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return const Center(child: Text("Google Maps solo para Android."));
    }

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _kDefaultLocation,
            onMapCreated: _onMapCreated,
            markers: {..._clubMarkers, ..._placeMarkers},
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            padding: const EdgeInsets.only(top: 120, bottom: 20),
          ),
          _buildHeader(),
          _buildFilterChips(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToMe,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
          ),
        ),
        child: const Text(
          'Radar',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 50,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          children: [
            _buildFilterChip('Talleres', Icons.build, () => _findNearbyPlaces('car_repair')),
            _buildFilterChip('Refacciones', Icons.settings_input_component, () => _findNearbyPlaces('car_repair')),
            _buildFilterChip('Gasolineras', Icons.local_gas_station, () => _findNearbyPlaces('gas_station')),
            _buildFilterChip('Eventos', Icons.event, () { /* Proximamente */ }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: RawChip(
        onPressed: onPressed,
        label: Text(label),
        labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        avatar: Icon(icon, color: Colors.white70, size: 20),
        backgroundColor: Colors.black.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
      ),
    );
  }
}
