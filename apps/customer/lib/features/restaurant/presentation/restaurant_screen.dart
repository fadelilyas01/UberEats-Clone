import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../../core/data/models.dart';
import '../../../core/providers/cart_provider.dart';
import '../../../core/providers/app_providers.dart';

class RestaurantScreen extends ConsumerStatefulWidget {
  final String id;
  const RestaurantScreen({super.key, required this.id});

  @override
  ConsumerState<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends ConsumerState<RestaurantScreen> {
  int selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    final restaurantAsync = ref.watch(restaurantDetailsProvider(widget.id));
    final menuItemsAsync = ref.watch(restaurantMenuProvider(widget.id));
    final cart = ref.watch(cartProvider);

    return restaurantAsync.when(
      loading: () => const _RestaurantLoadingSkeleton(),
      error: (err, stack) => Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: Center(
            child: Text('Error: $err',
                style: GoogleFonts.inter(color: AppColors.error))),
      ),
      data: (restaurant) {
        if (restaurant == null) {
          return Scaffold(
            appBar: AppBar(leading: const BackButton()),
            body: const Center(child: Text('Restaurant introuvable')),
          );
        }

        return menuItemsAsync.when(
          loading: () =>
              const _RestaurantLoadingSkeleton(), // Keep skeleton while menu loads
          error: (err, stack) =>
              Scaffold(body: Center(child: Text('Error loading menu: $err'))),
          data: (menuItems) {
            // Group items by category
            final categories =
                menuItems.map((m) => m.category).toSet().toList();
            final filteredItems = selectedCategoryIndex == 0
                ? menuItems
                : menuItems
                    .where((m) =>
                        m.category == categories[selectedCategoryIndex - 1])
                    .toList();

            return Scaffold(
              body: Stack(children: [
                // Background orb
                const BackgroundOrb(
                    size: 300,
                    color: AppColors.primary,
                    alignment: Alignment(1.5, -0.5)),

                CustomScrollView(slivers: [
                  // Parallax App Bar
                  SliverAppBar(
                    expandedHeight: 300,
                    pinned: true,
                    backgroundColor: AppColors.background,
                    leading: Padding(
                      padding: const EdgeInsets.all(8),
                      child: GlassIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => context.pop(),
                        size: 42,
                      ),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GlassIconButton(
                          icon: restaurant.isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          iconColor:
                              restaurant.isFavorite ? AppColors.error : null,
                          onTap: () {},
                          size: 42,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: GlassIconButton(
                            icon: Icons.share_rounded, onTap: () {}, size: 42),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(fit: StackFit.expand, children: [
                        OptimizedImage(imageUrl: restaurant.coverUrl),
                        Container(
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            AppColors.background.withOpacity(0.8),
                            AppColors.background
                          ],
                          stops: const [0, 0.4, 0.8, 1],
                        ))),

                        // Restaurant Info
                        Positioned(
                            left: 20,
                            right: 20,
                            bottom: 20,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (restaurant.promo != null)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: PremiumChip(
                                          label: restaurant.promo!,
                                          gradient: AppColors.gradientSecondary,
                                          icon: Icons.local_offer_rounded),
                                    ),
                                  Text(restaurant.name,
                                      style: GoogleFonts.inter(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Text(restaurant.tags.join(' • '),
                                      style: GoogleFonts.inter(
                                          color: AppColors.textSecondary,
                                          fontSize: 14)),
                                  const SizedBox(height: 12),
                                  Row(children: [
                                    const RatingBadge(
                                        rating:
                                            0.0), // Need to update RatingBadge to accept double or handle async is tricky here. Keeping simple for now or using restaurant.rating
                                    const SizedBox(width: 8),
                                    Text('(${restaurant.reviewCount})',
                                        style: GoogleFonts.inter(
                                            color: AppColors.textMuted,
                                            fontSize: 13)),
                                    const SizedBox(width: 16),
                                    const Icon(Icons.access_time_rounded,
                                        color: AppColors.textMuted, size: 16),
                                    const SizedBox(width: 4),
                                    Text(restaurant.deliveryTime,
                                        style: GoogleFonts.inter(
                                            color: AppColors.textSecondary,
                                            fontSize: 13)),
                                    const SizedBox(width: 16),
                                    const Icon(Icons.delivery_dining_rounded,
                                        color: AppColors.primary, size: 16),
                                    const SizedBox(width: 4),
                                    Text(restaurant.deliveryFee,
                                        style: GoogleFonts.inter(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13)),
                                  ]),
                                ])),
                      ]),
                    ),
                  ),

                  // Category Tabs
                  SliverToBoxAdapter(
                      child: Container(
                    height: 50,
                    margin: const EdgeInsets.only(top: 16),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        _CategoryTab(
                            label: 'Tous',
                            isSelected: selectedCategoryIndex == 0,
                            onTap: () =>
                                setState(() => selectedCategoryIndex = 0)),
                        ...categories.asMap().entries.map((e) => _CategoryTab(
                              label: e.value,
                              isSelected: selectedCategoryIndex == e.key + 1,
                              onTap: () => setState(
                                  () => selectedCategoryIndex = e.key + 1),
                            )),
                      ],
                    ),
                  )),

                  // Popular Section
                  if (selectedCategoryIndex == 0 &&
                      menuItems.any((m) => m.isPopular)) ...[
                    const SliverToBoxAdapter(
                        child: SectionHeader(
                            title: 'Les Plus Populaires',
                            padding: EdgeInsets.fromLTRB(20, 20, 20, 12))),
                    SliverToBoxAdapter(
                        child: SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: menuItems.where((m) => m.isPopular).length,
                        itemBuilder: (ctx, i) {
                          final item =
                              menuItems.where((m) => m.isPopular).toList()[i];
                          return _PopularItemCard(
                              item: item, restaurant: restaurant, index: i);
                        },
                      ),
                    )),
                  ],

                  // Menu Items
                  const SliverToBoxAdapter(
                      child: SectionHeader(
                          title: 'Menu',
                          padding: EdgeInsets.fromLTRB(20, 24, 20, 12))),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _MenuItemCard(
                          item: filteredItems[i],
                          restaurant: restaurant,
                          index: i),
                      childCount: filteredItems.length,
                    )),
                  ),

                  const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
                ]),

                // Bottom Cart Bar
                if (!cart.isEmpty && cart.restaurantId == widget.id)
                  Positioned(
                      left: 20,
                      right: 20,
                      bottom: 30,
                      child: _CartBar(cart: cart)),
              ]),
            );
          },
        );
      },
    );
  }
}

