import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import '../models/city.dart';
import '../providers/city_provider.dart';

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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final provider = context.read<UserProvider>();

    final request = {
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'userName': _userNameController.text,
      'email': _emailController.text,
      'roleId': _selectedRoleId,
      'cityId': _selectedCityId,
    };

    if (widget.user == null) {
      request['password'] = _passwordController.text;
      request['passwordConfirmation'] = _confirmPasswordController.text;
    }

    try {
      if (widget.user == null) {
        await provider.insert(request);
      } else {
        await provider.update(widget.user!.id, request);
      }

      if (!mounted) return;
      Navigator.pop(context, 'refresh');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      setState(() => _isSaving = false);
    }
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
      ).showSnackBar(SnackBar(content: Text("Failed to load cities: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE1D1),
      appBar: AppBar(
        title: Text(widget.user == null ? 'Add user' : 'Edit user'),
        backgroundColor: const Color(0xFF8B5A3C),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            color: const Color(0xFFD2B48C),
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.person,
                        size: 48,
                        color: Color(0xFF6F4E37),
                      ),
                      const SizedBox(height: 16),

                      _buildField(_firstNameController, 'First name'),
                      _buildField(_lastNameController, 'Last name'),
                      _buildField(_userNameController, 'Username'),
                      _buildField(
                        _emailController,
                        'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Required field';
                          }

                          final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );

                          if (!emailRegex.hasMatch(v.trim())) {
                            return 'Invalid email format';
                          }

                          return null;
                        },
                      ),

                      if (widget.user == null) ...[
                        _buildField(
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

                        _buildField(
                          _confirmPasswordController,
                          'Confirm password',
                          isPassword: true,
                          validator: (v) {
                            final value = (v ?? '').trim();
                            if (value.isEmpty) {
                              return 'Required field';
                            }
                            if (value != _passwordController.text.trim()) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ],

                      const SizedBox(height: 12),

                      _citiesLoading
                          ? const LinearProgressIndicator()
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
                              validator: (v) =>
                                  v == null ? 'Please select a city' : null,
                            ),

                      const SizedBox(height: 12),

                      DropdownButtonFormField<int>(
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
                          DropdownMenuItem(value: 1, child: Text('Admin')),
                          DropdownMenuItem(value: 2, child: Text('User')),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedRoleId = value);
                        },
                        validator: (value) =>
                            value == null ? 'Please select role' : null,
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              196,
                              145,
                              108,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isSaving ? null : _save,
                          child: _isSaving
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text('Save'),
                        ),
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

  Widget _buildField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
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
      ),
    );
  }
}
