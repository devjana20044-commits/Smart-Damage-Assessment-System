import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/localization.dart';
import '../../providers/locale_provider.dart';
import '../../providers/report_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_indicator.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _videoLinkController = TextEditingController();

  List<File> _selectedImages = [];
  File? _selectedPdf;
  List<String> _videoLinks = [];
  Position? _currentPosition;
  bool _isGettingLocation = false;
  int _currentImageIndex = 0;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    _videoLinkController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);

    try {
      // 1. Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('خدمة الموقع معطلة. يرجى تفعيل GPS.');
        return;
      }

      // 2. Check location permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('تم رفض إذن الموقع');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('تم رفض إذن الموقع بشكل دائم. يرجى تفعيله من الإعدادات.');
        return;
      }

      // 3. Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      setState(() {
        _currentPosition = position;
      });

      _showSnackBar('تم الحصول على الموقع بنجاح');
      print(
        "✅ Latitude: ${position.latitude}, Longitude: ${position.longitude}",
      );
    } on TimeoutException catch (_) {
      _showSnackBar('انتهت المهلة، جاري المحاولة بدقة أقل...');
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
        );
        setState(() {
          _currentPosition = position;
        });
        _showSnackBar('تم الحصول على الموقع بنجاح');
      } catch (e) {
        _showSnackBar('فشل الحصول على الموقع');
      }
    } catch (e) {
      _showSnackBar('فشل الحصول على الموقع: ${e.toString()}');
    } finally {
      setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _takePhoto() async {
    try {
      final permission = await Permission.camera.request();
      if (!permission.isGranted) {
        _showSnackBar('تم رفض إذن الكاميرا');
        return;
      }

      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImages.add(File(pickedFile.path));
        });
        _showSnackBar('تم التقاط الصورة بنجاح');
      }
    } catch (e) {
      _showSnackBar('فشل التقاط الصورة: ${e.toString()}');
    }
  }

  Future<void> _pickImagesFromGallery() async {
    try {
      PermissionStatus permission;

      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          permission = await Permission.photos.request();
        } else {
          permission = await Permission.storage.request();
        }
      } else {
        permission = await Permission.photos.request();
      }

      if (!permission.isGranted) {
        _showSnackBar('تم رفض إذن الصور');
        return;
      }

      final List<XFile>? images = await _imagePicker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (images != null && images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images.map((xfile) => File(xfile.path)));
        });
        _showSnackBar('تم اختيار ${images.length} صورة/صور');
      }
    } catch (e) {
      _showSnackBar('فشل اختيار الصور: ${e.toString()}');
    }
  }

  Future<void> _pickPdf() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedPdf = File(result.files.single.path!);
        });
        _showSnackBar('تم اختيار ملف PDF');
      }
    } catch (e) {
      _showSnackBar('فشل اختيار ملف PDF: ${e.toString()}');
    }
  }

  void _addVideoLink() {
    if (_videoLinkController.text.isNotEmpty) {
      final link = _videoLinkController.text.trim();
      if (link.startsWith('http://') || link.startsWith('https://')) {
        setState(() {
          _videoLinks.add(link);
          _videoLinkController.clear();
        });
        _showSnackBar('تم إضافة رابط الفيديو');
      } else {
        _showSnackBar('يرجى إدخال رابط صحيح (http:// أو https://)');
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      if (_currentImageIndex >= _selectedImages.length) {
        _currentImageIndex = _selectedImages.length - 1;
      }
    });
  }

  void _removePdf() {
    setState(() {
      _selectedPdf = null;
    });
  }

  void _removeVideoLink(int index) {
    setState(() {
      _videoLinks.removeAt(index);
    });
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImages.isEmpty) {
      _showSnackBar('يرجى إضافة صورة واحدة على الأقل');
      return;
    }

    final reportProvider = context.read<ReportProvider>();
    final success = await reportProvider.createReportWithMultimedia(
      userInputLocation: _locationController.text.trim(),
      userNotes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      latitude: _currentPosition?.latitude,
      longitude: _currentPosition?.longitude,
      images: _selectedImages,
      pdfFile: _selectedPdf,
      videoLinks: _videoLinks.isNotEmpty ? _videoLinks : null,
    );

    if (success && mounted) {
      _showSnackBar('تم إنشاء التقرير بنجاح');
      Navigator.of(context).pop();
    }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.loc;
    final localeProvider = context.watch<LocaleProvider>();
    final isArabic = localeProvider.isArabic;
    final reportProvider = context.watch<ReportProvider>();

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(title: Text(loc.createReport)),
        body: LoadingOverlay(
          isLoading: reportProvider.isLoading,
          message: 'جار إنشاء التقرير...',
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Location field
                    CustomTextField(
                      controller: _locationController,
                      labelText: loc.locationName,
                      hintText: loc.locationDescription,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return loc.requiredField;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Notes field
                    CustomTextField(
                      controller: _notesController,
                      labelText: 'ملاحظات (اختياري)',
                      hintText: loc.additionalDetails,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 24),

                    // Location section
                    Text(
                      loc.location,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Get location button
                    CustomOutlinedButton(
                      text: _isGettingLocation
                          ? 'جار الحصول على الموقع...'
                          : loc.getCurrentLocation,
                      onPressed: _isGettingLocation
                          ? null
                          : _getCurrentLocation,
                      isLoading: _isGettingLocation,
                    ),

                    // Location display
                    if (_currentPosition != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'تم الحصول على الموقع:',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.copy, color: theme.primaryColor),
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(
                                    text:
                                        '${_currentPosition!.latitude}, ${_currentPosition!.longitude}',
                                  ),
                                );
                                _showSnackBar('تم النسخ');
                              },
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Photos section
                    Text(
                      'الصور',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Photo buttons row
                    Row(
                      children: [
                        Expanded(
                          child: CustomOutlinedButton(
                            text: loc.takePhoto,
                            onPressed: _takePhoto,
                            borderColor: theme.colorScheme.secondary,
                            textColor: theme.colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomOutlinedButton(
                            text: 'من المعرض',
                            onPressed: _pickImagesFromGallery,
                            borderColor: theme.colorScheme.secondary,
                            textColor: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),

                    // Image preview carousel
                    if (_selectedImages.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.colorScheme.outline),
                        ),
                        child: Stack(
                          children: [
                            PageView.builder(
                              itemCount: _selectedImages.length,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentImageIndex = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _selectedImages[index],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                );
                              },
                            ),
                            if (_selectedImages.length > 1)
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
                                    '${_currentImageIndex + 1} / ${_selectedImages.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            Positioned(
                              top: 8,
                              right: isArabic ? 8 : null,
                              left: isArabic ? null : 8,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    _removeImage(_currentImageIndex),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'تم اختيار ${_selectedImages.length} صورة/صور',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // PDF section
                    Text(
                      'ملف PDF (اختياري)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    CustomOutlinedButton(
                      text: 'اختيار ملف PDF',
                      onPressed: _pickPdf,
                      borderColor: theme.colorScheme.tertiary,
                      textColor: theme.colorScheme.tertiary,
                    ),

                    if (_selectedPdf != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.picture_as_pdf),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedPdf!.path.split('/').last,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: _removePdf,
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Video links section
                    Text(
                      'روابط الفيديو (اختياري)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _videoLinkController,
                            decoration: InputDecoration(
                              labelText: 'رابط الفيديو',
                              hintText: 'https://youtube.com/watch?v=...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.add_circle),
                          color: theme.primaryColor,
                          onPressed: _addVideoLink,
                        ),
                      ],
                    ),

                    if (_videoLinks.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ..._videoLinks.asMap().entries.map((entry) {
                        final index = entry.key;
                        final link = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.colorScheme.outline.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.video_library),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  link,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeVideoLink(index),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],

                    const SizedBox(height: 32),

                    CustomButton(
                      text: loc.submitReport,
                      onPressed: reportProvider.isLoading
                          ? null
                          : _submitReport,
                      isLoading: reportProvider.isLoading,
                    ),

                    const SizedBox(height: 16),

                    CustomOutlinedButton(
                      text: loc.cancel,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
