import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:avtoassist/providers/locale_provider.dart';
import 'package:avtoassist/utils/app_theme.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _plateController = TextEditingController();
  final _mileageController = TextEditingController();

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    // TODO: Save to API
    final loc = context.read<LocaleProvider>();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.t('vehicle_added'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('add_vehicle')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.directions_car,
                size: 80,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 32),
              
              TextFormField(
                controller: _brandController,
                decoration: InputDecoration(
                  labelText: loc.t('brand_required'),
                  hintText: '${loc.t('eg')} Chevrolet',
                  prefixIcon: const Icon(Icons.car_rental),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return loc.t('enter_brand');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _modelController,
                decoration: InputDecoration(
                  labelText: loc.t('model_required'),
                  hintText: '${loc.t('eg')} Gentra',
                  prefixIcon: const Icon(Icons.directions_car),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return loc.t('enter_model');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _yearController,
                decoration: InputDecoration(
                  labelText: loc.t('year_optional'),
                  hintText: '2020',
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _plateController,
                decoration: InputDecoration(
                  labelText: loc.t('plate_optional'),
                  hintText: '01 A 777 BA',
                  prefixIcon: const Icon(Icons.confirmation_number),
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _mileageController,
                decoration: InputDecoration(
                  labelText: loc.t('current_mileage_required'),
                  hintText: '45000',
                  prefixIcon: const Icon(Icons.speed),
                  suffixText: 'km',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return loc.t('enter_mileage');
                  }
                  if (int.tryParse(value) == null) {
                    return loc.t('enter_number');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _saveVehicle,
                child: Text(loc.t('save')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
