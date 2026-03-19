import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/auth_screen.dart';
import 'features/cv_static/presentation/screens/profile_screen.dart';
import 'features/auth/presentation/screens/update_password_screen.dart';

import 'features/cv_builder/presentation/screens/cv_builder_wizard_screen.dart';
import 'features/cv_builder/presentation/providers/education_provider.dart';
import 'features/cv_builder/presentation/providers/course_provider.dart';
import 'features/cv_builder/presentation/providers/language_provider.dart';
import 'features/cv_builder/presentation/providers/project_provider.dart';
import 'features/cv_builder/presentation/providers/community_provider.dart';
import 'features/cv_builder/presentation/providers/experience_provider.dart';
import 'features/cv_builder/presentation/screens/github_integration_screen.dart';
import 'core/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/pdf_export/services/pdf_generator_service.dart';
import 'features/pdf_export/presentation/screens/pdf_preview_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize SharedPreferences
  final sharedPrefs = await SharedPreferences.getInstance();

  // Supabase initialization with project credentials from environment variables
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      ],
      child: const CareerFlowApp(),
    ),
  );
}

class CareerFlowApp extends ConsumerWidget {
  const CareerFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'CareerFlow',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.light,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('tr', 'TR')],
      locale: const Locale('tr', 'TR'),
      home: authState.when(
        data: (state) {
          if (state.event == AuthChangeEvent.passwordRecovery) {
            return const UpdatePasswordScreen();
          }
          if (state.session != null) {
            return const HomeScreen();
          }
          return const AuthScreen();
        },
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, stack) =>
            Scaffold(body: Center(child: Text('Error: $err'))),
      ),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Prefetch user profile in background to eliminate ProfileScreen loading delay
    ref.watch(currentUserProfileProvider);
    
    // Prefetch CV Builder lists to eliminate loading delay
    ref.watch(educationListProvider);
    ref.watch(courseListProvider);
    ref.watch(languageListProvider);
    ref.watch(projectListProvider);
    ref.watch(communityListProvider);
    ref.watch(experienceListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CareerFlow'),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.person_outline, size: 24),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(
                  navigationStartTime: DateTime.now(),
                ),
              ),
            );
          },
        ),
      ),
    ),
        actions: [
          IconButton(
            icon: Icon(
              ref.watch(themeProvider) == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CvBuilderWizardScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: const Text(
                    'Kariyer Yolculuğunu Yönet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 64),
            const Icon(
              Icons.rocket_launch_rounded,
              size: 80,
              color: Color(0xFF2196F3),
            ),
            const SizedBox(height: 24),
            const Text(
              'Hoş Geldin, Geliştirici',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Otonom CV motorun hazır.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTemplateSelection(context),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showTemplateSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CV Şablonu Seçin',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Kariyer hedeflerinize en uygun tasarımı seçerek başlayın.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 220,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _TemplateCard(
                    title: 'Modern Tech',
                    preview: const _ModernPreview(),
                    color: Colors.blue,
                    onTap: () => _startWithTemplate(context, CvTemplate.modernTech),
                  ),
                  _TemplateCard(
                    title: 'Professional',
                    preview: const _ProfessionalPreview(),
                    color: Colors.indigo,
                    onTap: () => _startWithTemplate(context, CvTemplate.professional),
                  ),
                  _TemplateCard(
                    title: 'Creative Grid',
                    preview: const _CreativePreview(),
                    color: Colors.purple,
                    onTap: () => _startWithTemplate(context, CvTemplate.creativeGrid),
                  ),
                  _TemplateCard(
                    title: 'Minimalist',
                    preview: const _MinimalistPreview(),
                    color: Colors.teal,
                    onTap: () => _startWithTemplate(context, CvTemplate.minimalist),
                  ),
                  _TemplateCard(
                    title: 'ATS Optimized (9.5)',
                    preview: const _AtsOptimizedPreview(),
                    color: Colors.orange,
                    onTap: () => _startWithTemplate(context, CvTemplate.atsOptimized),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _startWithTemplate(BuildContext context, CvTemplate template) {
    Navigator.pop(context); // Close sheet
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfPreviewScreen(template: template),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final String title;
  final Widget preview;
  final Color color;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.title,
    required this.preview,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: preview,
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernPreview extends StatelessWidget {
  const _ModernPreview();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            color: Colors.blue.shade50,
            padding: const EdgeInsets.all(4),
            child: Column(
              children: [
                Container(height: 12, width: 12, decoration: BoxDecoration(color: Colors.blue.shade200, shape: BoxShape.circle)),
                const SizedBox(height: 4),
                const Text('D.Tarih', style: TextStyle(fontSize: 4, fontWeight: FontWeight.bold, color: Colors.blue)),
                const SizedBox(height: 8),
                const Text('Sosyal', style: TextStyle(fontSize: 4, fontWeight: FontWeight.bold, color: Colors.blue)),
                Container(height: 1.5, width: 20, color: Colors.blue.shade100),
                const Spacer(),
                const Text('Yetenek', style: TextStyle(fontSize: 4, fontWeight: FontWeight.bold, color: Colors.blue)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('AD SOYAD', style: TextStyle(fontSize: 5, fontWeight: FontWeight.bold, color: Colors.blue)),
                  Container(height: 1.5, width: 40, color: Colors.grey.shade200),
                  const SizedBox(height: 8),
                  // Education Section
                  const Text('EĞİTİM', style: TextStyle(fontSize: 4, fontWeight: FontWeight.bold, color: Colors.grey)),
                  Container(height: 10, width: double.infinity, color: Colors.grey.shade50),
                  const SizedBox(height: 8),
                  // Experience Section
                  const Text('DENEYİM', style: TextStyle(fontSize: 4, fontWeight: FontWeight.bold, color: Colors.grey)),
                  Container(height: 20, width: double.infinity, color: Colors.grey.shade50),
                  const SizedBox(height: 8),
                  // Projects Section
                  const Text('PROJELER', style: TextStyle(fontSize: 4, fontWeight: FontWeight.bold, color: Colors.grey)),
                  Row(
                    children: [
                      Expanded(child: Container(height: 20, color: Colors.grey.shade50, child: const Center(child: Text('P1', style: TextStyle(fontSize: 4, color: Colors.grey))))),
                      const SizedBox(width: 4),
                      Expanded(child: Container(height: 20, color: Colors.grey.shade50, child: const Center(child: Text('P2', style: TextStyle(fontSize: 4, color: Colors.grey))))),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfessionalPreview extends StatelessWidget {
  const _ProfessionalPreview();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text('AD SOYAD', style: TextStyle(fontSize: 6, fontWeight: FontWeight.bold, color: Colors.indigo)),
            const Text('01.01.1990 | linkedin.com/in/user', style: TextStyle(fontSize: 3.5, color: Colors.grey)),
            const SizedBox(height: 8),
            // Experience
            Row(
              children: [
                const Text('İŞ DENEYİMİ', style: TextStyle(fontSize: 4, fontWeight: FontWeight.bold, color: Colors.indigo)),
                const Expanded(child: Divider(indent: 4, height: 1, thickness: 0.5)),
              ],
            ),
            const SizedBox(height: 4),
            Container(height: 25, width: double.infinity, color: Colors.grey.shade50, padding: const EdgeInsets.all(2), child: const Text('Kıdemli Yazılımcı @ Şirket A\n• Proje yönetimi ve geliştirme...', style: TextStyle(fontSize: 3, color: Colors.grey))),
            const SizedBox(height: 8),
            // Education
            Row(
              children: [
                const Text('EĞİTİM', style: TextStyle(fontSize: 4, fontWeight: FontWeight.bold, color: Colors.indigo)),
                const Expanded(child: Divider(indent: 4, height: 1, thickness: 0.5)),
              ],
            ),
            const SizedBox(height: 4),
            Container(height: 15, width: double.infinity, color: Colors.grey.shade50, padding: const EdgeInsets.all(2), child: const Text('Bilgisayar Mühendisliği @ Üniversite B', style: TextStyle(fontSize: 3, color: Colors.grey))),
            const SizedBox(height: 8),
            // Projects
            Row(
              children: [
                const Text('PROJELER', style: TextStyle(fontSize: 4, fontWeight: FontWeight.bold, color: Colors.indigo)),
                const Expanded(child: Divider(indent: 4, height: 1, thickness: 0.5)),
              ],
            ),
            const SizedBox(height: 4),
            Container(height: 15, width: double.infinity, color: Colors.grey.shade50),
          ],
        ),
      ),
    );
  }
}

class _CreativePreview extends StatelessWidget {
  const _CreativePreview();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Column(
        children: [
          Container(
            height: 40,
            width: double.infinity,
            color: Colors.purple.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(height: 25, width: 25, decoration: const BoxDecoration(color: Colors.purple, shape: BoxShape.circle), child: const Center(child: Text('USER', style: TextStyle(fontSize: 4, color: Colors.white, fontWeight: FontWeight.bold)))),
                const SizedBox(width: 8),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AD SOYAD', style: TextStyle(fontSize: 5, fontWeight: FontWeight.bold, color: Colors.purple)),
                    Text('Crea-Dev @ Portfolio', style: TextStyle(fontSize: 3.5, color: Colors.purple)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('DENEYİM', style: TextStyle(fontSize: 4, fontWeight: FontWeight.bold, color: Colors.purple)),
                        Container(height: 25, width: double.infinity, decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(2))),
                        const SizedBox(height: 6),
                        const Text('PROJELER', style: TextStyle(fontSize: 4, fontWeight: FontWeight.bold, color: Colors.purple)),
                        Container(height: 25, width: double.infinity, decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(2))),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      children: [
                        const Text('YETENEK', style: TextStyle(fontSize: 4, fontWeight: FontWeight.bold, color: Colors.purple)),
                        const SizedBox(height: 4),
                        Container(height: 8, width: double.infinity, color: Colors.purple.shade50),
                        const SizedBox(height: 2),
                        Container(height: 8, width: double.infinity, color: Colors.purple.shade50),
                        const Spacer(),
                        const Text('DOĞUM T.', style: TextStyle(fontSize: 3.5, color: Colors.grey)),
                        const Text('19.05.95', style: TextStyle(fontSize: 3.5, color: Colors.purple)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MinimalistPreview extends StatelessWidget {
  const _MinimalistPreview();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AD SOYAD', style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: 1.5)),
            const Text('19.05.1995 • Ankara • @SocialHandle', style: TextStyle(fontSize: 3.5, color: Colors.grey)),
            const SizedBox(height: 12),
            // Deneyim
            const Text('DENEYİM —', style: TextStyle(fontSize: 4, fontWeight: FontWeight.bold, color: Colors.teal)),
            const SizedBox(height: 4),
            Container(height: 12, width: double.infinity, color: Colors.grey.shade50),
            Container(height: 12, width: double.infinity, color: Colors.grey.shade50),
            const SizedBox(height: 10),
            // Projeler
            const Text('PROJELER —', style: TextStyle(fontSize: 4, fontWeight: FontWeight.bold, color: Colors.teal)),
            const SizedBox(height: 4),
            Container(height: 25, width: double.infinity, color: Colors.grey.shade50),
            const Spacer(),
            // Eğitim
            const Text('EĞİTİM —', style: TextStyle(fontSize: 4, fontWeight: FontWeight.bold, color: Colors.teal)),
            const Text('Üniversite - Fakülte', style: TextStyle(fontSize: 3.5, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
class _AtsOptimizedPreview extends StatelessWidget {
  const _AtsOptimizedPreview();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Header
            Container(height: 8, width: 60, color: Colors.black87),
            const SizedBox(height: 4),
            Container(height: 3, width: 80, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            // Section 1: Summary
            Align(alignment: Alignment.centerLeft, child: Container(height: 5, width: 45, color: Colors.blue.shade300)),
            const Divider(height: 6, thickness: 0.5),
            Container(height: 15, width: double.infinity, color: Colors.grey.shade50),
            const SizedBox(height: 10),
            // Section 2: Experience
            Align(alignment: Alignment.centerLeft, child: Container(height: 5, width: 45, color: Colors.blue.shade300)),
            const Divider(height: 6, thickness: 0.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(height: 5, width: 35, color: Colors.grey.shade400),
                Container(height: 4, width: 25, color: Colors.grey.shade300),
              ],
            ),
            const SizedBox(height: 2),
            Container(height: 15, width: double.infinity, color: Colors.grey.shade50),
            const Spacer(),
            // Section 3: Education
            Align(alignment: Alignment.centerLeft, child: Container(height: 5, width: 45, color: Colors.blue.shade300)),
            const Divider(height: 6, thickness: 0.5),
            Container(height: 10, width: double.infinity, color: Colors.grey.shade50),
          ],
        ),
      ),
    );
  }
}
