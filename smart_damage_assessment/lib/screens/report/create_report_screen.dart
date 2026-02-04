import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
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

  File? _selectedImage;
  Position? _currentPosition;
  bool _isGettingLocation = false;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);

    try {
      // 1. Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('Location service is disabled. Please enable GPS.');
        return;
      }

      // 2. Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        // Request permission if not granted
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('Location permission denied permanently. Please enable in app settings.');
        return;
      }

      // 3. Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _currentPosition = position;
      });

      _showSnackBar('Location obtained successfully');
      print("Latitude: ${position.latitude}, Longitude: ${position.longitude}");
    } catch (e) {
      _showSnackBar('Failed to get location: ${e.toString()}');
    } finally {
      setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _takePhoto() async {
    try {
      // Check camera permission
      final permission = await Permission.camera.request();
      if (!permission.isGranted) {
        if (permission.isPermanentlyDenied) {
          _showSnackBar('Camera permission denied permanently. Please enable in app settings.');
        } else {
          _showSnackBar('Camera permission denied');
        }
        return;
      }

      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80, // Compress image
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        _showSnackBar('Photo captured successfully');
        print("Image Path: ${pickedFile.path}");
      }
    } catch (e) {
      _showSnackBar('Failed to take photo: ${e.toString()}');
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImage == null) {
      _showSnackBar('Please take a photo');
      return;
    }

    final reportProvider = context.read<ReportProvider>();
    final success = await reportProvider.createReportFromXFile(
      userInputLocation: _locationController.text.trim(),
      userNotes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      latitude: _currentPosition?.latitude,
      longitude: _currentPosition?.longitude,
      imageFile: _selectedImage,
    );

    if (success && mounted) {
      _showSnackBar('Report created successfully');
      Navigator.of(context).pop();
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
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
    final reportProvider = context.watch<ReportProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Report'),
      ),
      body: LoadingOverlay(
        isLoading: reportProvider.isLoading,
        message: 'Creating report...',
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
                    labelText: 'Location Name',
                    hintText: 'Enter location name or description',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Location name is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Notes field
                  CustomTextField(
                    controller: _notesController,
                    labelText: 'Notes (Optional)',
                    hintText: 'Additional details about the damage',
                    maxLines: 3,
                  ),

                  const SizedBox(height: 24),

                  // Location section
                  Text(
                    'Location',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Get location button
                  CustomOutlinedButton(
                    text: _isGettingLocation ? 'Getting Location...' : 'Get Current Location',
                    onPressed: _isGettingLocation ? null : _getCurrentLocation,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location obtained:',
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
                  ],

                  const SizedBox(height: 24),

                  // Photo section
                  Text(
                    'Photo',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Take photo button
                  CustomOutlinedButton(
                    text: 'Take Photo',
                    onPressed: _takePhoto,
                    borderColor: theme.colorScheme.secondary,
                    textColor: theme.colorScheme.secondary,
                  ),

                  // Image preview
                  if (_selectedImage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Submit button
                  CustomButton(
                    text: 'Submit Report',
                    onPressed: reportProvider.isLoading ? null : _submitReport,
                    isLoading: reportProvider.isLoading,
                  ),

                  const SizedBox(height: 16),

                  // Cancel button
                  CustomOutlinedButton(
                    text: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}