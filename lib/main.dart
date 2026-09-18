import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/auth_service.dart';
import 'services/planner_service.dart';
import 'services/profile_service.dart';
import 'services/supabase_config.dart';
import 'theme/stitch_theme.dart';
import 'views/auth/auth_screen.dart';
import 'views/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase Backend
  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      // ignore: deprecated_member_use
      anonKey: SupabaseConfig.anonKey,
    );
  } catch (e) {
    debugPrint('Supabase init warning: $e');
  }

  // Inisialisasi service aplikasi
  final authService = AuthService();
  final plannerService = PlannerService();
  final profileService = ProfileService();

  await authService.initialize();
  await plannerService.initialize();
  await profileService.initialize();

  runApp(const BranchPlannerApp());
}

class BranchPlannerApp extends StatelessWidget {
  const BranchPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final profileService = ProfileService();

    return ListenableBuilder(
      listenable: Listenable.merge([authService, profileService]),
      builder: (context, _) {
        final isDark = profileService.profile.themeMode != 'notion_light';

        return MaterialApp(
          title: 'Branching Decision Planner',
          debugShowCheckedModeBanner: false,
          theme: isDark ? StitchTheme.darkTheme : StitchTheme.lightTheme,
          home: authService.isLoggedIn
              ? const MainNavigationScreen()
              : const AuthScreen(),
        );
      },
    );
  }
}
