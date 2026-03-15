import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
import 'core/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase initialization with project credentials
  await Supabase.initialize(
    url: 'https://REMOVED.supabase.co',
    anonKey:
        'SUPABASE_ANON_KEY_REMOVED',
  );

  runApp(const ProviderScope(child: CareerFlowApp()));
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
        leading: IconButton(
          icon: const Icon(Icons.person_outline),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.rocket_launch_rounded,
              size: 80,
              color: Color(0xFF2196F3),
            ),
            const SizedBox(height: 24),
            const Text(
              'Welcome, Developer',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your autonomous CV engine is ready.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 48),
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
                  icon: const Icon(Icons.edit_document),
                  label: const Text(
                    'Profilini Oluştur (CV)',
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
          ],
        ),
      ),
    );
  }
}
