import 'package:flutter/material.dart';

import '../../config/theme_config.dart';

// =====================================================
// NEGOTIATION TOPICS
// =====================================================

enum NegotiationTopic {
  general,
  price,
  dateTime,
  location,
  requirements,
  other,
}

// =====================================================
// NEGOTIATION STARTER MESSAGE
// =====================================================

String negotiationStarterMessage(
  NegotiationTopic topic,
) {
  switch (topic) {
    case NegotiationTopic.price:
      return 'Hi, I would like to discuss the price for this service.';

    case NegotiationTopic.dateTime:
      return 'Hi, I would like to discuss a different date or time.';

    case NegotiationTopic.location:
      return 'Hi, I would like to discuss a different service location.';

    case NegotiationTopic.requirements:
      return 'Hi, I would like to discuss my service requirements.';

    case NegotiationTopic.other:
      return 'Hi, I have a question about this service.';

    case NegotiationTopic.general:
      return 'Hi, I would like to discuss this service.';
  }
}

// =====================================================
// NEGOTIATION TOPIC LABEL
// =====================================================

String negotiationTopicLabel(
  NegotiationTopic topic,
) {
  switch (topic) {
    case NegotiationTopic.general:
      return 'Just Chat';

    case NegotiationTopic.price:
      return 'Discuss Price';

    case NegotiationTopic.dateTime:
      return 'Change Date / Time';

    case NegotiationTopic.location:
      return 'Change Location';

    case NegotiationTopic.requirements:
      return 'Discuss Requirements';

    case NegotiationTopic.other:
      return 'Something Else';
  }
}

// =====================================================
// NEGOTIATION TOPIC VALUE
// =====================================================

String negotiationTopicValue(
  NegotiationTopic topic,
) {
  switch (topic) {
    case NegotiationTopic.general:
      return 'general';

    case NegotiationTopic.price:
      return 'price';

    case NegotiationTopic.dateTime:
      return 'date_time';

    case NegotiationTopic.location:
      return 'location';

    case NegotiationTopic.requirements:
      return 'requirements';

    case NegotiationTopic.other:
      return 'other';
  }
}

// =====================================================
// NEGOTIATION TOPIC FROM VALUE
// =====================================================

NegotiationTopic negotiationTopicFromValue(
  String? value,
) {
  final normalized =
      value
          ?.trim()
          .toLowerCase()
          .replaceAll('-', '_')
          .replaceAll(' ', '_') ??
      '';

  switch (normalized) {
    case 'price':
    case 'discuss_price':
      return NegotiationTopic.price;

    case 'date_time':
    case 'datetime':
    case 'date':
    case 'time':
    case 'change_date_time':
      return NegotiationTopic.dateTime;

    case 'location':
    case 'change_location':
      return NegotiationTopic.location;

    case 'requirements':
    case 'requirement':
    case 'discuss_requirements':
      return NegotiationTopic.requirements;

    case 'other':
    case 'something_else':
      return NegotiationTopic.other;

    case 'general':
    case 'chat':
    case 'just_chat':
    default:
      return NegotiationTopic.general;
  }
}

// =====================================================
// NEGOTIATION TOPIC ICON
// =====================================================

IconData negotiationTopicIcon(
  NegotiationTopic topic,
) {
  switch (topic) {
    case NegotiationTopic.general:
      return Icons.chat_bubble_outline;

    case NegotiationTopic.price:
      return Icons.currency_rupee;

    case NegotiationTopic.dateTime:
      return Icons.schedule_outlined;

    case NegotiationTopic.location:
      return Icons.location_on_outlined;

    case NegotiationTopic.requirements:
      return Icons.checklist_outlined;

    case NegotiationTopic.other:
      return Icons.more_horiz;
  }
}

// =====================================================
// NEGOTIATION TOPIC DESCRIPTION
// =====================================================

String negotiationTopicDescription(
  NegotiationTopic topic,
) {
  switch (topic) {
    case NegotiationTopic.general:
      return 'Start a general conversation with the Provider.';

    case NegotiationTopic.price:
      return 'Discuss the service price, package, or budget.';

    case NegotiationTopic.dateTime:
      return 'Discuss another available date or time.';

    case NegotiationTopic.location:
      return 'Discuss a different service or event location.';

    case NegotiationTopic.requirements:
      return 'Discuss customization or specific service requirements.';

    case NegotiationTopic.other:
      return 'Ask another question about the service.';
  }
}

