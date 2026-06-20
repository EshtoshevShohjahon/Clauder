import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:avtoassist/providers/locale_provider.dart';
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
    final loc = context.read<LocaleProvider>();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.t('oil_change_added'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('add_oil_change')),
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
                decoration: InputDecoration(
                  labelText: loc.t('oil_type_required'),
                  prefixIcon: const Icon(Icons.oil_barrel),
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
                    return loc.t('choose_oil_type');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Oil brand
              TextFormField(
                controller: _oilBrandController,
                decoration: InputDecoration(
                  labelText: loc.t('oil_brand_optional'),
                  hintText: 'Shell, Mobil, Castrol...',
                  prefixIcon: const Icon(Icons.branding_watermark),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              
              // Current mileage
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
              const SizedBox(height: 16),
              
              // Next change mileage
              TextFormField(
                controller: _nextMileageController,
                decoration: InputDecoration(
                  labelText: loc.t('next_change_optional'),
                  hintText: '55000',
                  prefixIcon: const Icon(Icons.event),
                  suffixText: 'km',
                  helperText: loc.t('next_change_helper'),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              
              // Date
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: loc.t('date_required'),
                    prefixIcon: const Icon(Icons.calendar_today),
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
                decoration: InputDecoration(
                  labelText: loc.t('address_optional'),
                  hintText: 'Yunusobod',
                  prefixIcon: const Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),
              
              // Workshop
              TextFormField(
                controller: _workshopController,
                decoration: InputDecoration(
                  labelText: loc.t('workshop_optional'),
                  hintText: 'AvtoServis',
                  prefixIcon: const Icon(Icons.store),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              
              // Price
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: loc.t('price_optional'),
                  hintText: '250000',
                  prefixIcon: const Icon(Icons.attach_money),
                  suffixText: loc.t('sum_unit'),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              
              // Notes
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: loc.t('note_optional'),
                  hintText: loc.t('note_hint'),
                  prefixIcon: const Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _saveOilChange,
                child: Text(loc.t('save')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
