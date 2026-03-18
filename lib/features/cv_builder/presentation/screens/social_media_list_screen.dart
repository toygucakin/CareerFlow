import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/social_media.dart';
import '../providers/social_media_provider.dart';
import 'social_media_form_screen.dart';

class SocialMediaListScreen extends ConsumerWidget {
  final bool isWizardMode;

  const SocialMediaListScreen({super.key, this.isWizardMode = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(socialMediaListProvider);

    return Scaffold(
      appBar: isWizardMode
          ? null
          : AppBar(title: const Text('Sosyal Medya Hesapları')),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: accountsAsync.when(
          data: (accounts) => _buildContent(context, ref, accounts),
          loading: () => const Center(
            key: ValueKey('loading'),
            child: CircularProgressIndicator(),
          ),
          error: (e, s) => Center(
            key: const ValueKey('error'),
            child: Text('Hata: $e'),
          ),
        ),
      ),
      floatingActionButton: !isWizardMode
          ? FloatingActionButton(
              onPressed: () => _navigateToAdd(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<SocialMediaAccount> accounts) {
    return Column(
      children: [
        if (isWizardMode)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sosyal Medya Hesapları',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                IconButton(
                  onPressed: () => _navigateToAdd(context),
                  icon: const Icon(Icons.add_circle, color: Colors.blue, size: 28),
                ),
              ],
            ),
          ),
        if (accounts.isEmpty)
          const Expanded(
            child: Center(
              child: Text(
                'Henüz hesap eklemediniz.\nLinkedIn veya GitHub hesabınızı ekleyerek başlayın.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: accounts.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final account = accounts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Icon(account.platform.icon, color: account.platform.color),
                    title: Text(account.username),
                    subtitle: Text(
                      account.url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _navigateToEdit(context, account),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                          onPressed: () => _deleteAccount(ref, account),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  void _navigateToAdd(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SocialMediaFormScreen()),
    );
  }

  void _navigateToEdit(BuildContext context, SocialMediaAccount account) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SocialMediaFormScreen(accountToEdit: account)),
    );
  }

  void _deleteAccount(WidgetRef ref, SocialMediaAccount account) {
    ref.read(socialMediaListProvider.notifier).deleteAccount(account.id!);
  }
}
