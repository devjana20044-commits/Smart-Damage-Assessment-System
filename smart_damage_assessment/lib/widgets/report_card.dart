import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../core/theme.dart';
import '../models/report.dart';

class ReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback? onTap;
  final bool isArabic;

  const ReportCard({
    super.key,
    required this.report,
    this.onTap,
    this.isArabic = false,
  });

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final statusColor = _getStatusColor();
    final borderColor = _getBorderColor();
    final statusLabel = _getStatusLabel(loc);
    final statusIcon = _getStatusIcon();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF172439).withValues(alpha: 0.05),
              offset: const Offset(0, 4),
              blurRadius: 6,
            ),
            BoxShadow(
              color: const Color(0xFF172439).withValues(alpha: 0.05),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
          border: Border.all(color: const Color(0xFFE4E2DD)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageSection(statusColor, statusLabel, statusIcon),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: isArabic
                              ? BorderSide.none
                              : BorderSide(color: borderColor, width: 4),
                          left: isArabic
                              ? BorderSide(color: borderColor, width: 4)
                              : BorderSide.none,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  report.location.raw,
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    height: 28 / 20,
                                    color: Color(0xFF172439),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '#REP-${report.id}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF75777D),
                                  letterSpacing: 0.05,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 18,
                                color: Color(0xFF44474D),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  report.location.raw,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF44474D),
                                    height: 20 / 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: Color(0xFF44474D),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    report.formattedCreatedDate,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF44474D),
                                      letterSpacing: 0.05,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: onTap,
                                child: Row(
                                  children: [
                                    Text(
                                      loc.details,
                                      style: const TextStyle(
                                        color: Color(0xFF745A34),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Icon(
                                      isArabic
                                          ? Icons.chevron_left
                                          : Icons.chevron_right,
                                      size: 18,
                                      color: const Color(0xFF745A34),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(
    Color statusColor,
    String statusLabel,
    IconData statusIcon,
  ) {
    final hasImage = report.images.isNotEmpty;

    return SizedBox(
      height: 192,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasImage)
            Image.network(
              report.images.first,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(color: AppTheme.surfaceVariant);
              },
              errorBuilder: (_, _, _) => Container(
                color: AppTheme.surfaceVariant,
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 40,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.navyCore.withValues(alpha: 0.08),
                    AppTheme.navyCore.withValues(alpha: 0.15),
                  ],
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.photo_camera_outlined,
                  size: 48,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          Positioned(
            top: 12,
            left: isArabic ? null : 12,
            right: isArabic ? 12 : null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.05,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (report.damageAssessment.status) {
      case ReportStatus.completed:
        return const Color(0xFF003F53);
      case ReportStatus.processing:
        return AppTheme.statusPending;
      case ReportStatus.pending:
        return AppTheme.damageHigh;
      case ReportStatus.rejected:
        return AppTheme.errorColor;
    }
  }

  Color _getBorderColor() {
    if (report.damageAssessment.status == ReportStatus.completed) {
      return const Color(0xFF9CCDE6);
    }
    return AppTheme.getStatusColor(report.damageAssessment.status.name);
  }

  String _getStatusLabel(AppLocalizations loc) {
    return isArabic ? report.displayStatusArabic : report.displayStatus;
  }

  IconData _getStatusIcon() {
    switch (report.damageAssessment.status) {
      case ReportStatus.completed:
        return Icons.check_circle;
      case ReportStatus.processing:
        return Icons.hourglass_top;
      case ReportStatus.pending:
        return Icons.warning;
      case ReportStatus.rejected:
        return Icons.cancel;
    }
  }
}

class CompactReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback? onTap;

  const CompactReportCard({super.key, required this.report, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppTheme.getStatusColor(
                    report.damageAssessment.status.name,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
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
              Text(
                report.formattedCreatedDate,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
