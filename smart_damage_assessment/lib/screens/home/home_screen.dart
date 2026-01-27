import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/report_card.dart';
import '../auth/login_screen.dart';
import '../report/create_report_screen.dart';
import '../report/report_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load reports when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().fetchReports();
    });
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Logout'),
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

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => reportProvider.fetchReports(),
        child: reportProvider.isLoading && reportProvider.reports.isEmpty
            ? const LoadingIndicator(message: 'Loading reports...')
            : reportProvider.reports.isEmpty
                ? _buildEmptyState(theme)
                : _buildReportsList(reportProvider),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateReport,
        tooltip: 'Create New Report',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
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
            'No Reports Yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by creating your first damage report',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _navigateToCreateReport,
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Create First Report'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList(ReportProvider reportProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reportProvider.reports.length,
      itemBuilder: (context, index) {
        final report = reportProvider.reports[index];
        return ReportCard(
          report: report,
          onTap: () => _navigateToReportDetails(report.id),
        );
      },
    );
  }
}