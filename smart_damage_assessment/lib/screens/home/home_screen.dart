import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/localization.dart';
import '../../core/theme.dart';
import '../../models/report.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/report_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/report_card.dart';
import '../auth/login_screen.dart';
import '../auth/edit_profile_screen.dart';
import '../drafts/drafts_screen.dart';
import '../report/create_report_screen.dart';
import '../report/report_details_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<ReportStatus> _selectedStatuses = {};
  final Set<DamageLevel> _selectedDamageLevels = {};
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().fetchReports();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToCreateReport() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const CreateReportScreen()))
        .then((_) {
          if (mounted) {
            context.read<ReportProvider>().fetchReports();
          }
        });
  }

  void _navigateToReportDetails(int reportId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReportDetailsScreen(reportId: reportId),
      ),
    );
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

  List<Report> _filterReports(List<Report> reports) {
    String query = _searchController.text.toLowerCase();
    return reports.where((report) {
      bool matchesSearch =
          query.isEmpty ||
          report.location.raw.toLowerCase().contains(query) ||
          report.description.raw.toLowerCase().contains(query) ||
          report.id.toString().contains(query);
      bool matchesStatus =
          _selectedStatuses.isEmpty ||
          _selectedStatuses.contains(report.damageAssessment.status);
      bool matchesDamageLevel =
          _selectedDamageLevels.isEmpty ||
          _selectedDamageLevels.contains(report.damageAssessment.level);
      return matchesSearch && matchesStatus && matchesDamageLevel;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatuses.clear();
      _selectedDamageLevels.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final localeProvider = context.watch<LocaleProvider>();
    final isArabic = localeProvider.isArabic;
    final authProvider = context.watch<AuthProvider>();
    final reportProvider = context.watch<ReportProvider>();

    if (reportProvider.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(reportProvider.errorMessage!);
        reportProvider.clearError();
      });
    }

    final filteredReports = _filterReports(reportProvider.reports);
    final hasActiveFilters =
        _searchController.text.isNotEmpty ||
        _selectedStatuses.isNotEmpty ||
        _selectedDamageLevels.isNotEmpty;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFFBF9F4),
        drawer: _buildDrawer(context, loc, authProvider.user),
        body: Column(
          children: [
            _buildAppBar(loc, authProvider.user),
            Expanded(
              child: reportProvider.isLoading && reportProvider.reports.isEmpty
                  ? LoadingIndicator(message: '${loc.loading}...')
                  : reportProvider.reports.isEmpty
                  ? _buildEmptyState(loc)
                  : _buildBody(filteredReports, hasActiveFilters, loc),
            ),
          ],
        ),
        floatingActionButton: SizedBox(
          width: 56,
          height: 56,
          child: FloatingActionButton(
            onPressed: _navigateToCreateReport,
            backgroundColor: const Color(0xFFB8895A),
            foregroundColor: Colors.white,
            elevation: 4,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, size: 28),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations loc, User? user) {
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
          leading: Builder(
            builder: (ctx) {
              return IconButton(
                onPressed: () => Scaffold.of(ctx).openDrawer(),
                icon: const Icon(Icons.menu, color: Colors.white),
              );
            },
          ),
          title: Text(
            loc.myReports,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.01,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12, left: 12),
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                ),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF475569),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF64748B)),
                  ),
                  child: ClipOval(child: _buildAvatarImage(user, 32, 14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    List<Report> reports,
    bool hasActiveFilters,
    AppLocalizations loc,
  ) {
    return Column(
      children: [
        _buildSearchBar(loc),
        if (_showFilters) _buildFiltersSection(loc),
        if (hasActiveFilters)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${reports.length} ${loc.reports}',
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF44474D).withValues(alpha: 0.7),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _clearFilters,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.clear_all,
                        size: 16,
                        color: Color(0xFF745A34),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        loc.clear,
                        style: const TextStyle(
                          color: Color(0xFF745A34),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => context.read<ReportProvider>().fetchReports(),
            child: reports.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: const Color(0xFF44474D).withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          loc.noMatchingReports,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(
                              0xFF44474D,
                            ).withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: ReportCard(
                          report: reports[index],
                          isArabic: context.watch<LocaleProvider>().isArabic,
                          onTap: () =>
                              _navigateToReportDetails(reports[index].id),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(AppLocalizations loc) {
    final isArabic = context.watch<LocaleProvider>().isArabic;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: loc.searchReports,
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF75777D),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF6F3EE),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  prefixIcon: isArabic
                      ? null
                      : const Padding(
                          padding: EdgeInsets.only(left: 12, right: 4),
                          child: Icon(
                            Icons.search,
                            size: 20,
                            color: Color(0xFF75777D),
                          ),
                        ),
                  suffixIcon: isArabic
                      ? const Padding(
                          padding: EdgeInsets.only(right: 12, left: 4),
                          child: Icon(
                            Icons.search,
                            size: 20,
                            color: Color(0xFF75777D),
                          ),
                        )
                      : (_searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFC5C6CD)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFC5C6CD)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF144C61),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 44,
            height: 44,
            child: Material(
              color: const Color(0xFFEAE8E3),
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => setState(() => _showFilters = !_showFilters),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFC5C6CD)),
                  ),
                  child: const Icon(
                    Icons.tune,
                    size: 22,
                    color: Color(0xFF172439),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(AppLocalizations loc) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E2DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.status,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF172439),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ReportStatus.values.map((status) {
              final isSelected = _selectedStatuses.contains(status);
              return FilterChip(
                label: Text(_getStatusText(status, loc)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedStatuses.add(status);
                    } else {
                      _selectedStatuses.remove(status);
                    }
                  });
                },
                selectedColor: AppTheme.navyCore.withValues(alpha: 0.15),
                checkmarkColor: AppTheme.navyCore,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            loc.damageLevels,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF172439),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: DamageLevel.values.map((level) {
              final isSelected = _selectedDamageLevels.contains(level);
              final color = _getDamageLevelColor(level);
              return FilterChip(
                label: Text(_getDamageLevelText(level, loc)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedDamageLevels.add(level);
                    } else {
                      _selectedDamageLevels.remove(level);
                    }
                  });
                },
                selectedColor: color.withValues(alpha: 0.2),
                checkmarkColor: color,
              );
            }).toList(),
          ),
        ],
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
              Icons.description_outlined,
              size: 48,
              color: AppTheme.navyCore.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            loc.noReportsYet,
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
              loc.startByCreating,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF44474D),
                height: 20 / 14,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToCreateReport,
            icon: const Icon(Icons.add, size: 20),
            label: Text(loc.createFirstReport),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.navyCore,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(ReportStatus status, AppLocalizations loc) {
    switch (status) {
      case ReportStatus.pending:
        return loc.pending;
      case ReportStatus.processing:
        return loc.processing;
      case ReportStatus.completed:
        return loc.completed;
      case ReportStatus.rejected:
        return loc.rejected;
    }
  }

  String _getDamageLevelText(DamageLevel level, AppLocalizations loc) {
    switch (level) {
      case DamageLevel.low:
        return loc.low;
      case DamageLevel.medium:
        return loc.medium;
      case DamageLevel.high:
        return loc.high;
      case DamageLevel.critical:
        return loc.critical;
    }
  }

  Color _getDamageLevelColor(DamageLevel level) {
    switch (level) {
      case DamageLevel.low:
        return AppTheme.damageLow;
      case DamageLevel.medium:
        return AppTheme.damageMedium;
      case DamageLevel.high:
        return AppTheme.damageHigh;
      case DamageLevel.critical:
        return AppTheme.damageCritical;
    }
  }

  Future<void> _logout() async {
    final loc = context.loc;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.logout),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: Text(loc.logout),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  Widget _buildDrawer(BuildContext context, AppLocalizations loc, User? user) {
    return Drawer(
      backgroundColor: const Color(0xFF1E293B),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF475569),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF64748B),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(child: _buildAvatarImage(user, 52, 22)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Guest',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Divider(color: Colors.white.withValues(alpha: 0.15)),
            const SizedBox(height: 16),
            _buildDrawerButton(Icons.settings, loc.settings, () {
              Navigator.pop(context);
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            }),
            const SizedBox(height: 8),
            _buildDrawerButton(Icons.drafts, loc.drafts, () {
              Navigator.pop(context);
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const DraftsScreen()));
            }),
            const SizedBox(height: 8),
            _buildDrawerButton(Icons.add_circle_outline, loc.createReport, () {
              Navigator.pop(context);
              _navigateToCreateReport();
            }),
            const SizedBox(height: 8),
            Consumer<LocaleProvider>(
              builder: (context, localeProvider, child) {
                return _buildDrawerButton(
                  Icons.translate,
                  localeProvider.isArabic ? 'English' : 'العربية',
                  () {
                    localeProvider.changeLocale(
                      localeProvider.isArabic
                          ? const Locale('en')
                          : const Locale('ar'),
                    );
                  },
                  trailing: const Icon(
                    Icons.swap_horiz,
                    size: 20,
                    color: Color(0xFFB8895A),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            _buildDrawerButton(Icons.logout, loc.logout, () {
              Navigator.pop(context);
              _logout();
            }),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerButton(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFB8895A).withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 22, color: const Color(0xFFB8895A)),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                if (trailing != null) trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarImage(User? user, double size, double fontSize) {
    if (user?.profileImage != null && user!.profileImage!.isNotEmpty) {
      return Image.network(
        user.profileImage!,
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (_, __, ___) =>
            _buildInitialCircle(user.name, size, fontSize),
      );
    }
    return _buildInitialCircle(user?.name, size, fontSize);
  }

  Widget _buildInitialCircle(String? name, double size, double fontSize) {
    return Container(
      width: size,
      height: size,
      color: const Color(0xFF475569),
      child: Center(
        child: Text(
          (name ?? 'G').isNotEmpty ? name![0].toUpperCase() : 'G',
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
