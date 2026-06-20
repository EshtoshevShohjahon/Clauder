import 'package:flutter/material.dart';
import 'package:avtoassist/utils/app_theme.dart';

class AddOilChangeScreen extends StatefulWidget {
  final int vehicleId;

  const AddOilChangeScreen({super.key, required this.vehicleId});

  @override
  State<AddOilChangeScreen> createState() => _AddOilChangeScreenState();
}

class _AddOilChangeScreenState extends State<AddOilChangeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oilTypeController = TextEditingController();
  final _oilBrandController = TextEditingController();
  final _mileageController = TextEditingController();
  final _nextMileageController = TextEditingController();
  final _locationController = TextEditingController();
  final _workshopController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();

  final List<String> _commonOilTypes = [
    '5W-30',
    '5W-40',
    '10W-40',
    '15W-40',
    '0W-20',
    '0W-30',
  ];

  @override
  void dispose() {
    _oilTypeController.dispose();
    _oilBrandController.dispose();
    _mileageController.dispose();
    _nextMileageController.dispose();
    _locationController.dispose();
    _workshopController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveOilChange() async {
    if (!_formKey.currentState!.validate()) return;

    // TODO: Save to API
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Moy almashtirish qo\'shildi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moy almashtirish qo\'shish'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Oil type
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Moy turi *',
                  prefixIcon: Icon(Icons.oil_barrel),
                ),
                items: _commonOilTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  _oilTypeController.text = value ?? '';
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Moy turini tanlang';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Oil brand
              TextFormField(
                controller: _oilBrandController,
                decoration: const InputDecoration(
                  labelText: 'Moy markasi (ixtiyoriy)',
                  hintText: 'Shell, Mobil, Castrol...',
                  prefixIcon: Icon(Icons.branding_watermark),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              
              // Current mileage
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
              const SizedBox(height: 16),
              
              // Next change mileage
              TextFormField(
                controller: _nextMileageController,
                decoration: const InputDecoration(
                  labelText: 'Keyingi almashtirish (ixtiyoriy)',
                  hintText: '55000',
                  prefixIcon: Icon(Icons.event),
                  suffixText: 'km',
                  helperText: 'Eslatma uchun (odatda +10,000 km)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              
              // Date
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Sana *',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
                    style: AppTheme.bodyLarge,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Manzil (ixtiyoriy)',
                  hintText: 'Yunusobod tumani',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),
              
              // Workshop
              TextFormField(
                controller: _workshopController,
                decoration: const InputDecoration(
                  labelText: 'Ustaxona nomi (ixtiyoriy)',
                  hintText: 'AvtoServis №1',
                  prefixIcon: Icon(Icons.store),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              
              // Price
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Narx (ixtiyoriy)',
                  hintText: '250000',
                  prefixIcon: Icon(Icons.attach_money),
                  suffixText: 'so\'m',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              
              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Izoh (ixtiyoriy)',
                  hintText: 'Qo\'shimcha ma\'lumotlar...',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _saveOilChange,
                child: const Text('Saqlash'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
