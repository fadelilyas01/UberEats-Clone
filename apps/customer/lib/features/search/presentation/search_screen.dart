import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../../core/data/models.dart';
import '../../../core/data/mock_data.dart';

// Search State
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedFiltersProvider = StateProvider<Set<String>>((ref) => {});

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final selectedFilters = ref.watch(selectedFiltersProvider);

    // Filter restaurants based on query
    final filteredRestaurants = mockRestaurants.where((r) {
      if (query.isEmpty) return true;
      final q = query.toLowerCase();
      return r.name.toLowerCase().contains(q) ||
          r.tags.any((t) => t.toLowerCase().contains(q)) ||
          r.description.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      body: Stack(children: [
        const BackgroundOrb(
            size: 300,
            color: AppColors.primary,
            alignment: Alignment(1.5, -0.5)),
        const BackgroundOrb(
            size: 250,
            color: AppColors.accent,
            alignment: Alignment(-1.2, 0.8)),
        SafeArea(
            child: Column(children: [
          // Search Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              GlassIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => context.pop(),
                  size: 44),
              const SizedBox(width: 14),
              Expanded(
                  child: _SearchInput(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: (v) =>
                    ref.read(searchQueryProvider.notifier).state = v,
              )),
            ]),
          ).animate().fadeIn().slideY(begin: -0.1, end: 0),

          // Filter Chips
          _FilterChips(
            selectedFilters: selectedFilters,
            onFilterTap: (filter) {
              final current = ref.read(selectedFiltersProvider);
              if (current.contains(filter)) {
                ref.read(selectedFiltersProvider.notifier).state = {...current}
                  ..remove(filter);
              } else {
                ref.read(selectedFiltersProvider.notifier).state = {
                  ...current,
                  filter
                };
              }
            },
          ),

          // Results
          Expanded(
            child: query.isEmpty && selectedFilters.isEmpty
                ? _RecentSearches()
                : filteredRestaurants.isEmpty
                    ? _NoResults(query: query)
                    : _SearchResults(restaurants: filteredRestaurants),
          ),
        ])),
      ]),
    );
  }
}

class _SearchInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;

  const _SearchInput(
      {required this.controller,
      required this.focusNode,
      required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 20)
          ],
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Search restaurants, food...',
            hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
            prefixIcon: ShaderMask(
              shaderCallback: (b) => AppColors.gradientPrimary.createShader(b),
              child: const Icon(Icons.search_rounded,
                  color: Colors.white, size: 24),
            ),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textMuted),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      );
}

class _FilterChips extends StatelessWidget {
  final Set<String> selectedFilters;
  final Function(String) onFilterTap;

  const _FilterChips(
      {required this.selectedFilters, required this.onFilterTap});

  static const _filters = [
    'All',
    'Near You',
    'Top Rated',
    'Fast Delivery',
    'Free Delivery',
    'Popular'
  ];

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _filters.length,
          itemBuilder: (ctx, i) {
            final filter = _filters[i];
            final isSelected = selectedFilters.contains(filter) ||
                (filter == 'All' && selectedFilters.isEmpty);

            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => onFilterTap(filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
                                blurRadius: 10)
                          ]
                        : null,
                  ),
                  child: Text(filter,
                      style: GoogleFonts.inter(
                        color: isSelected ? Colors.white : AppColors.textMuted,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 13,
                      )),
                ),
              ),
            )
                .animate(delay: Duration(milliseconds: 100 + i * 50))
                .fadeIn()
                .slideX(begin: 0.2, end: 0);
          },
        ),
      );
}

class _RecentSearches extends StatelessWidget {
  static const _recentSearches = [
    'Pizza',
    'Sushi',
    'Burger King',
    'Thai food',
    'Healthy salads'
  ];
  static const _popularCategories = [
    {'emoji': '🍕', 'name': 'Pizza', 'color': Color(0xFFFF6B6B)},
    {'emoji': '🍔', 'name': 'Burgers', 'color': Color(0xFFFFB347)},
    {'emoji': '🍣', 'name': 'Sushi', 'color': Color(0xFF4ECDC4)},
    {'emoji': '🥗', 'name': 'Healthy', 'color': Color(0xFF95E1A3)},
    {'emoji': '🍜', 'name': 'Asian', 'color': Color(0xFFDDA0DD)},
    {'emoji': '🌮', 'name': 'Mexican', 'color': Color(0xFFFFD93D)},
  ];

