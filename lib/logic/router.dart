import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../ui/screens/login_screen.dart';
import '../ui/screens/register_screen.dart';
import '../ui/screens/main_layout.dart';
import '../ui/screens/onboarding_screen.dart';
import 'auth_provider.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: authProvider,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginScreen(),
        redirect: (context, state) {
          // If already authenticated
          if (authProvider.isAuthenticated) {
            return '/home';
          }
          // Check if onboarding is needed
          if (!authProvider.isOnboardingCompleted) {
            return '/onboarding';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
        redirect: (context, state) {
          if (authProvider.isAuthenticated) {
            return '/home';
          }
          if (!authProvider.isOnboardingCompleted) {
            return '/onboarding';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
        redirect: (context, state) {
          if (authProvider.isAuthenticated) {
            return '/home';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
        redirect: (context, state) {
          if (authProvider.isOnboardingCompleted) {
            return '/login'; // Or register, depending on flow
          }
          return null;
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainLayout(),
        redirect: (context, state) {
          if (!authProvider.isAuthenticated) {
            return '/login';
          }
          return null;
        },
      ),
    ],
  );
}
