import 'package:flutter/material.dart';

class AppErrorWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String buttonText;
  final VoidCallback? onRetry;

  const AppErrorWidget({
    super.key,
    this.title = 'Something Went Wrong',
    this.message =
        'Unable to load data. Please try again.',
    this.icon = Icons.error_outline,
    this.buttonText = 'Retry',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 90,
              color: Colors.red,
            ),

            const SizedBox(height: 20),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),

            if (onRetry != null) ...[
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(
                  Icons.refresh,
                ),
                label: Text(buttonText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Network Error Widget
class NetworkErrorWidget
    extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      icon: Icons.wifi_off,
      title: 'No Internet Connection',
      message:
          'Please check your network connection and try again.',
      onRetry: onRetry,
    );
  }
}

/// Server Error Widget
class ServerErrorWidget
    extends StatelessWidget {
  final VoidCallback? onRetry;

  const ServerErrorWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      icon: Icons.cloud_off,
      title: 'Server Error',
      message:
          'Server is temporarily unavailable. Please try again later.',
      onRetry: onRetry,
    );
  }
}

/// Data Not Found Widget
class DataNotFoundWidget
    extends StatelessWidget {
  final VoidCallback? onRetry;

  const DataNotFoundWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      icon: Icons.search_off,
      title: 'No Data Found',
      message:
          'The requested information could not be found.',
      onRetry: onRetry,
    );
  }
}

/// Unauthorized Widget
class UnauthorizedWidget
    extends StatelessWidget {
  final VoidCallback? onLogin;

  const UnauthorizedWidget({
    super.key,
    this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      icon: Icons.lock_outline,
      title: 'Unauthorized Access',
      message:
          'Please login to continue.',
      buttonText: 'Login',
      onRetry: onLogin,
    );
  }
}

/// Full Screen Error
class FullScreenErrorWidget
    extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const FullScreenErrorWidget({
    super.key,
    this.title =
        'Something Went Wrong',
    this.message =
        'An unexpected error occurred.',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppErrorWidget(
        title: title,
        message: message,
        onRetry: onRetry,
      ),
    );
  }
}