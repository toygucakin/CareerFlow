import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/models/user_profile.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _hobbiesController;
  late TextEditingController _languagesController;
  late TextEditingController _associationsController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _titleController = TextEditingController();
    _locationController = TextEditingController();
    _hobbiesController = TextEditingController();
    _languagesController = TextEditingController();
    _associationsController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _locationController.dispose();
    _hobbiesController.dispose();
    _languagesController.dispose();
    _associationsController.dispose();
    super.dispose();
  }

  List<String> _parseList(String value) {
    if (value.trim().isEmpty) return [];
    return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  Future<void> _saveProfile(UserProfile currentProfile) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final updatedProfile = currentProfile.copyWith(
        fullName: _nameController.text.trim(),
        title: _titleController.text.trim(),
        location: _locationController.text.trim(),
        hobbies: _parseList(_hobbiesController.text),
        languages: _parseList(_languagesController.text),
        associations: _parseList(_associationsController.text),
        updatedAt: DateTime.now(),
      );

      await ref.read(authRepositoryProvider).updateProfile(updatedProfile);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Information'),
      ),
      body: profileAsync.when(
        data: (profile) {
          final user = ref.read(authRepositoryProvider).currentUser;
          if (user == null) return const Center(child: Text('Please log in.'));

          // Use existing profile or create a skeleton one if doesn't exist yet
          final currentProfile = profile ?? UserProfile(id: user.id);

          // Initialize controllers with existing data if not already set
          if (_nameController.text.isEmpty && _titleController.text.isEmpty) {
            _nameController.text = currentProfile.fullName ?? '';
            _titleController.text = currentProfile.title ?? '';
            _locationController.text = currentProfile.location ?? '';
            _hobbiesController.text = (currentProfile.hobbies ?? []).join(', ');
            _languagesController.text = (currentProfile.languages ?? []).join(', ');
            _associationsController.text = (currentProfile.associations ?? []).join(', ');
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF2196F3),
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Professional Title',
                    hintText: 'e.g. Senior Flutter Developer',
                    prefixIcon: Icon(Icons.work_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'e.g. Istanbul, Turkey',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                Text(
                  'Additional Info',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2196F3),
                      ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _languagesController,
                  decoration: const InputDecoration(
                    labelText: 'Languages (comma separated)',
                    prefixIcon: Icon(Icons.language_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hobbiesController,
                  decoration: const InputDecoration(
                    labelText: 'Hobbies (comma separated)',
                    prefixIcon: Icon(Icons.interests_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _associationsController,
                  decoration: const InputDecoration(
                    labelText: 'Associations (comma separated)',
                    prefixIcon: Icon(Icons.groups_outlined),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isSaving ? null : () => _saveProfile(currentProfile),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Changes'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
