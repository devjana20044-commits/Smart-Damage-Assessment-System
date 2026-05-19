import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/localization.dart';
import '../../core/theme.dart';
import '../../models/draft_report.dart';
import '../../providers/draft_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/report_provider.dart';
import '../report/create_report_screen.dart';

class DraftsScreen extends StatefulWidget {
  const DraftsScreen({super.key});

  @override
  State<DraftsScreen> createState() => _DraftsScreenState();
}

class _DraftsScreenState extends State<DraftsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DraftProvider>().loadDrafts();
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _deleteDraft(DraftReport draft) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          context.loc.delete,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          context.loc.deleteConfirmation,
          style: const TextStyle(color: Color(0xFFCBD5E1)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              context.loc.cancel,
              style: const TextStyle(color: Color(0xFFCBD5E1)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(context.loc.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<DraftProvider>().deleteDraft(draft.id);
      _showSnackBar(context.loc.reportDeleted);
    }
  }

  Future<void> _submitDraft(DraftReport draft) async {
    final reportProvider = context.read<ReportProvider>();
    final success = await reportProvider.createReportWithMultimedia(
      userInputLocation: draft.location,
      userNotes: draft.description.isEmpty ? null : draft.description,
      latitude: draft.latitude,
      longitude: draft.longitude,
      images: draft.imagePaths.isNotEmpty
          ? draft.imagePaths
                .map((p) => File(p))
                .where((f) => f.existsSync())
                .toList()
          : null,
      pdfFile: draft.pdfPath != null && File(draft.pdfPath!).existsSync()
          ? File(draft.pdfPath!)
          : null,
      videoLinks: draft.videoLinks.isNotEmpty ? draft.videoLinks : null,
    );
    if (success && mounted) {
      await context.read<DraftProvider>().deleteDraft(draft.id);
      _showSnackBar(context.loc.draftSaved);
    } else if (mounted) {
      _showSnackBar(context.loc.failedToLoadReport);
    }
  }

  void _openDraft(DraftReport draft) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (_) => CreateReportScreen(draft: draft)),
        )
        .then((_) {
          if (mounted) context.read<DraftProvider>().loadDrafts();
        });
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final isArabic = context.watch<LocaleProvider>().isArabic;
    final draftProvider = context.watch<DraftProvider>();

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFFBF9F4),
        appBar: _buildAppBar(loc, isArabic),
        body: draftProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFC9A97C)),
              )
            : draftProvider.drafts.isEmpty
            ? _buildEmptyState(loc)
            : _buildDraftsList(draftProvider.drafts, loc, isArabic),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations loc, bool isArabic) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          border: Border(bottom: BorderSide(color: Color(0xFF334155))),
          boxShadow: [
            BoxShadow(
              color: Color(0x0A000000),
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              isArabic ? Icons.arrow_back : Icons.arrow_forward,
              color: Colors.white,
            ),
          ),
          title: Text(
            loc.drafts,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations loc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.navyCore.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.drafts,
              size: 48,
              color: AppTheme.navyCore.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            loc.noDraftsYet,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF172439),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              loc.draftsHint,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF44474D),
                height: 20 / 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraftsList(
    List<DraftReport> drafts,
    AppLocalizations loc,
    bool isArabic,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      itemCount: drafts.length,
      itemBuilder: (context, index) {
        return _buildDraftCard(drafts[index], loc, isArabic);
      },
    );
  }

  Widget _buildDraftCard(
    DraftReport draft,
    AppLocalizations loc,
    bool isArabic,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
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
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openDraft(draft),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC9A97C).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.drafts,
                            size: 14,
                            color: const Color(0xFFC9A97C),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            loc.drafts,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFC9A97C),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${draft.createdAt.day}/${draft.createdAt.month}/${draft.createdAt.year}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF75777D),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  draft.location,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF172439),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (draft.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    draft.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF75777D),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (draft.imagePaths.isNotEmpty)
                      _buildInfoChip(
                        Icons.photo_camera,
                        '${draft.imagePaths.length}',
                      ),
                    if (draft.imagePaths.isNotEmpty) const SizedBox(width: 8),
                    if (draft.pdfPath != null) ...[
                      _buildInfoChip(Icons.picture_as_pdf, 'PDF'),
                      const SizedBox(width: 8),
                    ],
                    if (draft.videoLinks.isNotEmpty)
                      _buildInfoChip(
                        Icons.videocam,
                        '${draft.videoLinks.length}',
                      ),
                    if (draft.latitude != null && draft.longitude != null) ...[
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.location_on,
                        '${draft.latitude!.toStringAsFixed(2)}, ${draft.longitude!.toStringAsFixed(2)}',
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: const Color(0xFFC9A97C).withValues(alpha: 0.3)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton.icon(
                          onPressed: () => _submitDraft(draft),
                          icon: const Icon(Icons.send, size: 16),
                          label: Text(
                            loc.submitReport,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC9A97C),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: OutlinedButton(
                        onPressed: () => _deleteDraft(draft),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorColor,
                          side: const BorderSide(color: AppTheme.errorColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Icon(Icons.delete_outline, size: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF75777D)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 11, color: Color(0xFF75777D)),
        ),
      ],
    );
  }
}
