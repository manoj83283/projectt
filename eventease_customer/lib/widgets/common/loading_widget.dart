import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String message;
  final double size;
  final Color? color;

  const LoadingWidget({
    super.key,
    this.message = "Loading...",
    this.size = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                        .primaryColor,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full Screen Loader
class FullScreenLoader
    extends StatelessWidget {
  final String message;

  const FullScreenLoader({
    super.key,
    this.message = "Please wait...",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LoadingWidget(
        message: message,
        size: 50,
      ),
    );
  }
}

/// Overlay Loader
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message = "Loading...",
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,

        if (isLoading)
          Container(
            color: Colors.black.withOpacity(
              0.4,
            ),
            child: Center(
              child: Card(
                elevation: 8,
                child: Padding(
                  padding:
                      const EdgeInsets.all(24),
                  child: LoadingWidget(
                    message: message,
                    size: 45,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}