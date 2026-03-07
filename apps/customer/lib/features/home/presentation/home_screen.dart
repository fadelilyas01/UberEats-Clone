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
import '../../../core/data/seed_data.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int selectedCategory = 0;

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final restaurantsAsync = ref.watch(restaurantsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final isTablet = Responsive.isTablet(context);

    return Scaffold(
      extendBody: true,
      body: Stack(children: [
        // Background orbs
        const BackgroundOrb(
            size: 400,
            color: AppColors.primary,
            alignment: Alignment(-1.2, -0.8)),
        const BackgroundOrb(
            size: 350,
            color: AppColors.secondary,
            alignment: Alignment(1.5, 0.5)),

        SafeArea(
            child: CustomScrollView(slivers: [
          // Premium Header
          SliverToBoxAdapter(child: _buildHeader(context, cart)),

          // Search Bar
          SliverToBoxAdapter(child: _buildSearchBar(context)),

          // Categories
          SliverToBoxAdapter(
            child: categoriesAsync.when(
              data: (categories) => _CategoryList(
                categories: categories,
                selectedIndex: selectedCategory,
                onSelect: (i) => setState(() => selectedCategory = i),
              ),
              loading: () => const _CategoriesShimmer(),
              error: (_, __) => const SizedBox(),
            ),
          ),

          // Featured Banner
          SliverToBoxAdapter(child: _buildFeaturedBanner()),

          // Nearby Restaurants Section
          SliverToBoxAdapter(
              child:
                  SectionHeader(title: 'Restaurants à proximité', onSeeAll: () {})),

          // Restaurant Grid (Responsive)
          restaurantsAsync.when(
            data: (restaurants) => SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent:
                      400, // Une carte prendra toute la largeur sur mobile (<400px), mais se mettra en grille sur tablette
                  mainAxisExtent:
                      260, // Hauteur fixe par carte pour éviter les calculs de ratio complexes
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) =>
                      _RestaurantCard(restaurant: restaurants[i], index: i),
                  childCount: restaurants.length,
                ),
              ),
            ),
            loading: () =>
                SliverToBoxAdapter(child: _buildRestaurantShimmerLoading()),
            error: (err, stack) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Error loading restaurants: $err',
                    style: GoogleFonts.inter(color: AppColors.error)),
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
        ])), // Fermeture de CustomScrollView
      ]),

      // Premium Bottom Nav
      bottomNavigationBar: _PremiumBottomNav(cartItemCount: cart.itemCount),

      // Temporary Seed Button (Remove in Production)
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton.extended(
          onPressed: () async {
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('Seeding Database... ⏳')));

            try {
              // Import locally to avoid pollution
              await DatabaseSeeder().seedData();
              scaffoldMessenger.showSnackBar(const SnackBar(
                  content: Text('Database Filled! 🎉 Pull to refresh.')));
              ref.refresh(restaurantsProvider);
              ref.refresh(categoriesProvider);
            } catch (e) {
              scaffoldMessenger
                  .showSnackBar(SnackBar(content: Text('Error: $e')));
            }
          },
          label: const Text('Remplir BDD'),
          icon: const Icon(Icons.cloud_upload),
          backgroundColor: Colors.orange,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CartState cart) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        // Location
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.location_on_rounded,
                  color: AppColors.secondary, size: 16),
              const SizedBox(width: 4),
              Text('LIVRER À',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                    letterSpacing: 1.2,
                  )),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Flexible(
                child: Text('12 Rue de la Paix, Paris',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.primary),
            ]),
          ]).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
        ),

        // Action buttons
        Row(children: [
          GlassIconButton(
            icon: Icons.notifications_outlined,
            onTap: () {},
            hasBadge: true,
            badgeCount: 3,
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: Hero(
              tag: 'profile-avatar',
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: const OptimizedImage(
                      imageUrl: 'https://i.pravatar.cc/100'),
                ),
              ),
            ),
          ),
        ])
            .animate()
            .fadeIn(duration: 400.ms, delay: 100.ms)
            .slideX(begin: 0.1, end: 0),
      ]),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: GestureDetector(
        onTap: () => context.push('/search'),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(children: [
            ShaderMask(
              shaderCallback: (b) => AppColors.gradientPrimary.createShader(b),
              child: const Icon(Icons.search_rounded,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text('Rechercher des restaurants, cuisines...',
                  style: GoogleFonts.inter(
                    color: AppColors.textMuted,
                    fontSize: 15,
                  )),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.tune_rounded,
                  color: AppColors.primary, size: 20),
            ),
          ]),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.15, end: 0),
      ),
    );
  }

  Widget _buildFeaturedBanner() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          gradient: AppColors.gradientPrimary,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 30,
                offset: const Offset(0, 15))
          ],
        ),
        child: Stack(children: [
          // Decorative circles
          Positioned(
              right: -40,
              bottom: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1)),
              )),
          Positioned(
              right: 30,
              top: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1)),
              )),
          Positioned(
              left: -20,
              bottom: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08)),
              )),

          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.local_fire_department_rounded, size: 16),
                  const SizedBox(width: 4),
                  Text('Offre Limitée',
                      style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
              ),
              const SizedBox(height: 14),
              Text('Obtenez -30%',
                  style: GoogleFonts.inter(
                      fontSize: 30, fontWeight: FontWeight.w800, height: 1.1)),
              const SizedBox(height: 4),
              Text('sur votre première commande',
                  style: GoogleFonts.inter(
                      fontSize: 16, color: Colors.white.withOpacity(0.85))),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1), blurRadius: 10)
                  ],
                ),
                child: Text('Commander',
                    style: GoogleFonts.inter(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    )),
              ),
            ]),
          ),
        ]),
      )
          .animate()
          .fadeIn(delay: 300.ms)
          .scale(begin: const Offset(0.96, 0.96), end: const Offset(1, 1)),
    );
  }

  Widget _buildRestaurantShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
          children: List.generate(
              3,
              (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Shimmer.fromColors(
                      baseColor: AppColors.surface,
                      highlightColor: AppColors.card,
                      child: Container(
                        height: 240,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ))),
    );
  }
}

