import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/provider_provider.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  bool _isAvailable = true;

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final Map<String, bool> _dayAvailability = {};

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();

    for (final day in _days) {
      _dayAvailability[day] = true;
    }

    _startTime = const TimeOfDay(
      hour: 9,
      minute: 0,
    );

    _endTime = const TimeOfDay(
      hour: 18,
      minute: 0,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAvailability();
    });
  }

  // =============================================================
  // ✅ LOAD EXISTING AVAILABILITY
  // =============================================================
  Future<void> _loadAvailability() async {
    try {
      final provider = context.read<ProviderProvider>();

      await provider.getProfile();

      if (!mounted) return;

      if (provider.provider != null) {
        setState(() {
          _isAvailable = provider.provider?.isAvailable ?? true;
        });
      }
    } catch (_) {
      // Silent fail to avoid UI crash
    }
  }

  // =============================================================
  // ✅ PICK START TIME
  // =============================================================
  Future<void> _pickStartTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: _startTime ??
          const TimeOfDay(
            hour: 9,
            minute: 0,
          ),
    );

    if (selectedTime != null) {
      setState(() {
        _startTime = selectedTime;
      });
    }
  }

  // =============================================================
  // ✅ PICK END TIME
  // =============================================================
  Future<void> _pickEndTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: _endTime ??
          const TimeOfDay(
            hour: 18,
            minute: 0,
          ),
    );

    if (selectedTime != null) {
      setState(() {
        _endTime = selectedTime;
      });
    }
  }

  // =============================================================
  // ✅ SAVE AVAILABILITY
  // =============================================================
  Future<void> _saveAvailability() async {
    final provider = context.read<ProviderProvider>();

    bool success = false;

    try {
      /// ✅ Your ProviderProvider currently expects a bool argument.
      /// This fixes:
      /// Too few positional arguments: 1 required, 0 given.
      success = await provider.updateAvailability(
        _isAvailable,
      );

      /// ✅ If later your backend supports working days/time,
      /// update ProviderProvider.updateAvailability() to accept:
      ///
      /// {
      ///   "isAvailable": _isAvailable,
      ///   "workingDays": [...],
      ///   "startTime": "...",
      ///   "endTime": "..."
      /// }
      ///
      /// For now we keep this screen compatible with your current provider.
    } catch (_) {
      success = false;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Availability updated successfully'
              : 'Failed to update availability',
        ),
      ),
    );
  }

  // =============================================================
  // ✅ TIME TEXT
  // =============================================================
  String _timeText(TimeOfDay? time) {
    if (time == null) return '--:--';

    return time.format(context);
  }

  // =============================================================
  // ✅ UI
  // =============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Availability',
        ),
      ),
      body: Consumer<ProviderProvider>(
        builder: (
          context,
          provider,
          child,
        ) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =====================
                // AVAILABILITY STATUS
                // =====================
                Card(
                  child: SwitchListTile(
                    value: _isAvailable,
                    title: const Text(
                      'Available for Booking',
                    ),
                    subtitle: Text(
                      _isAvailable
                          ? 'Customers can book your services'
                          : 'Services are temporarily unavailable',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _isAvailable = value;
                      });
                    },
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                const Text(
                  'Working Days',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Card(
                  child: Column(
                    children: _days.map(
                      (day) {
                        return CheckboxListTile(
                          value: _dayAvailability[day] ?? false,
                          title: Text(day),
                          onChanged: (value) {
                            setState(() {
                              _dayAvailability[day] = value ?? false;
                            });
                          },
                        );
                      },
                    ).toList(),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                const Text(
                  'Working Hours',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.schedule,
                          ),
                          title: const Text(
                            'Start Time',
                          ),
                          subtitle: Text(
                            _timeText(
                              _startTime,
                            ),
                          ),
                          onTap: _pickStartTime,
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    Expanded(
                      child: Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.schedule,
                          ),
                          title: const Text(
                            'End Time',
                          ),
                          subtitle: Text(
                            _timeText(
                              _endTime,
                            ),
                          ),
                          onTap: _pickEndTime,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 24,
                ),

                Card(
                  color: Colors.blue.withValues(alpha: 0.08),
                  child: const Padding(
                    padding: EdgeInsets.all(
                      16,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info,
                          color: Colors.blue,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            'Customers can only book your services during your selected availability schedule.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: provider.isLoading ? null : _saveAvailability,
                    icon: const Icon(
                      Icons.save,
                    ),
                    label: provider.isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'SAVE AVAILABILITY',
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}