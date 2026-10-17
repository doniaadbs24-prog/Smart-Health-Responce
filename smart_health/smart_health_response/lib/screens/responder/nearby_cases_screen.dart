import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/routes.dart';
import '../../providers/responder_provider.dart';
import '../../widgets/cards/case_card.dart';
import '../../widgets/layout/empty_state.dart';

class NearbyCasesScreen extends StatelessWidget {
  const NearbyCasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ResponderProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Near cases')),
      body: p.nearbyAlerts.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_off_outlined, title: 'No nearby cases')
          : ListView.separated(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              itemCount: p.nearbyAlerts.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.paddingM),
              itemBuilder: (_, i) => CaseCard(
                emergencyCase: p.nearbyAlerts[i],
                onTap: () => context.push(AppRoutes.alertNotification, extra: p.nearbyAlerts[i]),
              ),
            ),
    );
  }
}
