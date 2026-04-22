import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cafe.dart';
import '../models/city.dart';
import '../providers/cafe_provider.dart';
import '../providers/city_provider.dart';

class CafeDetailScreen extends StatefulWidget {
  final Cafe? cafe;

  const CafeDetailScreen({super.key, this.cafe});

  @override
  State<CafeDetailScreen> createState() => _CafeDetailScreenState();
}

class _CafeDetailScreenState extends State<CafeDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _phoneController;
  late TextEditingController _workingHoursController;

  List<City> _cities = [];
  int? _selectedCityId;
  bool _isActive = true;

  bool _isLoadingCities = true;
  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.cafe?.name ?? '');
    _addressController = TextEditingController(
      text: widget.cafe?.address ?? '',
    );
    _latitudeController = TextEditingController(
      text: widget.cafe?.latitude?.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: widget.cafe?.longitude?.toString() ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.cafe?.phoneNumber ?? '',
    );
    _workingHoursController = TextEditingController(
      text: widget.cafe?.workingHours ?? '',
    );

    _selectedCityId = widget.cafe?.cityId;
    _isActive = widget.cafe?.isActive ?? true;

    _loadCities();
  }

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF5EDE4),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.brown.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.brown.shade300),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFF8B5A3C), width: 1.6),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  Future<void> _loadCities() async {
    try {
      final cityProvider = context.read<CityProvider>();
      final result = await cityProvider.get();

      if (!mounted) return;

      setState(() {
        _cities = result.result;
        _isLoadingCities = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingCities = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load cities: $e')));
    }
  }

  String? _requiredValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  Future<void> _getCoordinatesFromAddress() async {
    if (_selectedCityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a city first')),
      );
      return;
    }

    final address = _addressController.text.trim();
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an address first')),
      );
      return;
    }

    try {
      final selectedCity = _cities.firstWhere((c) => c.id == _selectedCityId);
      final cityName = selectedCity.name ?? '';

      if (cityName.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selected city is invalid')),
        );
        return;
      }

      final provider = context.read<CafeProvider>();
      final data = await provider.geocode(address, cityName);

      if (!mounted) return;

      setState(() {
        _latitudeController.text = data['latitude'].toString();
        _longitudeController.text = data['longitude'].toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coordinates loaded successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error while loading coordinates: $e')),
      );
    }
  }

  String? _validateLatitude(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Latitude is required';
    }

    final lat = double.tryParse(value);
    if (lat == null) {
      return 'Latitude must be a valid number';
    }

    if (lat < -90 || lat > 90) {
      return 'Latitude must be between -90 and 90';
    }

    return null;
  }

  String? _validateLongitude(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Longitude is required';
    }

    final lng = double.tryParse(value);
    if (lng == null) {
      return 'Longitude must be a valid number';
    }

    if (lng < -180 || lng > 180) {
      return 'Longitude must be between -180 and 180';
    }

    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCityId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('City is required')));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final cafeProvider = context.read<CafeProvider>();

      final request = {
        "name": _nameController.text.trim(),
        "address": _addressController.text.trim(),
        "cityId": _selectedCityId,
        "latitude": double.parse(_latitudeController.text.trim()),
        "longitude": double.parse(_longitudeController.text.trim()),
        "phoneNumber": _phoneController.text.trim(),
        "workingHours": _workingHoursController.text.trim(),
        "isActive": _isActive,
      };

      if (widget.cafe == null) {
        await cafeProvider.insert(request);
      } else {
        await cafeProvider.update(widget.cafe!.id!, request);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.cafe == null
                ? 'Cafe added successfully'
                : 'Cafe updated successfully',
          ),
        ),
      );

      Navigator.of(context).pop('refresh');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save cafe: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _delete() async {
    if (widget.cafe?.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5EDE4),
          title: const Text('Delete cafe'),
          content: Text(
            'Are you sure you want to delete "${widget.cafe?.name ?? 'this cafe'}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.brown.shade700),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      final cafeProvider = context.read<CafeProvider>();
      await cafeProvider.delete(widget.cafe!.id!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cafe deleted successfully')),
      );

      Navigator.of(context).pop('refresh');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete cafe: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _phoneController.dispose();
    _workingHoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.cafe != null;

    return Scaffold(
      backgroundColor: const Color(0xFFEFE1D1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B5A3C),
        title: Text(
          isEdit ? 'Edit Cafe' : 'Add Cafe',
          style: const TextStyle(color: Colors.black87),
        ),
      ),
      body: _isLoadingCities
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Card(
                    elevation: 6,
                    color: const Color(0xFFD7BFA6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(color: Colors.brown.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isEdit
                                      ? Icons.edit_location_alt
                                      : Icons.add_business,
                                  color: const Color(0xFF6B432D),
                                  size: 28,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  isEdit ? 'Edit cafe details' : 'Add new cafe',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2F241F),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            TextFormField(
                              controller: _nameController,
                              decoration: _inputDecoration(label: 'Cafe name'),
                              validator: (value) =>
                                  _requiredValidator(value, 'Cafe name'),
                            ),
                            const SizedBox(height: 16),

                            DropdownButtonFormField<int>(
                              value: _selectedCityId,
                              decoration: _inputDecoration(label: 'City'),
                              items: _cities
                                  .map(
                                    (city) => DropdownMenuItem<int>(
                                      value: city.id,
                                      child: Text(city.name ?? ''),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCityId = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'City is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _addressController,
                              decoration: _inputDecoration(label: 'Address'),
                              validator: (value) =>
                                  _requiredValidator(value, 'Address'),
                            ),
                            const SizedBox(height: 16),

                            Align(
                              alignment: Alignment.centerLeft,
                              child: OutlinedButton.icon(
                                onPressed: _getCoordinatesFromAddress,
                                icon: const Icon(
                                  Icons.my_location,
                                  color: Color(0xFF6A4FB3),
                                ),
                                label: const Text(
                                  'Get coordinates',
                                  style: TextStyle(
                                    color: Color(0xFF6A4FB3),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: Colors.brown.shade200,
                                  ),
                                  backgroundColor: const Color(0xFFF0E6DC),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _latitudeController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                          signed: true,
                                        ),
                                    decoration: _inputDecoration(
                                      label: 'Latitude',
                                      hint:
                                          'Auto-filled (you can edit if needed)',
                                    ),
                                    validator: _validateLatitude,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _longitudeController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                          signed: true,
                                        ),
                                    decoration: _inputDecoration(
                                      label: 'Longitude',
                                      hint:
                                          'Auto-filled (you can edit if needed)',
                                    ),
                                    validator: _validateLongitude,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            Text(
                              'Coordinates are automatically calculated from address.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.brown.shade600,
                              ),
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _phoneController,
                              decoration: _inputDecoration(
                                label: 'Phone number',
                              ),
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _workingHoursController,
                              decoration: _inputDecoration(
                                label: 'Working hours',
                              ),
                            ),
                            const SizedBox(height: 16),

                            SwitchListTile(
                              value: _isActive,
                              activeColor: const Color(0xFF6A4FB3),
                              title: const Text(
                                'Active',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF2F241F),
                                ),
                              ),
                              contentPadding: EdgeInsets.zero,
                              onChanged: (value) {
                                setState(() {
                                  _isActive = value;
                                });
                              },
                            ),
                            const SizedBox(height: 24),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (isEdit)
                                  SizedBox(
                                    width: 160,
                                    child: OutlinedButton(
                                      onPressed: _isDeleting ? null : _delete,
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.redAccent,
                                        side: const BorderSide(
                                          color: Colors.redAccent,
                                          width: 1.5,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            22,
                                          ),
                                        ),
                                      ),
                                      child: _isDeleting
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.redAccent,
                                              ),
                                            )
                                          : const Text(
                                              'Delete',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ),
                                  ),

                                if (isEdit) const SizedBox(width: 14),

                                SizedBox(
                                  width: 160,
                                  child: ElevatedButton(
                                    onPressed: _isSaving ? null : _save,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF8B5A3C),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                    ),
                                    child: _isSaving
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            isEdit
                                                ? 'Save changes'
                                                : 'Add cafe',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
