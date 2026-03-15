import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'education_list_screen.dart';
import 'courses_list_screen.dart';
import 'skills_projects_screen.dart';
import 'experience_list_screen.dart';

// İleride diğer fazları da buraya ekleyeceğiz.
// import 'courses_list_screen.dart';
// import 'languages_projects_screen.dart';
// import 'experience_list_screen.dart';

class CvBuilderWizardScreen extends ConsumerStatefulWidget {
  const CvBuilderWizardScreen({super.key});

  @override
  ConsumerState<CvBuilderWizardScreen> createState() => _CvBuilderWizardScreenState();
}

class _CvBuilderWizardScreenState extends ConsumerState<CvBuilderWizardScreen> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  final List<String> _phaseTitles = [
    'Eğitim',
    'Sertifika',
    'Yetenek', // Dil/Proje/Topluluk
    'Deneyim'
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onStepTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Toplam ilerleme %'si hesaplama
    final double progress = (_currentPageIndex + 1) / _phaseTitles.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Özgeçmişimi Doldur'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // Adım başlıkları ve yuvarlak indikatörler
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_phaseTitles.length, (index) {
                    final isActive = index <= _currentPageIndex;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _onStepTapped(index),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: isActive ? const Color(0xFF2196F3) : Colors.grey.shade300,
                              foregroundColor: isActive ? Colors.white : Colors.grey.shade600,
                              child: Text('${index + 1}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _phaseTitles[index],
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                color: isActive 
                                    ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87) 
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                // Yüzdelik bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '%${(progress * 100).toInt()} Tamamlandı',
                    style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Only navigate via buttons/stepper
        onPageChanged: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        children: [
          // Faz 1
          const EducationListScreen(isWizardMode: true),
          
          // Faz 2
          const CoursesListScreen(isWizardMode: true),
          // Faz 3
          const SkillsProjectsScreen(isWizardMode: true),
          
          // Faz 4
          const ExperienceListScreen(isWizardMode: true),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Geri butonu
            if (_currentPageIndex > 0)
              TextButton.icon(
                onPressed: () => _onStepTapped(_currentPageIndex - 1),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Geri'),
              )
            else
              const SizedBox(width: 80), // spacer
              
            // İleri butonu
            if (_currentPageIndex < _phaseTitles.length - 1)
              ElevatedButton.icon(
                onPressed: () => _onStepTapped(_currentPageIndex + 1),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('İleri'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () {
                  // Profil tamamlandı, ana sayfaya dön
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check),
                label: const Text('Tamamla'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
