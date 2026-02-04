import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization.dart';
import '../../models/report.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/report_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/report_card.dart';
import '../auth/login_screen.dart';
import '../report/create_report_screen.dart';
import '../report/report_details_screen.dart';
import '../settings/settings_screen.dart';
import '../statistics/statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  Set<ReportStatus> _selectedStatuses = {};
  Set<DamageLevel> _selectedDamageLevels = {};
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    // Load reports when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().fetchReports();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(loc.logout),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();

      // Navigate to login screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _navigateToCreateReport() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreateReportScreen()),
    ).then((_) {
      // Refresh reports when returning from create screen
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
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  List<Report> _filterReports(List<Report> reports) {
    String query = _searchController.text.toLowerCase();
    
    return reports.where((report) {
      // Text search (case-insensitive)
      bool matchesSearch = query.isEmpty ||
          report.location.raw.toLowerCase().contains(query) ||
          report.description.raw.toLowerCase().contains(query) ||
          report.id.toString().contains(query);
      
      // Status filter
      bool matchesStatus = _selectedStatuses.isEmpty ||
          _selectedStatuses.contains(report.damageAssessment.status);
      
      // Damage level filter
      bool matchesDamageLevel = _selectedDamageLevels.isEmpty ||
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
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final reportProvider = context.watch<ReportProvider>();

    // Show error message if any
    if (reportProvider.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(reportProvider.errorMessage!);
        reportProvider.clearError();
      });
    }

    // Filter reports
    final filteredReports = _filterReports(reportProvider.reports);
    final hasActiveFilters = _searchController.text.isNotEmpty ||
        _selectedStatuses.isNotEmpty ||
        _selectedDamageLevels.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.myReports),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            tooltip: loc.filter,
          ),
        ],
      ),
      drawer: _buildDrawer(context, loc, theme, authProvider.user),
      body: RefreshIndicator(
        onRefresh: () => reportProvider.fetchReports(),
        child: reportProvider.isLoading && reportProvider.reports.isEmpty
            ? LoadingIndicator(message: '${loc.loading}...')
            : reportProvider.reports.isEmpty
                ? _buildEmptyState(theme, loc)
                : _buildReportsList(filteredReports, hasActiveFilters, loc, theme),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateReport,
        tooltip: loc.createReport,
        child: const Icon(Icons.description),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations loc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.camera_alt,
              size: 60,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            loc.noReportsYet,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loc.startByCreating,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _navigateToCreateReport,
            icon: const Icon(Icons.description),
            label: Text(loc.createFirstReport),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList(List<Report> reports, bool hasActiveFilters, AppLocalizations loc, ThemeData theme) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: loc.search,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        
        // Filters Section
        if (_showFilters) _buildFiltersSection(loc, theme),
        
        // Clear Filters Button
        if (hasActiveFilters)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${reports.length} ${loc.reports}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear_all),
                  label: Text(loc.clear),
                ),
              ],
            ),
          ),
        
        // Reports List
        Expanded(
          child: reports.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No matching reports',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ReportCard(
                        report: report,
                        onTap: () => _navigateToReportDetails(report.id),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFiltersSection(AppLocalizations loc, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Filters
          Text(
            'Status',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
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
                selectedColor: theme.primaryColor.withOpacity(0.2),
                checkmarkColor: theme.primaryColor,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          
          // Damage Level Filters
          Text(
            loc.damageLevels,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
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
                selectedColor: color.withOpacity(0.2),
                checkmarkColor: color,
              );
            }).toList(),
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
        return const Color(0xFF4CAF50);
      case DamageLevel.medium:
        return const Color(0xFFFF9800);
      case DamageLevel.high:
        return const Color(0xFFF44336);
      case DamageLevel.critical:
        return const Color(0xFF9C27B0);
    }
  }

  Widget _buildDrawer(BuildContext context, AppLocalizations loc, ThemeData theme, User? user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // User Profile Header
          UserAccountsDrawerHeader(
            accountName: Text(user?.name ?? 'Guest'),
            accountEmail: Text(user?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: theme.primaryColor,
              child: Text(
                (user?.name ?? 'Guest').isNotEmpty
                    ? user!.name[0].toUpperCase()
                    : 'G',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: theme.primaryColor,
            ),
          ),
          const Divider(),
          
          // Menu Items
          ListTile(
            leading: const Icon(Icons.description),
            title: Text(loc.myReports),
            onTap: () {
              Navigator.pop(context);
            },
            selected: true,
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: Text(loc.statistics),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StatisticsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(loc.settings),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const Divider(),
          
          // Language Toggle
          Consumer<LocaleProvider>(
            builder: (context, localeProvider, child) {
              return ListTile(
                leading: const Icon(Icons.language),
                title: Text(loc.language),
                trailing: Switch(
                  value: localeProvider.isArabic,
                  onChanged: (value) {
                    localeProvider.changeLocale(
                      value ? const Locale('ar') : const Locale('en'),
                    );
                  },
                ),
              );
            },
          ),
          
          const Divider(),
          
          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              loc.logout,
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              _logout();
            },
          ),
        ],
      ),
    );
  }
}