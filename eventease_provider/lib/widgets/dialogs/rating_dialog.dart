import 'package:flutter/material.dart';

class RatingDialog extends StatefulWidget {
  final String title;
  final String? subtitle;

  final double initialRating;

  final String? initialReview;

  final String submitButtonText;
  final String cancelButtonText;

  final Future<void> Function(
    double rating,
    String review,
  ) onSubmit;

  const RatingDialog({
    super.key,
    required this.onSubmit,
    this.title = 'Rate Your Experience',
    this.subtitle,
    this.initialRating = 0,
    this.initialReview,
    this.submitButtonText = 'Submit',
    this.cancelButtonText = 'Cancel',
  });

  static Future<void> show(
    BuildContext context, {
    required Future<void> Function(
      double rating,
      String review,
    )
        onSubmit,
    String title = 'Rate Your Experience',
    String? subtitle,
    double initialRating = 0,
    String? initialReview,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => RatingDialog(
        title: title,
        subtitle: subtitle,
        initialRating: initialRating,
        initialReview: initialReview,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<RatingDialog> createState() =>
      _RatingDialogState();
}

class _RatingDialogState
    extends State<RatingDialog> {
  late double _rating;

  late TextEditingController
      _reviewController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    _rating = widget.initialRating;

    _reviewController =
        TextEditingController(
      text: widget.initialReview ?? '',
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a rating',
          ),
        ),
      );
      return;
    }

    try {
      setState(() {
        _isSubmitting = true;
      });

      await widget.onSubmit(
        _rating,
        _reviewController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String get _ratingText {
    if (_rating <= 1) {
      return 'Poor';
    }

    if (_rating <= 2) {
      return 'Fair';
    }

    if (_rating <= 3) {
      return 'Good';
    }

    if (_rating <= 4) {
      return 'Very Good';
    }

    return 'Excellent';
  }

  Color get _ratingColor {
    if (_rating <= 2) {
      return Colors.red;
    }

    if (_rating <= 3) {
      return Colors.orange;
    }

    if (_rating <= 4) {
      return Colors.blue;
    }

    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            if (widget.subtitle != null) ...[
              Text(
                widget.subtitle!,
                textAlign:
                    TextAlign.center,
              ),
              const SizedBox(
                height: 20,
              ),
            ],

            // =========================
            // RATING VALUE
            // =========================

            Text(
              _rating == 0
                  ? 'Select Rating'
                  : _ratingText,
              style: TextStyle(
                color: _ratingColor,
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // =========================
            // STARS
            // =========================

            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .center,
              children: List.generate(
                5,
                (index) {
                  final star =
                      index + 1;

                  return IconButton(
                    iconSize: 40,
                    onPressed: () {
                      setState(() {
                        _rating =
                            star.toDouble();
                      });
                    },
                    icon: Icon(
                      star <= _rating
                          ? Icons.star
                          : Icons
                              .star_border,
                      color:
                          Colors.amber,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // REVIEW TEXT
            // =========================

            TextFormField(
              controller:
                  _reviewController,
              maxLines: 4,
              maxLength: 500,
              decoration:
                  InputDecoration(
                labelText:
                    'Review (Optional)',
                hintText:
                    'Write your feedback...',
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () {
                  Navigator.pop(
                    context,
                  );
                },
          child: Text(
            widget.cancelButtonText,
          ),
        ),

        ElevatedButton(
          onPressed: _isSubmitting
              ? null
              : _handleSubmit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  widget
                      .submitButtonText,
                ),
        ),
      ],
    );
  }
}