  @override
  Widget build(BuildContext context) =>
      ListView(padding: const EdgeInsets.all(20), children: [
        // Recent Searches
        Text('Recent Searches',
            style:
                GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _recentSearches
              .asMap()
              .entries
              .map((e) => _RecentSearchChip(
                    text: e.value,
                    index: e.key,
                  ))
              .toList(),
        ),

        const SizedBox(height: 32),

        // Popular Categories
        Text('Popular Categories',
            style:
                GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          children: _popularCategories
              .asMap()
              .entries
              .map((e) => _PopularCategoryCard(
                    data: e.value,
                    index: e.key,
                  ))
              .toList(),
        ),

        const SizedBox(height: 32),

        // Trending Now
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Trending Now 🔥',
              style:
                  GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('See All',
              style: GoogleFonts.inter(
                  color: AppColors.primary, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 16),
        ...mockRestaurants
            .take(3)
            .toList()
            .asMap()
            .entries
            .map((e) => _TrendingRestaurantCard(
                  restaurant: e.value,
                  index: e.key,
                )),
      ]);
}

class _RecentSearchChip extends StatelessWidget {
  final String text;
  final int index;

  const _RecentSearchChip({required this.text, required this.index});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.history_rounded,
              color: AppColors.textMuted, size: 16),
          const SizedBox(width: 8),
          Text(text, style: GoogleFonts.inter(color: AppColors.textSecondary)),
        ]),
      )
          .animate(delay: Duration(milliseconds: 200 + index * 50))
          .fadeIn()
          .scale(begin: const Offset(0.9, 0.9));
}

class _PopularCategoryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final int index;

  const _PopularCategoryCard({required this.data, required this.index});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: (data['color'] as Color).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
                child: Text(data['emoji'] as String,
                    style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(height: 10),
          Text(data['name'] as String,
              style:
                  GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
        ]),
      )
          .animate(delay: Duration(milliseconds: 300 + index * 60))
          .fadeIn()
          .scale(begin: const Offset(0.9, 0.9));
}

class _TrendingRestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final int index;

  const _TrendingRestaurantCard(
      {required this.restaurant, required this.index});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => context.push('/restaurant/${restaurant.id}'),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: OptimizedImage(
                  imageUrl: restaurant.imageUrl, width: 70, height: 70),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(restaurant.name,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(restaurant.tags.take(2).join(' • '),
                      style: GoogleFonts.inter(
                          color: AppColors.textMuted, fontSize: 13)),
                  const SizedBox(height: 6),
                  Row(children: [
                    RatingBadge(rating: restaurant.rating, compact: true),
                    const SizedBox(width: 10),
                    Text(restaurant.deliveryTime,
                        style: GoogleFonts.inter(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ]),
                ])),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.textMuted, size: 16),
          ]),
        )
            .animate(delay: Duration(milliseconds: 400 + index * 100))
            .fadeIn()
            .slideX(begin: 0.1, end: 0),
      );
}

class _NoResults extends StatelessWidget {
  final String query;
  const _NoResults({required this.query});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                shape: BoxShape.circle),
            child: const Icon(Icons.search_off_rounded,
                size: 48, color: AppColors.accent),
          ),
          const SizedBox(height: 24),
          Text('No results for "$query"',
              style:
                  GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Try a different search term',
              style: GoogleFonts.inter(color: AppColors.textMuted)),
        ]).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
      );
}

class _SearchResults extends StatelessWidget {
  final List<Restaurant> restaurants;
  const _SearchResults({required this.restaurants});

  @override
  Widget build(BuildContext context) => ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: restaurants.length,
        itemBuilder: (ctx, i) =>
            _TrendingRestaurantCard(restaurant: restaurants[i], index: i),
      );
}
