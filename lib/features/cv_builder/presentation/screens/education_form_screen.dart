import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/education_provider.dart';
import '../../domain/models/education.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

class EducationFormScreen extends ConsumerStatefulWidget {
  final Education? educationToEdit;
  const EducationFormScreen({super.key, this.educationToEdit});

  @override
  ConsumerState<EducationFormScreen> createState() => _EducationFormScreenState();
}

class _EducationFormScreenState extends ConsumerState<EducationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _schoolController;
  late TextEditingController _degreeController;
  
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isOngoing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _schoolController = TextEditingController(text: widget.educationToEdit?.school ?? '');
    _degreeController = TextEditingController(text: widget.educationToEdit?.degree ?? '');
    
    _startDate = widget.educationToEdit?.startDate;
    _endDate = widget.educationToEdit?.endDate;
    
    if (widget.educationToEdit != null) {
      // If we have an education but end date is null, it means it's ongoing
      _isOngoing = widget.educationToEdit?.endDate == null;
    }
  }

  @override
  void dispose() {
    _schoolController.dispose();
    _degreeController.dispose();
    super.dispose();
  }

  Future<void> _saveEducation() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Custom validation
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen başlangıç tarihi seçin.')),
      );
      return;
    }
    
    if (!_isOngoing && _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bitiş tarihi seçin veya "Devam Ediyor"u işaretleyin.')),
      );
      return;
    }
    
    if (!_isOngoing && _endDate != null && _endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitiş tarihi başlangıç tarihinden önce olamaz.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final user = ref.read(authRepositoryProvider).currentUser;
    
    try {
      final education = Education(
        id: widget.educationToEdit?.id,
        profileId: user?.id,
        school: _schoolController.text.trim(),
        degree: _degreeController.text.trim(),
        startDate: _startDate,
        endDate: _isOngoing ? null : _endDate,
      );

      if (widget.educationToEdit == null) {
        await ref.read(educationListProvider.notifier).addEducation(education);
      } else {
        await ref.read(educationListProvider.notifier).updateEducation(education);
      }
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Eğitim bilgisi başarıyla kaydedildi!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata oluştu: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showDatePickerModal(BuildContext context, bool isStart) {
    FocusScope.of(context).unfocus();
    final initialDate = isStart 
        ? (_startDate ?? DateTime.now()) 
        : (_endDate ?? (_startDate ?? DateTime.now()));
        
    DateTime tempSelectedDate = initialDate;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext builder) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black12, width: 1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('İptal', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ),
                    Text(
                      isStart ? 'Başlangıç Tarihi' : 'Bitiş Tarihi', 
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          if (isStart) {
                            _startDate = tempSelectedDate;
                          } else {
                            _endDate = tempSelectedDate;
                          }
                        });
                        Navigator.of(context).pop();
                      },
                      child: const Text('Bitti', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: DefaultTextStyle(
                  style: const TextStyle(color: Colors.black),
                  child: CupertinoTheme(
                    data: const CupertinoThemeData(
                      brightness: Brightness.light,
                      textTheme: CupertinoTextThemeData(
                        pickerTextStyle: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    ),
                    child: CupertinoDatePicker(
                      initialDateTime: initialDate,
                      mode: CupertinoDatePickerMode.monthYear, // Sadece Yıl ve Ay seçilsin
                      onDateTimeChanged: (DateTime newDate) {
                        tempSelectedDate = newDate;
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM yyyy', 'tr_TR');
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.educationToEdit == null ? 'Eğitim Ekle' : 'Eğitimi Düzenle'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              TextFormField(
                controller: _schoolController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Okul Adı',
                  hintText: 'Örn: İstanbul Teknik Üniversitesi',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                validator: (v) => v!.isEmpty ? 'Okul adı zorunludur' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _degreeController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Bölüm / Derece',
                  hintText: 'Örn: Bilgisayar Mühendisliği (Lisans)',
                  prefixIcon: Icon(Icons.menu_book_outlined),
                ),
              ),
              const SizedBox(height: 24),
              // Tarih Seçimi Butonları
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _showDatePickerModal(context, true),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Başlangıç Tarihi',
                          prefixIcon: const Icon(Icons.calendar_month_outlined),
                          errorText: _startDate == null ? 'Gerekli' : null,
                        ),
                        child: Text(
                          _startDate != null ? dateFormat.format(_startDate!) : 'Seçiniz',
                          style: TextStyle(
                            color: _startDate != null ? Theme.of(context).textTheme.bodyLarge?.color : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _isOngoing ? null : () => _showDatePickerModal(context, false),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Bitiş Tarihi',
                          prefixIcon: const Icon(Icons.event_available_outlined),
                          fillColor: _isOngoing ? Colors.grey.withOpacity(0.1) : null,
                          filled: _isOngoing,
                        ),
                        child: Text(
                          _isOngoing 
                              ? 'Devam Ediyor' 
                              : (_endDate != null ? dateFormat.format(_endDate!) : 'Seçiniz'),
                          style: TextStyle(
                            color: _endDate != null || _isOngoing ? Theme.of(context).textTheme.bodyLarge?.color : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Devam Ediyor'),
                subtitle: const Text('Şu anda bu okulda okumaya devam ediyorum.'),
                value: _isOngoing,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (bool? value) {
                  setState(() {
                    _isOngoing = value ?? false;
                    if (_isOngoing) {
                      _endDate = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveEducation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Kaydet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
