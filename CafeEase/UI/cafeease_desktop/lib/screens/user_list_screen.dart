import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import 'user_detail_screen.dart';
import 'user_edit_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  bool _isLoading = true;
  List<User> _users = [];

  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    final provider = context.read<UserProvider>();

    try {
      final filter = <String, dynamic>{};

      if (_searchText.trim().isNotEmpty) {
        filter['nameFTS'] = _searchText.trim();
      }

      final result = await provider.get(filter: filter);

      setState(() {
        _users = result.result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context,).showSnackBar(SnackBar(content: Text('Failed to load users: $e')));
    }
  }

  String _fullName(User u) {
    final first = u.firstName ?? '';
    final last = u.lastName ?? '';
    final full = ('$first $last').trim();
    return full.isEmpty ? u.username ?? 'User' : full;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE1D1),
      appBar: AppBar(
        title: const Text('Users'),
        backgroundColor: const Color(0xFF8B5A3C),
      ),
       floatingActionButton: FloatingActionButton(
    backgroundColor: const Color(0xFF8B5A3C),
    foregroundColor: Colors.white,
    child: const Icon(Icons.add),
    onPressed: () async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const UserEditScreen(),
        ),
      );

      if (result == 'refresh') {
        _loadUsers();
      }
    },
  ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users by name or email',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchText.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchText = '');
                          _loadUsers();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                _searchText = value;
                _loadUsers();
              },
            ),

            const SizedBox(height: 16),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _users.isEmpty
                  ? const Center(child: Text('No users found'))
                  : ListView.separated(
                      itemCount: _users.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, index) {
                        final user = _users[index];

                        return Card(
                          color: const Color(0xFFD2B48C),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.person,
                              color: Color(0xFF3E2723),
                            ),
                            title: Text(
                              _fullName(user),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (user.username != null)
                                  Text('Username: ${user.username}'),
                                if (user.email != null)
                                  Text('Email: ${user.email}'),
                              ],
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UserDetailScreen(user: user),
                                ),
                              );
                              if (result == 'refresh') {
                                _loadUsers();
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
