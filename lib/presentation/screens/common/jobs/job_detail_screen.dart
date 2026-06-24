import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../providers/job_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../../data/models/job_vacancy.dart';
import 'package:aneuso_app/core/utils/screen_title_util.dart';

final String _kScreenTitle = ScreenTitle.fromFile('job_detail_screen.dart');

class JobDetailScreen extends StatefulWidget {
  final int jobId;
  const JobDetailScreen({Key? key, required this.jobId}) : super(key: key);

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  final _coverLetterController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  Uint8List? _docFileBytes;
  String? _docFileName;
  bool _isSubmittingApp = false;
  JobVacancyModel? _job;
  bool _isLoadingJob = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadJobDetails();
    });
  }

  Future<void> _loadJobDetails() async {
    setState(() {
      _isLoadingJob = true;
    });
    try {
      final provider = Provider.of<JobProvider>(context, listen: false);
      final allJ = provider.allJobs;
      final myJ = provider.myJobs;
      
      JobVacancyModel? found;
      for (var j in allJ) {
        if (j.id == widget.jobId) found = j;
      }
      if (found == null) {
        for (var j in myJ) {
          if (j.id == widget.jobId) found = j;
        }
      }

      if (found != null) {
        setState(() {
          _job = found;
        });

        final authUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
        if (found.userId == authUser?.id) {
          await provider.fetchJobApplications(widget.jobId);
        }
      }
    } catch (e) {
      debugPrint('Error loading job: $e');
    } finally {
      setState(() {
        _isLoadingJob = false;
      });
    }
  }

  @override
  void dispose() {
    _coverLetterController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _docFileBytes = bytes;
          _docFileName = file.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick document: $e')),
      );
    }
  }

  Future<void> _apply() async {
    if (_docFileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select/upload a document or resume photo')),
      );
      return;
    }

    setState(() {
      _isSubmittingApp = true;
    });

    try {
      final provider = Provider.of<JobProvider>(context, listen: false);
      final docUrl = await provider.uploadDocument(_docFileBytes!, _docFileName!);
      if (docUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Failed to upload document')),
        );
        return;
      }

      final success = await provider.applyToJob(
        widget.jobId,
        coverLetter: _coverLetterController.text.trim(),
        documentUrl: docUrl,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted successfully!'),
            backgroundColor: Color(0xFF6F38C5),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Failed to apply')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isSubmittingApp = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authUser = Provider.of<AuthProvider>(context).currentUser;
    final jobProvider = Provider.of<JobProvider>(context);

    if (_isLoadingJob) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0616),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFA555EC))),
      );
    }

    if (_job == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0616),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(_kScreenTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text('Job Vacancy not found.', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final isOwner = _job!.userId == authUser?.id;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEBE0FF),
        elevation: 0,
        title: Text(
          _kScreenTitle,
          style: const TextStyle(color: Color(0xFF450693), fontWeight: FontWeight.w900, letterSpacing: 0.5)
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF450693).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF450693), size: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEBE0FF),
              Colors.white,
            ],
            stops: [0.0, 0.45],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Premium Job Detail Card with glow borders
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFF8A39E1).withOpacity(0.12), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8A39E1).withOpacity(0.06),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8A39E1).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFD78FEE).withOpacity(0.3)),
                              ),
                              child: Text(
                                _job!.category,
                                style: const TextStyle(
                                  color: Color(0xFF450693), 
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 13,
                                  letterSpacing: 0.5
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _job!.status == 'active' 
                                  ? Colors.green.withOpacity(0.15) 
                                  : Colors.blue.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _job!.status == 'active' ? Colors.greenAccent : Colors.blueAccent
                              ),
                            ),
                            child: Text(
                              _job!.status.toUpperCase(),
                              style: TextStyle(
                                color: _job!.status == 'active' ? Colors.green : Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                letterSpacing: 0.5
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _job!.title,
                        style: const TextStyle(
                          color: Color(0xFF450693), 
                          fontSize: 24, 
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _job!.description,
                        style: TextStyle(color: Colors.black87.withOpacity(0.8), fontSize: 15, height: 1.6),
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: Colors.black12, height: 1),
                      const SizedBox(height: 18),
                      
                      _buildDetailRow(Icons.wallet_rounded, 'Salary / Compensation', _job!.salary != null && _job!.salary!.isNotEmpty ? _job!.salary! : 'Negotiable'),
                      const SizedBox(height: 14),
                      _buildDetailRow(Icons.person_pin_rounded, 'Recruiter / Posted By', _job!.creatorName ?? 'User'),
                      const SizedBox(height: 14),
                      _buildDetailRow(Icons.phone_iphone_rounded, 'Contact Phone', _job!.contactPhone ?? 'Not Provided'),
                      const SizedBox(height: 14),
                      _buildDetailRow(Icons.alternate_email_rounded, 'Contact Email', _job!.contactEmail ?? 'Not Provided'),
                      const SizedBox(height: 14),
                      _buildDetailRow(Icons.pin_drop_rounded, 'Address / Location', _job!.contactAddress ?? 'Not Provided'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 28),

              // Applications section
              if (isOwner) ...[
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, bottom: 12),
                  child: Text(
                    'Applicants & Submissions',
                    style: TextStyle(color: Color(0xFF450693), fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.2),
                  ),
                ),
                _buildApplicationsList(jobProvider.currentJobApplications),
              ] else if (_job!.status == 'active') ...[
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, bottom: 12),
                  child: Text(
                    'Apply Now',
                    style: TextStyle(color: Color(0xFF450693), fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.2),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF6F38C5).withOpacity(0.12)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _coverLetterController,
                          maxLines: 4,
                          style: const TextStyle(color: Color(0xFF450693)),
                          decoration: InputDecoration(
                            hintText: 'Introduce yourself and state your suitability...',
                            hintStyle: TextStyle(color: const Color(0xFF450693).withOpacity(0.4)),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16), 
                              borderSide: BorderSide(color: const Color(0xFF6F38C5).withOpacity(0.15))
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16), 
                              borderSide: BorderSide(color: const Color(0xFF6F38C5).withOpacity(0.15))
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Picker button
                        InkWell(
                          onTap: _pickDocument,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFA555EC).withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(16),
                              color: const Color(0xFF8A39E1).withOpacity(0.05),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.cloud_upload_outlined, color: Color(0xFF450693)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _docFileName ?? 'Upload CV / Resume (Image/Photo)',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Color(0xFF450693), fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _isSubmittingApp
                            ? const Center(child: CircularProgressIndicator(color: Color(0xFFA555EC)))
                            : SizedBox(
                                width: double.infinity,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF8A39E1), Color(0xFFA555EC)],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFA555EC).withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    onPressed: _apply,
                                    child: const Text('Submit Application', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF8A39E1).withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF450693), size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: const Color(0xFF450693).withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              const SizedBox(height: 3),
              Text(value, style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildApplicationsList(List<JobApplicationModel> apps) {
    if (apps.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF6F38C5).withOpacity(0.12)),
        ),
        child: const Center(
          child: Text('No applications submitted yet.', style: TextStyle(color: Color(0xFF450693), fontSize: 15)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF6F38C5).withOpacity(0.12)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6F38C5).withOpacity(0.06),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFF8A39E1),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        app.applicantName != null && app.applicantName!.isNotEmpty ? app.applicantName![0].toUpperCase() : 'A',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        app.applicantName ?? 'Applicant',
                        style: const TextStyle(color: Color(0xFF450693), fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (app.applicantPhone != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.phone_android, size: 16, color: Color(0xFF450693)),
                      const SizedBox(width: 10),
                      Text(app.applicantPhone!, style: const TextStyle(color: Colors.black87, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                if (app.applicantEmail != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.alternate_email_rounded, size: 16, color: Color(0xFF450693)),
                      const SizedBox(width: 10),
                      Text(app.applicantEmail!, style: const TextStyle(color: Colors.black87, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                if (app.coverLetter != null && app.coverLetter!.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey[50], 
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Text(
                      app.coverLetter!,
                      style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (app.documentUrl != null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8A39E1).withOpacity(0.15),
                        foregroundColor: const Color(0xFFD78FEE),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: const Color(0xFF8A39E1).withOpacity(0.4)),
                        ),
                      ),
                      onPressed: () async {
                        final uri = Uri.parse(app.documentUrl!);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Could not open document link.')),
                          );
                        }
                      },
                      icon: const Icon(Icons.file_present_rounded),
                      label: const Text('Open CV / Document', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
