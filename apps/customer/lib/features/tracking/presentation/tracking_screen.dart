import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/premium_widgets.dart';

// Tracking State
class TrackingState {
  final int currentStep;
  final String eta;
  final double progress;

  const TrackingState(
      {this.currentStep = 0, this.eta = '25 min', this.progress = 0});

  TrackingState copyWith({int? currentStep, String? eta, double? progress}) =>
      TrackingState(
        currentStep: currentStep ?? this.currentStep,
        eta: eta ?? this.eta,
        progress: progress ?? this.progress,
      );
}

class TrackingNotifier extends StateNotifier<TrackingState> {
  TrackingNotifier() : super(const TrackingState()) {
    _startSimulation();
  }

  void _startSimulation() async {
    final steps = [
      (0, '25 min', 0.0),
      (1, '20 min', 0.2),
      (2, '15 min', 0.4),
      (3, '8 min', 0.7),
      (4, 'Arrivée !', 1.0),
    ];

    for (final step in steps) {
      await Future.delayed(Duration(seconds: 3 + step.$1));
      state =
          TrackingState(currentStep: step.$1, eta: step.$2, progress: step.$3);
    }
  }
}

final trackingProvider = StateNotifierProvider<TrackingNotifier, TrackingState>(
    (ref) => TrackingNotifier());

class TrackingScreen extends ConsumerWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracking = ref.watch(trackingProvider);
    final isTablet = Responsive.isTablet(context);

    final steps = [
      'Commande Confirmée',
      'En Préparation',
      'En Route',
      'À Proximité',
      'Livrée'
    ];

    return Scaffold(
      body: Stack(children: [
        // Background orbs
        const BackgroundOrb(
            size: 300,
            color: AppColors.secondary,
            alignment: Alignment(-1.2, -0.5)),
        const BackgroundOrb(
            size: 250,
            color: AppColors.primary,
            alignment: Alignment(1.5, 0.8)),

        SafeArea(
            child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              GlassIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => context.go('/'),
                  size: 44),
              const SizedBox(width: 16),
              Expanded(
                  child: Text('Suivi de Commande',
                      style: GoogleFonts.inter(
                          fontSize: 22, fontWeight: FontWeight.bold))),
              GlassIconButton(
                  icon: Icons.help_outline_rounded, onTap: () {}, size: 44),
            ]),
          ),

          // Content
          Expanded(
            child: isTablet
                ? Row(children: [
                    Expanded(child: _MapSection(progress: tracking.progress)),
                    Expanded(
                        child: _TrackingDetails(
                            steps: steps,
                            currentStep: tracking.currentStep,
                            eta: tracking.eta)),
                  ])
                : Column(children: [
                    Expanded(
                        flex: 2,
                        child: _MapSection(progress: tracking.progress)),
                    Expanded(
                        flex: 3,
                        child: _TrackingDetails(
                            steps: steps,
                            currentStep: tracking.currentStep,
                            eta: tracking.eta)),
                  ]),
          ),
        ])),
      ]),
    );
  }
}

class _MapSection extends StatelessWidget {
  final double progress;
  const _MapSection({required this.progress});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Stack(children: [
          // Map placeholder with animation
          Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 500),
                  builder: (ctx, value, _) =>
                      Stack(alignment: Alignment.center, children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 8,
                        backgroundColor: AppColors.surface,
                        valueColor:
                            const AlwaysStoppedAnimation(AppColors.secondary),
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientSecondary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.secondary.withOpacity(0.4),
                              blurRadius: 20)
                        ],
                      ),
                      child: const Icon(Icons.delivery_dining_rounded,
                          color: Colors.white, size: 36),
                    ),
                  ]),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.05, 1.05),
                    duration: 2.seconds),
                const SizedBox(height: 20),
                Text('${(progress * 100).toInt()}% Complété',
                    style: GoogleFonts.inter(color: AppColors.textMuted)),
              ])),

          // Live badge
          Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
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
                          ])),
                  const SizedBox(width: 8),
                  Text('EN DIRECT',
                      style: GoogleFonts.inter(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12)),
                ]),
              )),
        ]),
      ).animate().fadeIn();
}

class _TrackingDetails extends StatelessWidget {
  final List<String> steps;
  final int currentStep;
  final String eta;

  const _TrackingDetails(
      {required this.steps, required this.currentStep, required this.eta});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Statut de la Commande',
              style:
                  GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // Progress Steps
          ...steps.asMap().entries.map((e) {
            final isComplete = e.key <= currentStep;
            final isCurrent = e.key == currentStep;

            return Padding(
              padding:
                  EdgeInsets.only(bottom: e.key < steps.length - 1 ? 16 : 0),
              child: Row(children: [
                // Step indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: isComplete ? AppColors.gradientSecondary : null,
                    color: isComplete ? null : AppColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                                color: AppColors.secondary.withOpacity(0.5),
                                blurRadius: 15)
                          ]
                        : null,
                  ),
                  child: Icon(
                    isComplete ? Icons.check_rounded : Icons.circle,
                    color: isComplete ? Colors.white : AppColors.textMuted,
                    size: isComplete ? 18 : 8,
                  ),
                ),
                const SizedBox(width: 16),

                // Step label
                Expanded(
                    child: Text(e.value,
                        style: GoogleFonts.inter(
                          fontWeight:
                              isComplete ? FontWeight.w600 : FontWeight.normal,
                          color:
                              isComplete ? Colors.white : AppColors.textMuted,
                          fontSize: 15,
                        ))),

                // Current badge
                if (isCurrent)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text('Maintenant',
                        style: GoogleFonts.inter(
                            color: AppColors.secondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
              ])
                  .animate(delay: Duration(milliseconds: e.key * 100))
                  .fadeIn()
                  .slideX(begin: 0.1, end: 0),
            );
          }),

          const Spacer(),

          // Courier Info
          _CourierCard(),

          const SizedBox(height: 20),

          // ETA
          Center(
                  child: Column(children: [
            Text('Arrivée Estimée',
                style: GoogleFonts.inter(
                    color: AppColors.textMuted, fontSize: 13)),
            const SizedBox(height: 6),
            ShaderMask(
              shaderCallback: (b) =>
                  AppColors.gradientSecondary.createShader(b),
              child: Text(eta,
                  style: GoogleFonts.inter(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ]))
              .animate()
              .fadeIn(delay: 400.ms)
              .scale(begin: const Offset(0.9, 0.9)),
        ]),
      );
}

class _CourierCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          // Avatar
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.gradientPrimary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: AppColors.primary.withOpacity(0.4), blurRadius: 12)
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: const OptimizedImage(
                  imageUrl: 'https://i.pravatar.cc/100?u=courier',
                  width: 56,
                  height: 56),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Pierre Laurent',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold, fontSize: 16)),
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
                          color: AppColors.textMuted, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text('2,345 livraisons',
                      style: GoogleFonts.inter(
                          color: AppColors.textMuted, fontSize: 13)),
                ]),
              ])),

          // Action buttons
          Row(children: [
            _ActionButton(
                icon: Icons.call_rounded,
                color: AppColors.secondary,
                onTap: () {}),
            const SizedBox(width: 10),
            _ActionButton(
                icon: Icons.chat_bubble_rounded,
                color: AppColors.primary,
                onTap: () {}),
          ]),
        ]),
      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0);
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton(
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
