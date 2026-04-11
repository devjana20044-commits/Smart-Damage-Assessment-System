import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/localization.dart';
import '../../core/theme.dart';
import '../../models/report.dart';
import '../../providers/locale_provider.dart';
import '../../providers/report_provider.dart';
import '../../widgets/loading_indicator.dart';

class ReportDetailsScreen extends StatefulWidget {
  final int reportId;

  const ReportDetailsScreen({super.key, required this.reportId});

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  int _currentImageIndex = 0;
  bool _isEditing = false;

  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().fetchReportById(widget.reportId);
    });
  }

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: theme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Could not launch URL');
      }
    } catch (e) {
      _showErrorSnackBar('Error opening URL: ${e.toString()}');
    }
  }

  void _startEditing(Report report) {
    setState(() {
      _isEditing = true;
      _locationController.text = report.location.raw;
      _descriptionController.text = report.description.raw;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
    });
  }

  Future<void> _saveChanges() async {
    // TODO: Implement update report API call
    setState(() {
      _isEditing = false;
    });
    _showSuccessSnackBar(context.loc.reportUpdated);
  }

  Future<void> _deleteReport() async {
    final loc = context.loc;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.confirmDelete),
        content: Text(loc.deleteConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(loc.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final reportProvider = context.read<ReportProvider>();
      final success = await reportProvider.deleteReport(widget.reportId);
      if (success && mounted) {
        _showSuccessSnackBar(loc.reportDeleted);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.loc;
    final localeProvider = context.watch<LocaleProvider>();
    final isArabic = localeProvider.isArabic;
    final reportProvider = context.watch<ReportProvider>();
    final report = reportProvider.currentReport;

    if (reportProvider.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(reportProvider.errorMessage!);
        reportProvider.clearError();
      });
    }

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.reportDetails),
          actions: [
            if (report != null && report.isPending && !_isEditing) ...[
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _startEditing(report),
                tooltip: loc.editReport,
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: _deleteReport,
                tooltip: loc.deleteReport,
              ),
            ],
            if (_isEditing)
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: _saveChanges,
                tooltip: loc.save,
              ),
          ],
        ),
        body: reportProvider.isLoading && report == null
            ? LoadingIndicator(message: loc.loadingReportDetails)
            : report == null
            ? _buildErrorState(theme, loc)
            : _buildReportDetails(theme, report, loc, isArabic),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, AppLocalizations loc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(loc.failedToLoadReport, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            loc.pleaseTryAgain,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<ReportProvider>().fetchReportById(widget.reportId);
            },
            child: Text(loc.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildReportDetails(
    ThemeData theme,
    Report report,
    AppLocalizations loc,
    bool isArabic,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.getStatusColor(
                    report.damageAssessment.status.name,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.getStatusColor(
                      report.damageAssessment.status.name,
                    ),
                    width: 1,
                  ),
                ),
                child: Text(
                  isArabic ? report.displayStatusArabic : report.displayStatus,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.getStatusColor(
                      report.damageAssessment.status.name,
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (report.isPending) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.edit_note,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    loc.pendingEditNote,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 24),

          // Images section
          if (report.images.isNotEmpty) ...[
            Text(
              '${loc.images} (${report.images.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: report.images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          report.images[index],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: theme.colorScheme.surfaceContainerHighest,
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
                                    loc.imageNotAvailable,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  if (report.images.length > 1)
                    Positioned(
                      top: 8,
                      right: isArabic ? null : 8,
                      left: isArabic ? 8 : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_currentImageIndex + 1} / ${report.images.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  if (report.images.length > 1)
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          report.images.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // PDF section
          if (report.pdfUrl != null) ...[
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.picture_as_pdf,
                  color: theme.colorScheme.error,
                ),
                title: Text(loc.pdfDocument),
                subtitle: Text(loc.tapToView),
                trailing: Icon(
                  Icons.open_in_new,
                  color: theme.colorScheme.primary,
                ),
                onTap: () => _launchUrl(report.pdfUrl!),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Video links section
          if (report.videoLinks.isNotEmpty) ...[
            Text(
              '${loc.videoLinks} (${report.videoLinks.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...report.videoLinks.asMap().entries.map((entry) {
              final index = entry.key;
              final link = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.play_circle,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(
                    '${loc.video} ${index + 1}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    link,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  trailing: Icon(
                    Icons.open_in_new,
                    color: theme.colorScheme.primary,
                  ),
                  onTap: () => _launchUrl(link),
                ),
              );
            }).toList(),
            const SizedBox(height: 24),
          ],

          // Basic Information Section
          _buildSection(theme, loc.basicInformation, [
            if (_isEditing && report.isPending)
              _buildEditableField(loc.location, _locationController)
            else
              _buildInfoRow(loc.location, report.location.raw, theme),
            if (report.location.normalized != null)
              _buildInfoRow(
                loc.normalizedLocation,
                report.location.normalized!,
                theme,
              ),
            _buildInfoRow(loc.date, report.formattedCreatedDate, theme),
            if (report.location.coordinates != null)
              _buildInfoRow(
                loc.coordinates,
                report.formattedCoordinates,
                theme,
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: report.formattedCoordinates),
                  );
                  _showSuccessSnackBar('${loc.coordinates} ${loc.copied}');
                },
              ),
            _buildInfoRow(loc.reportedBy, report.user.name, theme),
          ]),

          // Description Section
          _buildSection(theme, loc.description, [
            if (_isEditing && report.isPending)
              _buildEditableField(
                loc.userDescription,
                _descriptionController,
                maxLines: 4,
              )
            else
              _buildInfoRow(loc.userDescription, report.description.raw, theme),
            if (report.description.aiAnalysis != null &&
                report.description.aiAnalysis!.isNotEmpty)
              _buildInfoRow(
                loc.aiAnalysis,
                report.description.aiAnalysis!,
                theme,
              ),
          ]),

          // Damage Assessment Section
          _buildSection(theme, loc.damageAssessment, [
            _buildInfoRow(
              loc.damageLevel,
              isArabic
                  ? report.displayDamageLevelArabic
                  : report.displayDamageLevel,
              theme,
            ),
            _buildInfoRow(
              loc.status,
              isArabic ? report.displayStatusArabic : report.displayStatus,
              theme,
            ),
          ]),

          // Cancel edit button
          if (_isEditing)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _cancelEditing,
                  icon: const Icon(Icons.cancel),
                  label: Text(loc.cancel),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
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

  Widget _buildInfoRow(
    String label,
    String value,
    ThemeData theme, {
    VoidCallback? onTap,
  }) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
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
                  textDirection: TextDirection.ltr,
                ),
              ),
              if (onTap != null)
                Icon(Icons.copy, size: 16, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
