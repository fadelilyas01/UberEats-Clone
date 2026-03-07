import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/mission/presentation/offer_screen.dart';
import 'features/delivery/presentation/active_delivery_screen.dart';
import 'core/utils/responsive.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: CourierApp()));
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (c, s) => const CourierDashboard()),
    GoRoute(path: '/offer', builder: (c, s) => const OfferScreen()),
    GoRoute(path: '/delivery', builder: (c, s) => const ActiveDeliveryScreen()),
  ],
);

class CourierApp extends StatelessWidget {
  const CourierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FoodFlow Courier',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeData(
        useMaterial3: true, brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF111827),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF10B981), brightness: Brightness.dark),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF111827), elevation: 0),
      ),
    );
  }
}

final isOnlineProvider = StateProvider<bool>((ref) => false);

class CourierDashboard extends ConsumerWidget {
  const CourierDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Responsive.init(context);
    final isOnline = ref.watch(isOnlineProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: Responsive.padding(horizontal: 20, vertical: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Hello, Pierre 👋', style: GoogleFonts.outfit(fontSize: Responsive.sp(24), fontWeight: FontWeight.bold)),
                Text(isOnline ? 'You\'re online' : 'You\'re offline', style: TextStyle(color: isOnline ? const Color(0xFF10B981) : Colors.grey, fontSize: Responsive.sp(14))),
              ]),
              GestureDetector(
                onTap: () => ref.read(isOnlineProvider.notifier).state = !isOnline,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.w(4), vertical: Responsive.h(1)),
                  decoration: BoxDecoration(
                    color: isOnline ? const Color(0xFF10B981).withAlpha(51) : Colors.grey.withAlpha(51),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: isOnline ? const Color(0xFF10B981) : Colors.grey),
                  ),
                  child: Row(children: [
                    Container(width: 12, height: 12, decoration: BoxDecoration(color: isOnline ? const Color(0xFF10B981) : Colors.grey, shape: BoxShape.circle)),
                    SizedBox(width: Responsive.w(2)),
                    Text(isOnline ? 'ONLINE' : 'OFFLINE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: Responsive.sp(12), color: isOnline ? const Color(0xFF10B981) : Colors.grey)),
                  ]),
                ),
              ),
            ]),
            
            SizedBox(height: Responsive.h(4)),
            
            // Stats
            Responsive.isTablet
                ? Row(children: [
                    const Expanded(child: _StatCard(icon: Icons.delivery_dining, label: 'Today', value: '12', color: Color(0xFF6366F1))),
                    SizedBox(width: Responsive.w(4)),
                    const Expanded(child: _StatCard(icon: Icons.euro, label: 'Earnings', value: '86.50 €', color: Color(0xFF10B981))),
                    SizedBox(width: Responsive.w(4)),
                    const Expanded(child: _StatCard(icon: Icons.star, label: 'Rating', value: '4.9', color: Colors.amber)),
                  ])
                : Column(children: [
                    Row(children: [
                      const Expanded(child: _StatCard(icon: Icons.delivery_dining, label: 'Today', value: '12', color: Color(0xFF6366F1))),
                      SizedBox(width: Responsive.w(4)),
                      const Expanded(child: _StatCard(icon: Icons.euro, label: 'Earnings', value: '86.50 €', color: Color(0xFF10B981))),
                    ]),
                    SizedBox(height: Responsive.h(2)),
                    const _StatCard(icon: Icons.star, label: 'Rating', value: '4.9', color: Colors.amber),
                  ]),
            
            const Spacer(),
            
            // Action Buttons
            if (isOnline) ...[
              SizedBox(width: double.infinity, height: Responsive.value(phone: 60, tablet: 70), child: ElevatedButton.icon(
                onPressed: () => context.push('/offer'),
                icon: Icon(Icons.notifications_active, size: Responsive.sp(24)),
                label: Text('Simulate Offer', style: GoogleFonts.outfit(fontSize: Responsive.sp(16), fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              )),
              SizedBox(height: Responsive.h(2)),
              SizedBox(width: double.infinity, height: Responsive.value(phone: 60, tablet: 70), child: OutlinedButton.icon(
                onPressed: () => context.push('/delivery'),
                icon: Icon(Icons.map, size: Responsive.sp(22)),
                label: Text('Demo Delivery', style: GoogleFonts.outfit(fontSize: Responsive.sp(14))),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF6366F1)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              )),
            ] else
              Center(child: Text('Go online to receive orders', style: TextStyle(color: Colors.grey, fontSize: Responsive.sp(16)))),
            
            SizedBox(height: Responsive.h(4)),
          ]),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Container(
      padding: Responsive.padding(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Container(padding: EdgeInsets.all(Responsive.w(3)), decoration: BoxDecoration(color: color.withAlpha(51), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: Responsive.sp(24))),
        SizedBox(width: Responsive.w(3)),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: Colors.grey, fontSize: Responsive.sp(12))),
          Text(value, style: GoogleFonts.outfit(fontSize: Responsive.sp(20), fontWeight: FontWeight.bold)),
        ]),
      ]),
    );
  }
}
