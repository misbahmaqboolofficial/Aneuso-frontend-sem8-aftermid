import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:aneuso_app/core/constants/app_constants.dart';
import 'package:aneuso_app/core/utils/form_validators.dart';
import 'package:aneuso_app/core/utils/storage_util.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:io' show File, Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:aneuso_app/core/utils/location_util.dart';
import 'package:aneuso_app/core/utils/screen_title_util.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

final String _kScreenTitle = ScreenTitle.fromFile('report_garbage_screen.dart');

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

  // Location state variables
  double _reportedLatitude = 0.0;
  double _reportedLongitude = 0.0;
  bool _isLocating = false;
  double? _gpsAccuracyMeters;
  final MapController _mapController = MapController();
  final FocusNode _addressFocusNode = FocusNode();

  /// Address text when coordinates were last updated (GPS, map tap, or suggestion).
  String? _addressAtLastCoordUpdate;
  List<AddressSuggestion> _addressSuggestions = [];
  bool _isSearchingAddress = false;
  bool _suppressAddressListener = false;
  int _searchRequestId = 0;
  int _gpsRequestId = 0;
  Timer? _addressSearchDebounce;

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

  bool get _hasValidLocation =>
      LocationUtil.isValidCoordinate(_reportedLatitude, _reportedLongitude);

  bool get _addressOutOfSync {
    final current = _addressController.text.trim();
    final synced = _addressAtLastCoordUpdate?.trim();
    if (synced == null || synced.isEmpty) return current.isNotEmpty;
    return current != synced;
  }

  @override
  void initState() {
    super.initState();
    _addressController.addListener(_onAddressTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _getCurrentLocation());
  }

  void _onAddressTextChanged() {
    if (_suppressAddressListener) return;
    if (mounted) setState(() {});

    _addressSearchDebounce?.cancel();
    final query = _addressController.text.trim();
    if (query.length < 3) {
      if (mounted) setState(() => _addressSuggestions = []);
      return;
    }

    _addressSearchDebounce = Timer(const Duration(milliseconds: 600), () {
      _loadAddressSuggestions(query);
    });
  }

  Future<void> _loadAddressSuggestions(String query) async {
    final requestId = ++_searchRequestId;
    if (mounted) setState(() => _isSearchingAddress = true);

    final results = await LocationUtil.searchAddresses(query, limit: 5);
    if (!mounted || requestId != _searchRequestId) return;

    setState(() {
      _isSearchingAddress = false;
      _addressSuggestions = results;
    });
  }

  void _selectAddressSuggestion(AddressSuggestion suggestion) {
    _gpsRequestId++;
    _searchRequestId++;
    _addressSearchDebounce?.cancel();

    _applyLocation(
      lat: suggestion.lat,
      lng: suggestion.lng,
      address: suggestion.displayName,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Pin set: ${LocationUtil.formatCoords(suggestion.lat, suggestion.lng)}',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _applyLocation({
    required double lat,
    required double lng,
    required String address,
    double? accuracy,
    bool fromGps = false,
  }) {
    setState(() {
      _suppressAddressListener = true;
      _reportedLatitude = lat;
      _reportedLongitude = lng;
      _gpsAccuracyMeters = fromGps ? accuracy : null;
      _addressAtLastCoordUpdate = address.trim();
      _addressSuggestions = [];
      _errorMessage = null;
      _addressController.value = TextEditingValue(
        text: address,
        selection: TextSelection.collapsed(offset: address.length),
      );
      _suppressAddressListener = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _moveMapTo(lat, lng);
    });
  }

  void _moveMapTo(double lat, double lng) {
    try {
      _mapController.move(LatLng(lat, lng), 16);
    } catch (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        try {
          _mapController.move(LatLng(lat, lng), 16);
        } catch (_) {}
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    final gpsId = ++_gpsRequestId;
    setState(() {
      _isLocating = true;
      _errorMessage = null;
    });

    try {
      // Check location service
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled. Please enable GPS.');
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );

      final lat = position.latitude;
      final lng = position.longitude;
      final locError = LocationUtil.validationError(lat, lng);
      if (locError != null) {
        throw Exception(locError);
      }

      if (!mounted || gpsId != _gpsRequestId) return;

      final displayName = await LocationUtil.reverseGeocode(lat, lng);
      final address = (displayName != null && displayName.isNotEmpty)
          ? displayName
          : LocationUtil.formatCoords(lat, lng);

      if (!mounted || gpsId != _gpsRequestId) return;
      _applyLocation(
        lat: lat,
        lng: lng,
        address: address,
        accuracy: position.accuracy,
        fromGps: true,
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get location: $e';
      });
    } finally {
      setState(() {
        _isLocating = false;
      });
    }
  }

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _addressSearchDebounce?.cancel();
    _addressController.removeListener(_onAddressTextChanged);
    _addressFocusNode.dispose();
    _mapController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _estimatedVolumeController.dispose();
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
    final locError = LocationUtil.validationError(
      _reportedLatitude,
      _reportedLongitude,
    );
    if (locError != null) {
      setState(() => _errorMessage = locError);
      return;
    }
    if (_addressOutOfSync) {
      setState(() {
        _errorMessage =
            'Address and map pin do not match. '
            'Pick a place from the address suggestions, tap Locate Me, or move the pin on the map.';
      });
      _addressFocusNode.requestFocus();
      return;
    }
    if (_gpsAccuracyMeters != null && _gpsAccuracyMeters! > 150) {
      setState(() {
        _errorMessage =
            'GPS accuracy is poor (${_gpsAccuracyMeters!.round()} m). '
            'Move outdoors and tap Locate Me again, or drag the pin on the map.';
      });
      return;
    }
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
      var requestBody = {
        'photo_url': _uploadedPhotoUrl,
        'latitude': _reportedLatitude,
        'longitude': _reportedLongitude,
        'address': _addressController.text.trim(),
        'description': _descriptionController.text.trim(),
        'estimated_volume': int.parse(_estimatedVolumeController.text.trim()),
        'funding_goal': 0,
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
              colors: [Color(0xFF6F38C5), Color(0xFF9B5DE0)],
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
                  foregroundColor: const Color(0xFF6F38C5),
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
    setState(() {
      _selectedImage = null;
      _uploadedPhotoUrl = null;
      _uploadedPhotoPath = null;
      _reportedLatitude = 0;
      _reportedLongitude = 0;
      _gpsAccuracyMeters = null;
      _addressAtLastCoordUpdate = null;
      _addressSuggestions = [];
    });
    _getCurrentLocation();
  }

  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _addressController,
          focusNode: _addressFocusNode,
          decoration: InputDecoration(
            labelText: 'Address',
            hintText: 'Keep typing — tap a suggestion when ready',
            prefixIcon: const Icon(
              Icons.location_on_outlined,
              color: Color(0xFF6F38C5),
            ),
            suffixIcon: _isLocating || _isSearchingAddress
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF6F38C5),
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.my_location_rounded,
                      color: Color(0xFF6F38C5),
                    ),
                    onPressed: _getCurrentLocation,
                    tooltip: 'Use my current GPS location',
                  ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator: FormValidators.address,
        ),
        if (_addressOutOfSync && _hasValidLocation)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Address changed — select a suggestion below so the map pin moves to that place.',
              style: TextStyle(fontSize: 11, color: Colors.orange.shade800),
            ),
          ),
      ],
    );
  }

  Widget _buildAddressSuggestions() {
    if (_isSearchingAddress && _addressSuggestions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text(
              'Searching addresses…',
              style: TextStyle(fontSize: 12, color: Color(0xFF6F38C5)),
            ),
          ],
        ),
      );
    }

    if (_addressSuggestions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PointerInterceptor(
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          color: Colors.white,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF6F38C5).withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final suggestion in _addressSuggestions)
                  TextButton(
                    onPressed: () => _selectAddressSuggestion(suggestion),
                    style: TextButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Color(0xFF6F38C5),
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            suggestion.displayName,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF450693),
                              height: 1.35,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationMap() {
    final hasPin = _hasValidLocation;
    final center = hasPin
        ? LatLng(_reportedLatitude, _reportedLongitude)
        : const LatLng(24.8607, 67.0011);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Confirm garbage location on map',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: Color(0xFF450693),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          hasPin
              ? 'Pin: ${LocationUtil.formatCoords(_reportedLatitude, _reportedLongitude)}'
              : 'Waiting for GPS… tap Locate Me or tap the map.',
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
        if (_gpsAccuracyMeters != null) ...[
          const SizedBox(height: 4),
          Text(
            'GPS accuracy: ~${_gpsAccuracyMeters!.round()} m',
            style: TextStyle(
              fontSize: 11,
              color: _gpsAccuracyMeters! > 80
                  ? Colors.orange.shade800
                  : Colors.green.shade700,
            ),
          ),
        ],
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 220,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: hasPin ? 16 : 12,
                onTap: (tapPos, point) async {
                  final err = LocationUtil.validationError(
                    point.latitude,
                    point.longitude,
                  );
                  if (err != null) {
                    setState(() => _errorMessage = err);
                    return;
                  }
                  final label = await LocationUtil.reverseGeocode(
                    point.latitude,
                    point.longitude,
                  );
                  if (!mounted) return;
                  _applyLocation(
                    lat: point.latitude,
                    lng: point.longitude,
                    address: label ??
                        LocationUtil.formatCoords(
                          point.latitude,
                          point.longitude,
                        ),
                  );
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.aneuso.app',
                ),
                if (hasPin)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(_reportedLatitude, _reportedLongitude),
                        width: 48,
                        height: 48,
                        child: const Icon(
                          Icons.location_pin,
                          color: Color(0xFFFF6B6B),
                          size: 42,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap the map to move the pin, or search address and pick a suggestion.',
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
      ],
    );
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
                  color: Color(0xFF6F38C5),
                  size: 20,
                ),
              ),
              onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _kScreenTitle,
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
                      Color(0xFF6F38C5),
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
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                      // Address with OSM autocomplete
                      _buildAddressField(),
                      const SizedBox(height: 8),
                      _buildAddressSuggestions(),
                      const SizedBox(height: 8),
                      _buildLocationMap(),
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
                            color: Color(0xFF6F38C5),
                          ),
                          alignLabelWithHint: true,
                        ),
                        validator: (value) =>
                            FormValidators.description(value, minLength: 10),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _estimatedVolumeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Estimated Volume',
                          hintText: 'kg',
                          prefixIcon: const Icon(
                            Icons.scale,
                            color: Color(0xFF450693),
                          ),
                          suffixText: 'kg',
                          suffixStyle: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        validator: (v) => FormValidators.weightKg(v),
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
                            colors: [Color(0xFF6F38C5), Color(0xFF9B5DE0)],
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
                          color: const Color(0xFF6F38C5).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: Color(0xFF6F38C5),
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
                ],
              ),
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
                  color: Color(0xFF6F38C5),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Upload Photo',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF6F38C5),
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
                      color: const Color(0xFF6F38C5).withOpacity(0.05),
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
                              fit: BoxFit.contain,
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
                              color: Color(0xFF6F38C5),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Tap to add photo',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6F38C5),
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
                  color: const Color(0xFF6F38C5),
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
