import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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

  void _showMonthYearPicker(BuildContext context, bool isStart) {
    FocusScope.of(context).unfocus();
    final initialDate = (isStart ? _startDate : _endDate) ?? DateTime.now();
    DateTime tempDate = initialDate;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text(
                        'İptal',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                    Text(
                      isStart ? 'Başlangıç Tarihi' : 'Bitiş Tarihi',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          if (isStart) {
                            _startDate = tempDate;
                          } else {
                            _endDate = tempDate;
                          }
                        });
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        'Bitti',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _MonthYearPickerInternal(
                  initialDate: initialDate,
                  onDateChanged: (date) => tempDate = date,
                ),
              ),
            ],
          ),
        );
      },
    );
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
    final dateFormat = DateFormat('MMMM yyyy', 'tr_TR');

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
              GestureDetector(
                onTap: () => _showMonthYearPicker(context, true),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Başlangıç Tarihi',
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _startDate == null
                                  ? 'Seçilmedi'
                                  : dateFormat.format(_startDate!),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: Colors.grey),
                    ],
                  ),
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
                GestureDetector(
                  onTap: () => _showMonthYearPicker(context, false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bitiş Tarihi',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _endDate == null
                                    ? 'Seçilmedi'
                                    : dateFormat.format(_endDate!),
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.calendar_today, color: Colors.grey),
                      ],
                    ),
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

class _MonthYearPickerInternal extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateChanged;

  const _MonthYearPickerInternal({
    required this.initialDate,
    required this.onDateChanged,
  });

  @override
  State<_MonthYearPickerInternal> createState() =>
      _MonthYearPickerInternalState();
}

class _MonthYearPickerInternalState extends State<_MonthYearPickerInternal> {
  late int _month, _year;
  late FixedExtentScrollController _monthCtrl, _yearCtrl;
  final List<String> _months = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık'
  ];
  final int _startYear = 1950;
  final int _endYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _month = widget.initialDate.month;
    _year = widget.initialDate.year;

    // Ensure initial items aren't beyond limits
    if (_year > _endYear) _year = _endYear;
    if (_year == _endYear && _month > DateTime.now().month) {
      _month = DateTime.now().month;
    }

    _monthCtrl = FixedExtentScrollController(initialItem: _month - 1);
    _yearCtrl = FixedExtentScrollController(initialItem: _year - _startYear);
  }

  void _onChanged() {
    widget.onDateChanged(DateTime(_year, _month));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: CupertinoTheme(
        data: CupertinoThemeData(
          brightness: Theme.of(context).brightness,
          textTheme: CupertinoTextThemeData(
            pickerTextStyle: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 18,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: CupertinoPicker.builder(
                scrollController: _monthCtrl,
                itemExtent: 44,
                onSelectedItemChanged: (i) {
                  _month = i + 1;
                  _onChanged();
                },
                childCount: _year == _endYear ? DateTime.now().month : 12,
                itemBuilder: (c, i) => Center(child: Text(_months[i])),
              ),
            ),
            Expanded(
              child: CupertinoPicker.builder(
                scrollController: _yearCtrl,
                itemExtent: 44,
                onSelectedItemChanged: (i) {
                  _year = _startYear + i;
                  if (_year == _endYear && _month > DateTime.now().month) {
                    _month = DateTime.now().month;
                    _monthCtrl.jumpToItem(_month - 1);
                  }
                  _onChanged();
                  setState(() {});
                },
                childCount: _endYear - _startYear + 1,
                itemBuilder: (c, i) => Center(child: Text('${_startYear + i}')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _monthCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }
}
