import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../chat/presentation/chat_screen.dart';

// Simulated courier location
class CourierLocation {
  final double lat;
  final double lng;
  final double progress; // 0.0 to 1.0
  final String status;
  final int eta; // minutes

  const CourierLocation({
    required this.lat,
    required this.lng,
    required this.progress,
    required this.status,
    required this.eta,
  });
}

class LocationNotifier extends StateNotifier<CourierLocation> {
  Timer? _timer;
  int _step = 0;

  LocationNotifier()
      : super(const CourierLocation(
            lat: 48.8566,
            lng: 2.3522,
            progress: 0.15,
            status: 'Picking up your order',
            eta: 25)) {
    _startSimulation();
  }

  void _startSimulation() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      _step++;
      if (_step >= _locations.length) {
        _timer?.cancel();
        return;
      }
      state = _locations[_step];
    });
  }

  static const _locations = [
    CourierLocation(
        lat: 48.8566,
        lng: 2.3522,
        progress: 0.15,
        status: 'Picking up your order',
        eta: 25),
    CourierLocation(
        lat: 48.8576,
        lng: 2.3532,
        progress: 0.30,
        status: 'Order picked up!',
        eta: 20),
    CourierLocation(
        lat: 48.8586,
        lng: 2.3542,
        progress: 0.45,
        status: 'On the way',
        eta: 15),
    CourierLocation(
        lat: 48.8596,
        lng: 2.3552,
        progress: 0.60,
        status: 'On the way',
        eta: 10),
    CourierLocation(
        lat: 48.8606,
        lng: 2.3562,
        progress: 0.75,
        status: 'Almost there!',
        eta: 5),
    CourierLocation(
        lat: 48.8616,
        lng: 2.3572,
        progress: 0.90,
        status: 'Arriving now',
        eta: 1),
    CourierLocation(
        lat: 48.8626, lng: 2.3582, progress: 1.0, status: 'Delivered!', eta: 0),
  ];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final courierLocationProvider =
    StateNotifierProvider<LocationNotifier, CourierLocation>(
        (ref) => LocationNotifier());

class LiveMapScreen extends ConsumerWidget {
  const LiveMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(courierLocationProvider);

    return Scaffold(
      body: Stack(children: [
        // Simulated Map Background
        _SimulatedMap(progress: location.progress),

        // Top Overlay
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 16, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.background,
                  AppColors.background.withOpacity(0)
                ],
              ),
            ),
            child: Row(children: [
              GlassIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => context.pop(),
                  size: 44),
              const SizedBox(width: 14),
              Expanded(
                  child: GlassCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.secondary.withOpacity(0.5),
                            blurRadius: 8)
                      ],
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.5, 1.5),
                      duration: 1.seconds),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('LIVE TRACKING',
                            style: GoogleFonts.inter(
                                color: AppColors.secondary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1)),
                        Text(location.status,
                            style:
                                GoogleFonts.inter(fontWeight: FontWeight.w600)),
                      ])),
                  Text('${location.eta} min',
                      style: GoogleFonts.inter(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                ]),
              )),
            ]),
          ),
        ),

        // Bottom Panel
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _BottomPanel(location: location),
        ),

        // Chat FAB
        Positioned(
          bottom: 280,
          right: 20,
          child: GestureDetector(
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const ChatScreen())),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8))
                ],
              ),
              child: const Icon(Icons.chat_bubble_rounded, color: Colors.white),
            ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),
          ),
        ),
      ]),
    );
  }
}

class _SimulatedMap extends StatelessWidget {
  final double progress;

  const _SimulatedMap({required this.progress});

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(color: Color(0xFF1A2035)),
        child: Stack(children: [
          // Grid pattern
          CustomPaint(painter: _GridPainter(), size: Size.infinite),

          // Route path
          CustomPaint(
              painter: _RoutePainter(progress: progress), size: Size.infinite),

          // Restaurant marker
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            left: MediaQuery.of(context).size.width * 0.3,
            child: const _LocationMarker(
              icon: Icons.restaurant_rounded,
              color: AppColors.accent,
              label: 'Restaurant',
            ),
          ),

          // Destination marker
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.35,
            right: MediaQuery.of(context).size.width * 0.25,
            child: const _LocationMarker(
              icon: Icons.home_rounded,
              color: AppColors.secondary,
              label: 'Your Location',
            ),
          ),

