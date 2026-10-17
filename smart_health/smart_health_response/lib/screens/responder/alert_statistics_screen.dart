import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/dimensions.dart';
import '../../providers/responder_provider.dart';
import '../../widgets/cards/stat_tile.dart';
import '../../widgets/layout/section_header.dart';

class AlertStatisticsScreen extends StatelessWidget {
  const AlertStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ResponderProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        children: [
          const SectionHeader(title: 'This Month'),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  icon: Icons.notifications_active_outlined,
                  label: 'Alerts received',
                  value: '${p.activeCases.length + p.nearbyAlerts.length}',
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: StatTile(
                  icon: Icons.check_circle_outline,
                  label: 'Accepted',
                  value: '${p.activeCases.length}',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  icon: Icons.timer_outlined,
                  label: 'Avg response',
                  value: '${(p.profile?.responseTime ?? 0).toStringAsFixed(1)}m',
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: StatTile(
                  icon: Icons.star_outline,
                  label: 'Avg rating',
                  value: (p.profile?.averageRating ?? 0).toStringAsFixed(1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
