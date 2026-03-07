import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/utils/responsive.dart';

class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Responsive.init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Earnings', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: Responsive.sp(20))),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.calendar_today, size: Responsive.sp(22)), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: Responsive.padding(horizontal: 20, vertical: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Total Earnings Card
          Container(
            width: double.infinity,
            padding: Responsive.padding(horizontal: 24, vertical: 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('This Week', style: TextStyle(color: Colors.white70, fontSize: Responsive.sp(14))),
              SizedBox(height: Responsive.h(1)),
              Text('€ 342.50', style: GoogleFonts.outfit(color: Colors.white, fontSize: Responsive.sp(40), fontWeight: FontWeight.bold)),
              SizedBox(height: Responsive.h(2)),
              Row(children: [
                const _StatBadge(label: '47 trips', icon: Icons.delivery_dining),
                SizedBox(width: Responsive.w(3)),
                const _StatBadge(label: '4.9 ⭐', icon: Icons.star),
              ]),
            ]),
          ),

          SizedBox(height: Responsive.h(4)),

          // Weekly Chart
          Text('Weekly Overview', style: GoogleFonts.outfit(fontSize: Responsive.sp(18), fontWeight: FontWeight.bold)),
          SizedBox(height: Responsive.h(2)),
          
          Container(
            height: Responsive.h(25),
            padding: Responsive.padding(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(20)),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][v.toInt()], style: TextStyle(color: Colors.grey, fontSize: Responsive.sp(10))))),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeBarGroup(0, 45),
                  _makeBarGroup(1, 60),
                  _makeBarGroup(2, 35),
                  _makeBarGroup(3, 80),
                  _makeBarGroup(4, 55),
                  _makeBarGroup(5, 90),
                  _makeBarGroup(6, 50),
                ],
              ),
            ),
          ),

          SizedBox(height: Responsive.h(4)),

          // Recent Earnings
          Text('Recent Deliveries', style: GoogleFonts.outfit(fontSize: Responsive.sp(18), fontWeight: FontWeight.bold)),
          SizedBox(height: Responsive.h(2)),
          
          ...List.generate(5, (i) => _EarningItem(
            restaurant: 'Burger King - Rivoli',
            time: '${10 + i}:30',
            amount: (8.50 + i * 1.5),
            tip: i % 2 == 0 ? 2.0 : null,
          )),
        ]),
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(toY: y, color: const Color(0xFF10B981), width: 16, borderRadius: const BorderRadius.vertical(top: Radius.circular(6))),
    ]);
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  const _StatBadge({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(3), vertical: Responsive.h(0.8)),
      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        Icon(icon, color: Colors.white, size: Responsive.sp(16)),
        SizedBox(width: Responsive.w(1)),
        Text(label, style: TextStyle(color: Colors.white, fontSize: Responsive.sp(13), fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _EarningItem extends StatelessWidget {
  final String restaurant;
  final String time;
  final double amount;
  final double? tip;

  const _EarningItem({required this.restaurant, required this.time, required this.amount, this.tip});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.h(1.5)),
      padding: Responsive.padding(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Container(
          padding: EdgeInsets.all(Responsive.w(3)),
          decoration: BoxDecoration(color: const Color(0xFF10B981).withAlpha(51), borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.delivery_dining, color: const Color(0xFF10B981), size: Responsive.sp(22)),
        ),
        SizedBox(width: Responsive.w(4)),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(restaurant, style: GoogleFonts.outfit(fontSize: Responsive.sp(15), fontWeight: FontWeight.w600)),
          Text('Today, $time', style: TextStyle(color: Colors.grey[500], fontSize: Responsive.sp(13))),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('€ ${amount.toStringAsFixed(2)}', style: GoogleFonts.outfit(color: const Color(0xFF10B981), fontSize: Responsive.sp(16), fontWeight: FontWeight.bold)),
          if (tip != null) Text('+ €${tip!.toStringAsFixed(2)} tip', style: TextStyle(color: Colors.amber, fontSize: Responsive.sp(12))),
        ]),
      ]),
    );
  }
}
