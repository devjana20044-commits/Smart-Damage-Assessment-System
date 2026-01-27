import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/report.dart';

/// Card widget to display report information in a list
class ReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback? onTap;
  final bool showImage;

  const ReportCard({
    super.key,
    required this.report,
    this.onTap,
    this.showImage = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image thumbnail (if enabled and image exists)
              if (showImage)
                Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: theme.colorScheme.surfaceVariant,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      report.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.image_not_supported,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 24,
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // Report details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location
                    Text(
                      report.location.raw,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // AI Analysis (if available)
                    if (report.description.aiAnalysis != null &&
                        report.description.aiAnalysis!.isNotEmpty)
                      Text(
                        report.description.aiAnalysis!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const SizedBox(height: 8),

                    // Status and date
                    Row(
                      children: [
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.getStatusColor(report.damageAssessment.status.name)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.getStatusColor(report.damageAssessment.status.name),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            report.displayStatus,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.getStatusColor(report.damageAssessment.status.name),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Date
                        Text(
                          report.formattedCreatedDate,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),

                        // Damage level (if completed)
                        if (report.isCompleted)
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.getDamageLevelColorFromString(
                                      report.damageAssessment.level.name)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  report.displayDamageLevel,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppTheme.getDamageLevelColorFromString(
                                        report.damageAssessment.level.name),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact version of report card for smaller spaces
class CompactReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback? onTap;

  const CompactReportCard({
    super.key,
    required this.report,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Status indicator
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppTheme.getStatusColor(report.damageAssessment.status.name),
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 12),

              // Location
              Expanded(
                child: Text(
                  report.location.raw,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Date
              Text(
                report.formattedCreatedDate,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}