import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../core/config.dart';
import '../../core/localization.dart';
import '../../core/theme.dart';
import '../../providers/locale_provider.dart';
import '../../services/storage_service.dart';
import '../../services/dio_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  final _pathController = TextEditingController();

  bool _isLoading = false;
  bool _isSaved = false;
  bool _connectionStatus = false;
  String? _connectionMessage;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _loadSettings();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _ipController.dispose();
    _portController.dispose();
    _pathController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final storage = await StorageService.getInstance();
      final config = storage.getBackendConfig();

      setState(() {
        _ipController.text = config['ip'] ?? AppConfig.defaultIp;
        _portController.text = config['port'] ?? AppConfig.defaultPort;
        _pathController.text = config['path'] ?? AppConfig.defaultPath;
      });
    } catch (e) {
      setState(() {
        _ipController.text = AppConfig.defaultIp;
        _portController.text = AppConfig.defaultPort;
        _pathController.text = AppConfig.defaultPath;
      });
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _isSaved = false;
    });

    try {
      final storage = await StorageService.getInstance();

      // Check if IP changed - if so, clear auth data
      final oldConfig = storage.getBackendConfig();
      final oldIp = oldConfig['ip'] ?? '';
      final newIp = _ipController.text.trim();

      if (oldIp.isNotEmpty && oldIp != newIp) {
        // IP changed - clear auth data and reports
        await storage.removeToken();
        await storage.removeUser();
        _showSnackBar(
          'تم تغيير عنوان IP - يرجى تسجيل الدخول مرة أخرى',
          isSuccess: true,
        );
      }

      await storage.saveBackendConfig(
        ip: _ipController.text.trim(),
        port: _portController.text.trim(),
        path: _pathController.text.trim(),
      );

      // Update DioService base URL in-place (no reset needed)
      final dioService = await DioService.getInstance();
      await dioService.updateBaseUrl();

      setState(() {
        _isLoading = false;
        _isSaved = true;
        _connectionStatus = false;
        _connectionMessage = null;
      });

      if (oldIp.isNotEmpty && oldIp != newIp) {
        // Navigate to login after IP change
        if (mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/splash', (route) => false);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('فشل حفظ الإعدادات: $e', isSuccess: false);
    }
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _connectionStatus = false;
      _connectionMessage = null;
    });

    try {
      final testUrl =
          'http://${_ipController.text.trim()}:${_portController.text.trim()}${_pathController.text.trim()}';
      final uri = Uri.parse(testUrl);
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;

      setState(() {
        _isLoading = false;
        _connectionStatus = isSuccess;
        _connectionMessage =
            'Status: ${response.statusCode} ${response.reasonPhrase ?? ''}';
      });

      _showConnectionDialog(testUrl, isSuccess, response);
    } on TimeoutException {
      setState(() {
        _isLoading = false;
        _connectionStatus = false;
        _connectionMessage = 'انتهت مهلة الاتصال';
      });
      _showErrorDialog(
        'انتهت مهلة الاتصال',
        'يرجى التحقق من عنوان IP ورقم المنفذ.',
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _connectionStatus = false;
        _connectionMessage = 'خطأ في الاتصال';
      });
      _showErrorDialog('فشل الاتصال', e.toString());
    }
  }

  void _resetSettings() {
    setState(() {
      _ipController.text = AppConfig.defaultIp;
      _portController.text = AppConfig.defaultPort;
      _pathController.text = AppConfig.defaultPath;
      _isSaved = false;
      _connectionStatus = false;
      _connectionMessage = null;
    });
    _showSnackBar('تم إعادة تعيين الإعدادات', isSuccess: true);
  }

  void _showSnackBar(String message, {required bool isSuccess}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isSuccess
            ? AppTheme.successColor
            : AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showConnectionDialog(
    String url,
    bool isSuccess,
    http.Response response,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isSuccess
                        ? [Colors.green.shade400, Colors.green.shade600]
                        : [Colors.red.shade400, Colors.red.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isSuccess ? Colors.green : Colors.red).withValues(
                        alpha: 0.4,
                      ),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  isSuccess ? Icons.wifi : Icons.wifi_off,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isSuccess ? 'متصل بنجاح!' : 'فشل الاتصال',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  url,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Status Code: ${response.statusCode}',
                style: TextStyle(
                  color: isSuccess ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSuccess ? Colors.green : Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('حسناً'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.error_outline, color: Colors.red),
            ),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final theme = Theme.of(context);
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.settings_suggest_outlined,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        loc.settings,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: Material(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      localeProvider.changeLocale(
                        localeProvider.isArabic
                            ? const Locale('en')
                            : const Locale('ar'),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.translate, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            localeProvider.isArabic ? 'EN' : 'ع',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (_isLoading)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  // Connection Status Card
                  _buildConnectionStatusCard(theme),
                  const SizedBox(height: 24),

                  // Server Configuration Section
                  _buildSectionHeader(
                    context,
                    icon: Icons.dns_outlined,
                    title: 'إعدادات السيرفر',
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildInputCard(
                          context,
                          controller: _ipController,
                          label: 'عنوان IP',
                          hint: 'مثال: 192.168.1.100',
                          icon: Icons.computer_outlined,
                          color: Colors.blue,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'يرجى إدخال عنوان IP';
                            }
                            final ipPattern = RegExp(
                              r'^(\d{1,3}\.){3}\d{1,3}$',
                            );
                            if (!ipPattern.hasMatch(value.trim())) {
                              return 'يرجى إدخال عنوان IP صحيح';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildInputCard(
                          context,
                          controller: _portController,
                          label: 'رقم المنفذ',
                          hint: 'مثال: 8000',
                          icon: Icons.settings_ethernet,
                          color: Colors.orange,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'يرجى إدخال رقم المنفذ';
                            }
                            final port = int.tryParse(value.trim());
                            if (port == null || port < 1 || port > 65535) {
                              return 'يرجى إدخال رقم منفذ صحيح (1-65535)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildInputCard(
                          context,
                          controller: _pathController,
                          label: 'المسار',
                          hint: 'مثال: /api',
                          icon: Icons.folder_outlined,
                          color: Colors.purple,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'يرجى إدخال المسار';
                            }
                            if (!value.trim().startsWith('/')) {
                              return 'يجب أن يبدأ المسار بـ /';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // URL Preview Card
                  _buildUrlPreviewCard(theme),
                  const SizedBox(height: 32),

                  // Action Buttons
                  _buildActionButton(
                    context,
                    label: 'حفظ الإعدادات',
                    icon: Icons.save_outlined,
                    color: AppTheme.successColor,
                    onPressed: _saveSettings,
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    context,
                    label: 'اختبار الاتصال',
                    icon: Icons.wifi_find_outlined,
                    color: AppTheme.accentColor,
                    onPressed: _testConnection,
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    context,
                    label: 'إعادة تعيين',
                    icon: Icons.refresh_outlined,
                    color: Colors.grey,
                    onPressed: _resetSettings,
                  ),

                  // Success Indicator
                  if (_isSaved) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade400,
                            Colors.green.shade600,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.check_circle_outline,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'تم حفظ الإعدادات بنجاح!',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatusCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _connectionStatus
              ? [Colors.green.shade400, Colors.green.shade600]
              : [Colors.grey.shade300, Colors.grey.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (_connectionStatus ? Colors.green : Colors.grey).withValues(
              alpha: 0.3,
            ),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _connectionStatus ? Icons.cloud_done : Icons.cloud_off,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _connectionStatus ? 'متصل' : 'غير متصل',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _connectionMessage ?? 'اضغط "اختبار الاتصال" للتحقق',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _connectionStatus ? Colors.white : Colors.white54,
              shape: BoxShape.circle,
              boxShadow: _connectionStatus
                  ? [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildInputCard(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color color,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildUrlPreviewCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'عنوان URL الكامل',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SelectableText(
              'http://${_ipController.text.trim()}:${_portController.text.trim()}${_pathController.text.trim()}',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
