import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/config.dart';
import '../../services/storage_service.dart';
import '../../services/dio_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_indicator.dart';

/// Settings screen for configuring backend connection
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  final _pathController = TextEditingController();

  bool _isLoading = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    _pathController.dispose();
    super.dispose();
  }

  /// Load saved settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final storage = await StorageService.getInstance();
      final config = storage.getBackendConfig();

      setState(() {
        _ipController.text = config['ip'] ?? '192.168.43.19';
        _portController.text = config['port'] ?? '8000';
        _pathController.text = config['path'] ?? '/api';
      });
    } catch (e) {
      setState(() {
        _ipController.text = '192.168.43.19';
        _portController.text = '8000';
        _pathController.text = '/api';
      });
    }
  }

  /// Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _isSaved = false;
    });

    try {
      final storage = await StorageService.getInstance();
      await storage.saveBackendConfig(
        ip: _ipController.text.trim(),
        port: _portController.text.trim(),
        path: _pathController.text.trim(),
      );

      // Update DioService with new base URL
      final dioService = await DioService.getInstance();
      await dioService.updateBaseUrl();

      setState(() {
        _isLoading = false;
        _isSaved = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ الإعدادات بنجاح'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل حفظ الإعدادات: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Test the connection with current settings
  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Build the test URL
      final testUrl = 'http://${_ipController.text.trim()}:${_portController.text.trim()}${_pathController.text.trim()}';

      // Test connection using http package
      final uri = Uri.parse(testUrl);
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 10));

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: isSuccess ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                const Text('نتيجة اختبار الاتصال'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('عنوان URL: $testUrl'),
                const SizedBox(height: 8),
                Text(
                  'حالة الاستجابة: ${response.statusCode}',
                  style: TextStyle(
                    color: isSuccess ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (response.body.isNotEmpty)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        'الاستجابة:\n${_formatJson(response.body)}',
                        style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                      ),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('حسناً'),
              ),
            ],
          ),
        );
      }
    } on TimeoutException {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text('فشل اختبار الاتصال'),
              ],
            ),
            content: const Text('انتهت مهلة الاتصال. يرجى التحقق من عنوان IP ورقم المنفذ.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('حسناً'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text('فشل اختبار الاتصال'),
              ],
            ),
            content: Text('خطأ في الاتصال: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('حسناً'),
              ),
            ],
          ),
        );
      }
    }
  }

  /// Format JSON for display
  String _formatJson(String jsonString) {
    try {
      final json = jsonDecode(jsonString);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(json);
    } catch (e) {
      return jsonString;
    }
  }

  /// Reset settings to defaults
  void _resetSettings() {
    setState(() {
      _ipController.text = '192.168.43.19';
      _portController.text = '8000';
      _pathController.text = '/api';
      _isSaved = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إعادة تعيين الإعدادات'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'إعدادات الباكند',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'قم بتعديل إعدادات الاتصال بالباكند هنا. '
                              'يتم حفظ الإعدادات تلقائياً عند الضغط على زر الحفظ.',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // IP Address field
                    CustomTextField(
                      controller: _ipController,
                      labelText: 'عنوان IP',
                      hintText: 'مثال: 192.168.43.19',
                      prefixIcon: const Icon(Icons.computer),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'يرجى إدخال عنوان IP';
                        }
                        // Basic IP validation
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

                    // Port field
                    CustomTextField(
                      controller: _portController,
                      labelText: 'رقم المنفذ (Port)',
                      hintText: 'مثال: 8000',
                      prefixIcon: const Icon(Icons.settings_ethernet),
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

                    // Path field
                    CustomTextField(
                      controller: _pathController,
                      labelText: 'المسار (Path)',
                      hintText: 'مثال: /api',
                      prefixIcon: const Icon(Icons.folder),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'يرجى إدخال المسار';
                        }
                        final path = value.trim();
                        if (!path.startsWith('/')) {
                          return 'يجب أن يبدأ المسار بـ /';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Preview URL
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'عنوان URL الكامل:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SelectableText(
                              'http://${_ipController.text.trim()}:${_portController.text.trim()}${_pathController.text.trim()}',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save button
                    CustomButton(
                      text: 'حفظ الإعدادات',
                      onPressed: _saveSettings,
                    ),
                    const SizedBox(height: 12),

                    // Test connection button
                    CustomButton(
                      text: 'اختبار الاتصال',
                      onPressed: _testConnection,
                      backgroundColor: Colors.orange,
                    ),
                    const SizedBox(height: 12),

                    // Reset button
                    CustomButton(
                      text: 'إعادة تعيين',
                      onPressed: _resetSettings,
                      backgroundColor: Colors.grey,
                    ),

                    // Success indicator
                    if (_isSaved)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              SizedBox(width: 8),
                              Text(
                                'تم حفظ الإعدادات بنجاح',
                                style: TextStyle(color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
