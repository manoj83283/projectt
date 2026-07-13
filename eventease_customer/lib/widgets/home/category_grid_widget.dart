import 'package:flutter/material.dart';

import '../services/category_card.dart';

class CategoryItem {
  final String id;
  final String title;
  final String? imageUrl;
  final IconData icon;
  final int serviceCount;
  final Color color;

  const CategoryItem({
    required this.id,
    required this.title,
    required this.icon,
    this.imageUrl,
    this.serviceCount = 0,
    this.color = Colors.blue,
  });
}

class CategoryGridWidget extends StatelessWidget {
  final List<CategoryItem> categories;
  final Function(CategoryItem)? onCategoryTap;

  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const CategoryGridWidget({
    super.key,
    required this.categories,
    this.onCategoryTap,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = 12,
    this.mainAxisSpacing = 12,
    this.shrinkWrap = true,
    this.physics =
        const NeverScrollableScrollPhysics(),
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Center(
        child: Text(
          "No Categories Available",
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: categories.length,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing:
            crossAxisSpacing,
        mainAxisSpacing:
            mainAxisSpacing,
        childAspectRatio:
            childAspectRatio,
      ),
      itemBuilder: (context, index) {
        final category =
            categories[index];

        return CategoryCard(
          id: category.id,
          title: category.title,
          icon: category.icon,
          imageUrl: category.imageUrl,
          serviceCount:
              category.serviceCount,
          color: category.color,
          onTap: () {
            onCategoryTap?.call(
              category,
            );
          },
        );
      },
    );
  }
}