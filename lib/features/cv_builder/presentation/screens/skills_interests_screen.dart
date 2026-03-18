import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/cv/skill.dart';
import '../../../../core/models/cv/interest.dart';
import '../providers/skill_provider.dart';
import '../providers/interest_provider.dart';
import '../providers/language_provider.dart';
import 'skill_form_screen.dart';
import 'interest_form_screen.dart';
import 'language_form_screen.dart';

class SkillsInterestsScreen extends ConsumerWidget {
  final bool isWizardMode;

  const SkillsInterestsScreen({super.key, this.isWizardMode = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skillsAsync = ref.watch(skillListProvider);
    final interestsAsync = ref.watch(interestListProvider);
    final languagesAsync = ref.watch(languageListProvider);

    return Scaffold(
      appBar: isWizardMode
          ? null
          : AppBar(title: const Text('Beceriler ve İlgi Alanları')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Teknik Beceriler',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const Divider(),
            const SizedBox(height: 16),
            
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: skillsAsync.when(
                data: (skills) {
                  final techSkills = skills.where((s) => s.category != 'Soft Skills').toList();
                  return _buildCategorizedSkills(context, ref, techSkills);
                },
                loading: () => const Center(
                  key: ValueKey('loading'),
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, s) => Center(
                  key: const ValueKey('error'),
                  child: Text('Hata: $e'),
                ),
              ),
            ),

            const SizedBox(height: 32),
            const Text(
              'Kişisel Beceriler & İlgi Alanları',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const Divider(),
            const SizedBox(height: 16),

            // Soft Skills Section
            _buildSectionHeader(
              context,
              'Kişisel Beceriler (Soft Skills)',
              Icons.psychology,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SkillFormScreen(initialCategory: 'Soft Skills', isSoftSkillMode: true),
                ),
              ),
            ),
            skillsAsync.when(
              data: (skills) {
                final softSkills = skills.where((s) => s.category == 'Soft Skills').toList();
                return _buildSimpleSkillList(context, ref, softSkills);
              },
              loading: () => const SizedBox(),
              error: (e, s) => Text('Hata: $e'),
            ),
            const SizedBox(height: 24),

            // Languages Section
            _buildSectionHeader(
              context,
              'Yabancı Diller',
              Icons.language,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LanguageFormScreen()),
              ),
            ),
            languagesAsync.when(
              data: (list) => _buildLanguageList(context, ref, list),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Hata: $e'),
            ),
            const SizedBox(height: 24),

            // Interests Section
            _buildSectionHeader(
              context,
              'İlgi Alanları',
              Icons.star_border,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InterestFormScreen()),
              ),
            ),
            interestsAsync.when(
              data: (list) => _buildInterestList(context, ref, list),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Hata: $e'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddSkill(BuildContext context, String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SkillFormScreen(initialCategory: category),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, VoidCallback onAdd) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        IconButton(
          onPressed: onAdd,
          icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
        ),
      ],
    );
  }

  Widget _buildCategorizedSkills(BuildContext context, WidgetRef ref, List<Skill> techSkills) {
    final Map<String, List<Skill>> grouped = {
      'Programlama': [],
      'Web': [],
      'Veritabanı': [],
      'Araçlar': [],
      'Ofis': [],
    };

    for (var skill in techSkills) {
      if (grouped.containsKey(skill.category)) {
        grouped[skill.category]!.add(skill);
      }
    }

    return Column(
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              entry.key,
              Icons.code,
              () => _navigateToAddSkill(context, entry.key),
            ),
            if (entry.value.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                child: Text('Henüz eklenmedi.', style: TextStyle(color: Colors.grey)),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: entry.value.map((skill) => _buildSkillChip(context, ref, skill)).toList(),
                ),
              ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSkillChip(BuildContext context, WidgetRef ref, Skill skill) {
    return InputChip(
      label: Text(
        skill.isActiveDevelopment ? '${skill.name} (Aktif Geliştirici)' : skill.name,
      ),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: () {
        ref.read(skillListProvider.notifier).deleteSkill(skill.id!);
      },
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SkillFormScreen(skillToEdit: skill),
          ),
        );
      },
      backgroundColor: skill.isActiveDevelopment ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
      side: BorderSide(
        color: skill.isActiveDevelopment ? Colors.blue : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildSimpleSkillList(BuildContext context, WidgetRef ref, List<Skill> skills) {
    if (skills.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
        child: Text('Henüz eklenmedi.', style: TextStyle(color: Colors.grey)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: skills.map((skill) {
        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          leading: const Icon(Icons.circle, size: 8, color: Colors.blue),
          title: Text(skill.name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SkillFormScreen(skillToEdit: skill, isSoftSkillMode: true))),
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                onPressed: () => ref.read(skillListProvider.notifier).deleteSkill(skill.id!),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLanguageList(BuildContext context, WidgetRef ref, List languages) {
    if (languages.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
        child: Text('Dil bilgisi eklenmemiş.', style: TextStyle(color: Colors.grey)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: languages.map((lang) {
        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          leading: const Icon(Icons.language, size: 16, color: Colors.blue),
          title: Text('${lang.name} (${lang.proficiency ?? ''})'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LanguageFormScreen(languageToEdit: lang))),
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                onPressed: () => ref.read(languageListProvider.notifier).deleteLanguage(lang.id!),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInterestList(BuildContext context, WidgetRef ref, List<Interest> interests) {
    if (interests.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
        child: Text('Henüz eklenmedi.', style: TextStyle(color: Colors.grey)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: interests.map((interest) {
        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          leading: const Icon(Icons.circle, size: 8, color: Colors.blue),
          title: Text(interest.name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InterestFormScreen(interestToEdit: interest))),
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                onPressed: () => ref.read(interestListProvider.notifier).deleteInterest(interest.id!),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
