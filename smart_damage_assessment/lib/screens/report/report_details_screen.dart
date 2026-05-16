import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/localization.dart';
import '../../core/theme.dart';
import '../../models/report.dart';
import '../../providers/locale_provider.dart';
import '../../providers/report_provider.dart';
import '../../widgets/loading_indicator.dart';
import 'create_report_screen.dart';

class ReportDetailsScreen extends StatefulWidget {
  final int reportId;

  const ReportDetailsScreen({super.key, required this.reportId});

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen>
    with SingleTickerProviderStateMixin {
  int _currentImageIndex = 0;
  late AnimationController _pulseController;
  WebViewController? _mapController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().fetchReportById(widget.reportId);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _initMapController(Report report) {
    if (_mapController != null) return;
    double? lat = report.location.coordinates?.latitude;
    double? lng = report.location.coordinates?.longitude;

    if (lat != null && lng != null) {
      _mapController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadHtmlString('''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
  <style>
    * { margin: 0; padding: 0; }
    html, body, #map { width: 100%; height: 100%; }
  </style>
</head>
<body>
  <div id="map"></div>
  <script>
    var map = L.map('map').setView([$lat, $lng], 15);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; OpenStreetMap contributors'
    }).addTo(map);
    L.marker([$lat, $lng]).addTo(map);
  </script>
</body>
</html>
''');
    }
  }

  void _startEditing(Report report) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateReportScreen(reportId: report.id),
      ),
    ).then((_) {
      if (mounted) {
        context.read<ReportProvider>().fetchReportById(widget.reportId);
      }
    });
  }

  void _openFullScreenImage(Report report, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullScreenImageViewer(
          images: report.images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  Future<void> _deleteReport(Report report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          context.loc.confirmDelete,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          context.loc.deleteConfirmation,
          style: const TextStyle(color: Color(0xFFCBD5E1)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              context.loc.cancel,
              style: const TextStyle(color: Color(0xFFCBD5E1)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(context.loc.deleteReport),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<ReportProvider>().deleteReport(report.id);
      if (success && mounted) {
        _showSuccessSnackBar(context.loc.reportDeleted);
        Navigator.pop(context);
      } else if (mounted) {
        _showErrorSnackBar(context.loc.failedToLoadReport);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: const Color(0xFFFBF9F4),
        appBar: _buildAppBar(loc, isArabic),
        body: reportProvider.isLoading && report == null
            ? LoadingIndicator(message: loc.loadingReportDetails)
            : report == null
            ? _buildErrorState(loc)
            : _buildContent(report, loc, isArabic),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations loc, bool isArabic) {
    return AppBar(
      backgroundColor: const Color(0xFF1E293B),
      foregroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      shape: Border(bottom: BorderSide(color: const Color(0xFFC9A97C).withValues(alpha: 0.3))),
      title: Text(
        loc.reportDetails,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          isArabic ? Icons.arrow_back : Icons.arrow_forward,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations loc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
          const SizedBox(height: 16),
          Text(
            loc.failedToLoadReport,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF172439),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loc.pleaseTryAgain,
            style: const TextStyle(fontSize: 14, color: Color(0xFFCBD5E1)),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () =>
                context.read<ReportProvider>().fetchReportById(widget.reportId),
            child: Text(loc.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Report report, AppLocalizations loc, bool isArabic) {
    _initMapController(report);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 768),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(report, loc, isArabic),
            const SizedBox(height: 24),
            _buildReportIdentity(report, loc, isArabic),
            const SizedBox(height: 16),
            if (report.description.raw.isNotEmpty ||
                (report.description.aiAnalysis != null &&
                    report.description.aiAnalysis!.isNotEmpty))
              _buildDescriptionCard(report, loc, isArabic),
            const SizedBox(height: 24),
            _buildInfoGrid(report, loc, isArabic),
            const SizedBox(height: 32),
            _buildActionButtons(report, loc, isArabic),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(Report report, AppLocalizations loc, bool isArabic) {
    final hasImage = report.images.isNotEmpty;
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasImage)
                PageView.builder(
                  itemCount: report.images.length,
                  onPageChanged: (i) => setState(() => _currentImageIndex = i),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _openFullScreenImage(report, index),
                      child: Image.network(
                        report.images[index],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(color: AppTheme.warmBackground);
                        },
                        errorBuilder: (_, _, _) => Container(
                          color: AppTheme.warmBackground,
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 48,
                              color: Color(0xFFCBD5E1),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                )
              else
                Container(
                  color: AppTheme.warmBackground,
                  child: const Center(
                    child: Icon(
                      Icons.photo_camera_outlined,
                      size: 48,
                      color: Color(0xFFCBD5E1),
                    ),
                  ),
                ),
              Positioned(
                top: 16,
                left: isArabic ? null : 16,
                right: isArabic ? 16 : null,
                child: _buildStatusBadge(report, loc, isArabic),
              ),
              if (report.images.length > 1)
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      report.images.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentImageIndex == i
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Report report, AppLocalizations loc, bool isArabic) {
    final statusText = isArabic
        ? report.displayStatusArabic
        : report.displayStatus;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFC9A97C),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.05,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportIdentity(
    Report report,
    AppLocalizations loc,
    bool isArabic,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          report.location.raw,
          style: const TextStyle(
            
            fontSize: 24,
            fontWeight: FontWeight.w600,
            height: 32 / 24,
            letterSpacing: -0.01,
            color: Color(0xFF172439),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          '${isArabic ? 'المعرف' : 'ID'}: SY-RE-${report.id.toString().padLeft(4, '0')}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFCBD5E1).withValues(alpha: 0.7),
            letterSpacing: 0.08,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGrid(Report report, AppLocalizations loc, bool isArabic) {
    final damageColor = AppTheme.getDamageLevelColorFromString(
      report.damageAssessment.level.name,
    );

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: _buildBoxDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 18,
                    color: Color(0xFFC9A97C),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    loc.location,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFCBD5E1),
                      letterSpacing: 0.05,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                report.location.raw,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF172439),
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: _buildEmbeddedMap(report),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: _buildBoxDecoration(),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.report_problem,
                              size: 18,
                              color: AppTheme.errorColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              loc.damageLevel,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFCBD5E1),
                                letterSpacing: 0.05,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: damageColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isArabic
                                    ? report.displayDamageLevelArabic
                                    : report.displayDamageLevel,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: damageColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  color: const Color(0xFFC9A97C).withValues(alpha: 0.3),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: Color(0xFFCBD5E1),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              loc.inspectionDate,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFCBD5E1),
                                letterSpacing: 0.05,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          report.formattedCreatedDate,
                          style: const TextStyle(
                            
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF172439),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildReportedByCard(report, loc),
      ],
    );
  }

  BoxDecoration _buildBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: const Color(0xFFC9A97C).withValues(alpha: 0.5),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  Widget _buildEmbeddedMap(Report report) {
    if (report.location.coordinates != null && _mapController != null) {
      return WebViewWidget(controller: _mapController!);
    }
    return Container(
      color: const Color(0xFFE8E6E1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.map_outlined,
              size: 36,
              color: Color(0xFFCBD5E1),
            ),
            const SizedBox(height: 6),
            Text(
              context.loc.viewOnMap,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFCBD5E1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(
    Report report,
    AppLocalizations loc,
    bool isArabic,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _buildBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.description.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFCBD5E1),
              letterSpacing: 0.05,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            report.description.raw,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF172439),
              height: 1.5,
            ),
          ),
          if (report.description.aiAnalysis != null &&
              report.description.aiAnalysis!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Divider(color: const Color(0xFFC9A97C).withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: AppTheme.mutedGold,
                ),
                const SizedBox(width: 6),
                Text(
                  loc.aiAnalysis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.mutedGold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              report.description.aiAnalysis!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFCBD5E1),
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReportedByCard(Report report, AppLocalizations loc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _buildBoxDecoration(),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFC9A97C),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                report.user.name.isNotEmpty
                    ? report.user.name[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.reportedBy,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFCBD5E1),
                    letterSpacing: 0.05,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  report.user.name,
                  style: const TextStyle(
                    
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF172439),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    Report report,
    AppLocalizations loc,
    bool isArabic,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => _startEditing(report),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC9A97C),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(
                0xFFC9A97C,
              ).withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: Text(
              loc.updateReport,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () => _deleteReport(report),
            icon: const Icon(Icons.delete_outline, size: 22),
            label: Text(
              loc.deleteReport,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC9A97C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
          ),
        ),
      ],
    );
  }
}

class _FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullScreenImageViewer({required this.images, this.initialIndex = 0});

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls),
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Center(
                    child: Image.network(
                      widget.images[index],
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                : null,
                            color: Colors.white,
                          ),
                        );
                      },
                      errorBuilder: (_, _, _) => const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 64,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Stack(
                children: [
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    right: 8,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  if (widget.images.length > 1)
                    Positioned(
                      bottom: MediaQuery.of(context).padding.bottom + 24,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_currentIndex + 1} / ${widget.images.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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
}
