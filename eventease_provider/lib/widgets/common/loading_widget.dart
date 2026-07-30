import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const LoadingWidget({
    super.key,
    this.message,
    this.size = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: color ??
                  Theme.of(context)
                      .colorScheme
                      .primary,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

// =====================================================
// FULL SCREEN LOADING
// =====================================================

class FullScreenLoading extends StatelessWidget {
  final String? message;

  const FullScreenLoading({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingWidget(
        message:
            message ?? 'Please wait...',
      ),
    );
  }
}

// =====================================================
// OVERLAY LOADING
// =====================================================

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,

        if (isLoading)
          Container(
            color: Colors.black45,
            child: Center(
              child: Container(
                width: 180,
                padding:
                    const EdgeInsets.all(
                  20,
                ),
                decoration:
                    BoxDecoration(
                  color: Theme.of(context)
                      .cardColor,
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),

                    const SizedBox(
                      height: 16,
                    ),

                    Text(
                      message ??
                          'Loading...',
                      textAlign:
                          TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// =====================================================
// SHIMMER PLACEHOLDER
// =====================================================

class LoadingCard extends StatelessWidget {
  final double height;

  const LoadingCard({
    super.key,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin:
          const EdgeInsets.symmetric(
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius:
            BorderRadius.circular(12),
      ),
    );
  }
}

// =====================================================
// LIST LOADER
// =====================================================

class LoadingList extends StatelessWidget {
  final int itemCount;

  const LoadingList({
    super.key,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const LoadingCard();
      },
    );
  }
}