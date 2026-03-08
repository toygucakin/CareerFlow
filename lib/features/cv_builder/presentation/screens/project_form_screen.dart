import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/project.dart';
import '../providers/project_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class ProjectFormScreen extends ConsumerStatefulWidget {
  final Project? projectToEdit;

  const ProjectFormScreen({super.key, this.projectToEdit});

  @override
  ConsumerState<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends ConsumerState<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _scopeController;
  late TextEditingController _descriptionController;
  late TextEditingController _technologiesController;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isOngoing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.projectToEdit?.name);
    _scopeController = TextEditingController(text: widget.projectToEdit?.scope);
    _descriptionController = TextEditingController(
      text: widget.projectToEdit?.description,
    );
    _technologiesController = TextEditingController(
      text: widget.projectToEdit?.technologies,
    );
    _startDate = widget.projectToEdit?.startDate;
    _endDate = widget.projectToEdit?.endDate;
    _isOngoing = widget.projectToEdit != null && widget.projectToEdit!.endDate == null && widget.projectToEdit!.startDate != null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _scopeController.dispose();
    _descriptionController.dispose();
    _technologiesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    final project = Project(
      id: widget.projectToEdit?.id,
      profileId: user.id,
      name: _nameController.text,
      scope: _scopeController.text,
      description: _descriptionController.text,
      technologies: _technologiesController.text,
      startDate: _startDate,
      endDate: _isOngoing ? null : _endDate,
      orderIndex: widget.projectToEdit?.orderIndex ?? 0,
      isAutonomous: widget.projectToEdit?.isAutonomous ?? false,
    );

    try {
      if (widget.projectToEdit == null) {
        await ref.read(projectListProvider.notifier).addProject(project);
      } else {
        await ref.read(projectListProvider.notifier).updateProject(project);
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
    final dateFormat = DateFormat('dd MMMM yyyy', 'tr_TR');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.projectToEdit == null ? 'Proje Ekle' : 'Proje Düzenle',
        ),
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
                  labelText: 'Proje Adı *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Lütfen proje adını girin'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _scopeController,
                decoration: const InputDecoration(
                  labelText: 'Proje Kapsamı',
                  border: OutlineInputBorder(),
                  hintText: 'Örn: Web Uygulaması, Bitirme Projesi',
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Başlangıç Tarihi'),
                subtitle: Text(_startDate == null ? 'Seçilmedi' : dateFormat.format(_startDate!)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Devam Ediyor'),
                value: _isOngoing,
                onChanged: (val) {
                  setState(() {
                    _isOngoing = val ?? false;
                    if (_isOngoing) _endDate = null;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              if (!_isOngoing) ...[
                const SizedBox(height: 8),
                ListTile(
                  title: const Text('Bitiş Tarihi'),
                  subtitle: Text(_endDate == null ? 'Seçilmedi' : dateFormat.format(_endDate!)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, false),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Proje Tanımı',
                  border: OutlineInputBorder(),
                  hintText: 'Projenin ne yaptığını kısaca açıklayın...',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _technologiesController,
                decoration: const InputDecoration(
                  labelText: 'Kullanılan Teknolojiler',
                  border: OutlineInputBorder(),
                  hintText: 'Örn: Flutter, Supabase, Python',
                ),
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
                        widget.projectToEdit == null ? 'Kaydet' : 'Güncelle',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
