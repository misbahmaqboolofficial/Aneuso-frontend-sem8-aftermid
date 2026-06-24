class JobVacancyModel {
  final int id;
  final int userId;
  final String title;
  final String category;
  final String description;
  final String? salary;
  final String? contactEmail;
  final String? contactPhone;
  final String? contactAddress;
  final String status;
  final String createdAt;
  final String? creatorName;
  final String? creatorEmail;
  final String? creatorPhone;

  JobVacancyModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.description,
    this.salary,
    this.contactEmail,
    this.contactPhone,
    this.contactAddress,
    required this.status,
    required this.createdAt,
    this.creatorName,
    this.creatorEmail,
    this.creatorPhone,
  });

  factory JobVacancyModel.fromJson(Map<String, dynamic> json) {
    return JobVacancyModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      salary: json['salary'],
      contactEmail: json['contact_email'],
      contactPhone: json['contact_phone'],
      contactAddress: json['contact_address'],
      status: json['status'] ?? 'active',
      createdAt: json['created_at'] ?? '',
      creatorName: json['creator_name'],
      creatorEmail: json['creator_email'],
      creatorPhone: json['creator_phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'category': category,
      'description': description,
      'salary': salary,
      'contact_email': contactEmail,
      'contact_phone': contactPhone,
      'contact_address': contactAddress,
      'status': status,
      'created_at': createdAt,
    };
  }
}

class JobApplicationModel {
  final int id;
  final int jobId;
  final int userId;
  final String? coverLetter;
  final String? documentUrl;
  final String createdAt;
  final String? applicantName;
  final String? applicantEmail;
  final String? applicantPhone;
  final String? jobTitle;

  JobApplicationModel({
    required this.id,
    required this.jobId,
    required this.userId,
    this.coverLetter,
    this.documentUrl,
    required this.createdAt,
    this.applicantName,
    this.applicantEmail,
    this.applicantPhone,
    this.jobTitle,
  });

  factory JobApplicationModel.fromJson(Map<String, dynamic> json) {
    return JobApplicationModel(
      id: json['id'] ?? 0,
      jobId: json['job_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      coverLetter: json['cover_letter'],
      documentUrl: json['document_url'],
      createdAt: json['created_at'] ?? '',
      applicantName: json['applicant_name'],
      applicantEmail: json['applicant_email'],
      applicantPhone: json['applicant_phone'],
      jobTitle: json['job_title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_id': jobId,
      'user_id': userId,
      'cover_letter': coverLetter,
      'document_url': documentUrl,
      'created_at': createdAt,
    };
  }
}
