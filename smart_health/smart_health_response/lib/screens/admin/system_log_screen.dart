import 'package:flutter/material.dart';
import 'package:smart_health_response/core/constants/enums.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/text_styles.dart';
import '../../models/audit_log_model.dart';
import '../../services/service_locator.dart';
import '../../utils/formatters.dart';
import '../../widgets/layout/empty_state.dart';

class SystemLogScreen extends StatefulWidget {
  const SystemLogScreen({super.key});

  @override
  State<SystemLogScreen> createState() => _SystemLogScreenState();
}

class _SystemLogScreenState extends State<SystemLogScreen> {
  List<AuditLog> _logs = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _logs = await sl.audit.getAll();
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('System Activity Log')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: AppColors.error),
                      const SizedBox(height: AppDimensions.paddingM),
                      Text('Failed to load logs',
                          style: AppTextStyles.titleSmall),
                      const SizedBox(height: AppDimensions.paddingS),
                      Text(_error!,
                          style: AppTextStyles.bodySmall,
                          textAlign: TextAlign.center),
                      const SizedBox(height: AppDimensions.paddingL),
                      ElevatedButton(
                        onPressed: _load,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _logs.isEmpty
                  ? const EmptyState(
                      icon: Icons.list_alt_outlined,
                      title: 'No log entries',
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding:
                            const EdgeInsets.all(AppDimensions.paddingL),
                        itemCount: _logs.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppDimensions.paddingS),
                        itemBuilder: (_, i) {
                          final l = _logs[i];
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusM),
                            ),
                            child: ListTile(
                              leading: Icon(
                                _iconForAction(l.actionType),
                                color: AppColors.primary,
                              ),
                              title: Text(
                                '${l.actionType.name} · ${l.resourceType}',
                                style: AppTextStyles.titleSmall,
                              ),
                              subtitle: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'User: ${l.userId.length > 12 ? '${l.userId.substring(0, 12)}…' : l.userId}',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                  Text(
                                    Formatters.dateTime(l.timestamp),
                                    style: AppTextStyles.caption,
                                  ),
                                  if (l.changeDetails.isNotEmpty)
                                    Text(
                                      l.changeDetails,
                                      style: AppTextStyles.caption,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  IconData _iconForAction(AuditActionType type) {
    switch (type) {
      case AuditActionType.login:
        return Icons.login_outlined;
      case AuditActionType.logout:
        return Icons.logout_outlined;
      case AuditActionType.dataModification:
        return Icons.edit_outlined;
      case AuditActionType.dataAccess:
        return Icons.visibility_outlined;
      case AuditActionType.alertCreation:
        return Icons.notification_add_outlined;
      case AuditActionType.approvalAction:
        return Icons.check_circle_outline;
      case AuditActionType.systemAction:
        return Icons.settings_outlined;
    }
  }
}
