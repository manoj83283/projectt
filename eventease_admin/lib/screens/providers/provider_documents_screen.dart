import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../models/provider_model.dart';
import '../../providers/kyc_provider.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/loading_widget.dart';

class ProviderDocumentsScreen extends StatefulWidget {
  const ProviderDocumentsScreen({
    super.key,
  });

  @override
  State<ProviderDocumentsScreen> createState() =>
      _ProviderDocumentsScreenState();
}

class _ProviderDocumentsScreenState
    extends State<ProviderDocumentsScreen> {
  ProviderModel? _provider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments;

    if (args is ProviderModel) {
      _provider = args;

      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          _loadDocuments();
        },
      );
    }
  }

  Future<void> _loadDocuments() async {
    if (_provider == null) return;

    await context
        .read<KycProvider>()
        .getProviderKyc(
          _provider!.id,
        );
  }

  Future<void> _refresh() async {
    await _loadDocuments();
  }

  @override
  Widget build(BuildContext context) {
    if (_provider == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Provider Documents',
          ),
        ),
        body: const Center(
          child: Text(
            'Provider not found',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Provider Documents',
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            onPressed: _refresh,
          ),
        ],
      ),
      body: Consumer<KycProvider>(
        builder: (
          context,
          provider,
          child,
        ) {
          if (provider.isLoading) {
            return const FullScreenLoadingWidget(
              message:
                  'Loading documents...',
            );
          }

          if (provider.errorMessage != null) {
            return AppErrorWidget(
              message:
                  provider.errorMessage!,
              onRetry: _refresh,
            );
          }

          final kyc =
              provider.selectedKyc;

          if (kyc == null) {
            return const Center(
              child: Text(
                'No documents available',
              ),
            );
          }

          final documents =
              _extractDocuments(
            kyc,
          );

          return RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(
                AppDimensions.padding24,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _buildProviderInfo(),

                  const SizedBox(height: 24),

                  Text(
                    'Documents',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                          fontWeight:
                              FontWeight.w700,
                        ),
                  ),

                  const SizedBox(height: 16),

                  documents.isEmpty
                      ? const Center(
                          child: Padding(
                            padding:
                                EdgeInsets.all(
                              40,
                            ),
                            child: Text(
                              'No documents uploaded',
                            ),
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          itemCount:
                              documents.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            mainAxisExtent: 260,
                          ),
                          itemBuilder:
                              (context, index) {
                            return _DocumentCard(
                              document:
                                  documents[index],
                            );
                          },
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProviderInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(
          20,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor:
                  AppColors.primary
                      .withValues(alpha: 0.1),
              child: Text(
                AppFormatters.getInitials(
                  _provider!.displayName,
                ),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    _provider!.displayName,
                    style:
                        const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    _provider!.businessName,
                    style:
                        const TextStyle(
                      color: AppColors
                          .textSecondary,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    _provider!.email,
                    style:
                        const TextStyle(
                      color: AppColors
                          .textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DocumentItem>
      _extractDocuments(
    dynamic kyc,
  ) {
    final docs = <DocumentItem>[];

    final map =
        kyc is Map<String, dynamic>
            ? kyc
            : {};

    void addDoc(
      String title,
      String key,
    ) {
      final url = map[key];

      if (url != null &&
          url.toString().isNotEmpty) {
        docs.add(
          DocumentItem(
            title: title,
            url: url.toString(),
          ),
        );
      }
    }

    addDoc(
      'Aadhaar Card',
      'aadhaarUrl',
    );

    addDoc(
      'PAN Card',
      'panUrl',
    );

    addDoc(
      'GST Document',
      'gstUrl',
    );

    addDoc(
      'Bank Proof',
      'bankProofUrl',
    );

    addDoc(
      'Business License',
      'businessLicenseUrl',
    );

    return docs;
  }
}

class DocumentItem {
  final String title;
  final String url;

  const DocumentItem({
    required this.title,
    required this.url,
  });
}

class _DocumentCard
    extends StatelessWidget {
  final DocumentItem document;

  const _DocumentCard({
    required this.document,
  });

  bool get isImage {
    return document.url
            .toLowerCase()
            .endsWith('.jpg') ||
        document.url
            .toLowerCase()
            .endsWith('.jpeg') ||
        document.url
            .toLowerCase()
            .endsWith('.png') ||
        document.url
            .toLowerCase()
            .endsWith('.webp');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          AppDimensions.radius16,
        ),
        side: const BorderSide(
          color: AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          12,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  isImage
                      ? Icons.image_outlined
                      : Icons.picture_as_pdf,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    document.title,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration:
                    BoxDecoration(
                  color:
                      AppColors.background,
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
                child: isImage
                    ? ClipRRect(
                        borderRadius:
                            BorderRadius.circular(
                          10,
                        ),
                        child:
                            Image.network(
                          document.url,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return const Center(
                              child: Icon(
                                Icons
                                    .broken_image_outlined,
                              ),
                            );
                          },
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons
                              .picture_as_pdf,
                          color:
                              AppColors.error,
                          size: 60,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  NavigationService.showInfo(
                    'Connect file preview/download handler here.',
                  );
                },
                icon: const Icon(
                  Icons.open_in_new,
                ),
                label: const Text(
                  'View Document',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}