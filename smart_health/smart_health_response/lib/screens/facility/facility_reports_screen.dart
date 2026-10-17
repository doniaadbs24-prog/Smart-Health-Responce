import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/dimensions.dart';
import '../../providers/facility_provider.dart';
import '../../widgets/cards/stat_tile.dart';
import '../../widgets/layout/section_header.dart';

class FacilityReportsScreen extends StatelessWidget {
  const FacilityReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<FacilityProvider>();
    final f = p.facility;
    return Scaffold(
      appBar: AppBar(title: const Text('Facility Reports')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        children: [
          const SectionHeader(title: 'Current Activity'),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  icon: Icons.call_received_outlined,
                  label: 'Incoming cases',
                  value: '${p.incomingCases.length}',
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: StatTile(
                  icon: Icons.healing_outlined,
                  label: 'In treatment',
                  value: '${p.currentCases.length}',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingM),
          const SectionHeader(title: 'Overall Statistics'),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  icon: Icons.medical_services_outlined,
                  label: 'Total handled',
                  value: '${f?.casesReceived ?? p.totalCasesHandled}',
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: StatTile(
                  icon: Icons.timer_outlined,
                  label: 'Avg response',
                  value: '${(f?.averageResponseTime ?? 0).toStringAsFixed(1)}m',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  icon: Icons.bed_outlined,
                  label: 'Capacity',
                  value: '${f?.capacity ?? 0}',
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: StatTile(
                  icon: Icons.person_outline,
                  label: 'Available beds',
                  value: '${f?.availableBeds ?? 0}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
