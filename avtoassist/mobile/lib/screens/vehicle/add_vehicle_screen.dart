import 'package:flutter/material.dart';
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
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Avtomobil qo\'shildi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avtomobil qo\'shish'),
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
                decoration: const InputDecoration(
                  labelText: 'Marka *',
                  hintText: 'Masalan: Chevrolet',
                  prefixIcon: Icon(Icons.car_rental),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Markani kiriting';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Model *',
                  hintText: 'Masalan: Gentra',
                  prefixIcon: Icon(Icons.directions_car),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Modelni kiriting';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(
                  labelText: 'Yil (ixtiyoriy)',
                  hintText: '2020',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _plateController,
                decoration: const InputDecoration(
                  labelText: 'Davlat raqami (ixtiyoriy)',
                  hintText: '01 A 777 BA',
                  prefixIcon: Icon(Icons.confirmation_number),
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _mileageController,
                decoration: const InputDecoration(
                  labelText: 'Hozirgi kilometraj *',
                  hintText: '45000',
                  prefixIcon: Icon(Icons.speed),
                  suffixText: 'km',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kilometrajni kiriting';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Raqam kiriting';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _saveVehicle,
                child: const Text('Saqlash'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
