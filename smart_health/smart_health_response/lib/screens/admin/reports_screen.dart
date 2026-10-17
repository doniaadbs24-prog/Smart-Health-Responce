import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../providers/admin_provider.dart';
import '../../services/export_service.dart';
import '../../utils/extensions.dart';
import '../../widgets/buttons/outlined_button_widget.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/cards/stat_tile.dart';
import '../../widgets/layout/section_header.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _exportingPdf = false;
  bool _exportingExcel = false;
  String? _lastSavedPath;

  Future<void> _exportPdf() async {
    setState(() => _exportingPdf = true);
    try {
      final p = context.read<AdminProvider>();
      final tempFile = await ExportService.generatePdf(p);
      if (!mounted) return;

      final dir = await getExternalStorageDirectory();
      if (dir == null) throw Exception('Storage not available');
      final fileName =
          'SHR_Report_${DateTime.now().millisecondsSinceEpoch}.pdf';
      await tempFile.copy('${dir.path}/$fileName');

      if (mounted) {
        setState(() => _lastSavedPath = '${dir.path}/$fileName');
        context.showSnack('PDF saved: $fileName');
      }
    } catch (e) {
      if (mounted) {
        context.showSnack('PDF export failed: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _exportingPdf = false);
    }
  }

  Future<void> _exportExcel() async {
    setState(() => _exportingExcel = true);
    try {
      final p = context.read<AdminProvider>();
      final tempFile = await ExportService.generateExcel(p);
      if (!mounted) return;

      final dir = await getExternalStorageDirectory();
      if (dir == null) throw Exception('Storage not available');
      final fileName =
          'SHR_Report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      await tempFile.copy('${dir.path}/$fileName');

      if (mounted) {
        setState(() => _lastSavedPath = '${dir.path}/$fileName');
        context.showSnack('Excel saved: $fileName');
      }
    } catch (e) {
      if (mounted) {
        context.showSnack('Excel export failed: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _exportingExcel = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdminProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        children: [
          const SectionHeader(title: 'System totals'),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  icon: Icons.people_outline,
                  label: 'Users',
                  value: '${p.users.length}',
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: StatTile(
                  icon: Icons.medical_services_outlined,
                  label: 'Cases',
                  value: '${p.allCases.length}',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  icon: Icons.local_hospital_outlined,
                  label: 'Facilities',
                  value: '${p.facilities.length}',
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: StatTile(
                  icon: Icons.favorite_outline,
                  label: 'AEDs',
                  value: '${p.aeds.length}',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingXL),
          PrimaryButton(
            label: 'Download PDF',
            icon: Icons.picture_as_pdf_outlined,
            onPressed: _exportPdf,
            isLoading: _exportingPdf,
          ),
          const SizedBox(height: AppDimensions.paddingM),
          OutlinedAppButton(
            label: 'Download Excel',
            icon: Icons.table_chart_outlined,
            onPressed: _exportExcel,
          ),
          if (_exportingExcel)
            const Padding(
              padding: EdgeInsets.only(top: AppDimensions.paddingM),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_lastSavedPath != null) ...[
            const SizedBox(height: AppDimensions.paddingL),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      color: AppColors.success, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Saved to:\n$_lastSavedPath',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
