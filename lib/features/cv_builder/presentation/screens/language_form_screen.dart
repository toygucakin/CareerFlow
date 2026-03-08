import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/language.dart';
import '../providers/language_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class LanguageFormScreen extends ConsumerStatefulWidget {
  final Language? languageToEdit;

  const LanguageFormScreen({super.key, this.languageToEdit});

  @override
  ConsumerState<LanguageFormScreen> createState() => _LanguageFormScreenState();
}

class _LanguageFormScreenState extends ConsumerState<LanguageFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  String? _selectedProficiency;
  bool _isLoading = false;

  final List<String> _proficiencies = [
    'A1 - Başlangıç',
    'A2 - Temel',
    'B1 - Orta',
    'B2 - İyi Orta',
    'C1 - İleri',
    'C2 - Ana Dil / Yetkin',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.languageToEdit?.name);
    _selectedProficiency = widget.languageToEdit?.proficiency;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    final language = Language(
      id: widget.languageToEdit?.id,
      profileId: user.id,
      name: _nameController.text,
      proficiency: _selectedProficiency,
      orderIndex: widget.languageToEdit?.orderIndex ?? 0,
    );

    try {
      if (widget.languageToEdit == null) {
        await ref.read(languageListProvider.notifier).addLanguage(language);
      } else {
        await ref.read(languageListProvider.notifier).updateLanguage(language);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.languageToEdit == null ? 'Dil Ekle' : 'Dil Düzenle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Dil Adı *',
                  border: OutlineInputBorder(),
                  hintText: 'Örn: İngilizce, Almanca',
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Lütfen dil adını girin'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedProficiency,
                decoration: const InputDecoration(
                  labelText: 'Seviye',
                  border: OutlineInputBorder(),
                ),
                items: _proficiencies.map((p) {
                  return DropdownMenuItem(value: p, child: Text(p));
                }).toList(),
                onChanged: (val) => setState(() => _selectedProficiency = val),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.languageToEdit == null ? 'Kaydet' : 'Güncelle',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
