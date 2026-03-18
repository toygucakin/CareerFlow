import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/social_media.dart';
import '../providers/social_media_provider.dart';

class SocialMediaFormScreen extends ConsumerStatefulWidget {
  final SocialMediaAccount? accountToEdit;

  const SocialMediaFormScreen({super.key, this.accountToEdit});

  @override
  ConsumerState<SocialMediaFormScreen> createState() => _SocialMediaFormScreenState();
}

class _SocialMediaFormScreenState extends ConsumerState<SocialMediaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late SocialMediaPlatform _selectedPlatform;
  final _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedPlatform = widget.accountToEdit?.platform ?? SocialMediaPlatform.linkedIn;
    _urlController.text = widget.accountToEdit?.url ?? '';
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final account = SocialMediaAccount(
      id: widget.accountToEdit?.id,
      platform: _selectedPlatform,
      url: _urlController.text.trim(),
    );

    if (widget.accountToEdit != null) {
      await ref.read(socialMediaListProvider.notifier).updateAccount(account);
    } else {
      await ref.read(socialMediaListProvider.notifier).addAccount(account);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.accountToEdit != null ? 'Hesabı Düzenle' : 'Yeni Sosyal Medya Hesabı'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<SocialMediaPlatform>(
              value: _selectedPlatform,
              decoration: const InputDecoration(
                labelText: 'Platform',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.share),
              ),
              items: SocialMediaPlatform.values.map((platform) {
                return DropdownMenuItem(
                  value: platform,
                  child: Row(
                    children: [
                      Icon(platform.icon, size: 20, color: platform.color),
                      const SizedBox(width: 12),
                      Text(platform.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedPlatform = val);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Profil URL',
                hintText: 'https://github.com/username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
              validator: (val) {
                if (val == null || val.isEmpty) return 'Lütfen URL girin';
                if (!val.startsWith('http')) return 'Geçerli bir URL girin (http/https)';
                return null;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Kaydet', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
