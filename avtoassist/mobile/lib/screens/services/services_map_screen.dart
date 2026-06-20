import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:avtoassist/models/service_place_model.dart';
import 'package:avtoassist/providers/places_provider.dart';
import 'package:avtoassist/services/location_service.dart';
import 'package:avtoassist/services/offline_map_service.dart';
import 'package:avtoassist/services/phone_service.dart';
import 'package:avtoassist/utils/app_theme.dart';

/// Xizmat ko'rsatuvchilar xaritasi
/// 
/// OFFLINE ishlaydi:
/// - OpenStreetMap tile'lari cache qilinadi
/// - GPS satellite orqali joylashuv
/// - Service places SharedPreferences'da
class ServicesMapScreen extends StatefulWidget {
  final String? serviceType;
  final String title;

  const ServicesMapScreen({
    super.key,
    this.serviceType,
    required this.title,
  });

  @override
  State<ServicesMapScreen> createState() => _ServicesMapScreenState();
}

class _ServicesMapScreenState extends State<ServicesMapScreen> {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();
  final OfflineMapService _mapService = OfflineMapService();
  final PhoneService _phoneService = PhoneService();

  LatLng? _userLocation;
  bool _isLoadingLocation = false;
  ServicePlace? _selectedPlace;
  bool _showList = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final placesProvider = context.read<PlacesProvider>();
    
    // Joylashuvni olish
    setState(() => _isLoadingLocation = true);
    
    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null && mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
        });
        
        // Yaqin atrofdagi xizmat ko'rsatuvchilarni yuklash
        await placesProvider.loadNearbyPlaces(
          latitude: position.latitude,
          longitude: position.longitude,
          type: widget.serviceType,
          radius: 10000, // 10 km
        );
        
        // Xaritani markazga keltirish
        _mapController.move(_userLocation!, 14.0);
      }
    } catch (e) {
      // Joylashuv xatolik - barcha places'ni yuklash
      await placesProvider.loadPlaces(type: widget.serviceType);
    }
    
    setState(() => _isLoadingLocation = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          // Offline rejim indicator
          Consumer<PlacesProvider>(
            builder: (context, placesProvider, _) {
              if (placesProvider.isOfflineMode) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cloud_off, size: 16, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Offline rejim',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // View mode toggle
          IconButton(
            icon: Icon(_showList ? Icons.map : Icons.list),
            onPressed: () => setState(() => _showList = !_showList),
            tooltip: _showList ? 'Xaritada ko\'rish' : 'Ro\'yxatda ko\'rish',
          ),
        ],
      ),
      body: Consumer<PlacesProvider>(
        builder: (context, placesProvider, _) {
          if (placesProvider.isLoading && placesProvider.places.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (placesProvider.error != null && placesProvider.places.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Ma\'lumot yuklanmadi',
                    style: AppTheme.heading3,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    placesProvider.error!,
                    style: AppTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Qayta urinish'),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              // Xarita yoki ro'yxat
              _showList 
                  ? _buildListView(placesProvider.places)
                  : _buildMapView(placesProvider.places),
              
              // Selected place bottom sheet
              if (_selectedPlace != null)
                _buildPlaceDetailsSheet(_selectedPlace!),
            ],
          );
        },
      ),
      floatingActionButton: _userLocation != null && !_showList
          ? FloatingActionButton(
              onPressed: () {
                _mapController.move(_userLocation!, 14.0);
              },
              child: const Icon(Icons.my_location),
            )
          : null,
    );
  }

  Widget _buildMapView(List<ServicePlace> places) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _userLocation ?? OfflineMapService.tashkentCenter,
        initialZoom: OfflineMapService.defaultZoom,
        onTap: (_, __) => setState(() => _selectedPlace = null),
      ),
      children: [
        // OpenStreetMap tiles (offline cache)
        _mapService.getTileLayer(),
        
        // Markers
        MarkerLayer(
          markers: [
            // User location marker
            if (_userLocation != null)
              _mapService.createUserMarker(_userLocation!),
            
            // Service places markers
            ...places.map((place) => _mapService.createServiceMarker(
              position: place.location,
              serviceType: place.type,
              onTap: () => setState(() => _selectedPlace = place),
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildListView(List<ServicePlace> places) {
    if (places.isEmpty) {
      return const Center(
        child: Text('Xizmat ko\'rsatuvchilar topilmadi'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: places.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final place = places[index];
        return _buildPlaceCard(place);
      },
    );
  }

  Widget _buildPlaceCard(ServicePlace place) {
    return Card(
      child: InkWell(
        onTap: () => setState(() {
          _selectedPlace = place;
          _showList = false;
          _mapController.move(place.location, 16.0);
        }),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(place.name, style: AppTheme.heading3),
                        const SizedBox(height: 4),
                        Text(place.typeName, style: AppTheme.caption),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: AppTheme.accentColor),
                      const SizedBox(width: 4),
                      Text(
                        place.rating.toStringAsFixed(1),
                        style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(place.address, style: AppTheme.bodySmall),
                  ),
                ],
              ),
              if (place.distance != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.directions, size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(place.formattedDistance, style: AppTheme.bodySmall),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _phoneService.makePhoneCall(place.phone),
                      icon: const Icon(Icons.phone, size: 18),
                      label: const Text('Qo\'ng\'iroq'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedPlace = place;
                          _showList = false;
                          _mapController.move(place.location, 16.0);
                        });
                      },
                      icon: const Icon(Icons.map, size: 18),
                      label: const Text('Xaritada'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceDetailsSheet(ServicePlace place) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(place.name, style: AppTheme.heading3),
                        const SizedBox(height: 4),
                        Text(place.typeName, style: AppTheme.caption),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _selectedPlace = null),
                  ),
                ],
              ),
              const Divider(),
              _buildInfoRow(Icons.location_on, place.address),
              if (place.workingHours != null)
                _buildInfoRow(Icons.access_time, place.workingHours!),
              if (place.distance != null)
                _buildInfoRow(Icons.directions, place.formattedDistance),
              Row(
                children: [
                  const Icon(Icons.star, size: 20, color: AppTheme.accentColor),
                  const SizedBox(width: 8),
                  Text(
                    place.rating.toStringAsFixed(1),
                    style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await _phoneService.showPhoneCallDialog(
                          context: context,
                          primaryPhone: place.phone,
                          secondaryPhone: place.phone2,
                          placeName: place.name,
                        );
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Qo\'ng\'iroq qilish'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: AppTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
