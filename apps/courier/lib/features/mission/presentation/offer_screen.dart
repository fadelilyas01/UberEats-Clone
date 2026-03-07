import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/utils/responsive.dart';

// Timer State
final offerTimerProvider = StateNotifierProvider<OfferTimerNotifier, int>((ref) => OfferTimerNotifier());

class OfferTimerNotifier extends StateNotifier<int> {
  Timer? _timer;
  OfferTimerNotifier() : super(30);

  void start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state > 0) {
        state--;
      } else {
        _timer?.cancel();
      }
    });
  }

  void reset() { _timer?.cancel(); state = 30; }
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }
}

class OfferScreen extends ConsumerStatefulWidget {
  const OfferScreen({super.key});
  @override
  ConsumerState<OfferScreen> createState() => _OfferScreenState();
}

class _OfferScreenState extends ConsumerState<OfferScreen> {
  @override
  void initState() { super.initState(); Future.microtask(() => ref.read(offerTimerProvider.notifier).start()); }
  @override
  void dispose() { ref.read(offerTimerProvider.notifier).reset(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final seconds = ref.watch(offerTimerProvider);
    final expired = seconds == 0;

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: SafeArea(
        child: Padding(
          padding: Responsive.padding(horizontal: 24, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: Responsive.isTablet ? 500 : double.infinity),
              child: Column(children: [
                // Timer
                Stack(alignment: Alignment.center, children: [
                  SizedBox(
                    width: Responsive.value(phone: 120, tablet: 150),
                    height: Responsive.value(phone: 120, tablet: 150),
                    child: CircularProgressIndicator(value: seconds / 30, strokeWidth: 8, backgroundColor: Colors.grey[800], valueColor: AlwaysStoppedAnimation(expired ? Colors.red : const Color(0xFF10B981))),
                  ),
                  Text('$seconds', style: GoogleFonts.outfit(fontSize: Responsive.sp(48), fontWeight: FontWeight.bold, color: expired ? Colors.red : Colors.white)),
                ]).animate().scale(duration: 300.ms),

                SizedBox(height: Responsive.h(4)),

                // Earnings
                Text('12.50 €', style: GoogleFonts.outfit(fontSize: Responsive.sp(56), fontWeight: FontWeight.w800, color: const Color(0xFF10B981))).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 800.ms),

                SizedBox(height: Responsive.h(1)),
                Text('2.3 km • 15 min', style: TextStyle(color: Colors.grey, fontSize: Responsive.sp(16))),

                SizedBox(height: Responsive.h(4)),

                // Route Info
                Container(
                  padding: Responsive.padding(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(20)),
                  child: Column(children: [
                    const _RoutePoint(icon: Icons.store, color: Colors.orange, title: 'Burger King', subtitle: '12 Rue de Rivoli'),
                    Container(margin: EdgeInsets.symmetric(vertical: Responsive.h(1)), width: 2, height: Responsive.h(4), color: Colors.grey[700]),
                    const _RoutePoint(icon: Icons.location_on, color: Color(0xFF6366F1), title: 'Jean Dupont', subtitle: '45 Av. des Champs-Élysées'),
                  ]),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

                const Spacer(),

                // Actions
                if (!expired) ...[
                  SizedBox(width: double.infinity, height: Responsive.value(phone: 64, tablet: 72), child: ElevatedButton(
                    onPressed: () => context.go('/delivery'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                    child: Text('ACCEPTER LA COURSE', style: GoogleFonts.outfit(fontSize: Responsive.sp(20), fontWeight: FontWeight.bold)),
                  )).animate().slideY(begin: 0.5, end: 0).fadeIn(),
                  SizedBox(height: Responsive.h(2)),
                  TextButton(onPressed: () => context.pop(), child: Text('Refuser', style: TextStyle(color: Colors.grey, fontSize: Responsive.sp(16)))),
                ] else
                  Text('Offre expirée', style: TextStyle(color: Colors.red, fontSize: Responsive.sp(18), fontWeight: FontWeight.bold)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoutePoint extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle;
  const _RoutePoint({required this.icon, required this.color, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Row(children: [
      Container(padding: EdgeInsets.all(Responsive.w(3)), decoration: BoxDecoration(color: color.withAlpha(51), shape: BoxShape.circle), child: Icon(icon, color: color, size: Responsive.sp(24))),
      SizedBox(width: Responsive.w(4)),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.outfit(fontSize: Responsive.sp(16), fontWeight: FontWeight.bold)),
        Text(subtitle, style: TextStyle(color: Colors.grey, fontSize: Responsive.sp(13)), overflow: TextOverflow.ellipsis),
      ])),
    ]);
  }
}
