import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
    final dateFormat = DateFormat('MMMM yyyy', 'tr_TR');

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
                onTap: () => _showMonthYearPicker(context, true),
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
                  onTap: () => _showMonthYearPicker(context, false),
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

class _MonthYearPickerInternal extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateChanged;

  const _MonthYearPickerInternal({
    required this.initialDate,
    required this.onDateChanged,
  });

  @override
  State<_MonthYearPickerInternal> createState() => _MonthYearPickerInternalState();
}

class _MonthYearPickerInternalState extends State<_MonthYearPickerInternal> {
  late int _month, _year;
  late FixedExtentScrollController _monthCtrl, _yearCtrl;
  final List<String> _months = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
  ];
  final int _startYear = 1950;
  final int _endYear = DateTime.now().year + 50;

  @override
  void initState() {
    super.initState();
    _month = widget.initialDate.month;
    _year = widget.initialDate.year;
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
                childCount: 12,
                itemBuilder: (c, i) => Center(child: Text(_months[i])),
              ),
            ),
            Expanded(
              child: CupertinoPicker.builder(
                scrollController: _yearCtrl,
                itemExtent: 44,
                onSelectedItemChanged: (i) {
                  _year = _startYear + i;
                  _onChanged();
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
