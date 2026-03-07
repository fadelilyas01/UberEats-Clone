import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/restaurant/presentation/restaurant_screen.dart';
import 'features/checkout/presentation/checkout_screen.dart';
import 'features/payment/presentation/payment_screen.dart';
import 'features/tracking/presentation/tracking_screen.dart';
import 'features/search/presentation/search_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/orders/presentation/orders_screen.dart';
import 'features/auth/presentation/auth_screens.dart';
import 'features/chat/presentation/chat_screen.dart';
import 'features/rating/presentation/rating_screen.dart';
import 'features/map/presentation/live_map_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    Stripe.publishableKey =
        'pk_test_51SymX58IQI5NhSPAnYySr8tyw5NmBAQp1uG13owkBRTKZM1d7sdbTZZfRaLnl3GsMAHyQoXZUt4W0uqClwqNNPg400fVXGYxd9';
    await Stripe.instance.applySettings();
  } catch (e) {
    print(
        "Warning: Firebase not initialized. Run 'flutterfire configure'. Error: $e");
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.background,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const ProviderScope(child: FoodFlowApp()));
}

// Router Configuration with smooth transitions
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    // Main App Routes
    GoRoute(
      path: '/',
      pageBuilder: (ctx, state) => const CustomTransitionPage(
        child: HomeScreen(),
        transitionsBuilder: _fadeTransition,
      ),
    ),
    GoRoute(
      path: '/restaurant/:id',
      pageBuilder: (ctx, state) => CustomTransitionPage(
        child: RestaurantScreen(id: state.pathParameters['id'] ?? ''),
        transitionsBuilder: _slideRightTransition,
      ),
    ),
    GoRoute(
      path: '/checkout',
      pageBuilder: (ctx, state) => const CustomTransitionPage(
        child: CheckoutScreen(),
        transitionsBuilder: _slideUpTransition,
      ),
    ),
    GoRoute(
      path: '/payment',
      pageBuilder: (ctx, state) => const CustomTransitionPage(
        child: PaymentScreen(),
        transitionsBuilder: _slideRightTransition,
      ),
    ),
    GoRoute(
      path: '/tracking',
      pageBuilder: (ctx, state) => const CustomTransitionPage(
        child: TrackingScreen(),
        transitionsBuilder: _scaleTransition,
      ),
    ),
    GoRoute(
      path: '/search',
      pageBuilder: (ctx, state) => const CustomTransitionPage(
        child: SearchScreen(),
        transitionsBuilder: _fadeSlideTransition,
      ),
    ),
    GoRoute(
      path: '/orders',
      pageBuilder: (ctx, state) => const CustomTransitionPage(
        child: OrdersScreen(),
        transitionsBuilder: _slideRightTransition,
      ),
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (ctx, state) => const CustomTransitionPage(
        child: ProfileScreen(),
        transitionsBuilder: _slideRightTransition,
      ),
    ),

    // Auth Routes
    GoRoute(
      path: '/login',
      pageBuilder: (ctx, state) => const CustomTransitionPage(
        child: LoginScreen(),
        transitionsBuilder: _fadeTransition,
      ),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (ctx, state) => const CustomTransitionPage(
        child: RegisterScreen(),
        transitionsBuilder: _slideRightTransition,
      ),
    ),

    // Chat Route
    GoRoute(
      path: '/chat',
      pageBuilder: (ctx, state) => const CustomTransitionPage(
        child: ChatScreen(),
        transitionsBuilder: _slideUpTransition,
      ),
    ),

    // Rating Route
    GoRoute(
      path: '/rating',
      pageBuilder: (ctx, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return CustomTransitionPage(
          child: RatingScreen(
            orderId: extra['orderId'] ?? '',
            restaurantName: extra['restaurantName'] ?? 'Restaurant',
            courierName: extra['courierName'] ?? 'Courier',
          ),
          transitionsBuilder: _scaleTransition,
        );
      },
    ),

    // Live Map Route
    GoRoute(
      path: '/live-map',
      pageBuilder: (ctx, state) => const CustomTransitionPage(
        child: LiveMapScreen(),
        transitionsBuilder: _fadeTransition,
      ),
    ),
  ],
);

// Transition Builders
Widget _fadeTransition(BuildContext ctx, Animation<double> animation,
        Animation<double> secondary, Widget child) =>
    FadeTransition(opacity: animation, child: child);

Widget _slideRightTransition(BuildContext ctx, Animation<double> animation,
        Animation<double> secondary, Widget child) =>
    SlideTransition(
      position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    );

Widget _slideUpTransition(BuildContext ctx, Animation<double> animation,
        Animation<double> secondary, Widget child) =>
    SlideTransition(
      position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    );

Widget _scaleTransition(BuildContext ctx, Animation<double> animation,
        Animation<double> secondary, Widget child) =>
    FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween(begin: 0.95, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      ),
    );

Widget _fadeSlideTransition(BuildContext ctx, Animation<double> animation,
        Animation<double> secondary, Widget child) =>
    FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.05), end: Offset.zero).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      ),
    );

class FoodFlowApp extends StatelessWidget {
  const FoodFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FoodFlow Pro',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.darkTheme,
      routerConfig: _router,
    );
  }
}
