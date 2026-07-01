import 'package:go_router/go_router.dart';
import '../../presentation/features/main/main_screen.dart';
import '../../presentation/features/onboarding/onboarding_screen.dart';

class AppRouter {
  static GoRouter createRouter(bool hasSeenOnboarding) {
    return GoRouter(
      initialLocation: hasSeenOnboarding ? '/' : '/onboarding',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const MainScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
      ],
    );
  }
}
