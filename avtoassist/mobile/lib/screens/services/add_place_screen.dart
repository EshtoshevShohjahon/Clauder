import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:avtoassist/providers/locale_provider.dart';
import 'package:avtoassist/providers/places_provider.dart';
import 'package:avtoassist/providers/auth_provider.dart';
import 'package:avtoassist/services/location_service.dart';
import 'package:avtoassist/services/offline_map_service.dart';
import 'package:avtoassist/utils/app_theme.dart';

/// Xizmat ko'rsatuvchi o'z manzilini xaritada belgilab, ma'lumot kiritadi
class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mapController = MapController();
  final _locationService = LocationService();
  final _mapService = OfflineMapService();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phone2Controller = TextEditingController();
  final _hoursController = TextEditingController();

  // Xizmat turlari (place type)
  final List<String> _types = const [
    'gas_station',
    'auto_parts',
    'workshop',
    'car_wash',
    'tire_service',
    'evacuator',
  ];
  late String _type;

  LatLng _center = OfflineMapService.tashkentCenter;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _type = _defaultType();
    _initLocation();
  }

  // Provider serviceType -> place type
  String _defaultType() {
    final st = context.read<AuthProvider>().user?.serviceType;
    switch (st) {
      case 'fuel_delivery':
        return 'gas_station';
      case 'car_wash':
        return 'car_wash';
      case 'evacuator':
        return 'evacuator';
      case 'mechanic':
        return 'workshop';
      default:
        return 'workshop';
    }
  }

  Future<void> _initLocation() async {
    final pos = await _locationService.getCurrentPosition();
    if (pos != null && mounted) {
      setState(() => _center = LatLng(pos.latitude, pos.longitude));
      _mapController.move(_center, 16);
    }
  }

  String _typeKey(String t) {
    switch (t) {
      case 'gas_station':
        return 'service_gas_stations';
      case 'auto_parts':
        return 'service_auto_parts';
      case 'workshop':
        return 'service_workshop';
      case 'car_wash':
        return 'service_car_wash';
      case 'tire_service':
        return 'service_tire_service';
      case 'evacuator':
        return 'service_evacuator';
      default:
        return 'service_workshop';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _phone2Controller.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _save(LocaleProvider loc) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final placesProvider = context.read<PlacesProvider>();
    final ok = await placesProvider.createPlace(
      name: _nameController.text.trim(),
      type: _type,
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      phone2: _phone2Controller.text.trim(),
      latitude: _center.latitude,
      longitude: _center.longitude,
      workingHours: _hoursController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.t('place_added'))),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(placesProvider.error ?? 'Xato'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(loc.t('add_my_place'))),
      body: Column(
        children: [
          // Xarita (markaziy pin = tanlangan joylashuv)
          SizedBox(
            height: 260,
            child: Stack(
              alignment: Alignment.center,
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom: 15,
                    onPositionChanged: (pos, hasGesture) {
                      if (pos.center != null) _center = pos.center!;
                    },
                  ),
                  children: [_mapService.getTileLayer()],
                ),
                // Markaziy pin
                const Padding(
                  padding: EdgeInsets.only(bottom: 28),
                  child: Icon(Icons.location_on,
                      size: 44, color: AppTheme.primaryColor),
                ),
                // Mening joylashuvim tugmasi
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: FloatingActionButton.small(
                    onPressed: _initLocation,
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
          ),

          // Forma
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(loc.t('map_pick_hint'), style: AppTheme.bodySmall),
                    const SizedBox(height: 16),

                    // Tur tanlash
                    DropdownButtonFormField<String>(
                      value: _type,
                      decoration: InputDecoration(
                        labelText: loc.t('choose_service_type'),
                        prefixIcon: const Icon(Icons.category),
                      ),
                      items: _types.map((t) {
                        return DropdownMenuItem(
                          value: t,
                          child: Text(loc.t(_typeKey(t))),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _type = v ?? _type),
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: loc.t('place_name'),
                        prefixIcon: const Icon(Icons.store),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? loc.t('place_name') : null,
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: loc.t('address'),
                        prefixIcon: const Icon(Icons.location_on),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? loc.t('address') : null,
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: loc.t('phone_number'),
                        hintText: '+998901234567',
                        prefixIcon: const Icon(Icons.phone),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? loc.t('enter_phone') : null,
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _phone2Controller,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: loc.t('phone2_optional'),
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _hoursController,
                      decoration: InputDecoration(
                        labelText: loc.t('working_hours'),
                        hintText: '09:00 - 21:00',
                        prefixIcon: const Icon(Icons.access_time),
                      ),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _saving ? null : () => _save(loc),
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(loc.t('save')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
