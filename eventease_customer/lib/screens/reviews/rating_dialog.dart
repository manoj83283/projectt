import 'package:flutter/material.dart';

class RatingDialog extends StatefulWidget {
  final String title;
  final String? serviceId;
  final double initialRating;
  final String initialReview;
  final Function(double rating, String review)? onSubmit;

  const RatingDialog({
    super.key,
    this.title = 'Rate Your Experience',
    this.serviceId,
    this.initialRating = 0,
    this.initialReview = '',
    this.onSubmit,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  late final TextEditingController _reviewController;

  late double _rating;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _rating = widget.initialRating.clamp(0, 5);
    _reviewController = TextEditingController(
      text: widget.initialReview,
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    FocusScope.of(context).unfocus();

    if (_rating <= 0) {
      _showSnackBar(
        message: 'Please select a rating',
        backgroundColor: Colors.orange,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String review = _reviewController.text.trim();

      await widget.onSubmit?.call(
        _rating,
        review,
      );

      if (!mounted) return;

      Navigator.pop(
        context,
        {
          'serviceId': widget.serviceId,
          'rating': _rating,
          'review': review,
        },
      );

      _showSnackBar(
        message: 'Review submitted successfully',
        backgroundColor: Colors.green,
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showSnackBar(
        message: error.toString(),
        backgroundColor: Colors.red,
      );
    }
  }

  void _showSnackBar({
    required String message,
    required Color backgroundColor,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Text(message),
      ),
    );
  }

  String _getRatingText() {
    switch (_rating.toInt()) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }

  Color _getRatingColor() {
    if (_rating <= 1) {
      return Colors.red;
    }

    if (_rating <= 2) {
      return Colors.deepOrange;
    }

    if (_rating <= 3) {
      return Colors.orange;
    }

    if (_rating <= 4) {
      return Colors.amber.shade700;
    }

    return Colors.green;
  }

  Widget _buildStar(int index) {
    final bool selected = _rating >= index;

    return IconButton(
      iconSize: 42,
      splashRadius: 28,
      tooltip: '$index star',
      onPressed: _isLoading
          ? null
          : () {
              setState(() {
                _rating = index.toDouble();
              });
            },
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: Icon(
          selected ? Icons.star : Icons.star_border,
          key: ValueKey<bool>(selected),
          color: Colors.orange,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 35,
          backgroundColor: Color(0xFFFFF3E0),
          child: Icon(
            Icons.star,
            color: Colors.orange,
            size: 40,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Rate Your Experience',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSelector() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (index) => _buildStar(index + 1),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _rating > 0
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _getRatingText(),
                    key: ValueKey<double>(_rating),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getRatingColor(),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildReviewField() {
    return TextField(
      controller: _reviewController,
      enabled: !_isLoading,
      maxLines: 5,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        labelText: 'Write Review',
        hintText: 'Share your experience...',
        alignLabelWithHint: true,
        prefixIcon: const Padding(
          padding: EdgeInsets.only(bottom: 82),
          child: Icon(Icons.rate_review_outlined),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isLoading
                ? null
                : () {
                    Navigator.pop(context);
                  },
            icon: const Icon(Icons.close),
            label: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _submitReview,
            icon: _isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_circle_outline),
            label: Text(
              _isLoading ? 'Submitting...' : 'Submit',
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 460,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildRatingSelector(),
                const SizedBox(height: 24),
                _buildReviewField(),
                const SizedBox(height: 24),
                _buildActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// BACKWARD COMPATIBILITY
// Old code using rating_dialog() will still work.
// ==========================================

class rating_dialog extends RatingDialog {
  const rating_dialog({
    super.key,
    super.title = 'Rate Your Experience',
    super.serviceId,
    super.initialRating = 0,
    super.initialReview = '',
    super.onSubmit,
  });
}