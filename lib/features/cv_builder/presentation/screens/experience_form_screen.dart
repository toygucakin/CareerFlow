import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/experience.dart';
import '../providers/experience_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class ExperienceFormScreen extends ConsumerStatefulWidget {
  final Experience? experienceToEdit;

  const ExperienceFormScreen({super.key, this.experienceToEdit});

  @override
  ConsumerState<ExperienceFormScreen> createState() =>
      _ExperienceFormScreenState();
}

class _ExperienceFormScreenState extends ConsumerState<ExperienceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _companyController;
  late TextEditingController _roleController;
  late TextEditingController _descriptionController;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isOngoing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _companyController = TextEditingController(
      text: widget.experienceToEdit?.company,
    );
    _roleController = TextEditingController(
      text: widget.experienceToEdit?.role,
    );
    _descriptionController = TextEditingController(
      text: widget.experienceToEdit?.description,
    );
    _startDate = widget.experienceToEdit?.startDate;
    _endDate = widget.experienceToEdit?.endDate;
    _isOngoing =
        widget.experienceToEdit != null &&
        widget.experienceToEdit!.endDate == null;

    // If we're editing and endDate is null, it means it's ongoing
    if (widget.experienceToEdit != null &&
        widget.experienceToEdit!.endDate == null) {
      _isOngoing = true;
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _roleController.dispose();
    _descriptionController.dispose();
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
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen başlangıç tarihini seçin.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    final experience = Experience(
      id: widget.experienceToEdit?.id,
      profileId: user.id,
      company: _companyController.text,
      role: _roleController.text,
      description: _descriptionController.text,
      startDate: _startDate,
      endDate: _isOngoing ? null : _endDate,
      orderIndex: widget.experienceToEdit?.orderIndex ?? 0,
    );

    try {
      if (widget.experienceToEdit == null) {
        await ref
            .read(experienceListProvider.notifier)
            .addExperience(experience);
      } else {
        await ref
            .read(experienceListProvider.notifier)
            .updateExperience(experience);
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
          widget.experienceToEdit == null ? 'Deneyim Ekle' : 'Deneyim Düzenle',
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
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Firma / Kurum Adı *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Lütfen firma adını girin'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roleController,
                decoration: const InputDecoration(
                  labelText: 'Rolünüz',
                  border: OutlineInputBorder(),
                  hintText: 'Örn: Yazılım Geliştirici, Proje Yöneticisi',
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Başlangıç Tarihi'),
                subtitle: Text(
                  _startDate == null
                      ? 'Seçilmedi'
                      : dateFormat.format(_startDate!),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Halen burada çalışıyorum (Devam Ediyor)'),
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
                  subtitle: Text(
                    _endDate == null
                        ? 'Seçilmedi'
                        : dateFormat.format(_endDate!),
                  ),
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
                  labelText: 'Açıklama',
                  border: OutlineInputBorder(),
                  hintText: 'Yaptığınız işler, sorumluluklar...',
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
                        widget.experienceToEdit == null ? 'Kaydet' : 'Güncelle',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
