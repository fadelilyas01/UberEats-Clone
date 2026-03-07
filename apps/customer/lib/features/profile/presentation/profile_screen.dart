import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../../core/providers/app_providers.dart';

// Mock user data
class UserProfile {
  final String name;
  final String email;
  final String phone;
  final String photoUrl;
  final int orderCount;
  final double totalSpent;
  final int loyaltyPoints;

  const UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.photoUrl,
    this.orderCount = 0,
    this.totalSpent = 0,
    this.loyaltyPoints = 0,
  });
}

final userProvider = Provider<UserProfile>((ref) => const UserProfile(
      name: 'John Doe',
      email: 'john.doe@example.com',
      phone: '+33 6 12 34 56 78',
      photoUrl: 'https://i.pravatar.cc/200',
      orderCount: 47,
      totalSpent: 1234.50,
      loyaltyPoints: 2450,
    ));

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
      body: Stack(children: [
        // Background gradient
        Container(
          height: 280,
          decoration: const BoxDecoration(gradient: AppColors.gradientPrimary),
        ),
        const BackgroundOrb(
            size: 200, color: Colors.white, alignment: Alignment(-1.5, -0.5)),

        SafeArea(
            child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GlassIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => context.pop(),
                      size: 44),
                  Text('Profil',
                      style: GoogleFonts.inter(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  GlassIconButton(
                      icon: Icons.settings_outlined, onTap: () {}, size: 44),
                ]),
          ),

          Expanded(
              child: ListView(padding: EdgeInsets.zero, children: [
            // Profile Card
            _ProfileCard(user: user)
                .animate()
                .fadeIn()
                .slideY(begin: 0.1, end: 0),

            // Stats
            _StatsSection(user: user)
                .animate(delay: 100.ms)
                .fadeIn()
                .slideY(begin: 0.1, end: 0),

            // Loyalty Card
            _LoyaltyCard(points: user.loyaltyPoints)
                .animate(delay: 200.ms)
                .fadeIn()
                .scale(begin: const Offset(0.95, 0.95)),

            // Menu Options
            const _MenuSection()
                .animate(delay: 300.ms)
                .fadeIn()
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 20),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _LogoutButton(),
            ).animate(delay: 400.ms).fadeIn(),

            const SizedBox(height: 40),
          ])),
        ])),
      ]),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final UserProfile user;
  const _ProfileCard({required this.user});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15))
          ],
        ),
        child: Column(children: [
          // Avatar
          Hero(
            tag: 'profile-avatar',
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8))
                ],
              ),
              padding: const EdgeInsets.all(4),
              child: ClipOval(child: OptimizedImage(imageUrl: user.photoUrl)),
            ),
          ),
          const SizedBox(height: 16),

          // Name & Email
          Text(user.name,
              style:
                  GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(user.email,
              style: GoogleFonts.inter(color: AppColors.textMuted)),
          const SizedBox(height: 16),

          // Edit Profile Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.edit_rounded,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text('Modifier le Profil',
                  style: GoogleFonts.inter(
                      color: AppColors.primary, fontWeight: FontWeight.w600)),
            ]),
          ),
        ]),
      );
}

class _StatsSection extends StatelessWidget {
  final UserProfile user;
  const _StatsSection({required this.user});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(children: [
          _StatCard(
              icon: Icons.receipt_long_rounded,
              value: '${user.orderCount}',
              label: 'Commandes',
              color: AppColors.secondary),
          const SizedBox(width: 12),
          _StatCard(
              icon: Icons.euro_rounded,
              value: '${user.totalSpent.toInt()}',
              label: 'Dépensé',
              color: AppColors.primary),
          const SizedBox(width: 12),
          const _StatCard(
              icon: Icons.favorite_rounded,
              value: '12',
              label: 'Favoris',
              color: AppColors.error),
        ]),
      );
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard(
      {required this.icon,
      required this.value,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label,
                style: GoogleFonts.inter(
                    color: AppColors.textMuted, fontSize: 12)),
          ]),
        ),
      );
}

