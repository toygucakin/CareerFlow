import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/cv/skill.dart';
import '../providers/skill_provider.dart';

class SkillFormScreen extends ConsumerStatefulWidget {
  final Skill? skillToEdit;
  final String? initialCategory;

  const SkillFormScreen({super.key, this.skillToEdit, this.initialCategory});

  @override
  ConsumerState<SkillFormScreen> createState() => _SkillFormScreenState();
}

class _SkillFormScreenState extends ConsumerState<SkillFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _category;
  late String _name;
  late bool _isActiveDevelopment;
  bool _isLoading = false;

  final List<String> _categories = [
    'Programming',
    'Web',
    'Databases',
    'Tools',
    'Office',
    'Soft Skills'
  ];

  @override
  void initState() {
    super.initState();
    _category = widget.skillToEdit?.category ?? widget.initialCategory ?? _categories.first;
    _name = widget.skillToEdit?.name ?? '';
    _isActiveDevelopment = widget.skillToEdit?.isActiveDevelopment ?? false;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      final skill = Skill(
        id: widget.skillToEdit?.id,
        category: _category,
        name: _name,
        isActiveDevelopment: _isActiveDevelopment,
      );

      if (widget.skillToEdit == null) {
        await ref.read(skillListProvider.notifier).addSkill(skill);
      } else {
        await ref.read(skillListProvider.notifier).updateSkill(skill);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.skillToEdit == null ? 'Yetenek Ekle' : 'Yetenek Düzenle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Text(c),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _category = val;
                    });
                  }
                },
                onSaved: (val) => _category = val ?? _categories.first,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(
                  labelText: 'Yetenek Adı (Örn: Python, React, İletişim)',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Gerekli' : null,
                onSaved: (val) => _name = val ?? '',
              ),
              const SizedBox(height: 16),
              if (_category != 'Soft Skills' && _category != 'Office')
                CheckboxListTile(
                  title: const Text('Aktif Olarak Geliştiriyorum'),
                  subtitle: const Text('Bu teknolojiyi şu anda öğreniyor veya aktif kullanıyorsanız işaretleyin.'),
                  value: _isActiveDevelopment,
                  onChanged: (val) {
                    setState(() {
                      _isActiveDevelopment = val ?? false;
                    });
                  },
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
