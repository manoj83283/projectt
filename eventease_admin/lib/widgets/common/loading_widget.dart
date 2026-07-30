import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final double size;
  final double strokeWidth;
  final Color? color;

  const LoadingWidget({
    super.key,
    this.message,
    this.size = 40,
    this.strokeWidth = 3,
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
              strokeWidth: strokeWidth,
              valueColor:
                  AlwaysStoppedAnimation<Color>(
                color ?? AppColors.primary,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class FullScreenLoadingWidget
    extends StatelessWidget {
  final String message;

  const FullScreenLoadingWidget({
    super.key,
    this.message = 'Loading...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(
              AppDimensions.padding24,
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 50,
                  height: 50,
                  child:
                      CircularProgressIndicator(
                    color:
                        AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  message,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OverlayLoadingWidget
    extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const OverlayLoadingWidget({
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
          Positioned.fill(
            child: Container(
              color:
                  Colors.black.withOpacity(
                0.4,
              ),
              child: Center(
                child: Card(
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      AppDimensions.radius16,
                    ),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                      AppDimensions
                          .padding24,
                    ),
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        const SizedBox(
                          height: 45,
                          width: 45,
                          child:
                              CircularProgressIndicator(
                            color:
                                AppColors.primary,
                          ),
                        ),

                        if (message !=
                            null) ...[
                          const SizedBox(
                            height: 16,
                          ),
                          Text(
                            message!,
                            textAlign:
                                TextAlign
                                    .center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class TableLoadingWidget
    extends StatelessWidget {
  final String message;

  const TableLoadingWidget({
    super.key,
    this.message =
        'Loading data...',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Center(
        child: LoadingWidget(
          message: message,
        ),
      ),
    );
  }
}

class ButtonLoadingWidget
    extends StatelessWidget {
  final Color color;
  final double size;

  const ButtonLoadingWidget({
    super.key,
    this.color = Colors.white,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        color: color,
        strokeWidth: 2,
      ),
    );
  }
}