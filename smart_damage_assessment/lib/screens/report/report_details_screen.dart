import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/report.dart';
import '../../providers/report_provider.dart';
import '../../widgets/loading_indicator.dart';

class ReportDetailsScreen extends StatefulWidget {
  final int reportId;

  const ReportDetailsScreen({
    super.key,
    required this.reportId,
  });

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Load report details when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().fetchReportById(widget.reportId);
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reportProvider = context.watch<ReportProvider>();
    final report = reportProvider.currentReport;

    // Show error message if any
    if (reportProvider.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(reportProvider.errorMessage!);
        reportProvider.clearError();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
      ),
      body: reportProvider.isLoading && report == null
          ? const LoadingIndicator(message: 'Loading report details...')
          : report == null
              ? _buildErrorState(theme)
              : _buildReportDetails(theme, report),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load report',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again later',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<ReportProvider>().fetchReportById(widget.reportId);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportDetails(ThemeData theme, Report report) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                report.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: theme.colorScheme.surfaceVariant,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: theme.colorScheme.surfaceVariant,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Image not available',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.getStatusColor(report.damageAssessment.status.name).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.getStatusColor(report.damageAssessment.status.name),
                width: 1,
              ),
            ),
            child: Text(
              report.displayStatus,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.getStatusColor(report.damageAssessment.status.name),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Basic Information Section
          _buildSection(
            theme,
            'Basic Information',
            [
              _buildInfoRow('Location', report.location.raw),
              if (report.location.normalized != null)
                _buildInfoRow('Normalized Location', report.location.normalized!),
              _buildInfoRow('Date', report.formattedCreatedDate),
              if (report.location.coordinates != null)
                _buildInfoRow('Coordinates', report.formattedCoordinates),
              _buildInfoRow('Reported By', report.user.name),
            ],
          ),

          // Description Section
          _buildSection(
            theme,
            'Description',
            [
              _buildInfoRow('User Description', report.description.raw),
              if (report.description.aiAnalysis != null && report.description.aiAnalysis!.isNotEmpty)
                _buildInfoRow('AI Analysis', report.description.aiAnalysis!),
            ],
          ),

          // Damage Assessment Section
          _buildSection(
            theme,
            'Damage Assessment',
            [
              _buildInfoRow('Damage Level', report.displayDamageLevel),
              _buildInfoRow('Status', report.displayStatus),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
