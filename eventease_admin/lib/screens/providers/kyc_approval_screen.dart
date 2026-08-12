import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../models/provider_model.dart';
import '../../providers/kyc_provider.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/dialogs/approve_dialog.dart';

class KycApprovalScreen extends StatefulWidget {
  const KycApprovalScreen({
    super.key,
  });

  @override
  State<KycApprovalScreen> createState() =>
      _KycApprovalScreenState();
}

class _KycApprovalScreenState
    extends State<KycApprovalScreen> {
  ProviderModel? _provider;

  String? _providerId;
  String? _kycId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments;

    if (args is ProviderModel) {
      _provider = args;
      _providerId = args.id;

      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          _loadProviderKyc();
        },
      );
    } else if (args is Map<String, dynamic>) {
      final providerArg = args['provider'];

      if (providerArg is ProviderModel) {
        _provider = providerArg;
        _providerId = providerArg.id;
      } else {
        _providerId = args['providerId']?.toString();
      }

      _kycId = args['kycId']?.toString();

      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          if (_kycId != null &&
              _kycId!.isNotEmpty) {
            _loadKycDetails();
          } else {
            _loadProviderKyc();
          }
        },
      );
    }
  }

  // =====================================================
  // LOAD PROVIDER KYC
  // =====================================================

  Future<void> _loadProviderKyc() async {
    if (_providerId == null ||
        _providerId!.isEmpty) {
      return;
    }

    await context
        .read<KycProvider>()
        .getProviderKyc(
          _providerId!,
        );
  }

  // =====================================================
  // LOAD KYC DETAILS
  // =====================================================

  Future<void> _loadKycDetails() async {
    if (_kycId == null || _kycId!.isEmpty) {
      return;
    }

    await context
        .read<KycProvider>()
        .getKycDetails(
          _kycId!,
        );
  }

  // =====================================================
  // REFRESH
  // =====================================================

  Future<void> _refresh() async {
    if (_kycId != null &&
        _kycId!.isNotEmpty) {
      await _loadKycDetails();
    } else {
      await _loadProviderKyc();
    }
  }

  // =====================================================
  // APPROVE KYC
  // =====================================================

  Future<void> _approveKyc(
    String kycId,
  ) async {
    final confirmed =
        await ApproveKycDialog.show(
      context: context,
    );

    if (confirmed != true) return;

    final success =
        await context
            .read<KycProvider>()
            .approveKyc(
              kycId: kycId,
              remarks:
                  'KYC approved by admin',
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'KYC approved successfully',
      );

      await _refresh();
    } else {
      _showError();
    }
  }

  // =====================================================
  // REJECT KYC
  // =====================================================

  Future<void> _rejectKyc(
    String kycId,
  ) async {
    final reasonController =
        TextEditingController();

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Reject KYC',
          ),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Please enter rejection reason.',
              ),

              const SizedBox(height: 16),

              TextField(
                controller:
                    reasonController,
                maxLines: 4,
                decoration:
                    const InputDecoration(
                  hintText:
                      'Rejection reason',
                  border:
                      OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                AppStrings.cancel,
              ),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.error,
              ),
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Reject',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      reasonController.dispose();
      return;
    }

    final reason =
        reasonController.text.trim();

    reasonController.dispose();

    if (reason.isEmpty) {
      NavigationService.showWarning(
        'Rejection reason is required',
      );
      return;
    }

    final success =
        await context
            .read<KycProvider>()
            .rejectKyc(
              kycId: kycId,
              reason: reason,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'KYC rejected successfully',
      );

      await _refresh();
    } else {
      _showError();
    }
  }

  // =====================================================
  // REQUEST RESUBMISSION
  // =====================================================

  Future<void> _requestResubmission(
    String kycId,
  ) async {
    final reasonController =
        TextEditingController();

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Request Resubmission',
          ),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Mention what needs to be corrected by the provider.',
              ),

              const SizedBox(height: 16),

              TextField(
                controller:
                    reasonController,
                maxLines: 4,
                decoration:
                    const InputDecoration(
                  hintText:
                      'Resubmission reason',
                  border:
                      OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                AppStrings.cancel,
              ),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.warning,
              ),
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Request',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      reasonController.dispose();
      return;
    }

    final reason =
        reasonController.text.trim();

    reasonController.dispose();

    if (reason.isEmpty) {
      NavigationService.showWarning(
        'Reason is required',
      );
      return;
    }

    final success =
        await context
            .read<KycProvider>()
            .requestResubmission(
              kycId: kycId,
              reason: reason,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Resubmission requested successfully',
      );

      await _refresh();
    } else {
      _showError();
    }
  }

  // =====================================================
  // VERIFY DOCUMENT
  // =====================================================

  Future<void> _verifyDocument({
    required String kycId,
    required String documentType,
  }) async {
    final success =
        await context
            .read<KycProvider>()
            .verifyDocument(
              kycId: kycId,
              documentType: documentType,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        '$documentType verified successfully',
      );

      await _refresh();
    } else {
      _showError();
    }
  }

  // =====================================================
  // ERROR
  // =====================================================

  void _showError() {
    final error =
        context.read<KycProvider>().errorMessage;

    NavigationService.showError(
      error ?? AppStrings.somethingWentWrong,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_providerId == null &&
        _provider == null &&
        _kycId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'KYC Approval',
          ),
        ),
        body: const Center(
          child: Text(
            'KYC data not found',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        title: const Text(
          'KYC Approval',
        ),
        actions: [
          IconButton(
            tooltip: AppStrings.refresh,
            onPressed: _refresh,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<KycProvider>(
          builder: (
            context,
            kycProvider,
            child,
          ) {
            if (kycProvider.isLoading) {
              return const FullScreenLoadingWidget(
                message:
                    'Loading KYC details...',
              );
            }

            final kyc =
                kycProvider.selectedKyc;

            if (kycProvider.errorMessage != null &&
                kyc == null) {
              return AppErrorWidget(
                message:
                    kycProvider.errorMessage!,
                onRetry: _refresh,
              );
            }

            if (kyc == null) {
              return const Center(
                child: Text(
                  'No KYC record found',
                ),
              );
            }

            final kycId =
                _readString(kyc, [
              'id',
              '_id',
              'kycId',
            ]);

            final status =
                _readString(
              kyc,
              [
                'status',
                'kycStatus',
              ],
              fallback: 'pending',
            );

            return RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(
                  AppDimensions.padding24,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    if (kycProvider
                            .errorMessage !=
                        null)
                      Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom:
                              AppDimensions.padding16,
                        ),
                        child: ErrorCard(
                          message: kycProvider
                              .errorMessage!,
                          onRetry: _refresh,
                        ),
                      ),

                    _buildHeaderCard(
                      kyc,
                      status,
                    ),

                    const SizedBox(
                      height:
                          AppDimensions.padding24,
                    ),

                    LayoutBuilder(
                      builder: (
                        context,
                        constraints,
                      ) {
                        final isMobile =
                            constraints.maxWidth <
                                900;

                        if (isMobile) {
                          return Column(
                            children: [
                              _buildProviderInfoCard(
                                kyc,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              _buildBusinessInfoCard(
                                kyc,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              _buildBankInfoCard(
                                kyc,
                              ),
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Expanded(
                              child:
                                  _buildProviderInfoCard(
                                kyc,
                              ),
                            ),

                            const SizedBox(
                              width: 16,
                            ),

                            Expanded(
                              child:
                                  _buildBusinessInfoCard(
                                kyc,
                              ),
                            ),

                            const SizedBox(
                              width: 16,
                            ),

                            Expanded(
                              child:
                                  _buildBankInfoCard(
                                kyc,
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(
                      height:
                          AppDimensions.padding24,
                    ),

                    _buildDocumentsSection(
                      kyc,
                      kycId,
                    ),

                    const SizedBox(
                      height:
                          AppDimensions.padding24,
                    ),

                    _buildActionsSection(
                      kycId: kycId,
                      status: status,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // =====================================================
  // HEADER CARD
  // =====================================================

  Widget _buildHeaderCard(
    dynamic kyc,
    String status,
  ) {
    final providerName =
        _provider?.displayName ??
            _readString(
              kyc,
              [
                'providerName',
                'name',
                'fullName',
              ],
              fallback: 'Provider',
            );

    final businessName =
        _provider?.businessName ??
            _readString(
              kyc,
              [
                'businessName',
                'companyName',
              ],
              fallback: '-',
            );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.radius16,
        ),
        side: const BorderSide(
          color: AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.padding24,
        ),
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final isMobile =
                constraints.maxWidth < 700;

            final info = Row(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor:
                      AppColors.primary
                          .withValues(alpha: 0.10),
                  child: Text(
                    AppFormatters.getInitials(
                      providerName,
                    ),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 18),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        providerName,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              fontWeight:
                                  FontWeight.w800,
                              color: AppColors
                                  .textPrimary,
                            ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        businessName,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors
                              .textSecondary,
                        ),
                      ),

                      const SizedBox(height: 10),

                      _StatusChip(
                        label: AppFormatters
                            .formatStatus(
                          status,
                        ),
                        color:
                            _statusColor(status),
                      ),
                    ],
                  ),
                ),
              ],
            );

            final submittedAt =
                _readDateTime(
              kyc,
              [
                'submittedAt',
                'createdAt',
                'updatedAt',
              ],
            );

            final dateWidget =
                _MiniInfoBox(
              title: 'Submitted',
              value:
                  AppFormatters.formatDate(
                submittedAt,
              ),
              icon: Icons.calendar_today_outlined,
              color: AppColors.info,
            );

            if (isMobile) {
              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  info,
                  const SizedBox(height: 18),
                  dateWidget,
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: info),
                const SizedBox(width: 20),
                dateWidget,
              ],
            );
          },
        ),
      ),
    );
  }

  // =====================================================
  // PROVIDER INFO CARD
  // =====================================================

  Widget _buildProviderInfoCard(
    dynamic kyc,
  ) {
    return _DetailsCard(
      title: 'Provider Information',
      icon: Icons.person_outline,
      children: [
        _InfoRow(
          label: 'Provider ID',
          value: _providerId ??
              _readString(
                kyc,
                [
                  'providerId',
                  'provider',
                ],
                fallback: '-',
              ),
        ),
        _InfoRow(
          label: 'Full Name',
          value: _provider?.fullName ??
              _readString(
                kyc,
                [
                  'fullName',
                  'providerName',
                  'name',
                ],
                fallback: '-',
              ),
        ),
        _InfoRow(
          label: 'Email',
          value: _provider?.email ??
              _readString(
                kyc,
                [
                  'email',
                  'providerEmail',
                ],
                fallback: '-',
              ),
        ),
        _InfoRow(
          label: 'Phone',
          value: AppFormatters.formatPhone(
            _provider?.phone ??
                _readString(
                  kyc,
                  [
                    'phone',
                    'providerPhone',
                  ],
                  fallback: '',
                ),
          ),
        ),
      ],
    );
  }

  // =====================================================
  // BUSINESS INFO CARD
  // =====================================================

  Widget _buildBusinessInfoCard(
    dynamic kyc,
  ) {
    return _DetailsCard(
      title: 'Business Information',
      icon: Icons.business_center_outlined,
      children: [
        _InfoRow(
          label: 'Business Name',
          value: _provider?.businessName ??
              _readString(
                kyc,
                [
                  'businessName',
                  'companyName',
                ],
                fallback: '-',
              ),
        ),
        _InfoRow(
          label: 'Category',
          value: _provider?.categoryName ??
              _readString(
                kyc,
                [
                  'categoryName',
                  'category',
                ],
                fallback: '-',
              ),
        ),
        _InfoRow(
          label: 'GST Number',
          value: _readString(
            kyc,
            [
              'gstNumber',
              'gst',
            ],
            fallback: '-',
          ),
        ),
        _InfoRow(
          label: 'PAN Number',
          value: _readString(
            kyc,
            [
              'panNumber',
              'pan',
            ],
            fallback: '-',
          ),
        ),
        _InfoRow(
          label: 'Address',
          value: _readString(
            kyc,
            [
              'businessAddress',
              'address',
            ],
            fallback: '-',
          ),
        ),
      ],
    );
  }

  // =====================================================
  // BANK INFO CARD
  // =====================================================

  Widget _buildBankInfoCard(
    dynamic kyc,
  ) {
    return _DetailsCard(
      title: 'Bank Information',
      icon: Icons.account_balance_outlined,
      children: [
        _InfoRow(
          label: 'Account Holder',
          value: _readString(
            kyc,
            [
              'accountHolderName',
              'bankAccountName',
            ],
            fallback: '-',
          ),
        ),
        _InfoRow(
          label: 'Bank Name',
          value: _readString(
            kyc,
            [
              'bankName',
            ],
            fallback: '-',
          ),
        ),
        _InfoRow(
          label: 'Account Number',
          value: _maskAccount(
            _readString(
              kyc,
              [
                'accountNumber',
                'bankAccountNumber',
              ],
              fallback: '',
            ),
          ),
        ),
        _InfoRow(
          label: 'IFSC',
          value: _readString(
            kyc,
            [
              'ifscCode',
              'ifsc',
            ],
            fallback: '-',
          ),
        ),
      ],
    );
  }

  // =====================================================
  // DOCUMENTS SECTION
  // =====================================================

  Widget _buildDocumentsSection(
    dynamic kyc,
    String kycId,
  ) {
    final documents =
        _readDocuments(kyc);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.radius16,
        ),
        side: const BorderSide(
          color: AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.padding20,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.description_outlined,
                  color: AppColors.primary,
                ),

                const SizedBox(width: 10),

                Text(
                  'Uploaded Documents',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            if (documents.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No documents uploaded',
                  ),
                ),
              )
            else
              LayoutBuilder(
                builder: (
                  context,
                  constraints,
                ) {
                  final isMobile =
                      constraints.maxWidth < 700;

                  if (isMobile) {
                    return Column(
                      children: documents
                          .map(
                            (doc) =>
                                Padding(
                              padding:
                                  const EdgeInsets.only(
                                bottom: 12,
                              ),
                              child:
                                  _DocumentCard(
                                document: doc,
                                onVerify: () {
                                  _verifyDocument(
                                    kycId: kycId,
                                    documentType:
                                        doc.type,
                                  );
                                },
                              ),
                            ),
                          )
                          .toList(),
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    itemCount:
                        documents.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      mainAxisExtent: 170,
                    ),
                    itemBuilder:
                        (_, index) {
                      return _DocumentCard(
                        document:
                            documents[index],
                        onVerify: () {
                          _verifyDocument(
                            kycId: kycId,
                            documentType:
                                documents[index]
                                    .type,
                          );
                        },
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // ACTIONS SECTION
  // =====================================================

  Widget _buildActionsSection({
    required String kycId,
    required String status,
  }) {
    final isFinal =
        status.toLowerCase() == 'approved' ||
            status.toLowerCase() == 'rejected';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.radius16,
        ),
        side: const BorderSide(
          color: AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.padding20,
        ),
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final isMobile =
                constraints.maxWidth < 800;

            final actions = [
              CustomButton(
                text: 'Approve KYC',
                type: ButtonType.success,
                icon:
                    Icons.check_circle_outline,
                isEnabled: !isFinal,
                onPressed: isFinal
                    ? null
                    : () {
                        _approveKyc(kycId);
                      },
              ),
              CustomButton(
                text: 'Reject KYC',
                type: ButtonType.danger,
                icon: Icons.cancel_outlined,
                isEnabled: !isFinal,
                onPressed: isFinal
                    ? null
                    : () {
                        _rejectKyc(kycId);
                      },
              ),
              CustomButton(
                text: 'Request Resubmission',
                type: ButtonType.warning,
                icon:
                    Icons.upload_file_outlined,
                isEnabled: !isFinal,
                onPressed: isFinal
                    ? null
                    : () {
                        _requestResubmission(
                          kycId,
                        );
                      },
              ),
            ];

            if (isMobile) {
              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _buildActionsHeader(),
                  const SizedBox(height: 16),
                  ...actions.map(
                    (action) => Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: action,
                      ),
                    ),
                  ),
                ],
              );
            }

            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _buildActionsHeader(),
                const SizedBox(height: 16),
                Row(
                  children: actions
                      .map(
                        (action) => Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets
                                    .only(
                              right: 12,
                            ),
                            child: action,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionsHeader() {
    return Row(
      children: [
        const Icon(
          Icons.admin_panel_settings_outlined,
          color: AppColors.primary,
        ),
        const SizedBox(width: 10),
        Text(
          'KYC Admin Actions',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  // =====================================================
  // DATA HELPERS
  // =====================================================

  static Map<String, dynamic> _toMap(
    dynamic item,
  ) {
    if (item is Map<String, dynamic>) {
      return item;
    }

    try {
      final json = item.toJson();

      if (json is Map<String, dynamic>) {
        return json;
      }
    } catch (_) {
      //
    }

    return {};
  }

  static String _readString(
    dynamic item,
    List<String> keys, {
    String fallback = '',
  }) {
    final map = _toMap(item);

    for (final key in keys) {
      final value = map[key];

      if (value != null &&
          value.toString().isNotEmpty) {
        return value.toString();
      }
    }

    return fallback;
  }

  static DateTime? _readDateTime(
    dynamic item,
    List<String> keys,
  ) {
    final map = _toMap(item);

    for (final key in keys) {
      final value = map[key];

      if (value is DateTime) {
        return value;
      }

      final parsed =
          DateTime.tryParse(
        value?.toString() ?? '',
      );

      if (parsed != null) {
        return parsed;
      }
    }

    return null;
  }

  static List<_KycDocument> _readDocuments(
    dynamic kyc,
  ) {
    final map = _toMap(kyc);

    final rawDocuments =
        map['documents'] ??
            map['kycDocuments'] ??
            map['uploadedDocuments'];

    if (rawDocuments is List) {
      return rawDocuments.map((item) {
        final doc = _toMap(item);

        return _KycDocument(
          type: _readString(
            doc,
            [
              'type',
              'documentType',
              'name',
            ],
            fallback: 'Document',
          ),
          url: _readString(
            doc,
            [
              'url',
              'fileUrl',
              'documentUrl',
            ],
          ),
          isVerified:
              doc['isVerified'] == true ||
                  doc['verified'] == true,
        );
      }).toList();
    }

    final documents = <_KycDocument>[];

    void addDoc(
      String type,
      List<String> keys,
    ) {
      final url =
          _readString(map, keys);

      if (url.isNotEmpty) {
        documents.add(
          _KycDocument(
            type: type,
            url: url,
            isVerified: false,
          ),
        );
      }
    }

    addDoc(
      'Aadhaar',
      [
        'aadhaarUrl',
        'aadhaarDocument',
        'aadhaarImage',
      ],
    );

    addDoc(
      'PAN',
      [
        'panUrl',
        'panDocument',
        'panImage',
      ],
    );

    addDoc(
      'GST',
      [
        'gstUrl',
        'gstDocument',
      ],
    );

    addDoc(
      'Bank Proof',
      [
        'bankProofUrl',
        'cancelledChequeUrl',
        'bankDocument',
      ],
    );

    return documents;
  }

  static String _maskAccount(
    String value,
  ) {
    if (value.isEmpty) {
      return '-';
    }

    if (value.length <= 4) {
      return value;
    }

    return 'XXXX XXXX ${value.substring(value.length - 4)}';
  }

  static Color _statusColor(
    String status,
  ) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.success;

      case 'rejected':
        return AppColors.error;

      case 'resubmission_required':
        return AppColors.warning;

      case 'under_review':
        return AppColors.info;

      case 'pending':
      default:
        return AppColors.warning;
    }
  }
}

// =====================================================
// DETAILS CARD
// =====================================================

class _DetailsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _DetailsCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.radius16,
        ),
        side: const BorderSide(
          color: AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.padding20,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            ...children,
          ],
        ),
      ),
    );
  }
}

