import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../../core/localization.dart';
import '../../core/theme.dart';
import '../../models/draft_report.dart';
import '../../providers/draft_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/report_provider.dart';
import '../../widgets/loading_indicator.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CreateReportScreen extends StatefulWidget {
  final DraftReport? draft;
  final int? reportId;

  const CreateReportScreen({super.key, this.draft, this.reportId});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _videoLinkController = TextEditingController();

  final List<File> _selectedImages = [];
  File? _selectedPdf;
  final List<String> _videoLinks = [];
  Position? _currentPosition;
  bool _isGettingLocation = false;
  int _currentImageIndex = 0;

  final ImagePicker _imagePicker = ImagePicker();

  static const Color _gold = Color(0xFFC9A97C);
  static const Color _navy = Color(0xFF2D3A50);
  static const Color _bg = Color(0xFFFBF9F4);
  static const Color _cardBg = Color(0xFFF6F3EE);
  static const Color _labelColor = Color(0xFF44474D);

  @override
  void initState() {
    super.initState();
    if (widget.draft != null) {
      _loadDraft(widget.draft!);
    } else if (widget.reportId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadReport();
      });
    }
  }

  void _loadReport() async {
    final provider = context.read<ReportProvider>();
    await provider.fetchReportById(widget.reportId!);
    if (!mounted) return;
    final report = provider.currentReport;
    if (report != null) {
      setState(() {
        _locationController.text = report.location.raw;
        _notesController.text = report.description.raw;
        if (report.location.coordinates != null) {
          _currentPosition = Position(
            latitude: report.location.coordinates!.latitude,
            longitude: report.location.coordinates!.longitude,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            altitudeAccuracy: 0,
            heading: 0,
            headingAccuracy: 0,
            speed: 0,
            speedAccuracy: 0,
          );
        }
        _videoLinks.addAll(report.videoLinks);
      });
    }
  }

  void _loadDraft(DraftReport draft) {
    _locationController.text = draft.location;
    _notesController.text = draft.description;
    if (draft.latitude != null && draft.longitude != null) {
      _currentPosition = Position(
        latitude: draft.latitude!,
        longitude: draft.longitude!,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    }
    for (final path in draft.imagePaths) {
      final file = File(path);
      if (file.existsSync()) {
        _selectedImages.add(file);
      }
    }
    if (draft.pdfPath != null) {
      final file = File(draft.pdfPath!);
      if (file.existsSync()) {
        _selectedPdf = file;
      }
    }
    _videoLinks.addAll(draft.videoLinks);
  }

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
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('خدمة الموقع معطلة. يرجى تفعيل GPS.');
        return;
      }
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
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      setState(() => _currentPosition = position);
      _showSnackBar('تم الحصول على الموقع بنجاح');
    } on TimeoutException catch (_) {
      _showSnackBar('انتهت المهلة، جاري المحاولة بدقة أقل...');
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
        );
        setState(() => _currentPosition = position);
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
        setState(() => _selectedImages.add(File(pickedFile.path)));
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
        setState(() => _selectedPdf = File(result.files.single.path!));
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

  Future<void> _pickLocationOnMap() async {
    final Map<String, double>? result =
        await Navigator.of(context).push<Map<String, double>>(
      MaterialPageRoute(
        builder: (_) => _LocationPickerScreen(
          initialLat: _currentPosition?.latitude ?? 33.5138,
          initialLng: _currentPosition?.longitude ?? 36.2765,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _currentPosition = Position(
          latitude: result['lat']!,
          longitude: result['lng']!,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      });
      _showSnackBar('تم تحديد الموقع على الخريطة');
    }
  }

  void _removePdf() {
    setState(() => _selectedPdf = null);
  }

  void _removeVideoLink(int index) {
    setState(() => _videoLinks.removeAt(index));
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty && widget.reportId == null) {
      _showSnackBar('يرجى إضافة صورة واحدة على الأقل');
      return;
    }
    final reportProvider = context.read<ReportProvider>();

    if (widget.reportId != null) {
      final success = await reportProvider.updateReport(
        reportId: widget.reportId!,
        rawLocation: _locationController.text.trim(),
        rawDescription: _notesController.text.trim(),
        latitude: _currentPosition?.latitude,
        longitude: _currentPosition?.longitude,
        images: _selectedImages,
        pdfFile: _selectedPdf,
        videoLinks: _videoLinks.isNotEmpty ? _videoLinks : null,
      );
      if (success && mounted) {
        _showSnackBar('تم تحديث التقرير بنجاح');
        Navigator.of(context).pop();
      } else if (mounted && reportProvider.errorMessage != null) {
        _showSnackBar('فشل التحديث: ${reportProvider.errorMessage}');
      }
      return;
    }

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
      if (widget.draft != null) {
        await context.read<DraftProvider>().deleteDraft(widget.draft!.id);
      }
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

  Future<void> _saveDraft() async {
    final location = _locationController.text.trim();
    if (location.isEmpty) {
      _showSnackBar('يرجى إدخال اسم الموقع قبل حفظ المسودة');
      return;
    }
    final draft = DraftReport(
      id: widget.draft?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      location: location,
      description: _notesController.text.trim(),
      latitude: _currentPosition?.latitude,
      longitude: _currentPosition?.longitude,
      imagePaths: _selectedImages.map((f) => f.path).toList(),
      pdfPath: _selectedPdf?.path,
      videoLinks: _videoLinks,
    );
    await context.read<DraftProvider>().saveDraft(draft);
    if (mounted) {
      _showSnackBar('تم حفظ المسودة بنجاح');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final localeProvider = context.watch<LocaleProvider>();
    final isArabic = localeProvider.isArabic;
    final reportProvider = context.watch<ReportProvider>();

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: _buildAppBar(loc, isArabic),
        body: LoadingOverlay(
          isLoading: reportProvider.isLoading,
          message: 'جار إنشاء التقرير...',
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSiteInfoSection(loc),
                        const SizedBox(height: 24),
                        _buildLocationSection(loc, isArabic),
                        const SizedBox(height: 24),
                        _buildMediaSection(loc),
                        const SizedBox(height: 24),
                        _buildPdfSection(),
                        const SizedBox(height: 24),
                        _buildVideoSection(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildFooter(reportProvider, loc),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations loc, bool isArabic) {
    return AppBar(
      backgroundColor: _navy,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          isArabic ? Icons.arrow_back : Icons.arrow_forward,
          color: Colors.white,
        ),
      ),
      title: Text(
        widget.reportId != null ? loc.updateReport : loc.createReport,
        style: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _gold),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF172439),
              height: 28 / 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: _labelColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _gold),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _gold),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _gold, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.errorColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSiteInfoSection(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputField(
          controller: _locationController,
          label: loc.locationName,
          hint: 'أدخل اسم الموقع الإنشائي...',
          validator: (value) {
            if (value == null || value.isEmpty) return loc.requiredField;
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _notesController,
          label: 'ملاحظات (اختياري)',
          hint: 'أضف أي تفاصيل أو ملاحظات إضافية هنا...',
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildLocationSection(AppLocalizations loc, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(icon: Icons.location_on, title: loc.location),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _gold),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: const Color(0xFFE8E6E1),
                        child: Center(
                          child: Icon(
                            Icons.map_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                      if (_currentPosition != null)
                        Container(
                          color: const Color(0xFFE8E6E1),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.my_location, color: _gold, size: 28),
                                const SizedBox(height: 4),
                                Text(
                                  '${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF172439),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: _gold),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.explore, size: 16, color: Color(0xFF172439)),
                              const SizedBox(width: 8),
                              Text(
                                _currentPosition != null
                                    ? 'تم تحديد الإحداثيات'
                                    : 'تحديد الإحداثيات',
                                style: const TextStyle(
                                  color: Color(0xFF172439),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
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
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isGettingLocation ? null : _getCurrentLocation,
                  icon: _isGettingLocation
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.my_location, size: 20),
                  label: Text(
                    _isGettingLocation
                        ? 'جار الحصول على الموقع...'
                        : loc.getCurrentLocation,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _gold,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _pickLocationOnMap,
                  icon: const Icon(Icons.map_outlined, size: 20),
                  label: const Text(
                    'تحديد الموقع على الخريطة',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _navy,
                    side: const BorderSide(color: _gold, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediaSection(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(icon: Icons.photo_library, title: 'الصور'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDashedButton(
                icon: Icons.add_a_photo,
                label: loc.takePhoto,
                onTap: _takePhoto,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDashedButton(
                icon: Icons.upload_file,
                label: 'من المعرض',
                onTap: _pickImagesFromGallery,
              ),
            ),
          ],
        ),
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: PageView.builder(
                    itemCount: _selectedImages.length,
                    onPageChanged: (i) =>
                        setState(() => _currentImageIndex = i),
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
                ),
                if (_selectedImages.length > 1)
                  Positioned(
                    top: 8,
                    left: 8,
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
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.errorColor),
                    onPressed: () => _removeImage(_currentImageIndex),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: const Size(32, 32),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'تم اختيار ${_selectedImages.length} صورة/صور',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDashedButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _gold, width: 2, strokeAlign: BorderSide.strokeAlignInside),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: const Color(0xFF75777D)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF44474D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(icon: Icons.picture_as_pdf, title: 'ملف PDF (اختياري)'),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _pickPdf,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFEAE8E3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _gold),
            ),
            child: Row(
              children: [
                const Icon(Icons.cloud_upload, color: AppTheme.errorColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedPdf != null
                        ? _selectedPdf!.path.split(Platform.pathSeparator).last
                        : 'اختيار ملف PDF',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: _selectedPdf != null
                          ? const Color(0xFF172439)
                          : const Color(0xFF44474D),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_selectedPdf != null)
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.errorColor, size: 20),
                    onPressed: _removePdf,
                  )
                else
                  const Icon(Icons.chevron_left, color: Color(0xFF75777D)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(icon: Icons.videocam, title: 'روابط الفيديو (اختياري)'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: TextField(
                  controller: _videoLinkController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'https://youtube.com/...',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _gold),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _gold),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _gold, width: 2),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 48,
              height: 48,
              child: ElevatedButton(
                onPressed: _addVideoLink,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gold,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 4,
                  padding: EdgeInsets.zero,
                ),
                child: const Icon(Icons.add, size: 24),
              ),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _gold.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.video_library, color: _gold, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      link,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF172439)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.errorColor, size: 18),
                    onPressed: () => _removeVideoLink(index),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildFooter(ReportProvider reportProvider, AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        border: const Border(top: BorderSide(color: Color(0xFFC5C6CD))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 25,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: reportProvider.isLoading ? null : _submitReport,
                icon: reportProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(3.14159),
                        child: const Icon(Icons.send, size: 20),
                      ),
                label: Text(
                  widget.reportId != null ? loc.updateReport : loc.submitReport,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gold,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                  shadowColor: _gold.withValues(alpha: 0.3),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: _saveDraft,
                icon: const Icon(Icons.drafts, size: 22),
                label: Text(
                  loc.drafts,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _navy,
                  side: const BorderSide(color: _gold, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF44474D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  loc.cancel,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationPickerScreen extends StatefulWidget {
  final double initialLat;
  final double initialLng;

  const _LocationPickerScreen({
    required this.initialLat,
    required this.initialLng,
  });

  @override
  State<_LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<_LocationPickerScreen> {
  late WebViewController _controller;
  double _selectedLat = 33.5138;
  double _selectedLng = 36.2765;

  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _selectedLat = widget.initialLat;
    _selectedLng = widget.initialLng;
    _initMap();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _initMap() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            _controller.runJavaScript('initMap();');
          },
        ),
      )
      ..addJavaScriptChannel(
        'MapChannel',
        onMessageReceived: (message) {
          final parts = message.message.split(',');
          if (parts.length == 2) {
            setState(() {
              _selectedLat = double.tryParse(parts[0]) ?? _selectedLat;
              _selectedLng = double.tryParse(parts[1]) ?? _selectedLng;
            });
          }
        },
      )
      ..loadHtmlString('''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
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
    var map, marker;
    function initMap() {
      if (map) return;
      map = L.map('map').setView([${widget.initialLat}, ${widget.initialLng}], 14);
      L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; OpenStreetMap contributors'
      }).addTo(map);
      marker = L.marker([${widget.initialLat}, ${widget.initialLng}], {draggable: true}).addTo(map);
      map.on('click', function(e) {
        marker.setLatLng(e.latlng);
        MapChannel.postMessage(e.latlng.lat + ',' + e.latlng.lng);
      });
      marker.on('dragend', function(e) {
        var pos = e.target.getLatLng();
        MapChannel.postMessage(pos.lat + ',' + pos.lng);
      });
      setTimeout(function(){ map.invalidateSize(); }, 200);
    }
    function moveTo(lat, lng) {
      if (map && marker) {
        map.setView([lat, lng], 16);
        marker.setLatLng([lat, lng]);
        MapChannel.postMessage(lat + ',' + lng);
      }
    }
  </script>
</body>
</html>
''');
  }

  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': query,
        'format': 'json',
        'limit': '5',
        'accept-language': 'ar',
      });
      final response = await http.get(uri, headers: {
        'User-Agent': 'SmartDamageAssessment/1.0',
      });
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _searchResults = data.cast<Map<String, dynamic>>();
          _isSearching = false;
        });
      } else {
        setState(() => _isSearching = false);
      }
    } catch (_) {
      setState(() => _isSearching = false);
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      _searchLocation(value);
    });
  }

  void _selectSearchResult(Map<String, dynamic> result) {
    final lat = double.tryParse(result['lat']?.toString() ?? '') ?? _selectedLat;
    final lng = double.tryParse(result['lon']?.toString() ?? '') ?? _selectedLng;
    setState(() {
      _selectedLat = lat;
      _selectedLng = lng;
      _searchResults = [];
      _searchController.text = result['display_name']?.toString() ?? '';
    });
    _controller.runJavaScript('moveTo($lat, $lng);');
    _searchFocusNode.unfocus();
  }

  void _confirm() {
    Navigator.pop(context, {'lat': _selectedLat, 'lng': _selectedLng});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D3A50),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'تحديد الموقع',
          style: TextStyle(fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: _confirm,
            child: const Text(
              'تأكيد',
              style: TextStyle(color: Color(0xFFC9A97C), fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onChanged: _onSearchChanged,
                        textInputAction: TextInputAction.search,
                        onSubmitted: _searchLocation,
                        decoration: InputDecoration(
                          hintText: 'ابحث عن موقع...',
                          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFFC9A97C)),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Color(0xFF75777D), size: 20),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchResults = []);
                                  },
                                )
                              : _isSearching
                                  ? const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    )
                                  : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (_searchResults.isNotEmpty)
                        Divider(height: 1, color: Colors.grey.shade200),
                    ],
                  ),
                ),
                if (_searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
                      itemBuilder: (context, index) {
                        final result = _searchResults[index];
                        return InkWell(
                          onTap: () => _selectSearchResult(result),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, color: Color(0xFFC9A97C), size: 22),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    result['display_name']?.toString() ?? '',
                                    style: const TextStyle(fontSize: 13, color: Color(0xFF172439)),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_pin, color: Color(0xFFC9A97C), size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_selectedLat.toStringAsFixed(5)}, ${_selectedLng.toStringAsFixed(5)}',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF172439),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _confirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC9A97C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 2,
                    ),
                    child: const Text('تأكيد', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
