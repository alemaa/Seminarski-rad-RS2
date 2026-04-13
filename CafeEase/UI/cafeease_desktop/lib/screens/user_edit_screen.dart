import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/city.dart';
import '../models/user.dart';
import '../providers/city_provider.dart';
import '../providers/user_provider.dart';

class UserEditScreen extends StatefulWidget {
  final User? user;

  const UserEditScreen({super.key, this.user});

  @override
  State<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _userNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  int? _selectedRoleId;
  bool _isSaving = false;

  int? _selectedCityId;
  List<City> _cities = [];
  bool _citiesLoading = false;

  bool get isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();

    _firstNameController = TextEditingController(
      text: widget.user?.firstName ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.user?.lastName ?? '',
    );
    _userNameController = TextEditingController(
      text: widget.user?.username ?? '',
    );
    _emailController = TextEditingController(text: widget.user?.email ?? '');

    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _selectedRoleId = widget.user?.roleId;
    _selectedCityId = widget.user?.cityId;

    _loadCities();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadCities() async {
    setState(() => _citiesLoading = true);

    try {
      final cityProvider = context.read<CityProvider>();
      final res = await cityProvider.getCities();

      final list = res.result;
      final unique = <int, City>{};

      for (final c in list) {
        final id = c.id;
        if (id == null) continue;
        unique[id] = c;
      }

      if (!mounted) return;

      setState(() {
        _cities = unique.values.toList();
        _citiesLoading = false;

        if (_selectedCityId != null &&
            !_cities.any((x) => x.id == _selectedCityId)) {
          _selectedCityId = null;
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _citiesLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load cities: $e')));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final provider = context.read<UserProvider>();

    final request = <String, dynamic>{
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'userName': _userNameController.text.trim(),
      'email': _emailController.text.trim(),
      'roleId': _selectedRoleId,
      'cityId': _selectedCityId,
    };

    if (!isEdit) {
      request['password'] = _passwordController.text.trim();
      request['passwordConfirmation'] = _confirmPasswordController.text.trim();
    }

    try {
      if (isEdit) {
        await provider.update(widget.user!.id, request);
      } else {
        await provider.insert(request);
      }

      if (!mounted) return;
      Navigator.pop(context, 'refresh');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _twoColumn({
    required Widget left,
    required Widget right,
    required double maxWidth,
  }) {
    final isWide = maxWidth >= 850;

    if (!isWide) {
      return Column(children: [left, const SizedBox(height: 16), right]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword,
      validator:
          validator ??
          (String? v) {
            if (v == null || v.trim().isEmpty) {
              return 'Required field';
            }
            return null;
          },
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.brown.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE1D1),
      appBar: AppBar(
        title: Text(isEdit ? 'Edit user' : 'Add user'),
        backgroundColor: const Color(0xFF8B5A3C),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxContentWidth = constraints.maxWidth > 1200
              ? 900.0
              : constraints.maxWidth > 900
              ? 820.0
              : constraints.maxWidth;

          return Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Card(
                  color: const Color(0xFFD2B48C),
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.person,
                                size: 30,
                                color: Color(0xFF6F4E37),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                isEdit ? 'User details' : 'New user',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          _twoColumn(
                            maxWidth: maxContentWidth,
                            left: _buildField(
                              _firstNameController,
                              'First name',
                            ),
                            right: _buildField(
                              _lastNameController,
                              'Last name',
                            ),
                          ),

                          const SizedBox(height: 16),

                          _twoColumn(
                            maxWidth: maxContentWidth,
                            left: _buildField(_userNameController, 'Username'),
                            right: _buildField(
                              _emailController,
                              'Email',
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Required field';
                                }

                                final emailRegex = RegExp(
                                  r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$',
                                );

                                if (!emailRegex.hasMatch(v.trim())) {
                                  return 'Invalid email format';
                                }

                                return null;
                              },
                            ),
                          ),

                          if (!isEdit) ...[
                            const SizedBox(height: 16),
                            _twoColumn(
                              maxWidth: maxContentWidth,
                              left: _buildField(
                                _passwordController,
                                'Password',
                                isPassword: true,
                                validator: (v) {
                                  final value = (v ?? '').trim();

                                  if (value.isEmpty) {
                                    return 'Required field';
                                  }

                                  if (value.length < 4) {
                                    return 'Password must be at least 4 characters';
                                  }

                                  return null;
                                },
                              ),
                              right: _buildField(
                                _confirmPasswordController,
                                'Confirm password',
                                isPassword: true,
                                validator: (v) {
                                  final value = (v ?? '').trim();

                                  if (value.isEmpty) {
                                    return 'Required field';
                                  }

                                  if (value !=
                                      _passwordController.text.trim()) {
                                    return 'Passwords do not match';
                                  }

                                  return null;
                                },
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),

                          _twoColumn(
                            maxWidth: maxContentWidth,
                            left: _citiesLoading
                                ? Container(
                                    height: 56,
                                    alignment: Alignment.centerLeft,
                                    child: const LinearProgressIndicator(),
                                  )
                                : DropdownButtonFormField<int?>(
                                    value: _selectedCityId,
                                    decoration: InputDecoration(
                                      labelText: 'City',
                                      filled: true,
                                      fillColor: Colors.brown.shade50,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    items: _cities
                                        .map(
                                          (c) => DropdownMenuItem<int?>(
                                            value: c.id,
                                            child: Text(c.name ?? ''),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) =>
                                        setState(() => _selectedCityId = v),
                                    validator: (v) => v == null
                                        ? 'Please select a city'
                                        : null,
                                  ),
                            right: DropdownButtonFormField<int>(
                              value: _selectedRoleId,
                              decoration: InputDecoration(
                                labelText: 'Role',
                                filled: true,
                                fillColor: Colors.brown.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 1,
                                  child: Text('Admin'),
                                ),
                                DropdownMenuItem(value: 2, child: Text('User')),
                              ],
                              onChanged: (value) {
                                setState(() => _selectedRoleId = value);
                              },
                              validator: (value) =>
                                  value == null ? 'Please select role' : null,
                            ),
                          ),

                          const SizedBox(height: 28),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 150,
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFC4916C),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  onPressed: _isSaving ? null : _save,
                                  child: _isSaving
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Save'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