class _LoyaltyCard extends StatelessWidget {
  final int points;
  const _LoyaltyCard({required this.points});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppColors.gradientSecondary,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: AppColors.secondary.withOpacity(0.4),
                blurRadius: 25,
                offset: const Offset(0, 12))
          ],
        ),
        child: Row(children: [
          // Points info
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  const Icon(Icons.stars_rounded,
                      color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Text('Points de Fidélité',
                      style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.8))),
                ]),
                const SizedBox(height: 8),
                Text('$points',
                    style: GoogleFonts.inter(
                        fontSize: 36, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('= \$${(points / 100).toStringAsFixed(2)} en récompenses',
                    style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.7), fontSize: 13)),
              ])),

          // Redeem button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Text('Échanger',
                style: GoogleFonts.inter(
                    color: AppColors.secondary, fontWeight: FontWeight.bold)),
          ),
        ]),
      );
}

class _MenuSection extends ConsumerWidget {
  const _MenuSection();

  static const _menuItems = [
    {
      'icon': Icons.location_on_rounded,
      'title': 'Adresses enregistrées',
      'subtitle': '3 addresses saved',
      'color': AppColors.primary
    },
    {
      'icon': Icons.credit_card_rounded,
      'title': 'Moyens de paiement',
      'subtitle': 'Visa •••• 4242',
      'color': AppColors.accent
    },
    {
      'icon': Icons.notifications_rounded,
      'title': 'Notifications',
      'subtitle': 'Push, email, SMS',
      'color': AppColors.secondary
    },
    {
      'icon': Icons.help_outline_rounded,
      'title': 'Aide & Support',
      'subtitle': '24/7 customer service',
      'color': AppColors.error
    },
    {
      'icon': Icons.description_outlined,
      'title': 'Conditions & Confidentialité',
      'subtitle': 'Legal information',
      'color': AppColors.textMuted
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useMock = ref.watch(useMockDataProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Paramètres',
              style:
                  GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                ..._menuItems.asMap().entries.map((e) => _MenuItem(
                      icon: e.value['icon'] as IconData,
                      title: e.value['title'] as String,
                      subtitle: e.value['subtitle'] as String,
                      color: e.value['color'] as Color,
                      showDivider: e.key < _menuItems.length - 1,
                    )),

                // Dev Mode Switch
                Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: Colors.white.withOpacity(0.05)),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.developer_mode_rounded,
                          color: Colors.purple, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('Mode Développeur',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(
                              useMock
                                  ? 'Utilisation de Données Factices'
                                  : 'Utilisation de Données Réelles (Firebase)',
                              style: GoogleFonts.inter(
                                  color: AppColors.textMuted, fontSize: 12)),
                        ])),
                    Switch(
                      value: !useMock,
                      onChanged: (val) {
                        ref.read(useMockDataProvider.notifier).state = !val;
                        // Show snackbar
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: val ? Colors.green : Colors.orange,
                          content: Text(val
                              ? 'Passage aux Données Réelles...'
                              : 'Passage aux Données Factices'),
                        ));
                      },
                      activeThumbColor: AppColors.primary,
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool showDivider;

  const _MenuItem(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.color,
      this.showDivider = true});

  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          color: AppColors.textMuted, fontSize: 12)),
                ])),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ]),
        ),
        if (showDivider)
          Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.white.withOpacity(0.05)),
      ]);
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => _showLogoutDialog(context),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.error.withOpacity(0.3)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.logout_rounded, color: AppColors.error),
            const SizedBox(width: 10),
            Text('Se Déconnecter',
                style: GoogleFonts.inter(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                    fontSize: 16)),
          ]),
        ),
      );

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Se Déconnecter ?',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text('Voulez-vous vraiment vous déconnecter ?',
            style: GoogleFonts.inter(color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Annuler',
                  style: GoogleFonts.inter(color: AppColors.textMuted))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/');
            },
            child: Text('Se Déconnecter',
                style: GoogleFonts.inter(
                    color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
