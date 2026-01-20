import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../models/user_update_request.dart';
import '../providers/user_provider.dart';
import '../utils/util.dart';
import 'login_screen.dart';
import '../models/city.dart';
import '../providers/city_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _loading = true;
  bool _saving = false;
  bool _deleting = false;

  int? _selectedCityId;
  List<City> _cities = [];
  bool _citiesLoading = false;

  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _username = TextEditingController();

  static const _bg = Color(0xFFEFE1D1);
  static const _primary = Color(0xFF8B5A3C);
  static const _primaryDark = Color(0xFF6D4C41);
  static const _card = Color(0xFFF6EEE5);

  @override
  void initState() {
    super.initState();
    _loadMe();
    _loadCities();
  }

  Future<void> _loadMe() async {
    final userId = Authorization.userId;
    if (userId == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final userProvider = context.read<UserProvider>();
      final user = await userProvider.getById(userId);

      setState(() {
        _user = user;
        _firstName.text = user.firstName ?? "";
        _lastName.text = user.lastName ?? "";
        _email.text = user.email ?? "";
        _username.text = user.username ?? "";
        _selectedCityId = user.cityId;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load profile: $e")),
        );
      }
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load cities: $e")),
      );
    }
  }

  String? _required(String? v, String fieldName) {
    if (v == null || v.trim().isEmpty) return "$fieldName is required";
    return null;
  }

  String? _emailValidator(String? v) {
    final value = (v ?? "").trim();
    if (value.isEmpty) return "Email is required";
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
    if (!ok) return "Enter a valid email";
    return null;
  }

  Future<void> _save() async {
    if (_user == null) return;

    setState(() => _autoValidate = AutovalidateMode.onUserInteraction);

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fix the highlighted fields.")),
      );
      return;
    }

    if (_selectedCityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a city.")),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final userProvider = context.read<UserProvider>();
      final req = UserUpdateRequest(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        email: _email.text.trim(),
        username: _username.text.trim(),
        roleId: _user!.roleId,
        cityId: _selectedCityId!,
      );

      await userProvider.updateUserVoid(_user!.id!, req);
      final freshUser = await userProvider.getById(_user!.id!);

      if (!mounted) return;
      setState(() {
        _user = freshUser;
        _saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated")),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $e")),
      );
    }
  }

  void _logout() {
    Authorization.username = null;
    Authorization.password = null;
    Authorization.userId = null;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _deleteProfile() async {
    if (_user?.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete account?"),
        content: const Text(
          "This action is permanent. Are you sure you want to delete your profile?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _deleting = true);
    try {
      final userProvider = context.read<UserProvider>();
      await userProvider.deleteUser(_user!.id!);

      Authorization.username = null;
      Authorization.password = null;
      Authorization.userId = null;

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete profile: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _username.dispose();
    super.dispose();
  }

  InputDecoration _decor(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _primary),
      filled: true,
      fillColor: Colors.white.withOpacity(0.85),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _primary.withOpacity(0.35), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1.6),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _decor(label, icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullName =
        "${_user?.firstName ?? ""} ${_user?.lastName ?? ""}".trim();

    final initials = (() {
      final f = (_user?.firstName ?? "").trim();
      final l = (_user?.lastName ?? "").trim();
      final a = f.isNotEmpty ? f[0].toUpperCase() : "";
      final b = l.isNotEmpty ? l[0].toUpperCase() : "";
      return (a + b).isNotEmpty ? (a + b) : "U";
    })();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _primary,
        elevation: 0,
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
            tooltip: "Logout",
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_user == null)
              ? const Center(child: Text("No user loaded"))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [_primaryDark, _primary],
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                            color: Colors.black.withOpacity(0.14),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white.withOpacity(0.92),
                            child: Text(
                              initials,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: _primaryDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fullName.isEmpty ? "User" : fullName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "@${_user!.username ?? "-"}",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Form(
                      key: _formKey,
                      autovalidateMode: _autoValidate,
                      child: Card(
                        color: _card,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Account info",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: _primaryDark,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _field(
                                controller: _firstName,
                                label: "First name",
                                icon: Icons.badge_outlined,
                                validator: (v) => _required(v, "First name"),
                              ),
                              const SizedBox(height: 12),
                              _field(
                                controller: _lastName,
                                label: "Last name",
                                icon: Icons.badge,
                                validator: (v) => _required(v, "Last name"),
                              ),
                              const SizedBox(height: 12),
                              _field(
                                controller: _username,
                                label: "Username",
                                icon: Icons.alternate_email,
                                validator: (v) => _required(v, "Username"),
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<int>(
                                value: (_selectedCityId != null &&
                                        _cities.any(
                                            (c) => c.id == _selectedCityId))
                                    ? _selectedCityId
                                    : null,
                                decoration: _decor("City", Icons.location_city),
                                hint: const Text("Select city"),
                                items: _cities
                                    .map((c) => DropdownMenuItem<int>(
                                          value: c.id,
                                          child: Text(c.name ?? ""),
                                        ))
                                    .toList(),
                                onChanged: _citiesLoading
                                    ? null
                                    : (v) =>
                                        setState(() => _selectedCityId = v),
                                validator: (v) =>
                                    v == null ? "City is required" : null,
                              ),
                              const SizedBox(height: 12),
                              _field(
                                controller: _email,
                                label: "Email",
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: _emailValidator,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Card(
                      color: Colors.red.shade50,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Danger zone",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "This action is permanent and cannot be undone.",
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: _saving || _deleting
                                    ? null
                                    : _deleteProfile,
                                icon: _deleting
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Icon(Icons.delete_forever),
                                label: const Text(
                                  "Delete my profile",
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saving || _deleting ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 2,
                        ),
                        child: _saving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(
                                "Save changes",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
    );
  }
}
