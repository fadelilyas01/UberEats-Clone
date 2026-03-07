import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../../core/providers/cart_provider.dart';
import '../../../core/services/payment_service.dart';

enum PaymentMethod { card, applePay, googlePay, cash }

final selectedPaymentMethod =
    StateProvider<PaymentMethod>((ref) => PaymentMethod.card);
final isProcessingPayment = StateProvider<bool>((ref) => false);

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _cardNumberController =
      TextEditingController(text: '4242 4242 4242 4242');
  final _expiryController = TextEditingController(text: '12/28');
  final _cvvController = TextEditingController(text: '123');

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final paymentMethod = ref.watch(selectedPaymentMethod);
    final isProcessing = ref.watch(isProcessingPayment);

    return Scaffold(
      body: Stack(children: [
        const BackgroundOrb(
            size: 300,
            color: AppColors.secondary,
            alignment: Alignment(1.2, -0.6)),

        SafeArea(
            child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              GlassIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => context.pop(),
                  size: 44),
              const SizedBox(width: 16),
              Text('Paiement',
                  style: GoogleFonts.inter(
                      fontSize: 22, fontWeight: FontWeight.bold)),
            ]),
          ),

          Expanded(
              child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                // Card Preview
                _CardPreview(
                  cardNumber: _cardNumberController.text,
                  expiry: _expiryController.text,
                ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),

                const SizedBox(height: 32),

                // Payment Methods
                Text('Méthode de paiement',
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Row(children: [
                  _PaymentMethodChip(
                      method: PaymentMethod.card,
                      icon: Icons.credit_card_rounded,
                      label: 'Carte'),
                  SizedBox(width: 12),
                  _PaymentMethodChip(
                      method: PaymentMethod.applePay,
                      icon: Icons.apple,
                      label: 'Apple'),
                  SizedBox(width: 12),
                  _PaymentMethodChip(
                      method: PaymentMethod.googlePay,
                      icon: Icons.g_mobiledata_rounded,
                      label: 'Google'),
                ]).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 32),

                // Card Details (if card selected)
                if (paymentMethod == PaymentMethod.card) ...[
                  Text('Détails de la carte',
                      style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _StyledTextField(
                    controller: _cardNumberController,
                    label: 'Numéro de carte',
                    icon: Icons.credit_card_rounded,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(
                        child: _StyledTextField(
                      controller: _expiryController,
                      label: 'Exp.',
                      icon: Icons.calendar_today_rounded,
                      onChanged: (_) => setState(() {}),
                    )),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _StyledTextField(
                      controller: _cvvController,
                      label: 'CVV',
                      icon: Icons.lock_rounded,
                      obscureText: true,
                    )),
                  ]),
                ],

                const SizedBox(height: 32),

                // Delivery Address
                _DeliveryAddressCard().animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 100),
              ])),
        ])),

        // Bottom Pay Button
        Positioned(
            left: 20,
            right: 20,
            bottom: 30,
            child: GradientButton(
              text: isProcessing ? '' : 'Payer \$${cart.total.toStringAsFixed(2)}',
              icon: isProcessing ? null : Icons.lock_rounded,
              isLoading: isProcessing,
              onPressed: () => _processPayment(context, ref),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.5, end: 0)),

        // Processing Overlay
        if (isProcessing)
          Container(
            color: Colors.black.withOpacity(0.7),
            child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(24)),
                child: Column(children: [
                  const CircularProgressIndicator(
                      color: AppColors.primary, strokeWidth: 3),
                  const SizedBox(height: 20),
                  Text('Traitement du paiement...',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('Veuillez patienter',
                      style: GoogleFonts.inter(
                          color: AppColors.textMuted, fontSize: 13)),
                ]),
              ),
            ])),
          ),
      ]),
    );
  }

  Future<void> _processPayment(BuildContext context, WidgetRef ref) async {
    ref.read(isProcessingPayment.notifier).state = true;
    final cart = ref.watch(cartProvider);

    try {
      // 1. Init Payment Sheet (Backend Call)
      await PaymentService().initPaymentSheet(
        amount: cart.total,
        currency: 'usd', // Or 'eur'
        restaurantId: cart.items.first.item.restaurantId,
      );

      // 2. Show Payment Sheet (Stripe UI)
      await PaymentService().presentPaymentSheet();

      // 3. Success Handling
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paiement réussi ! 🚀')),
        );
        ref.read(cartProvider.notifier).clearCart();
        context.go('/tracking');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Échec du paiement : $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      ref.read(isProcessingPayment.notifier).state = false;
    }
  }
}

