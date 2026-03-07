import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../../core/data/models.dart';

// Mock Orders Data
final mockOrders = [
  _MockOrder(
    id: 'ORD-001234',
    restaurantName: 'Burger King Premium',
    restaurantImage:
        'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=200',
    items: ['Double Whopper x2', 'Loaded Fries x1'],
    total: 31.50,
    status: OrderStatus.delivered,
    date: DateTime.now().subtract(const Duration(days: 2)),
  ),
  _MockOrder(
    id: 'ORD-001235',
    restaurantName: 'Sushi Master Tokyo',
    restaurantImage:
        'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=200',
    items: ['Dragon Roll x1', 'Salmon Nigiri x1'],
    total: 33.40,
    status: OrderStatus.delivered,
    date: DateTime.now().subtract(const Duration(days: 5)),
  ),
  _MockOrder(
    id: 'ORD-001236',
    restaurantName: 'Napoli Pizza House',
    restaurantImage:
        'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=200',
    items: ['Margherita DOC x1', 'Tiramisu x1'],
    total: 22.40,
    status: OrderStatus.delivered,
    date: DateTime.now().subtract(const Duration(days: 10)),
  ),
  _MockOrder(
    id: 'ORD-001237',
    restaurantName: 'Thai Express Gourmet',
    restaurantImage:
        'https://images.unsplash.com/photo-1562565652-a0d8f0c59eb4?w=200',
    items: ['Pad Thai x1', 'Spring Rolls x2'],
    total: 28.90,
    status: OrderStatus.cancelled,
    date: DateTime.now().subtract(const Duration(days: 15)),
  ),
];

class _MockOrder {
  final String id;
  final String restaurantName;
  final String restaurantImage;
  final List<String> items;
  final double total;
  final OrderStatus status;
  final DateTime date;

  const _MockOrder({
    required this.id,
    required this.restaurantName,
    required this.restaurantImage,
    required this.items,
    required this.total,
    required this.status,
    required this.date,
  });
}

// Providers
final selectedTabProvider = StateProvider<int>((ref) => 0);

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);

    final activeOrders = mockOrders
        .where((o) =>
            o.status != OrderStatus.delivered &&
            o.status != OrderStatus.cancelled)
        .toList();
    final pastOrders = mockOrders
        .where((o) =>
            o.status == OrderStatus.delivered ||
            o.status == OrderStatus.cancelled)
        .toList();

    return Scaffold(
      body: Stack(children: [
        const BackgroundOrb(
            size: 300,
            color: AppColors.primary,
            alignment: Alignment(-1.2, -0.6)),
        const BackgroundOrb(
            size: 250,
            color: AppColors.secondary,
            alignment: Alignment(1.5, 0.8)),
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
              Text('Mes Commandes',
                  style: GoogleFonts.inter(
                      fontSize: 22, fontWeight: FontWeight.bold)),
            ]),
          ).animate().fadeIn().slideY(begin: -0.1, end: 0),

          // Tabs
          _OrderTabs(selectedTab: selectedTab).animate(delay: 100.ms).fadeIn(),

          // Orders List
          Expanded(
            child: selectedTab == 0
                ? activeOrders.isEmpty
                    ? const _EmptyOrders(isActive: true)
                    : _OrdersList(orders: activeOrders)
                : pastOrders.isEmpty
                    ? const _EmptyOrders(isActive: false)
                    : _OrdersList(orders: pastOrders),
          ),
        ])),
      ]),
    );
  }
}

class _OrderTabs extends ConsumerWidget {
  final int selectedTab;
  const _OrderTabs({required this.selectedTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(children: [
          _TabButton(
              label: 'En cours',
              isSelected: selectedTab == 0,
              onTap: () => ref.read(selectedTabProvider.notifier).state = 0),
          _TabButton(
              label: 'Historique',
              isSelected: selectedTab == 1,
              onTap: () => ref.read(selectedTabProvider.notifier).state = 1),
        ]),
      );
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: isSelected ? AppColors.gradientPrimary : null,
              borderRadius: BorderRadius.circular(14),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 10)
                    ]
                  : null,
            ),
            child: Center(
                child: Text(label,
                    style: GoogleFonts.inter(
                      color: isSelected ? Colors.white : AppColors.textMuted,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ))),
          ),
        ),
      );
}

class _EmptyOrders extends StatelessWidget {
  final bool isActive;
  const _EmptyOrders({required this.isActive});

  @override
  Widget build(BuildContext context) => EmptyState(
        icon: isActive
            ? Icons.delivery_dining_rounded
            : Icons.receipt_long_rounded,
        title: isActive ? 'Aucune commande en cours' : 'Aucun historique',
        subtitle: isActive
            ? 'Vos commandes en cours apparaîtront ici'
            : 'Vos commandes passées apparaîtront ici',
        buttonText: 'Parcourir les Restaurants',
        onButtonPressed: () => context.go('/'),
      );
}

class _OrdersList extends StatelessWidget {
  final List<_MockOrder> orders;
  const _OrdersList({required this.orders});

  @override
  Widget build(BuildContext context) => ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: orders.length,
        itemBuilder: (ctx, i) => _OrderCard(order: orders[i], index: i),
      );
}

class _OrderCard extends StatelessWidget {
  final _MockOrder order;
  final int index;

  const _OrderCard({required this.order, required this.index});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);
    final statusText = _getStatusText(order.status);
    final dateStr = _formatDate(order.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: OptimizedImage(
                  imageUrl: order.restaurantImage, width: 60, height: 60),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(order.restaurantName,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(dateStr,
                      style: GoogleFonts.inter(
                          color: AppColors.textMuted, fontSize: 12)),
                ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10)),
              child: Text(statusText,
                  style: GoogleFonts.inter(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12)),
            ),
          ]),
        ),

        // Divider
        Container(height: 1, color: Colors.white.withOpacity(0.05)),

        // Items
        Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(order.items.join(', '),
                style: GoogleFonts.inter(
                    color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Text('Total : ',
                    style: GoogleFonts.inter(color: AppColors.textMuted)),
                Text('\$${order.total.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ]),
              Row(children: [
                if (order.status == OrderStatus.delivered) ...[
                  _ActionChip(
                      icon: Icons.replay_rounded,
                      label: 'Commander à nouveau',
                      color: AppColors.secondary,
                      onTap: () {}),
                  const SizedBox(width: 10),
                ],
                _ActionChip(
                    icon: Icons.receipt_long_rounded,
                    label: 'Détails',
                    color: AppColors.primary,
                    onTap: () {}),
              ]),
            ]),
          ]),
        ),
      ]),
    )
        .animate(delay: Duration(milliseconds: 200 + index * 100))
        .fadeIn()
        .slideX(begin: 0.1, end: 0);
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
      case OrderStatus.confirmed:
      case OrderStatus.preparing:
        return AppColors.accent;
      case OrderStatus.readyForPickup:
      case OrderStatus.pickedUp:
      case OrderStatus.delivering:
        return AppColors.primary;
      case OrderStatus.delivered:
        return AppColors.secondary;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'En attente';
      case OrderStatus.confirmed:
        return 'Confirmée';
      case OrderStatus.preparing:
        return 'En préparation';
      case OrderStatus.readyForPickup:
        return 'Prête';
      case OrderStatus.pickedUp:
        return 'Récupérée';
      case OrderStatus.delivering:
        return 'En route';
      case OrderStatus.delivered:
        return 'Livrée';
      case OrderStatus.cancelled:
        return 'Annulée';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Aujourd\'hui';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} jours';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: GoogleFonts.inter(
                    color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          ]),
        ),
      );
}
