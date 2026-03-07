import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/premium_widgets.dart';

// Rating State
class RatingState {
  final double rating;
  final String? comment;
  final List<String> selectedTags;
  final double tipAmount;

  const RatingState({
    this.rating = 0,
    this.comment,
    this.selectedTags = const [],
    this.tipAmount = 0,
  });

  RatingState copyWith(
          {double? rating,
          String? comment,
          List<String>? selectedTags,
          double? tipAmount}) =>
      RatingState(
        rating: rating ?? this.rating,
        comment: comment ?? this.comment,
        selectedTags: selectedTags ?? this.selectedTags,
        tipAmount: tipAmount ?? this.tipAmount,
      );
}

final ratingStateProvider =
    StateProvider<RatingState>((ref) => const RatingState());

class RatingScreen extends ConsumerWidget {
  final String orderId;
  final String restaurantName;
  final String courierName;

  const RatingScreen({
    super.key,
    required this.orderId,
    required this.restaurantName,
    required this.courierName,
  });

  static const _positiveTags = [
    'Fast Delivery',
    'Great Food',
    'Hot & Fresh',
    'Nice Courier',
    'Good Packaging',
    'On Time'
  ];
  static const _tipAmounts = [0.0, 1.0, 2.0, 5.0];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ratingStateProvider);

    return Scaffold(
      body: Stack(children: [
        const BackgroundOrb(
            size: 300,
            color: AppColors.secondary,
            alignment: Alignment(-1, -0.5)),
        const BackgroundOrb(
            size: 250, color: AppColors.accent, alignment: Alignment(1.5, 0.8)),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const SizedBox(height: 20),

              // Success Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientSecondary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.secondary.withOpacity(0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 10))
                  ],
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 50),
              ).animate().scale(
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                  curve: Curves.elasticOut,
                  duration: 600.ms),

              const SizedBox(height: 24),

              Text('Order Delivered!',
                      style: GoogleFonts.inter(
                          fontSize: 28, fontWeight: FontWeight.bold))
                  .animate()
                  .fadeIn(delay: 200.ms),
              const SizedBox(height: 8),
              Text('Your order from $restaurantName has arrived',
                      style: GoogleFonts.inter(
                          color: AppColors.textMuted, fontSize: 15),
                      textAlign: TextAlign.center)
                  .animate()
                  .fadeIn(delay: 250.ms),

              const SizedBox(height: 40),

              // Rating Section
              GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(children: [
                  Text('How was your experience?',
                      style: GoogleFonts.inter(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  // Star Rating
                  _StarRating(
                    rating: state.rating,
                    onRatingChanged: (r) => ref
                        .read(ratingStateProvider.notifier)
                        .state = state.copyWith(rating: r),
                  ),

                  const SizedBox(height: 16),

                  // Rating Label
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _getRatingLabel(state.rating),
                      key: ValueKey(state.rating),
                      style: GoogleFonts.inter(
                          color: _getRatingColor(state.rating),
                          fontWeight: FontWeight.w600,
                          fontSize: 16),
                    ),
                  ),
                ]),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 20),

              // Tags Section
              if (state.rating > 0)
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('What did you like?',
                            style: GoogleFonts.inter(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _positiveTags
                              .map((tag) => _SelectableTag(
                                    label: tag,
                                    isSelected:
                                        state.selectedTags.contains(tag),
                                    onTap: () {
                                      final current = state.selectedTags;
                                      if (current.contains(tag)) {
                                        ref
                                                .read(ratingStateProvider.notifier)
                                                .state =
                                            state.copyWith(
                                                selectedTags: current
                                                    .where((t) => t != tag)
                                                    .toList());
                                      } else {
                                        ref
                                            .read(ratingStateProvider.notifier)
                                            .state = state.copyWith(selectedTags: [
                                          ...current,
                                          tag
                                        ]);
                                      }
                                    },
                                  ))
                              .toList(),
                        ),
                      ]),
                ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 20),

              // Tip Section
              GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.volunteer_activism_rounded,
                              color: AppColors.accent, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text('Tip your courier',
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16)),
                              Text(courierName,
                                  style: GoogleFonts.inter(
                                      color: AppColors.textMuted,
                                      fontSize: 13)),
                            ])),
                      ]),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _tipAmounts
                            .map((amount) => _TipButton(
                                  amount: amount,
                                  isSelected: state.tipAmount == amount,
                                  onTap: () => ref
                                          .read(ratingStateProvider.notifier)
                                          .state =
                                      state.copyWith(tipAmount: amount),
                                ))
                            .toList(),
                      ),
                    ]),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 20),

              // Comment Section
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  maxLines: 3,
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Add a comment (optional)',
                    hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
                    border: InputBorder.none,
                  ),
                  onChanged: (v) => ref
                      .read(ratingStateProvider.notifier)
                      .state = state.copyWith(comment: v),
                ),
              ).animate().fadeIn(delay: 450.ms),

              const SizedBox(height: 32),

              // Submit Button
              GradientButton(
                text: state.tipAmount > 0
                    ? 'Submit & Pay €${state.tipAmount.toStringAsFixed(2)} Tip'
                    : 'Submit Rating',
                gradient: AppColors.gradientSecondary,
                onPressed: () => _submitRating(context, state),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Skip for now',
                    style: GoogleFonts.inter(color: AppColors.textMuted)),
              ).animate().fadeIn(delay: 550.ms),

              const SizedBox(height: 40),
            ]),
          ),
        ),
      ]),
    );
  }

  String _getRatingLabel(double rating) {
    if (rating == 0) return 'Tap to rate';
    if (rating <= 1) return 'Terrible 😞';
    if (rating <= 2) return 'Poor 😕';
    if (rating <= 3) return 'Okay 😐';
    if (rating <= 4) return 'Good 😊';
    return 'Amazing! 🤩';
  }

  Color _getRatingColor(double rating) {
    if (rating == 0) return AppColors.textMuted;
    if (rating <= 2) return AppColors.error;
    if (rating <= 3) return AppColors.accent;
    return AppColors.secondary;
  }

  void _submitRating(BuildContext context, RatingState state) {
    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.15),
                shape: BoxShape.circle),
            child: const Icon(Icons.check_circle_rounded,
                color: AppColors.secondary, size: 40),
          ),
          const SizedBox(height: 20),
          Text('Thank You!',
              style:
                  GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Your feedback helps us improve',
              style: GoogleFonts.inter(color: AppColors.textMuted),
              textAlign: TextAlign.center),
        ]),
        actions: [
          Center(
              child: GradientButton(
            text: 'Done',
            width: 150,
            height: 48,
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
          )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final double rating;
  final Function(double) onRatingChanged;

  const _StarRating({required this.rating, required this.onRatingChanged});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (i) {
          final starValue = i + 1.0;
          final isActive = rating >= starValue;

          return GestureDetector(
            onTap: () => onRatingChanged(starValue),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: AnimatedScale(
                scale: isActive ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isActive ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: isActive ? AppColors.accent : AppColors.textMuted,
                  size: 44,
                ),
              ),
            ),
          )
              .animate(delay: Duration(milliseconds: i * 50))
              .fadeIn()
              .scale(begin: const Offset(0.5, 0.5));
        }),
      );
}

class _SelectableTag extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableTag(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.gradientPrimary : null,
            color: isSelected ? null : AppColors.surface,
            borderRadius: BorderRadius.circular(25),
            border: isSelected
                ? null
                : Border.all(color: Colors.white.withOpacity(0.08)),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 10)
                  ]
                : null,
          ),
          child: Text(label,
              style: GoogleFonts.inter(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              )),
        ),
      );
}

class _TipButton extends StatelessWidget {
  final double amount;
  final bool isSelected;
  final VoidCallback onTap;

  const _TipButton(
      {required this.amount, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 70,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.gradientSecondary : null,
            color: isSelected ? null : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: isSelected
                ? null
                : Border.all(color: Colors.white.withOpacity(0.08)),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: AppColors.secondary.withOpacity(0.3),
                        blurRadius: 10)
                  ]
                : null,
          ),
          child: Column(children: [
            if (amount == 0)
              Text('No tip',
                  style: GoogleFonts.inter(
                      color: isSelected ? Colors.white : AppColors.textMuted,
                      fontSize: 11))
            else
              Text('€${amount.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  )),
          ]),
        ),
      );
}
