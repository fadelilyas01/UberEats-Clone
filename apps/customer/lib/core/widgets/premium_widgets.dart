import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';

/// Gradient Button with glow effect
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final LinearGradient gradient;
  final double? width;
  final double height;
  final IconData? icon;
  final bool isLoading;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.gradient = AppColors.gradientPrimary,
    this.width,
    this.height = 56,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: isLoading ? null : onPressed,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  color: gradient.colors.first.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8))
            ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    if (icon != null) Icon(icon, color: Colors.white, size: 22),
                    if (icon != null) const SizedBox(width: 10),
                    Text(text,
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ]),
          ),
        ),
      );
}

/// Glass Card with blur effect
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: margin,
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10))
            ],
          ),
          child: child,
        ),
      );
}

/// Icon Button with glass effect
class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color? iconColor;
  final bool hasBadge;
  final int badgeCount;

  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 48,
    this.iconColor,
    this.hasBadge = false,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(size * 0.35),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.15), blurRadius: 10)
                ],
              ),
              child: Icon(icon,
                  color: iconColor ?? AppColors.textSecondary,
                  size: size * 0.45),
            ),
            if (hasBadge && badgeCount > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                      color: AppColors.error, shape: BoxShape.circle),
                  child: Center(
                      child: Text('$badgeCount',
                          style: GoogleFonts.inter(
                              fontSize: 11, fontWeight: FontWeight.bold))),
                ),
              ),
          ],
        ),
      );
}

/// Optimized Network Image with shimmer loading
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: fit,
          placeholder: (ctx, url) => Shimmer.fromColors(
            baseColor: AppColors.surface,
            highlightColor: AppColors.card,
            child: Container(width: width, height: height, color: Colors.white),
          ),
          errorWidget: (ctx, url, err) => Container(
            width: width,
            height: height,
            color: AppColors.surface,
            child: Icon(Icons.broken_image_rounded,
                color: AppColors.textMuted, size: (height ?? 48) * 0.3),
          ),
        ),
      );
}

/// Section Header with "See All" button
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  final EdgeInsets padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: padding,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title,
              style:
                  GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Row(children: [
                Text('See All',
                    style: GoogleFonts.inter(
                        color: AppColors.primary, fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: AppColors.primary, size: 14),
              ]),
            ),
        ]),
      );
}

/// Tag/Chip widget
class PremiumChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final LinearGradient? gradient;
  final bool isSmall;

  const PremiumChip({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.gradient,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 8 : 12, vertical: isSmall ? 4 : 6),
        decoration: BoxDecoration(
          gradient: gradient,
          color: gradient == null
              ? (color ?? AppColors.primary).withOpacity(0.15)
              : null,
          borderRadius: BorderRadius.circular(isSmall ? 6 : 10),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null)
            Icon(icon,
                size: isSmall ? 12 : 14,
                color: gradient != null
                    ? Colors.white
                    : (color ?? AppColors.primary)),
          if (icon != null) SizedBox(width: isSmall ? 3 : 5),
          Text(label,
              style: GoogleFonts.inter(
                fontSize: isSmall ? 10 : 12,
                fontWeight: FontWeight.w600,
                color: gradient != null
                    ? Colors.white
                    : (color ?? AppColors.primary),
              )),
        ]),
      );
}

/// Animated Background Orb
class BackgroundOrb extends StatelessWidget {
  final double size;
  final Color color;
  final Alignment alignment;

  const BackgroundOrb({
    super.key,
    required this.size,
    required this.color,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: Align(
          alignment: alignment,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                  colors: [color.withOpacity(0.3), Colors.transparent]),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 4.seconds,
                curve: Curves.easeInOut,
              ),
        ),
      );
}

/// Rating Badge
class RatingBadge extends StatelessWidget {
  final double rating;
  final bool compact;

  const RatingBadge({super.key, required this.rating, this.compact = false});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 10, vertical: compact ? 4 : 6),
        decoration: BoxDecoration(
          color: AppColors.secondary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.star_rounded,
              color: AppColors.secondary, size: compact ? 14 : 16),
          SizedBox(width: compact ? 3 : 5),
          Text(rating.toStringAsFixed(1),
              style: GoogleFonts.inter(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
                fontSize: compact ? 12 : 13,
              )),
        ]),
      );
}

/// Quantity Selector
class QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
            color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _QuantityButton(
              icon: Icons.remove_rounded,
              onTap: onDecrease,
              enabled: quantity > 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('$quantity',
                style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          _QuantityButton(
              icon: Icons.add_rounded, onTap: onIncrease, enabled: true),
        ]),
      );
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _QuantityButton(
      {required this.icon, required this.onTap, required this.enabled});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Icon(icon,
              size: 18,
              color: enabled ? AppColors.textPrimary : AppColors.textMuted),
        ),
      );
}

/// Empty State Widget
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(title,
                style: GoogleFonts.inter(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle,
                style: GoogleFonts.inter(color: AppColors.textMuted),
                textAlign: TextAlign.center),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              GradientButton(text: buttonText!, onPressed: onButtonPressed!),
            ],
          ]).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
        ),
      );
}