          // Courier marker (animated position)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 500),
            builder: (ctx, value, _) {
              final size = MediaQuery.of(ctx).size;
              final startX = size.width * 0.3;
              final startY = size.height * 0.25;
              final endX = size.width * 0.75;
              final endY = size.height * 0.65;

              // Bezier curve path
              final control1X = size.width * 0.5;
              final control1Y = size.height * 0.3;
              final control2X = size.width * 0.6;
              final control2Y = size.height * 0.5;

              final x = _cubicBezier(startX, control1X, control2X, endX, value);
              final y = _cubicBezier(startY, control1Y, control2Y, endY, value);

              return Positioned(
                left: x - 25,
                top: y - 25,
                child: _CourierMarker(),
              );
            },
          ),
        ]),
      );

  double _cubicBezier(double p0, double p1, double p2, double p3, double t) {
    final mt = 1 - t;
    return mt * mt * mt * p0 +
        3 * mt * mt * t * p1 +
        3 * mt * t * t * p2 +
        t * t * t * p3;
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;

    const spacing = 50.0;
    for (var x = 0.0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoutePainter extends CustomPainter {
  final double progress;

  _RoutePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final startX = size.width * 0.3;
    final startY = size.height * 0.25;
    final endX = size.width * 0.75;
    final endY = size.height * 0.65;
    final control1X = size.width * 0.5;
    final control1Y = size.height * 0.3;
    final control2X = size.width * 0.6;
    final control2Y = size.height * 0.5;

    final path = Path()
      ..moveTo(startX, startY)
      ..cubicTo(control1X, control1Y, control2X, control2Y, endX, endY);

    // Background path
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, bgPaint);

    // Progress path
    final progressPaint = Paint()
      ..shader =
          const LinearGradient(colors: [AppColors.primary, AppColors.secondary])
              .createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final pathMetrics = path.computeMetrics().first;
    final progressPath =
        pathMetrics.extractPath(0, pathMetrics.length * progress);
    canvas.drawPath(progressPath, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _LocationMarker extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _LocationMarker(
      {required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) =>
      Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.5), blurRadius: 15)
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: AppColors.card, borderRadius: BorderRadius.circular(6)),
          child: Text(label,
              style:
                  GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600)),
        ),
      ]).animate().fadeIn().scale(begin: const Offset(0.8, 0.8));
}

class _CourierMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: AppColors.gradientPrimary,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 20)
          ],
        ),
        child: const Icon(Icons.delivery_dining_rounded,
            color: Colors.white, size: 26),
      ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
          begin: const Offset(1, 1),
          end: const Offset(1.1, 1.1),
          duration: 1.5.seconds);
}

class _BottomPanel extends StatelessWidget {
  final CourierLocation location;

  const _BottomPanel({required this.location});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.fromLTRB(
            20, 24, 20, MediaQuery.of(context).padding.bottom + 20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, -10))
          ],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Progress Bar
          Container(
            height: 6,
            decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(3)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: location.progress,
              child: Container(
                  decoration: BoxDecoration(
                      gradient: AppColors.gradientSecondary,
                      borderRadius: BorderRadius.circular(3))),
            ),
          ),

          const SizedBox(height: 20),

          // Courier Info
          Row(children: [
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(3),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: const OptimizedImage(
                    imageUrl: 'https://i.pravatar.cc/100?u=courier',
                    width: 54,
                    height: 54),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Pierre Laurent',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold, fontSize: 17)),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.star_rounded,
                        color: AppColors.accent, size: 16),
                    const SizedBox(width: 4),
                    Text('4.9',
                        style: GoogleFonts.inter(
                            color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(width: 8),
                    Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                            color: AppColors.textMuted,
                            shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text('Bicycle',
                        style: GoogleFonts.inter(
                            color: AppColors.textMuted, fontSize: 13)),
                  ]),
                ])),
            _ActionBtn(
                icon: Icons.call_rounded,
                color: AppColors.secondary,
                onTap: () {}),
            const SizedBox(width: 10),
            _ActionBtn(
                icon: Icons.chat_bubble_rounded,
                color: AppColors.primary,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ChatScreen()))),
          ]),

          const SizedBox(height: 20),

          // Order Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              const Icon(Icons.receipt_long_rounded,
                  color: AppColors.textMuted),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Order #12345',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    Text('Burger King Premium • 3 items',
                        style: GoogleFonts.inter(
                            color: AppColors.textMuted, fontSize: 12)),
                  ])),
              Text('€24.90',
                  style: GoogleFonts.inter(
                      color: AppColors.primary, fontWeight: FontWeight.bold)),
            ]),
          ),
        ]),
      ).animate().fadeIn().slideY(begin: 0.2, end: 0);
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: color.withOpacity(0.15), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 22),
        ),
      );
}
