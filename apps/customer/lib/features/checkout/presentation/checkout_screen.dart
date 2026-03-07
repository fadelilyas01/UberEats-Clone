import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../../core/data/models.dart';
import '../../../core/providers/cart_provider.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(
            leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => context.pop())),
        body: EmptyState(
          icon: Icons.shopping_bag_outlined,
          title: 'Votre panier est vide',
          subtitle: 'Parcourez les restaurants et ajoutez de délicieux articles',
          buttonText: 'Parcourir les Restaurants',
          onButtonPressed: () => context.go('/'),
        ),
      );
    }

    return Scaffold(
      body: Stack(children: [
        // Background
        const BackgroundOrb(
            size: 350,
            color: AppColors.primary,
            alignment: Alignment(-1, -0.5)),

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
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Votre Panier',
                        style: GoogleFonts.inter(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    Text('de ${cart.restaurantName ?? "Restaurant"}',
                        style: GoogleFonts.inter(
                            color: AppColors.textMuted, fontSize: 14)),
                  ])),
              GlassIconButton(
                  icon: Icons.delete_outline_rounded,
                  onTap: () => _showClearDialog(context, ref),
                  size: 44),
            ]),
          ),

          // Cart Items
          Expanded(
              child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                ...cart.items
                    .asMap()
                    .entries
                    .map((e) => _CartItemCard(index: e.key, cartItem: e.value)),

                const SizedBox(height: 24),

                // Promo Code
                _PromoCodeSection(),

                const SizedBox(height: 24),

                // Order Summary
                _OrderSummary(cart: cart),

                const SizedBox(height: 100),
              ])),
        ])),

        // Bottom CTA
        Positioned(
            left: 20,
            right: 20,
            bottom: 30,
            child: _CheckoutButton(total: cart.total)),
      ]),
    );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Vider le panier ?',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text('Voulez-vous vraiment supprimer tous les articles ?',
            style: GoogleFonts.inter(color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Annuler',
                  style: GoogleFonts.inter(color: AppColors.textMuted))),
          TextButton(
            onPressed: () {
              ref.read(cartProvider.notifier).clearCart();
              Navigator.pop(ctx);
            },
            child: Text('Vider',
                style: GoogleFonts.inter(
                    color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends ConsumerWidget {
  final int index;
  final CartItem cartItem;

  const _CartItemCard({required this.index, required this.cartItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Dismissible(
        key: Key(cartItem.item.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) =>
            ref.read(cartProvider.notifier).removeItem(cartItem.item.id),
        background: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20)),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          child: const Icon(Icons.delete_rounded,
              color: AppColors.error, size: 28),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: OptimizedImage(
                    imageUrl: cartItem.item.imageUrl, width: 75, height: 75),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(cartItem.item.name,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          QuantitySelector(
                            quantity: cartItem.quantity,
                            onIncrease: () => ref
                                .read(cartProvider.notifier)
                                .incrementItem(cartItem.item.id),
                            onDecrease: () => ref
                                .read(cartProvider.notifier)
                                .decrementItem(cartItem.item.id),
                          ),
                          Text('\$${cartItem.total.toStringAsFixed(2)}',
                              style: GoogleFonts.inter(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ]),
                  ])),
            ]),
          ),
        )
            .animate(delay: Duration(milliseconds: index * 80))
            .fadeIn()
            .slideX(begin: 0.1, end: 0),
      );
}

class _PromoCodeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.local_offer_rounded,
                color: AppColors.accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Ajouter un code promo',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                Text('Obtenez des réductions sur votre commande',
                    style: GoogleFonts.inter(
                        color: AppColors.textMuted, fontSize: 13)),
              ])),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ]),
      ).animate().fadeIn(delay: 300.ms);
}

class _OrderSummary extends StatelessWidget {
  final CartState cart;
  const _OrderSummary({required this.cart});

  @override
  Widget build(BuildContext context) => GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          _SummaryRow(
              label: 'Sous-total', value: '\$${cart.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          _SummaryRow(
              label: 'Frais de livraison',
              value: cart.deliveryFee == 0
                  ? 'GRATUIT'
                  : '\$${cart.deliveryFee.toStringAsFixed(2)}',
              valueColor: cart.deliveryFee == 0 ? AppColors.secondary : null),
          const SizedBox(height: 12),
          _SummaryRow(
              label: 'Frais de service',
              value: '\$${cart.serviceFee.toStringAsFixed(2)}'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Container(
                height: 1,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.1),
                  Colors.transparent
                ]))),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Total',
                style: GoogleFonts.inter(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            ShaderMask(
              shaderCallback: (b) => AppColors.gradientPrimary.createShader(b),
              child: Text('\$${cart.total.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ]),
        ]),
      ).animate().fadeIn(delay: 400.ms);
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: GoogleFonts.inter(color: AppColors.textMuted)),
        Text(value,
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w600, color: valueColor)),
      ]);
}

class _CheckoutButton extends StatelessWidget {
  final double total;
  const _CheckoutButton({required this.total});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => context.push('/payment'),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            gradient: AppColors.gradientPrimary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: AppColors.primary.withOpacity(0.5),
                  blurRadius: 25,
                  offset: const Offset(0, 10))
            ],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.lock_rounded, size: 20),
            const SizedBox(width: 10),
            Text('Passer au Paiement',
                style: GoogleFonts.inter(
                    fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10)),
              child: Text('\$${total.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            ),
          ]),
        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.5, end: 0),
      );
}
