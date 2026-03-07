import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/responsive.dart';

enum DeliveryPhase { navigatingToRestaurant, atRestaurant, navigatingToCustomer, atCustomer, completed }
final deliveryPhaseProvider = StateProvider<DeliveryPhase>((ref) => DeliveryPhase.navigatingToRestaurant);

class ActiveDeliveryScreen extends ConsumerWidget {
  const ActiveDeliveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Responsive.init(context);
    final phase = ref.watch(deliveryPhaseProvider);

    return Scaffold(
      body: Stack(children: [
        // Map
        Container(height: Responsive.isTablet ? Responsive.h(100) : Responsive.h(55), color: const Color(0xFF1F2937), child: const Center(child: Icon(Icons.map, size: 64, color: Colors.white24))),

        // Bottom Sheet
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            constraints: BoxConstraints(maxWidth: Responsive.isTablet ? 500 : double.infinity),
            margin: Responsive.isTablet ? EdgeInsets.only(left: Responsive.w(50) - 250, right: Responsive.w(50) - 250) : EdgeInsets.zero,
            padding: Responsive.padding(horizontal: 24, vertical: 24),
            decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(32)), boxShadow: [BoxShadow(color: Colors.black.withAlpha(77), blurRadius: 20)]),
            child: SafeArea(top: false, child: _buildPhaseContent(context, ref, phase)),
          ),
        ),

        // Status Bar
        Positioned(
          top: 0, left: 0, right: 0,
          child: SafeArea(child: Container(
            margin: Responsive.padding(horizontal: 16, vertical: 16),
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(4), vertical: Responsive.h(1.5)),
            decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              Icon(Icons.delivery_dining, color: Colors.black, size: Responsive.sp(24)),
              SizedBox(width: Responsive.w(3)),
              Expanded(child: Text(_getPhaseLabel(phase), style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: Responsive.sp(14)))),
              Text('12.50 €', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: Responsive.sp(14))),
            ]),
          )).animate().slideY(begin: -1, end: 0),
        ),
      ]),
    );
  }

  String _getPhaseLabel(DeliveryPhase p) => switch (p) {
    DeliveryPhase.navigatingToRestaurant => 'En route vers le restaurant',
    DeliveryPhase.atRestaurant => 'Arrivé au restaurant',
    DeliveryPhase.navigatingToCustomer => 'En livraison',
    DeliveryPhase.atCustomer => 'Arrivé chez le client',
    DeliveryPhase.completed => 'Livraison terminée',
  };

  Widget _buildPhaseContent(BuildContext context, WidgetRef ref, DeliveryPhase phase) {
    switch (phase) {
      case DeliveryPhase.navigatingToRestaurant:
        return _NavPanel(title: 'Burger King', subtitle: '12 Rue de Rivoli', distance: '1.2 km', eta: '5 min', onArrived: () => ref.read(deliveryPhaseProvider.notifier).state = DeliveryPhase.atRestaurant);
      case DeliveryPhase.atRestaurant:
        return _PickupPanel(items: const ['2x Double Whopper', '1x Fries', '1x Coca'], onPickedUp: () => ref.read(deliveryPhaseProvider.notifier).state = DeliveryPhase.navigatingToCustomer);
      case DeliveryPhase.navigatingToCustomer:
        return _NavPanel(title: 'Jean Dupont', subtitle: '45 Av. Champs-Élysées', distance: '2.8 km', eta: '12 min', isDelivery: true, onArrived: () => ref.read(deliveryPhaseProvider.notifier).state = DeliveryPhase.atCustomer);
      case DeliveryPhase.atCustomer:
        return _DeliverPanel(onDelivered: () { ref.read(deliveryPhaseProvider.notifier).state = DeliveryPhase.completed; context.go('/'); });
      case DeliveryPhase.completed:
        return const Center(child: Text('Terminé !'));
    }
  }
}

