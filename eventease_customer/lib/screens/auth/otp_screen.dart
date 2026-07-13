import 'dart:async';

import 'package:flutter/material.dart';

import '../../config/route_config.dart';
import '../../config/theme_config.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() =>
      _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController>
      otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  bool isLoading = false;

  int secondsRemaining = 60;

  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    secondsRemaining = 60;

    timer?.cancel();

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (secondsRemaining == 0) {
          timer.cancel();
        } else {
          setState(() {
            secondsRemaining--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();

    for (final controller
        in otpControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  String get otpCode =>
      otpControllers
          .map((e) => e.text)
          .join();

  Future<void> verifyOtp() async {
    if (otpCode.length != 6) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter valid OTP',
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
        const Duration(seconds: 2),
      );

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteConfig.home,
        (route) => false,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void resendOtp() {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'OTP sent successfully',
        ),
      ),
    );

    startTimer();
  }

  Widget buildOtpField(int index) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller:
            otpControllers[index],
        keyboardType:
            TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        decoration:
            const InputDecoration(
          counterText: '',
        ),
        onChanged: (value) {
          if (value.isNotEmpty &&
              index < 5) {
            FocusScope.of(context)
                .nextFocus();
          }

          if (value.isEmpty &&
              index > 0) {
            FocusScope.of(context)
                .previousFocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'OTP Verification',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 30),

              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: ThemeConfig
                      .primaryColor
                      .withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(
                    24,
                  ),
                ),
                child: const Icon(
                  Icons.sms_outlined,
                  color: ThemeConfig
                      .primaryColor,
                  size: 60,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Verification Code',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Enter the 6 digit OTP sent to your registered mobile number or email.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  color:
                      Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceEvenly,
                children: List.generate(
                  6,
                  (index) =>
                      buildOtpField(
                    index,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed:
                      isLoading
                          ? null
                          : verifyOtp,
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2,
                            color:
                                Colors.white,
                          ),
                        )
                      : const Text(
                          'Verify OTP',
                        ),
                ),
              ),

              const SizedBox(height: 25),

              Text(
                secondsRemaining > 0
                    ? 'Resend OTP in ${secondsRemaining}s'
                    : 'Did not receive the OTP?',
                style: TextStyle(
                  color:
                      Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed:
                    secondsRemaining == 0
                        ? resendOtp
                        : null,
                child: const Text(
                  'Resend OTP',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}