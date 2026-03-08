import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/community.dart';
import '../providers/community_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class CommunityFormScreen extends ConsumerStatefulWidget {
  final Community? communityToEdit;

  const CommunityFormScreen({super.key, this.communityToEdit});

  @override
  ConsumerState<CommunityFormScreen> createState() =>
      _CommunityFormScreenState();
}

class _CommunityFormScreenState extends ConsumerState<CommunityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _roleController;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isOngoing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.communityToEdit?.name);
    _roleController = TextEditingController(text: widget.communityToEdit?.role);
    _startDate = widget.communityToEdit?.startDate;
    _endDate = widget.communityToEdit?.endDate;
    _isOngoing = widget.communityToEdit != null && widget.communityToEdit!.endDate == null && widget.communityToEdit!.startDate != null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
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

    final community = Community(
      id: widget.communityToEdit?.id,
      profileId: user.id,
      name: _nameController.text,
      role: _roleController.text,
      startDate: _startDate,
      endDate: _isOngoing ? null : _endDate,
      orderIndex: widget.communityToEdit?.orderIndex ?? 0,
    );

    try {
      if (widget.communityToEdit == null) {
        await ref.read(communityListProvider.notifier).addCommunity(community);
      } else {
        await ref
            .read(communityListProvider.notifier)
            .updateCommunity(community);
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
          widget.communityToEdit == null ? 'Topluluk Ekle' : 'Topluluk Düzenle',
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
                  labelText: 'Topluluk / Kulüp Adı *',
                  border: OutlineInputBorder(),
                  hintText: 'Örn: IEEE Öğrenci Kolu, GDG Istanbul',
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Lütfen topluluk adını girin'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roleController,
                decoration: const InputDecoration(
                  labelText: 'Rolünüz',
                  border: OutlineInputBorder(),
                  hintText: 'Örn: Üye, Yönetim Kurulu Başkanı',
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
                        widget.communityToEdit == null ? 'Kaydet' : 'Güncelle',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