class _NavPanel extends StatelessWidget {
  final String title, subtitle, distance, eta;
  final bool isDelivery;
  final VoidCallback onArrived;
  const _NavPanel({required this.title, required this.subtitle, required this.distance, required this.eta, this.isDelivery = false, required this.onArrived});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Row(children: [
        Container(padding: EdgeInsets.all(Responsive.w(3)), decoration: BoxDecoration(color: (isDelivery ? const Color(0xFF6366F1) : Colors.orange).withAlpha(51), shape: BoxShape.circle), child: Icon(isDelivery ? Icons.location_on : Icons.store, color: isDelivery ? const Color(0xFF6366F1) : Colors.orange, size: Responsive.sp(24))),
        SizedBox(width: Responsive.w(4)),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.outfit(fontSize: Responsive.sp(18), fontWeight: FontWeight.bold)), Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: Responsive.sp(14)))])),
      ]),
      SizedBox(height: Responsive.h(3)),
      Row(children: [_InfoTile(icon: Icons.route, value: distance, label: 'Distance'), SizedBox(width: Responsive.w(4)), _InfoTile(icon: Icons.timer, value: eta, label: 'ETA')]),
      SizedBox(height: Responsive.h(3)),
      SizedBox(width: double.infinity, height: Responsive.value(phone: 56, tablet: 64), child: ElevatedButton(onPressed: onArrived, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: Text("Je suis arrivé", style: GoogleFonts.outfit(fontSize: Responsive.sp(18), fontWeight: FontWeight.bold)))),
    ]);
  }
}

class _PickupPanel extends StatelessWidget {
  final List<String> items;
  final VoidCallback onPickedUp;
  const _PickupPanel({required this.items, required this.onPickedUp});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Text('Vérifiez la commande', style: GoogleFonts.outfit(fontSize: Responsive.sp(20), fontWeight: FontWeight.bold)),
      SizedBox(height: Responsive.h(2)),
      ...items.map((i) => Padding(padding: EdgeInsets.only(bottom: Responsive.h(1.5)), child: Row(children: [Icon(Icons.check_box_outline_blank, color: Colors.grey, size: Responsive.sp(20)), SizedBox(width: Responsive.w(3)), Text(i, style: TextStyle(fontSize: Responsive.sp(16)))]))),
      SizedBox(height: Responsive.h(3)),
      SizedBox(width: double.infinity, height: Responsive.value(phone: 56, tablet: 64), child: ElevatedButton(onPressed: onPickedUp, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: Text("Commande récupérée", style: GoogleFonts.outfit(fontSize: Responsive.sp(18), fontWeight: FontWeight.bold)))),
    ]);
  }
}

class _DeliverPanel extends StatelessWidget {
  final VoidCallback onDelivered;
  const _DeliverPanel({required this.onDelivered});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.check_circle_outline, size: Responsive.sp(64), color: const Color(0xFF10B981)),
      SizedBox(height: Responsive.h(2)),
      Text('Remettez la commande', style: GoogleFonts.outfit(fontSize: Responsive.sp(18))),
      SizedBox(height: Responsive.h(3)),
      SizedBox(width: double.infinity, height: Responsive.value(phone: 56, tablet: 64), child: ElevatedButton(onPressed: onDelivered, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: Text("Livraison effectuée", style: GoogleFonts.outfit(fontSize: Responsive.sp(18), fontWeight: FontWeight.bold)))),
    ]);
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String value, label;
  const _InfoTile({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Expanded(child: Container(
      padding: Responsive.padding(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Icon(icon, color: Colors.grey, size: Responsive.sp(20)),
        SizedBox(width: Responsive.w(3)),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: GoogleFonts.outfit(fontSize: Responsive.sp(18), fontWeight: FontWeight.bold)), Text(label, style: TextStyle(color: Colors.grey[500], fontSize: Responsive.sp(12)))]),
      ]),
    ));
  }
}
