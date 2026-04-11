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
      appBar: AppBar(title: Text(loc.statistics), centerTitle: true),
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

          // Damage level counts - only for completed reports
          final completedReports = reports.where((r) => r.isCompleted);
          final lowCount = completedReports
              .where((r) => r.damageAssessment.level == DamageLevel.low)
              .length;
          final mediumCount = completedReports
              .where((r) => r.damageAssessment.level == DamageLevel.medium)
              .length;
          final highCount = completedReports
              .where((r) => r.damageAssessment.level == DamageLevel.high)
              .length;
          final criticalCount = completedReports
              .where((r) => r.damageAssessment.level == DamageLevel.critical)
              .length;

          return RefreshIndicator(
            onRefresh: () => reportProvider.fetchReports(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Total Reports Card - Smaller
                  _buildTotalCard(total, theme),
                  const SizedBox(height: 20),

                  // Status Section
                  _buildSectionTitle(context, loc.reportStatus, theme),
                  const SizedBox(height: 12),
                  _buildStatusGrid(
                    context: context,
                    completed: completed,
                    pending: pending,
                    processing: processing,
                    rejected: rejected,
                  ),
                  const SizedBox(height: 24),

                  // Damage Levels Section
                  _buildSectionTitle(context, loc.damageLevels, theme),
                  const SizedBox(height: 12),
                  _buildDamageLevelsCard(
                    context,
                    loc: loc,
                    theme: theme,
                    low: lowCount,
                    medium: mediumCount,
                    high: highCount,
                    critical: criticalCount,
                    processedTotal: completedReports.length,
                  ),
                  const SizedBox(height: 24),

                  // Distribution Overview
                  _buildDistributionCard(context, loc, theme),
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
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bar_chart_outlined,
                size: 60,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              loc.noDataAvailable,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              loc.createReportsToSeeStats,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard(int total, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.85),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.loc.totalReports,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  total.toString(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.trending_up,
            color: Colors.white.withValues(alpha: 0.7),
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusGrid({
    required BuildContext context,
    required int completed,
    required int pending,
    required int processing,
    required int rejected,
  }) {
    final loc = context.loc;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatusCard(
                context,
                title: loc.completedReports,
                count: completed,
                color: AppTheme.successColor,
                icon: Icons.check_circle_outline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatusCard(
                context,
                title: loc.pendingReports,
                count: pending,
                color: AppTheme.statusPending,
                icon: Icons.pending_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatusCard(
                context,
                title: loc.processing,
                count: processing,
                color: AppTheme.accentColor,
                icon: Icons.sync,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatusCard(
                context,
                title: loc.rejectedReports,
                count: rejected,
                color: AppTheme.errorColor,
                icon: Icons.cancel_outlined,
              ),
            ),
          ],
        ),
      ],
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  count.toString(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDamageLevelsCard(
    BuildContext context, {
    required AppLocalizations loc,
    required ThemeData theme,
    required int low,
    required int medium,
    required int high,
    required int critical,
    required int processedTotal,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: theme.colorScheme.primary,
                size: 22,
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
          if (processedTotal == 0) ...[
            const SizedBox(height: 24),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'لا توجد تقارير معالجة بعد',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 20),
            _buildDamageLevelRow(
              context,
              label: loc.low,
              count: low,
              total: processedTotal,
              color: AppTheme.damageLow,
              icon: Icons.sentiment_satisfied_alt,
            ),
            const SizedBox(height: 14),
            _buildDamageLevelRow(
              context,
              label: loc.medium,
              count: medium,
              total: processedTotal,
              color: AppTheme.damageMedium,
              icon: Icons.sentiment_neutral,
            ),
            const SizedBox(height: 14),
            _buildDamageLevelRow(
              context,
              label: loc.high,
              count: high,
              total: processedTotal,
              color: AppTheme.damageHigh,
              icon: Icons.sentiment_dissatisfied,
            ),
            const SizedBox(height: 14),
            _buildDamageLevelRow(
              context,
              label: loc.critical,
              count: critical,
              total: processedTotal,
              color: AppTheme.damageCritical,
              icon: Icons.dangerous_outlined,
            ),
          ],
        ],
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count ($percentage%)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: total > 0 ? count / total : 0,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDistributionCard(
    BuildContext context,
    AppLocalizations loc,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pie_chart_outline,
                color: theme.colorScheme.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                loc.distributionOverview,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.insert_chart_outlined,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.chartPlaceholder,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
