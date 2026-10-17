import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reporter_provider.dart';
import '../../widgets/cards/case_card.dart';
import '../../widgets/layout/empty_state.dart';

class CaseHistoryScreen extends StatefulWidget {
  const CaseHistoryScreen({super.key});

  @override
  State<CaseHistoryScreen> createState() => _CaseHistoryScreenState();
}

class _CaseHistoryScreenState extends State<CaseHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<ReporterProvider>().watchMyCases(user.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ReporterProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('My Cases')),
      body: p.isLoading
          ? const Center(child: CircularProgressIndicator())
          : p.myCases.isEmpty
          ? const EmptyState(
              icon: Icons.history_outlined,
              title: 'No cases yet',
              subtitle: 'Your past emergencies will appear here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              itemCount: p.myCases.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppDimensions.paddingM),
              itemBuilder: (_, i) => CaseCard(
                emergencyCase: p.myCases[i],
                onTap: () => context.push(
                  '${AppRoutes.caseTracking}?caseId=${p.myCases[i].caseId}',
                ),
              ),
            ),
    );
  }
}