class _CardPreview extends StatelessWidget {
  final String cardNumber;
  final String expiry;

  const _CardPreview({required this.cardNumber, required this.expiry});

  @override
  Widget build(BuildContext context) => Container(
        height: 200,
        decoration: BoxDecoration(
          gradient: AppColors.gradientPrimary,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: AppColors.primary.withOpacity(0.5),
                blurRadius: 30,
                offset: const Offset(0, 15))
          ],
        ),
        child: Stack(children: [
          // Decorative circles
          Positioned(
              right: -50,
              top: -50,
              child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1)))),
          Positioned(
              left: -30,
              bottom: -30,
              child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08)))),

          Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.credit_card_rounded,
                              color: Colors.white.withOpacity(0.7), size: 32),
                          Text('VISA',
                              style: GoogleFonts.inter(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2)),
                        ]),
                    const Spacer(),
                    Text(cardNumber,
                        style: GoogleFonts.jetBrainsMono(
                            fontSize: 21,
                            letterSpacing: 3,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 20),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('TITULAIRE',
                                    style: GoogleFonts.inter(
                                        fontSize: 10,
                                        color: Colors.white.withOpacity(0.6),
                                        letterSpacing: 1)),
                                const SizedBox(height: 4),
                                Text('JOHN DOE',
                                    style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                              ]),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('EXP.',
                                    style: GoogleFonts.inter(
                                        fontSize: 10,
                                        color: Colors.white.withOpacity(0.6),
                                        letterSpacing: 1)),
                                const SizedBox(height: 4),
                                Text(expiry,
                                    style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                              ]),
                        ]),
                  ])),
        ]),
      );
}

class _PaymentMethodChip extends ConsumerWidget {
  final PaymentMethod method;
  final IconData icon;
  final String label;

  const _PaymentMethodChip(
      {required this.method, required this.icon, required this.label});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedPaymentMethod);
    final isSelected = selected == method;

    return Expanded(
        child: GestureDetector(
      onTap: () => ref.read(selectedPaymentMethod.notifier).state = method,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.gradientPrimary : null,
          color: isSelected ? null : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? null
              : Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.3), blurRadius: 12)
                ]
              : null,
        ),
        child: Column(children: [
          Icon(icon,
              color: isSelected ? Colors.white : AppColors.textMuted, size: 24),
          const SizedBox(height: 6),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textMuted)),
        ]),
      ),
    ));
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final Function(String)? onChanged;

  const _StyledTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        obscureText: obscureText,
        onChanged: onChanged,
        style: GoogleFonts.inter(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(color: AppColors.textMuted),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          filled: true,
          fillColor: AppColors.card,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        ),
      );
}

class _DeliveryAddressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.location_on_rounded,
                  color: AppColors.secondary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Adresse de livraison',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                  Text('12 Rue de la Paix, Paris',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                ])),
            GlassIconButton(icon: Icons.edit_rounded, onTap: () {}, size: 38),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            const Icon(Icons.access_time_rounded,
                color: AppColors.textMuted, size: 16),
            const SizedBox(width: 8),
            Text('Livraison estimée : 25-35 min',
                style: GoogleFonts.inter(
                    color: AppColors.textSecondary, fontSize: 13)),
          ]),
        ]),
      );
}
