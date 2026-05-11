import 'dart:convert';
import 'dart:typed_data';
import 'package:aneuso_app/core/constants/app_constants.dart';
import 'package:aneuso_app/core/utils/storage_util.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:io' show File, Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

// Cross-platform image data holder
class ImageData {
  final Uint8List bytes;
  final String fileName;
  final String mimeType;
  final String? localPath; // For mobile only

  ImageData({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
    this.localPath,
  });
}

class ReportGarbageScreen extends StatefulWidget {
  const ReportGarbageScreen({super.key});

  @override
  State<ReportGarbageScreen> createState() => _ReportGarbageScreenState();
}

class _ReportGarbageScreenState extends State<ReportGarbageScreen> {
  // Text controllers
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _estimatedVolumeController = TextEditingController();
  final _fundingGoalController = TextEditingController();

  // Image related
  ImageData? _selectedImage;
  bool _isUploading = false;
  String? _uploadedPhotoUrl;
  String? _uploadedPhotoPath;

  // Form state
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  String? _errorMessage;

  // API Configuration - You can set this dynamically
  String apiBaseUrl = AppConstants.baseUrl;
  String get uploadEndpoint => '$apiBaseUrl/upload';
  String get reportEndpoint => '$apiBaseUrl/reports/public-garbage';

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _addressController.dispose();
    _descriptionController.dispose();
    _estimatedVolumeController.dispose();
    _fundingGoalController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        await _processSelectedImage(image);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick image: $e';
      });
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) {
        await _processSelectedImage(image);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to take photo: $e';
      });
    }
  }

  Future<void> _processSelectedImage(XFile image) async {
    // Read image bytes (works on all platforms)
    Uint8List imageBytes = await image.readAsBytes();

    // Get file name and extension
    String fileName = image.name;
    String extension = fileName.split('.').last.toLowerCase();

    // Determine mime type
    String mimeType;
    if (extension == 'jpg' || extension == 'jpeg') {
      mimeType = 'image/jpeg';
    } else if (extension == 'png') {
      mimeType = 'image/png';
    } else if (extension == 'gif') {
      mimeType = 'image/gif';
    } else {
      mimeType = 'image/jpeg';
      fileName = '$fileName.jpg';
    }

    setState(() {
      _selectedImage = ImageData(
        bytes: imageBytes,
        fileName: fileName,
        mimeType: mimeType,
        localPath: kIsWeb ? null : image.path,
      );
      _uploadedPhotoUrl = null;
      _uploadedPhotoPath = null;
      _errorMessage = null;
    });
  }

  Future<bool> _uploadImage() async {
    if (_selectedImage == null) {
      setState(() {
        _errorMessage = 'Please select an image first';
      });
      return false;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      final token = StorageUtil.getToken();
      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse(uploadEndpoint));
      request.headers['Authorization'] = 'Bearer $token';

      // Create multipart file from bytes (works on web and mobile)
      var multipartFile = http.MultipartFile.fromBytes(
        'photo',
        _selectedImage!.bytes,
        filename: _selectedImage!.fileName,
        contentType: MediaType.parse(_selectedImage!.mimeType),
      );

      request.files.add(multipartFile);

      // Send request
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseBody);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        setState(() {
          _uploadedPhotoUrl = jsonResponse['data']['url'];
          _uploadedPhotoPath = jsonResponse['data']['path'];
          _isUploading = false;
        });
        return true;
      } else {
        throw Exception(jsonResponse['message'] ?? 'Upload failed');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Image upload failed: $e';
        _isUploading = false;
      });
      return false;
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      setState(() {
        _errorMessage = 'Please take or select a photo of the garbage';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    // Step 1: Upload image first
    bool imageUploaded = await _uploadImage();
    if (!imageUploaded) {
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    // Step 2: Submit report with uploaded image URL
    try {
      // Get current location (simplified - you can integrate geolocator package for real coordinates)
      // For demo, using sample coordinates. In production, use Geolocator to get actual location
      double latitude = 0;
      double longitude = 0;

      var requestBody = {
        'photo_url': _uploadedPhotoUrl,
        'latitude': latitude,
        'longitude': longitude,
        'address': _addressController.text.trim(),
        'description': _descriptionController.text.trim(),
        'estimated_volume': int.parse(_estimatedVolumeController.text.trim()),
        'funding_goal': int.parse(_fundingGoalController.text.trim()),
      };

      final token = StorageUtil.getToken();
      var response = await http.post(
        Uri.parse(reportEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      var jsonResponse = json.decode(response.body);

      if (response.statusCode == 201 && jsonResponse['success'] == true) {
        _showSuccessDialog(jsonResponse['data']);
        _resetForm();
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to submit report');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to submit report: $e';
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSuccessDialog(Map<String, dynamic> reportData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4E56C0), Color(0xFF9B5DE0)],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Report Submitted!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Report ID: ${reportData['id']}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4E56C0),
                ),
                child: const Text('Great!'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resetForm() {
    _addressController.clear();
    _descriptionController.clear();
    _estimatedVolumeController.clear();
    _fundingGoalController.clear();
    setState(() {
      _selectedImage = null;
      _uploadedPhotoUrl = null;
      _uploadedPhotoPath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Modern Gradient Header
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF4E56C0),
                  size: 20,
                ),
              ),
              onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Report Garbage',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF4E56C0),
                        Color(0xFF9B5DE0),
                        Color(0xFFD78FEE),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     Icon(Icons.cleaning_services, color: Colors.white.withOpacity(0.9), size: 28),
                      //     const SizedBox(width: 12),
                      //     Text(
                      //       'Make Your City Clean',
                      //       style: TextStyle(
                      //         color: Colors.white.withOpacity(0.9),
                      //         fontSize: 16,
                      //         fontWeight: FontWeight.w500,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Error Message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade400),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Image Upload Section
                _buildImageUploadSection(),
                const SizedBox(height: 24),
                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Address Field
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          hintText: 'Enter the location address',
                          prefixIcon: const Icon(
                            Icons.location_on_outlined,
                            color: Color(0xFF4E56C0),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Description Field
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          hintText: 'Describe the garbage situation...',
                          prefixIcon: const Icon(
                            Icons.description_outlined,
                            color: Color(0xFF4E56C0),
                          ),
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _estimatedVolumeController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Estimated Volume',
                                hintText: 'kg',
                                prefixIcon: const Icon(
                                  Icons.scale,
                                  color: Color(0xFF4E56C0),
                                ),
                                suffixText: 'kg',
                                suffixStyle: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Invalid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _fundingGoalController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Funding Goal',
                                hintText: 'Amount',
                                prefixIcon: const Icon(
                                  Icons.attach_money,
                                  color: Color(0xFF4E56C0),
                                ),
                                prefixText: 'PKR ',
                                prefixStyle: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Invalid amount';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Submit Button
                _isSubmitting || _isUploading
                    ? Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4E56C0), Color(0xFF9B5DE0)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _submitReport,
                        child: const Text(
                          'Submit Report',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                const SizedBox(height: 20),
                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFDCFFA).withOpacity(0.3),
                        const Color(0xFFD78FEE).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4E56C0).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: Color(0xFF4E56C0),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your report will help us take action. Funds collected will be used for cleanup operations.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFDCFFA).withOpacity(0.4),
            const Color(0xFFD78FEE).withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                const Icon(
                  Icons.camera_alt,
                  color: Color(0xFF4E56C0),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Upload Photo',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF4E56C0),
                  ),
                ),
                const Spacer(),
                if (_isUploading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: () => _showImagePickerDialog(),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFD78FEE).withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4E56C0).withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.memory(
                              _selectedImage!.bytes,
                              fit: BoxFit.cover,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.5),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Change',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDCFFA).withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.cloud_upload_outlined,
                              size: 40,
                              color: Color(0xFF4E56C0),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Tap to add photo',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF4E56C0),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'JPG, PNG or GIF',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Photo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImagePickerOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage();
                  },
                  color: const Color(0xFF4E56C0),
                ),
                _buildImagePickerOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto();
                  },
                  color: const Color(0xFF9B5DE0),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