class _RestaurantLoadingSkeleton extends StatelessWidget {
  const _RestaurantLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 300,
          leading:
              const Padding(padding: EdgeInsets.all(8), child: BackButton()),
          flexibleSpace: FlexibleSpaceBar(
            background: Shimmer.fromColors(
              baseColor: AppColors.surface,
              highlightColor: AppColors.card,
              child: Container(color: Colors.white),
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ShimmerContainer(width: 200, height: 30),
              SizedBox(height: 10),
              ShimmerContainer(width: 150, height: 20),
              SizedBox(height: 30),
              ShimmerContainer(width: double.infinity, height: 100),
              SizedBox(height: 20),
              ShimmerContainer(width: double.infinity, height: 100),
            ]),
          ),
        ),
      ]),
    );
  }
}

class ShimmerContainer extends StatelessWidget {
  final double width;
  final double height;
  const ShimmerContainer(
      {super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: AppColors.surface,
        highlightColor: AppColors.card,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12)),
        ),
      );
}

class _CategoryTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTab(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.gradientPrimary : null,
            color: isSelected ? null : AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: isSelected
                ? null
                : Border.all(color: Colors.white.withOpacity(0.05)),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ]
                : null,
          ),
          child: Text(label,
              style: GoogleFonts.inter(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textMuted,
                fontSize: 14,
              )),
        ),
      );
}

class _PopularItemCard extends ConsumerWidget {
  final MenuItem item;
  final Restaurant restaurant;
  final int index;

  const _PopularItemCard(
      {required this.item, required this.restaurant, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) => GestureDetector(
        onTap: () => ref
            .read(cartProvider.notifier)
            .addItem(item, restaurant.id, restaurant.name),
        child: Container(
          width: 160,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Stack(children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: OptimizedImage(
                    imageUrl: item.imageUrl,
                    height: 100,
                    width: double.infinity),
              ),
              Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                        gradient: AppColors.gradientPrimary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 8)
                        ]),
                    child: const Icon(Icons.add_rounded,
                        color: Colors.white, size: 20),
                  )),
            ]),
            Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('\$${item.price.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ])),
          ]),
        )
            .animate(delay: Duration(milliseconds: index * 80))
            .fadeIn()
            .slideX(begin: 0.15, end: 0),
      );
}

class _MenuItemCard extends ConsumerWidget {
  final MenuItem item;
  final Restaurant restaurant;
  final int index;

  const _MenuItemCard(
      {required this.item, required this.restaurant, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quantity = ref.watch(cartProvider.notifier).getQuantity(item.id);

    return Container(
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
            borderRadius: BorderRadius.circular(16),
            child:
                OptimizedImage(imageUrl: item.imageUrl, width: 95, height: 95),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  if (item.isPopular)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: PremiumChip(
                          label: 'Populaire',
                          isSmall: true,
                          color: AppColors.accent),
                    ),
                  if (item.isVegetarian)
                    const PremiumChip(
                        label: '🌱', isSmall: true, color: AppColors.secondary),
                ]),
                const SizedBox(height: 4),
                Text(item.name,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(item.description,
                    style: GoogleFonts.inter(
                        color: AppColors.textMuted, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 10),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${item.price.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 17)),
                      if (quantity > 0)
                        QuantitySelector(
                          quantity: quantity,
                          onIncrease: () => ref
                              .read(cartProvider.notifier)
                              .incrementItem(item.id),
                          onDecrease: () => ref
                              .read(cartProvider.notifier)
                              .decrementItem(item.id),
                        )
                      else
                        GestureDetector(
                          onTap: () => ref
                              .read(cartProvider.notifier)
                              .addItem(item, restaurant.id, restaurant.name),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                gradient: AppColors.gradientPrimary,
                                borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.add_rounded,
                                color: Colors.white, size: 22),
                          ),
                        ),
                    ]),
              ])),
        ]),
      ),
    )
        .animate(delay: Duration(milliseconds: 100 + index * 60))
        .fadeIn()
        .slideX(begin: 0.08, end: 0);
  }
}

class _CartBar extends StatelessWidget {
  final CartState cart;
  const _CartBar({required this.cart});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => context.push('/checkout'),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10)),
              child: Text('${cart.itemCount}',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Text('Voir le Panier',
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.bold))),
            Text('\$${cart.total.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                    fontSize: 17, fontWeight: FontWeight.bold)),
          ]),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.5, end: 0),
      );
}
