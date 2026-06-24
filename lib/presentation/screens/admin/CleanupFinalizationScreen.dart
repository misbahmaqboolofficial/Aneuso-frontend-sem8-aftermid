import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'public_garbage_reports_screen.dart';
import 'package:aneuso_app/core/utils/screen_title_util.dart';

final String _kScreenTitle = ScreenTitle.fromFile('CleanupFinalizationScreen.dart');

class CleanupFinalizationScreen extends StatefulWidget {
  final GarbageReport report;

  const CleanupFinalizationScreen({super.key, required this.report});

  @override
  State<CleanupFinalizationScreen> createState() => _CleanupFinalizationScreenState();
}

class _CleanupFinalizationScreenState extends State<CleanupFinalizationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fuelController = TextEditingController();
  final _laborController = TextEditingController();
  final _otherController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  XFile? _beforePhoto;
  XFile? _afterPhoto;
  bool _isUploading = false;
  final _picker = ImagePicker();

  // â”€â”€ Exclusive WOW Purple Palette (with White for Lightness) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static const darkPurple  = Color(0xFF450693);
  static const mainPurple  = Color(0xFF6F38C5);
  static const brightPurp  = Color(0xFF9B5DE0);
  static const softLilac   = Color(0xFFD78FEE);
  static const palePink    = Color(0xFFFDCFFA);

  Future<void> _pickImage(bool isBefore) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) setState(() { if (isBefore) _beforePhoto = image; else _afterPhoto = image; });
  }

  Future<void> _submit() async {
    if (_afterPhoto == null) { _showError('Post-cleanup documentation required'); return; }
    if (_beforePhoto == null && widget.report.photoUrl.isEmpty) { _showError('Pre-cleanup documentation required'); return; }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);
    try {
      final api = ApiService();
      String? beforeUrl;
      if (_beforePhoto != null) beforeUrl = await api.uploadPhoto(_beforePhoto!);
      final afterUrl = await api.uploadPhoto(_afterPhoto!);
      if (afterUrl == null) throw Exception('Upload Protocol Failed');

      final success = await api.finalizeReport(
        reportId: widget.report.id,
        fuel: double.tryParse(_fuelController.text) ?? 0,
        labor: double.tryParse(_laborController.text) ?? 0,
        other: double.tryParse(_otherController.text) ?? 0,
        description: _descriptionController.text,
        beforePhoto: beforeUrl,
        afterPhoto: afterUrl,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mission Log Finalized!'), backgroundColor: brightPurp));
          Navigator.pop(context, true);
        }
      } else { throw Exception('API Finalization Failed'); }
    } catch (e) { if (mounted) _showError(e.toString()); }
    finally { if (mounted) setState(() => _isUploading = false); }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: darkPurple, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                iconTheme: const IconThemeData(color: darkPurple),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(_kScreenTitle, style: TextStyle(fontWeight: FontWeight.w900, color: darkPurple, fontSize: 16, letterSpacing: 4)),
                  background: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [palePink.withOpacity(0.5), Colors.white]))),
                ),
              ),
              
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 60),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _lightCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionLabel('SITE DOCUMENTATION', Icons.camera_rounded),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(child: _photoHexagon('BEFORE', _beforePhoto, widget.report.photoUrl, () => _pickImage(true))),
                                  const SizedBox(width: 20),
                                  Expanded(child: _photoHexagon('AFTER', _afterPhoto, null, () => _pickImage(false))),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        _lightCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionLabel('OPERATIONAL LOGS', Icons.receipt_long_rounded),
                              const SizedBox(height: 24),
                              _wowTextField(_fuelController, 'FUEL EXPENSES', Icons.local_gas_station_rounded, isNum: true),
                              const SizedBox(height: 20),
                              _wowTextField(_laborController, 'PERSONNEL COSTS', Icons.groups_rounded, isNum: true),
                              const SizedBox(height: 20),
                              _wowTextField(_otherController, 'MISC CHARGES', Icons.payments_rounded, isNum: true),
                              const SizedBox(height: 20),
                              _wowTextField(_descriptionController, 'MISSION NOTES', Icons.edit_note_rounded, maxLines: 3, isReq: false),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 48),
                        _buildActionBtn(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _lightCard({required Widget child}) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), border: Border.all(color: darkPurple.withOpacity(0.05)), boxShadow: [BoxShadow(color: darkPurple.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))]), child: Padding(padding: const EdgeInsets.all(24), child: child));

  Widget _sectionLabel(String label, IconData icon) => Row(children: [Icon(icon, color: brightPurp, size: 20), const SizedBox(width: 12), Text(label, style: const TextStyle(color: darkPurple, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2))]);

  Widget _photoHexagon(String label, XFile? file, String? networkUrl, VoidCallback onTap) {
    bool hasImg = file != null || (networkUrl != null && networkUrl.isNotEmpty);
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 160,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), border: Border.all(color: hasImg ? brightPurp : darkPurple.withOpacity(0.05), width: 2), color: palePink.withOpacity(0.1)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (file != null) ...[
                    kIsWeb ? Image.network(file.path, fit: BoxFit.contain) : Image.file(File(file.path), fit: BoxFit.contain),
                  ] else if (networkUrl != null && networkUrl.isNotEmpty) ...[
                    Image.network(networkUrl, fit: BoxFit.contain),
                  ] else
                    Center(child: Icon(Icons.add_a_photo_rounded, color: darkPurple.withOpacity(0.1), size: 32)),
                  Positioned(bottom: 0, left: 0, right: 0, child: Container(padding: const EdgeInsets.symmetric(vertical: 6), color: darkPurple.withOpacity(0.6), child: Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)))),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _wowTextField(TextEditingController controller, String label, IconData icon, {bool isNum = false, int maxLines = 1, bool isReq = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: darkPurple.withOpacity(0.5), letterSpacing: 1.5)),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: isNum ? TextInputType.number : TextInputType.text,
          inputFormatters: isNum ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))] : null,
          maxLines: maxLines,
          style: const TextStyle(color: darkPurple, fontSize: 16, fontWeight: FontWeight.w700),
          decoration: InputDecoration(prefixIcon: Icon(icon, color: brightPurp, size: 20), filled: true, fillColor: palePink.withOpacity(0.1), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: darkPurple.withOpacity(0.05))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: brightPurp, width: 2))),
          validator: (v) => (isReq && (v == null || v.isEmpty)) ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildActionBtn() {
    return Container(
      width: double.infinity, height: 64,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: const LinearGradient(colors: [brightPurp, mainPurple]), boxShadow: [BoxShadow(color: brightPurp.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))]),
      child: ElevatedButton(onPressed: _isUploading ? null : _submit, style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: _isUploading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : const Text('SUBMIT REPORT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5))),
    );
  }
}
