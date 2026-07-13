import 'package:flutter/material.dart';

class RatingDialog extends StatefulWidget {
  final String title;
  final String? serviceId;
  final Function(double rating, String review)?
      onSubmit;

  const RatingDialog({
    super.key,
    required this.title,
    this.serviceId,
    this.onSubmit,
  });

  @override
  State<RatingDialog> createState() =>
      _RatingDialogState();
}

class _RatingDialogState
    extends State<RatingDialog> {
  final TextEditingController reviewController =
      TextEditingController();

  double rating = 0;
  bool isLoading = false;

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  Future<void> submitReview() async {
    if (rating == 0) {
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

    setState(() {
      isLoading = true;
    });

    try {
      await Future.delayed(
        const Duration(seconds: 1),
      );

      widget.onSubmit?.call(
        rating,
        reviewController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pop(
        context,
        {
          "rating": rating,
          "review":
              reviewController.text.trim(),
        },
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Review submitted successfully',
          ),
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  String getRatingText() {
    if (rating == 1) {
      return "Poor";
    } else if (rating == 2) {
      return "Fair";
    } else if (rating == 3) {
      return "Good";
    } else if (rating == 4) {
      return "Very Good";
    } else if (rating == 5) {
      return "Excellent";
    }

    return "";
  }

  Widget buildStar(int index) {
    return IconButton(
      iconSize: 42,
      onPressed: () {
        setState(() {
          rating = index.toDouble();
        });
      },
      icon: Icon(
        rating >= index
            ? Icons.star
            : Icons.star_border,
        color: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 35,
                backgroundColor:
                    Color(0xFFFFF3E0),
                child: Icon(
                  Icons.star,
                  color: Colors.orange,
                  size: 40,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "Rate Your Experience",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  buildStar(1),
                  buildStar(2),
                  buildStar(3),
                  buildStar(4),
                  buildStar(5),
                ],
              ),

              if (rating > 0) ...[
                const SizedBox(height: 8),
                Text(
                  getRatingText(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              TextField(
                controller:
                    reviewController,
                maxLines: 5,
                decoration:
                    InputDecoration(
                  labelText:
                      "Write Review",
                  hintText:
                      "Share your experience...",
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          isLoading
                              ? null
                              : () {
                                  Navigator.pop(
                                    context,
                                  );
                                },
                      child:
                          const Text(
                        "Cancel",
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          isLoading
                              ? null
                              : submitReview,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color:
                                    Colors.white,
                              ),
                            )
                          : const Text(
                              "Submit",
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}