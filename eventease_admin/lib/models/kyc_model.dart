class KycModel {
  final String id;

  final String providerId;
  final String providerName;
  final String providerEmail;
  final String providerPhone;

  final String kycStatus;

  final bool aadhaarVerified;
  final bool panVerified;
  final bool bankVerified;
  final bool gstVerified;

  final String? aadhaarNumber;
  final String? panNumber;
  final String? gstNumber;

  final String? aadhaarFrontImage;
  final String? aadhaarBackImage;
  final String? panImage;
  final String? gstCertificateImage;
  final String? profileImage;

  final String bankAccountHolderName;
  final String bankAccountNumber;
  final String ifscCode;
  final String bankName;

  final String? rejectionReason;
  final String? adminRemarks;

  final String? verifiedBy;
  final String? verifiedById;

  final DateTime? submittedAt;
  final DateTime? verifiedAt;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const KycModel({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.providerEmail,
    required this.providerPhone,
    required this.kycStatus,
    required this.aadhaarVerified,
    required this.panVerified,
    required this.bankVerified,
    required this.gstVerified,
    this.aadhaarNumber,
    this.panNumber,
    this.gstNumber,
    this.aadhaarFrontImage,
    this.aadhaarBackImage,
    this.panImage,
    this.gstCertificateImage,
    this.profileImage,
    required this.bankAccountHolderName,
    required this.bankAccountNumber,
    required this.ifscCode,
    required this.bankName,
    this.rejectionReason,
    this.adminRemarks,
    this.verifiedBy,
    this.verifiedById,
    this.submittedAt,
    this.verifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory KycModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return KycModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',

      providerId:
          json['providerId']
                  ?.toString() ??
              '',

      providerName:
          json['providerName']
                  ?.toString() ??
              '',

      providerEmail:
          json['providerEmail']
                  ?.toString() ??
              '',

      providerPhone:
          json['providerPhone']
                  ?.toString() ??
              '',

      kycStatus:
          json['kycStatus']
                  ?.toString() ??
              'pending',

      aadhaarVerified:
          json['aadhaarVerified'] ??
              false,

      panVerified:
          json['panVerified'] ??
              false,

      bankVerified:
          json['bankVerified'] ??
              false,

      gstVerified:
          json['gstVerified'] ??
              false,

      aadhaarNumber:
          json['aadhaarNumber']
              ?.toString(),

      panNumber:
          json['panNumber']
              ?.toString(),

      gstNumber:
          json['gstNumber']
              ?.toString(),

      aadhaarFrontImage:
          json['aadhaarFrontImage']
              ?.toString(),

      aadhaarBackImage:
          json['aadhaarBackImage']
              ?.toString(),

      panImage:
          json['panImage']
              ?.toString(),

      gstCertificateImage:
          json['gstCertificateImage']
              ?.toString(),

      profileImage:
          json['profileImage']
              ?.toString(),

      bankAccountHolderName:
          json['bankAccountHolderName']
                  ?.toString() ??
              '',

      bankAccountNumber:
          json['bankAccountNumber']
                  ?.toString() ??
              '',

      ifscCode:
          json['ifscCode']
                  ?.toString() ??
              '',

      bankName:
          json['bankName']
                  ?.toString() ??
              '',

      rejectionReason:
          json['rejectionReason']
              ?.toString(),

      adminRemarks:
          json['adminRemarks']
              ?.toString(),

      verifiedBy:
          json['verifiedBy']
              ?.toString(),

      verifiedById:
          json['verifiedById']
              ?.toString(),

      submittedAt:
          json['submittedAt'] != null
              ? DateTime.tryParse(
                  json['submittedAt']
                      .toString(),
                )
              : null,

      verifiedAt:
          json['verifiedAt'] != null
              ? DateTime.tryParse(
                  json['verifiedAt']
                      .toString(),
                )
              : null,

      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(
                  json['createdAt']
                      .toString(),
                )
              : null,

      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(
                  json['updatedAt']
                      .toString(),
                )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'providerId': providerId,
      'providerName': providerName,
      'providerEmail': providerEmail,
      'providerPhone': providerPhone,
      'kycStatus': kycStatus,
      'aadhaarVerified': aadhaarVerified,
      'panVerified': panVerified,
      'bankVerified': bankVerified,
      'gstVerified': gstVerified,
      'aadhaarNumber': aadhaarNumber,
      'panNumber': panNumber,
      'gstNumber': gstNumber,
      'aadhaarFrontImage': aadhaarFrontImage,
      'aadhaarBackImage': aadhaarBackImage,
      'panImage': panImage,
      'gstCertificateImage':
          gstCertificateImage,
      'profileImage': profileImage,
      'bankAccountHolderName':
          bankAccountHolderName,
      'bankAccountNumber':
          bankAccountNumber,
      'ifscCode': ifscCode,
      'bankName': bankName,
      'rejectionReason':
          rejectionReason,
      'adminRemarks': adminRemarks,
      'verifiedBy': verifiedBy,
      'verifiedById': verifiedById,
      'submittedAt':
          submittedAt?.toIso8601String(),
      'verifiedAt':
          verifiedAt?.toIso8601String(),
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  KycModel copyWith({
    String? id,
    String? providerId,
    String? providerName,
    String? providerEmail,
    String? providerPhone,
    String? kycStatus,
    bool? aadhaarVerified,
    bool? panVerified,
    bool? bankVerified,
    bool? gstVerified,
    String? aadhaarNumber,
    String? panNumber,
    String? gstNumber,
    String? aadhaarFrontImage,
    String? aadhaarBackImage,
    String? panImage,
    String? gstCertificateImage,
    String? profileImage,
    String? bankAccountHolderName,
    String? bankAccountNumber,
    String? ifscCode,
    String? bankName,
    String? rejectionReason,
    String? adminRemarks,
    String? verifiedBy,
    String? verifiedById,
    DateTime? submittedAt,
    DateTime? verifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KycModel(
      id: id ?? this.id,
      providerId:
          providerId ?? this.providerId,
      providerName:
          providerName ??
              this.providerName,
      providerEmail:
          providerEmail ??
              this.providerEmail,
      providerPhone:
          providerPhone ??
              this.providerPhone,
      kycStatus:
          kycStatus ?? this.kycStatus,
      aadhaarVerified:
          aadhaarVerified ??
              this.aadhaarVerified,
      panVerified:
          panVerified ??
              this.panVerified,
      bankVerified:
          bankVerified ??
              this.bankVerified,
      gstVerified:
          gstVerified ??
              this.gstVerified,
      aadhaarNumber:
          aadhaarNumber ??
              this.aadhaarNumber,
      panNumber:
          panNumber ?? this.panNumber,
      gstNumber:
          gstNumber ?? this.gstNumber,
      aadhaarFrontImage:
          aadhaarFrontImage ??
              this.aadhaarFrontImage,
      aadhaarBackImage:
          aadhaarBackImage ??
              this.aadhaarBackImage,
      panImage:
          panImage ?? this.panImage,
      gstCertificateImage:
          gstCertificateImage ??
              this.gstCertificateImage,
      profileImage:
          profileImage ??
              this.profileImage,
      bankAccountHolderName:
          bankAccountHolderName ??
              this.bankAccountHolderName,
      bankAccountNumber:
          bankAccountNumber ??
              this.bankAccountNumber,
      ifscCode:
          ifscCode ?? this.ifscCode,
      bankName:
          bankName ?? this.bankName,
      rejectionReason:
          rejectionReason ??
              this.rejectionReason,
      adminRemarks:
          adminRemarks ??
              this.adminRemarks,
      verifiedBy:
          verifiedBy ?? this.verifiedBy,
      verifiedById:
          verifiedById ??
              this.verifiedById,
      submittedAt:
          submittedAt ??
              this.submittedAt,
      verifiedAt:
          verifiedAt ?? this.verifiedAt,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  bool get isPending =>
      kycStatus.toLowerCase() ==
      'pending';

  bool get isApproved =>
      kycStatus.toLowerCase() ==
      'approved';

  bool get isRejected =>
      kycStatus.toLowerCase() ==
      'rejected';

  bool get isUnderReview =>
      kycStatus.toLowerCase() ==
      'under_review';

  bool get allDocumentsVerified =>
      aadhaarVerified &&
      panVerified &&
      bankVerified;

  bool get hasGst =>
      gstNumber != null &&
      gstNumber!.isNotEmpty;

  bool get hasRejectionReason =>
      rejectionReason != null &&
      rejectionReason!.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KycModel &&
          other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'KycModel('
        'id: $id, '
        'providerName: $providerName, '
        'status: $kycStatus'
        ')';
  }
}