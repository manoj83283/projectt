import Review from "../models/Review.js"; //  updated model
import Service from "../models/service.js";

export const addReview = async (req, res) => {
  try {
    const { bookingId, serviceId, rating, review, comment } = req.body;

    /// ✅ VALIDATION (PRESERVED + EXTENDED)
    if (!serviceId || !rating) {
      return res.status(400).json({
        message: "Service ID and rating required",
      });
    }

    ///  PREVENT DUPLICATE REVIEW (NEW)
    if (bookingId) {
      const exists = await Review.findOne({ bookingId });

      if (exists) {
        return res.status(400).json({
          message: "Already reviewed",
        });
      }
    }

    ///  CREATE REVIEW (MERGED STRUCTURE)
    const newReview = await Review.create({
      //  OLD STRUCTURE (PRESERVED)
      service: serviceId,
      user: req.user.id,
      rating,
      comment: comment || review || "",

      //  NEW STRUCTURE
      bookingId,
      serviceId,
      userId: req.user._id,
      review: review || comment || "",
    });

    ///  UPDATE SERVICE RATING (PRESERVED )
    const reviews = await Review.find({ service: serviceId });

    const avgRating =
      reviews.reduce((acc, r) => acc + (r.rating || 0), 0) /
      (reviews.length || 1);

    await Service.findByIdAndUpdate(serviceId, {
      rating: avgRating,
      reviewCount: reviews.length,
    });

    res.json({
      message: " Review added",
      review: newReview,
    });

  } catch (err) {
    console.error("❌ Add Review Error:", err);

    res.status(500).json({
      message: "Failed to add review",
      error: err.message,
    });
  }
};