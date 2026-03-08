import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/course.dart';
import '../providers/course_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class CourseFormScreen extends ConsumerStatefulWidget {
  final Course? courseToEdit;

  const CourseFormScreen({super.key, this.courseToEdit});

  @override
  ConsumerState<CourseFormScreen> createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends ConsumerState<CourseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _issuerController;
  late TextEditingController _descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.courseToEdit?.name);
    _issuerController = TextEditingController(
      text: widget.courseToEdit?.issuer,
    );
    _descriptionController = TextEditingController(
      text: widget.courseToEdit?.description,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _issuerController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen önce giriş yapın.')));
      setState(() => _isLoading = false);
      return;
    }

    final course = Course(
      id: widget.courseToEdit?.id,
      profileId: user.id,
      name: _nameController.text,
      issuer: _issuerController.text,
      description: _descriptionController.text,
      orderIndex: widget.courseToEdit?.orderIndex ?? 0,
    );

    try {
      if (widget.courseToEdit == null) {
        await ref.read(courseListProvider.notifier).addCourse(course);
      } else {
        await ref.read(courseListProvider.notifier).updateCourse(course);
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
        title: Text(
          widget.courseToEdit == null
              ? 'Kurs/Sertifika Ekle'
              : 'Kurs/Sertifika Düzenle',
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
                  labelText: 'Kurs veya Sertifika Adı *',
                  border: OutlineInputBorder(),
                  hintText: 'Örn: Flutter ile Mobil Uygulama Geliştirme',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Lütfen adı girin' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _issuerController,
                decoration: const InputDecoration(
                  labelText: 'Veren Kurum / Firma',
                  border: OutlineInputBorder(),
                  hintText: 'Örn: Udemy, Google, BTK Akademi',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Kısa Tanımlama',
                  border: OutlineInputBorder(),
                  hintText:
                      'Kursun içeriği veya kazandırdığı yetkinlikler hakkında kısa bilgi...',
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
                    : Text(widget.courseToEdit == null ? 'Kaydet' : 'Güncelle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
