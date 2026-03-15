import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/cv/interest.dart';
import '../providers/interest_provider.dart';

class InterestFormScreen extends ConsumerStatefulWidget {
  final Interest? interestToEdit;

  const InterestFormScreen({super.key, this.interestToEdit});

  @override
  ConsumerState<InterestFormScreen> createState() => _InterestFormScreenState();
}

class _InterestFormScreenState extends ConsumerState<InterestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.interestToEdit?.name ?? '';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      final interest = Interest(
        id: widget.interestToEdit?.id,
        name: _name,
      );

      if (widget.interestToEdit == null) {
        await ref.read(interestListProvider.notifier).addInterest(interest);
      } else {
        await ref.read(interestListProvider.notifier).updateInterest(interest);
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
        title: Text(widget.interestToEdit == null ? 'İlgi Alanı Ekle' : 'İlgi Alanı Düzenle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(
                  labelText: 'İlgi Alanı (Örn: Mobil Geliştirme, Yapay Zeka)',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Gerekli' : null,
                onSaved: (val) => _name = val ?? '',
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