// =====================================================
// INFO ROW
// =====================================================

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 9,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 135,
            child: Text(
              label,
              style: const TextStyle(
                color:
                    AppColors.textSecondary,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// DOCUMENT MODEL
// =====================================================

class _KycDocument {
  final String type;
  final String url;
  final bool isVerified;

  const _KycDocument({
    required this.type,
    required this.url,
    required this.isVerified,
  });
}

// =====================================================
// DOCUMENT CARD
// =====================================================

class _DocumentCard extends StatelessWidget {
  final _KycDocument document;
  final VoidCallback onVerify;

  const _DocumentCard({
    required this.document,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    final isImage =
        document.url.toLowerCase().endsWith('.png') ||
            document.url.toLowerCase().endsWith('.jpg') ||
            document.url.toLowerCase().endsWith('.jpeg') ||
            document.url.toLowerCase().endsWith('.webp');

    return Container(
      padding: const EdgeInsets.all(
        AppDimensions.padding12,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.border,
        ),
        borderRadius: BorderRadius.circular(
          AppDimensions.radius12,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isImage
                    ? Icons.image_outlined
                    : Icons.description_outlined,
                color: AppColors.primary,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  document.type,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),

              if (document.isVerified)
                const Icon(
                  Icons.verified_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
            ],
          ),

          const SizedBox(height: 12),

          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius:
                    BorderRadius.circular(
                  AppDimensions.radius8,
                ),
              ),
              child: isImage
                  ? ClipRRect(
                      borderRadius:
                          BorderRadius.circular(
                        AppDimensions.radius8,
                      ),
                      child: Image.network(
                        document.url,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return const Icon(
                            Icons.broken_image_outlined,
                            color: AppColors
                                .textSecondary,
                          );
                        },
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.picture_as_pdf_outlined,
                        color: AppColors.error,
                        size: 42,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: document.url.isEmpty
                      ? null
                      : () {
                          NavigationService.showInfo(
                            'Preview/download handler can be connected here.',
                          );
                        },
                  icon: const Icon(
                    Icons.open_in_new,
                    size: 16,
                  ),
                  label: const Text(
                    'View',
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      document.isVerified
                          ? null
                          : onVerify,
                  icon: const Icon(
                    Icons.verified_outlined,
                    size: 16,
                  ),
                  label: const Text(
                    'Verify',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =====================================================
// MINI INFO BOX
// =====================================================

class _MiniInfoBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniInfoBox({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 160,
      ),
      padding: const EdgeInsets.all(
        AppDimensions.padding14,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(
          AppDimensions.radius14,
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
          ),

          const SizedBox(width: 10),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight:
                      FontWeight.w700,
                  color:
                      AppColors.textPrimary,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  color:
                      AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =====================================================
// STATUS CHIP
// =====================================================

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius:
            BorderRadius.circular(30),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// =====================================================
// ROUTE GENERATOR COMPATIBILITY ALIAS
// =====================================================

class ProviderKycScreen extends StatelessWidget {
  const ProviderKycScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const KycApprovalScreen();
  }
}