class _CategoryList extends StatelessWidget {
  final List<Category> categories;
  final int selectedIndex;
  final Function(int) onSelect;

  const _CategoryList({
    required this.categories,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        height: 115,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: categories.length,
          itemBuilder: (ctx, i) => _CategoryItem(
            category: categories[i],
            isSelected: selectedIndex == i,
            onTap: () => onSelect(i),
            index: i,
          ),
        ),
      ),
    );
  }
}

class _CategoriesShimmer extends StatelessWidget {
  const _CategoriesShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        height: 115,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: 5,
          itemBuilder: (ctx, i) => Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Shimmer.fromColors(
              baseColor: AppColors.surface,
              highlightColor: AppColors.card,
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;
  final int index;

  const _CategoryItem({
    required this.category,
    required this.isSelected,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(right: 16),
          child: Column(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.gradientPrimary : null,
                color: isSelected ? null : AppColors.card,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : Colors.white.withOpacity(0.05)),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6))
                      ]
                    : null,
              ),
              child: Center(
                  child: Text(category.emoji,
                      style: const TextStyle(fontSize: 30))),
            ),
            const SizedBox(height: 10),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
              ),
              child: Text(category.name),
            ),
          ]),
        )
            .animate(delay: Duration(milliseconds: 100 + index * 50))
            .fadeIn()
            .slideX(begin: 0.2, end: 0),
      );
}

class _RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final int index;

  const _RestaurantCard({required this.restaurant, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/restaurant/${restaurant.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 10))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.4)
                      ],
                    ).createShader(bounds),
                    blendMode: BlendMode.darken,
                    child: OptimizedImage(
                        imageUrl: restaurant.imageUrl,
                        height: 160,
                        width: double.infinity),
                  ),
                ),

                // Time badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time_rounded,
                            color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(restaurant.deliveryTime,
                            style: GoogleFonts.inter(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),

                // Favorite button
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Icon(
                      restaurant.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: restaurant.isFavorite
                          ? AppColors.error
                          : Colors.white,
                      size: 18,
                    ),
                  ),
                ),

                // Promo badge
                if (restaurant.promo != null)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: PremiumChip(
                      label: restaurant.promo!,
                      gradient: AppColors.gradientSecondary,
                      icon: Icons.local_offer_rounded,
                    ),
                  ),
              ],
            ),

            // Info section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: GoogleFonts.inter(
                              fontSize: 17, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      RatingBadge(rating: restaurant.rating),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    restaurant.tags.join(' • '),
                    style: GoogleFonts.inter(
                        color: AppColors.textMuted, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.delivery_dining_rounded,
                          color: AppColors.primary.withOpacity(0.8), size: 18),
                      const SizedBox(width: 6),
                      Text(
                        restaurant.deliveryFee,
                        style: GoogleFonts.inter(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      const Icon(Icons.location_on_outlined,
                          color: AppColors.textMuted, size: 14),
                      const SizedBox(width: 3),
                      Text('${restaurant.distance} km',
                          style: GoogleFonts.inter(
                              color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 400 + index * 80))
        .fadeIn()
        .slideY(begin: 0.15, end: 0);
  }
}

class _PremiumBottomNav extends StatelessWidget {
  final int cartItemCount;
  const _PremiumBottomNav({required this.cartItemCount});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.all(20),
        height: 75,
        decoration: BoxDecoration(
          color: AppColors.card.withOpacity(0.95),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 30,
                offset: const Offset(0, 12))
          ],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _NavItem(
              icon: Icons.home_rounded,
              label: 'Accueil',
              isActive: true,
              onTap: () {}),
          _NavItem(
              icon: Icons.search_rounded,
              label: 'Recherche',
              isActive: false,
              onTap: () => context.push('/search')),

          // Center Cart Button
          GestureDetector(
            onTap: () => context.push('/checkout'),
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.5),
                      blurRadius: 18,
                      offset: const Offset(0, 6))
                ],
              ),
              child: Stack(alignment: Alignment.center, children: [
                const Icon(Icons.shopping_bag_rounded,
                    color: Colors.white, size: 26),
                if (cartItemCount > 0)
                  Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                            color: AppColors.accent, shape: BoxShape.circle),
                        child: Center(
                            child: Text('$cartItemCount',
                                style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold))),
                      )),
              ]),
            ),
          ),

          _NavItem(
              icon: Icons.receipt_long_rounded,
              label: 'Commandes',
              isActive: false,
              onTap: () => context.push('/orders')),
          _NavItem(
              icon: Icons.person_rounded,
              label: 'Profil',
              isActive: false,
              onTap: () => context.push('/profile')),
        ]),
      ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.5, end: 0);
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem(
      {required this.icon,
      required this.label,
      required this.isActive,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          ShaderMask(
            shaderCallback: (b) => isActive
                ? AppColors.gradientPrimary.createShader(b)
                : const LinearGradient(colors: [Colors.grey, Colors.grey])
                    .createShader(b),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: isActive ? AppColors.primary : AppColors.textMuted,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              )),
        ]),
      );
}
