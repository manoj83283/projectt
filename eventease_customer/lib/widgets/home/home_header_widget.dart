import 'package:flutter/material.dart';

class HomeHeaderWidget extends StatelessWidget {
  final String userName;
  final String location;
  final String? profileImage;

  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onCartTap;
  final VoidCallback? onLocationTap;
  final ValueChanged<String>? onSearch;

  const HomeHeaderWidget({
    super.key,
    required this.userName,
    required this.location,
    this.profileImage,
    this.onProfileTap,
    this.onNotificationTap,
    this.onCartTap,
    this.onLocationTap,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        50,
        16,
        20,
      ),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // =========================
          // TOP SECTION
          // =========================

          Row(
            children: [
              GestureDetector(
                onTap: onProfileTap,
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor:
                      Colors.white,
                  backgroundImage:
                      profileImage != null &&
                              profileImage!
                                  .isNotEmpty
                          ? NetworkImage(
                              profileImage!,
                            )
                          : null,
                  child: profileImage ==
                          null
                      ? const Icon(
                          Icons.person,
                          size: 28,
                        )
                      : null,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello 👋",
                      style: TextStyle(
                        color:
                            Colors.white70,
                        fontSize: 14,
                      ),
                    ),

                    Text(
                      userName,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        color:
                            Colors.white,
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed:
                    onNotificationTap,
                icon: const Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                ),
              ),

              IconButton(
                onPressed: onCartTap,
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // =========================
          // LOCATION
          // =========================

          InkWell(
            onTap: onLocationTap,
            borderRadius:
                BorderRadius.circular(12),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white
                    .withOpacity(0.15),
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 20,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      location,
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ),

                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // =========================
          // SEARCH BAR
          // =========================

          Container(
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),
            child: TextField(
              onChanged: onSearch,
              decoration:
                  const InputDecoration(
                hintText:
                    "Search services, venues, photography...",
                prefixIcon:
                    Icon(Icons.search),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}