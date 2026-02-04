import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization.dart';
import '../../core/theme.dart';
import '../../models/report.dart';
import '../../providers/report_provider.dart';
import '../../widgets/loading_indicator.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    // Load reports if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportProvider = context.read<ReportProvider>();
      if (reportProvider.reports.isEmpty) {
        reportProvider.fetchReports();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.statistics),
        centerTitle: true,
      ),
      body: Consumer<ReportProvider>(
        builder: (context, reportProvider, child) {
          final reports = reportProvider.reports;
          
          if (reportProvider.isLoading && reports.isEmpty) {
            return LoadingIndicator(message: loc.loadingStatistics);
          }

          if (reports.isEmpty) {
            return _buildEmptyState(context, loc);
          }

          // Calculate statistics
          final total = reports.length;
          final completed = reports.where((r) => r.isCompleted).length;
          final pending = reports.where((r) => r.isPending).length;
          final processing = reports.where((r) => r.isProcessing).length;
          final rejected = reports.where((r) => r.isRejected).length;

          // Damage level counts
          final low = reports.where((r) => r.damageAssessment.level == DamageLevel.low).length;
          final medium = reports.where((r) => r.damageAssessment.level == DamageLevel.medium).length;
          final high = reports.where((r) => r.damageAssessment.level == DamageLevel.high).length;
          final critical = reports.where((r) => r.damageAssessment.level == DamageLevel.critical).length;

          return RefreshIndicator(
            onRefresh: () => reportProvider.fetchReports(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Summary Cards
                  Text(
                    loc.totalReports,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryCard(
                    context,
                    title: loc.totalReports,
                    count: total,
                    color: theme.primaryColor,
                    icon: Icons.assignment,
                  ),
                  const SizedBox(height: 16),
                  
                  // Status Breakdown
                  Text(
                    loc.reportStatus,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 2.5,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _buildStatusCard(
                        context,
                        title: loc.completedReports,
                        count: completed,
                        color: AppTheme.successColor,
                        icon: Icons.check_circle,
                      ),
                      _buildStatusCard(
                        context,
                        title: loc.pendingReports,
                        count: pending,
                        color: AppTheme.statusPending,
                        icon: Icons.pending,
                      ),
                      _buildStatusCard(
                        context,
                        title: loc.processing,
                        count: processing,
                        color: AppTheme.accentColor,
                        icon: Icons.sync,
                      ),
                      _buildStatusCard(
                        context,
                        title: loc.rejectedReports,
                        count: rejected,
                        color: AppTheme.errorColor,
                        icon: Icons.cancel,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Damage Levels
                  Text(
                    loc.damageLevels,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDamageLevelsSection(
                    context,
                    low: low,
                    medium: medium,
                    high: high,
                    critical: critical,
                    total: total,
                  ),
                  const SizedBox(height: 24),
                  
                  // Chart Placeholder (optional)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.distributionOverview,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 150,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                loc.chartPlaceholder,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations loc) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 80,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            loc.noDataAvailable,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loc.createReportsToSeeStats,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    count.toString(),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context, {
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    count.toString(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDamageLevelsSection(
    BuildContext context, {
    required int low,
    required int medium,
    required int high,
    required int critical,
    required int total,
  }) {
    final loc = context.loc;
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning,
                  color: theme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  loc.damageSeverityDistribution,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDamageLevelRow(
              context,
              label: loc.low,
              count: low,
              total: total,
              color: AppTheme.damageLow,
              icon: Icons.tag_faces,
            ),
            const SizedBox(height: 12),
            _buildDamageLevelRow(
              context,
              label: loc.medium,
              count: medium,
              total: total,
              color: AppTheme.damageMedium,
              icon: Icons.warning_amber,
            ),
            const SizedBox(height: 12),
            _buildDamageLevelRow(
              context,
              label: loc.high,
              count: high,
              total: total,
              color: AppTheme.damageHigh,
              icon: Icons.error_outline,
            ),
            const SizedBox(height: 12),
            _buildDamageLevelRow(
              context,
              label: loc.critical,
              count: critical,
              total: total,
              color: AppTheme.damageCritical,
              icon: Icons.dangerous,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDamageLevelRow(
    BuildContext context, {
    required String label,
    required int count,
    required int total,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final percentage = total > 0 ? (count / total * 100).round() : 0;
    
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '$count ($percentage%)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: total > 0 ? count / total : 0,
                backgroundColor: theme.colorScheme.surfaceVariant,
                color: color,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}