// =====================================================
// NEGOTIATION MENU
// =====================================================

class NegotiationMenu extends StatelessWidget {
  const NegotiationMenu({
    super.key,
    this.serviceName = '',
    this.providerName = '',
  });

  final String serviceName;
  final String providerName;

  // =====================================================
  // SHOW MENU
  // =====================================================

  static Future<NegotiationTopic?> show(
    BuildContext context, {
    String serviceName = '',
    String providerName = '',
  }) {
    return showModalBottomSheet<NegotiationTopic>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (
        BuildContext context,
      ) {
        return NegotiationMenu(
          serviceName: serviceName,
          providerName: providerName,
        );
      },
    );
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final normalizedServiceName =
        serviceName.trim();

    final normalizedProviderName =
        providerName.trim();

    return SafeArea(
      child: Padding(
        padding:
            const EdgeInsets.fromLTRB(
          16,
          4,
          16,
          20,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      ThemeConfig.primaryColor,
                  child: Icon(
                    Icons.chat_outlined,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Text(
                    'Chat with Provider',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            if (normalizedServiceName.isNotEmpty ||
                normalizedProviderName.isNotEmpty) ...[
              const SizedBox(
                height: 12,
              ),
              Text(
                _buildSubtitle(
                  serviceName:
                      normalizedServiceName,
                  providerName:
                      normalizedProviderName,
                ),
                style: TextStyle(
                  color:
                      Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ],

            const SizedBox(
              height: 12,
            ),

            Text(
              'What would you like to discuss?',
              style: TextStyle(
                color:
                    Colors.grey.shade700,
                fontWeight:
                    FontWeight.w500,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            _NegotiationOption(
              topic:
                  NegotiationTopic.general,
            ),

            _NegotiationOption(
              topic:
                  NegotiationTopic.price,
            ),

            _NegotiationOption(
              topic:
                  NegotiationTopic.dateTime,
            ),

            _NegotiationOption(
              topic:
                  NegotiationTopic.location,
            ),

            _NegotiationOption(
              topic:
                  NegotiationTopic.requirements,
            ),

            _NegotiationOption(
              topic:
                  NegotiationTopic.other,
            ),

            const SizedBox(
              height: 8,
            ),

            Container(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets.all(
                12,
              ),
              decoration:
                  BoxDecoration(
                color:
                    Colors.blueGrey
                        .withValues(
                  alpha: 0.06,
                ),
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child: const Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 19,
                    color:
                        Colors.blueGrey,
                  ),
                  SizedBox(
                    width: 9,
                  ),
                  Expanded(
                    child: Text(
                      'This is a pre-booking negotiation chat. Booking chat and phone access follow the booking lifecycle after you confirm the service.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color:
                            Colors.blueGrey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _buildSubtitle({
    required String serviceName,
    required String providerName,
  }) {
    if (serviceName.isNotEmpty &&
        providerName.isNotEmpty) {
      return '$serviceName • $providerName';
    }

    if (serviceName.isNotEmpty) {
      return serviceName;
    }

    return providerName;
  }
}

// =====================================================
// NEGOTIATION OPTION
// =====================================================

class _NegotiationOption
    extends StatelessWidget {
  const _NegotiationOption({
    required this.topic,
  });

  final NegotiationTopic topic;

  @override
  Widget build(
    BuildContext context,
  ) {
    return ListTile(
      contentPadding:
          EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor:
            ThemeConfig.primaryColor
                .withValues(
          alpha: 0.10,
        ),
        child: Icon(
          negotiationTopicIcon(
            topic,
          ),
          size: 21,
          color:
              ThemeConfig.primaryColor,
        ),
      ),
      title: Text(
        negotiationTopicLabel(
          topic,
        ),
        style:
            const TextStyle(
          fontWeight:
              FontWeight.w600,
        ),
      ),
      subtitle: Text(
        negotiationTopicDescription(
          topic,
        ),
      ),
      trailing:
          const Icon(
        Icons.chevron_right,
      ),
      onTap: () {
        Navigator.of(
          context,
        ).pop(
          topic,
        );
      },
    );
  }
}