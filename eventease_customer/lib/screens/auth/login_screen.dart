import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/route_config.dart';
import '../../config/theme_config.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // =====================================================
  // ROUTE HELPERS
  // =====================================================

  bool _shouldReturnToBooking() {
    final dynamic arguments =
        ModalRoute.of(context)?.settings.arguments;

    if (arguments is Map) {
      return arguments['returnToBooking'] == true;
    }

    return false;
  }

  // =====================================================
  // MESSAGE HELPERS
  // =====================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError
              ? Colors.red.shade700
              : Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst(
          'Exception: ',
          '',
        )
        .replaceFirst(
          'Invalid argument(s): ',
          '',
        )
        .trim();
  }

  // =====================================================
  // LOGIN
  // =====================================================

  Future<void> _login() async {
    if (isLoading) {
      return;
    }

    final FormState? formState =
        _formKey.currentState;

    if (formState == null ||
        !formState.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
    });

    try {
      final AuthProvider authProvider =
          context.read<AuthProvider>();

      final bool success =
          await authProvider.login(
        email: emailController.text
            .trim()
            .toLowerCase(),
        password: passwordController.text,
      );

      if (!mounted) {
        return;
      }

      if (!success) {
        final String errorMessage =
            authProvider.error?.trim().isNotEmpty ==
                    true
                ? authProvider.error!.trim()
                : 'Unable to sign in. Check your '
                    'email and password.';

        _showMessage(
          _cleanError(errorMessage),
          isError: true,
        );

        return;
      }

      /*
       * Do not navigate until the saved JWT can be read
       * back from local storage.
       */
      final String? token =
          await AuthService.instance.getToken();

      if (token == null || token.trim().isEmpty) {
        throw Exception(
          'Sign-in succeeded, but the customer '
          'authentication token was not saved.',
        );
      }

      /*
       * Explicitly attach the JWT to Dio so protected
       * booking requests include:
       *
       * Authorization: Bearer CUSTOMER_JWT
       */
      ApiService.instance.setAuthToken(token);

      if (!ApiService.instance.hasAuthToken) {
        throw Exception(
          'Sign-in succeeded, but customer authentication '
          'could not be attached to API requests.',
        );
      }

      debugPrint(
        'CUSTOMER SIGN-IN COMPLETED',
      );

      debugPrint(
        'CUSTOMER TOKEN AVAILABLE: '
        '${AuthService.instance.hasToken}',
      );

      debugPrint(
        'CUSTOMER API AUTH HEADER AVAILABLE: '
        '${ApiService.instance.hasAuthToken}',
      );

      _showMessage(
        'Signed in successfully.',
      );

      /*
       * When Login was opened from BookingScreen, return
       * to the existing booking form instead of replacing
       * it with the Home screen.
       */
      if (_shouldReturnToBooking()) {
        Navigator.of(context).pop(true);
        return;
      }

      Navigator.of(context).pushNamedAndRemoveUntil(
        RouteConfig.home,
        (
          Route<dynamic> route,
        ) {
          return false;
        },
      );
    } catch (error, stackTrace) {
      debugPrint(
        'CUSTOMER SIGN-IN ERROR: $error',
      );

      debugPrint(
        'CUSTOMER SIGN-IN STACK TRACE: $stackTrace',
      );

      if (!mounted) {
        return;
      }

      final String message = _cleanError(error);

      _showMessage(
        message.isEmpty
            ? 'Unable to sign in. Please try again.'
            : message,
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // =====================================================
  // GOOGLE LOGIN
  // =====================================================

  Future<void> _googleLogin() async {
    if (isLoading) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
    });

    try {
      final AuthProvider authProvider =
          context.read<AuthProvider>();

      final bool success =
          await authProvider.googleLogin();

      if (!mounted) {
        return;
      }

      if (!success) {
        final String message =
            authProvider.error ??
                'Unable to sign in with Google.';

        _showMessage(
          _cleanError(message),
          isError: true,
        );

        return;
      }

      final String? token =
          await AuthService.instance.getToken();

      if (token == null || token.trim().isEmpty) {
        throw Exception(
          'Google sign-in succeeded, but the customer '
          'authentication token was not saved.',
        );
      }

      ApiService.instance.setAuthToken(token);

      if (!ApiService.instance.hasAuthToken) {
        throw Exception(
          'Unable to attach Google authentication '
          'to API requests.',
        );
      }

      if (_shouldReturnToBooking()) {
        Navigator.of(context).pop(true);
        return;
      }

      Navigator.of(context).pushNamedAndRemoveUntil(
        RouteConfig.home,
        (
          Route<dynamic> route,
        ) {
          return false;
        },
      );
    } catch (error, stackTrace) {
      debugPrint(
        'GOOGLE SIGN-IN ERROR: $error',
      );

      debugPrint(
        'GOOGLE SIGN-IN STACK TRACE: $stackTrace',
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        _cleanError(error),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // =====================================================
  // SIGN-UP NAVIGATION
  // =====================================================

  Future<void> _openSignup() async {
    if (isLoading) {
      return;
    }

    final dynamic result =
        await Navigator.of(context).pushNamed(
      RouteConfig.signup,
      arguments: <String, dynamic>{
        if (_shouldReturnToBooking())
          'returnToBooking': true,
      },
    );

    if (!mounted) {
      return;
    }

    /*
     * If sign-up returned success and saved a JWT,
     * return to the booking form.
     */
    if (_shouldReturnToBooking() &&
        result == true) {
      final String? token =
          await AuthService.instance.getToken();

      if (token != null &&
          token.trim().isNotEmpty) {
        ApiService.instance.setAuthToken(token);

        if (!mounted) {
          return;
        }

        Navigator.of(context).pop(true);
      }
    }
  }

  // =====================================================
  // VALIDATORS
  // =====================================================

  String? _validateEmail(String? value) {
    final String email =
        value?.trim().toLowerCase() ?? '';

    if (email.isEmpty) {
      return 'Email is required';
    }

    final RegExp emailPattern = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );

    if (!emailPattern.hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final String password = value ?? '';

    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 6) {
      return 'Password must contain at least 6 characters';
    }

    return null;
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior
                  .onDrag,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
          ),
          child: Form(
            key: _formKey,
            autovalidateMode:
                AutovalidateMode.onUserInteraction,
            child: Column(
              children: <Widget>[
                const SizedBox(height: 36),

                /*
                 * Show Back when Sign In was opened
                 * from the booking flow.
                 */
                if (_shouldReturnToBooking())
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      tooltip: 'Back to booking',
                      onPressed: isLoading
                          ? null
                          : () {
                              Navigator.of(context)
                                  .pop(false);
                            },
                      icon: const Icon(
                        Icons.arrow_back,
                      ),
                    ),
                  ),

                const SizedBox(height: 14),

                // =========================================
                // LOGO
                // =========================================

                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: ThemeConfig.primaryColor,
                    borderRadius:
                        BorderRadius.circular(20),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: ThemeConfig.primaryColor
                            .withValues(
                          alpha: 0.24,
                        ),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.event_available,
                    size: 50,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  _shouldReturnToBooking()
                      ? 'Sign in to continue with your booking'
                      : 'Sign in to continue using EventEase',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 40),

                // =========================================
                // EMAIL
                // =========================================

                TextFormField(
                  controller: emailController,
                  enabled: !isLoading,
                  keyboardType:
                      TextInputType.emailAddress,
                  textInputAction:
                      TextInputAction.next,
                  autofillHints: const <String>[
                    AutofillHints.email,
                    AutofillHints.username,
                  ],
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateEmail,
                ),

                const SizedBox(height: 16),

                // =========================================
                // PASSWORD
                // =========================================

                TextFormField(
                  controller: passwordController,
                  enabled: !isLoading,
                  obscureText: obscurePassword,
                  textInputAction:
                      TextInputAction.done,
                  autofillHints: const <String>[
                    AutofillHints.password,
                  ],
                  onFieldSubmitted: (_) {
                    if (!isLoading) {
                      _login();
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                    ),
                    border:
                        const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      tooltip: obscurePassword
                          ? 'Show password'
                          : 'Hide password',
                      onPressed: isLoading
                          ? null
                          : () {
                              setState(() {
                                obscurePassword =
                                    !obscurePassword;
                              });
                            },
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                  validator: _validatePassword,
                ),

                const SizedBox(height: 10),

                // =========================================
                // FORGOT PASSWORD
                // =========================================

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.of(context)
                                .pushNamed(
                              RouteConfig
                                  .forgotPassword,
                            );
                          },
                    child: const Text(
                      'Forgot Password?',
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // =========================================
                // SIGN-IN BUTTON
                // =========================================

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed:
                        isLoading ? null : _login,
                    child: isLoading
                        ? const Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            children: <Widget>[
                              SizedBox(
                                height: 22,
                                width: 22,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Signing In...',
                              ),
                            ],
                          )
                        : const Text(
                            'Sign In',
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // =========================================
                // DIVIDER
                // =========================================

                Row(
                  children: <Widget>[
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      child: Text('OR'),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // =========================================
                // GOOGLE LOGIN
                // =========================================

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    onPressed:
                        isLoading ? null : _googleLogin,
                    icon: const Icon(
                      Icons.g_mobiledata,
                      size: 28,
                    ),
                    label: const Text(
                      'Continue with Google',
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // =========================================
                // SIGN-UP
                // =========================================

                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment:
                      WrapCrossAlignment.center,
                  children: <Widget>[
                    const Text(
                      "Don't have an account?",
                    ),
                    TextButton(
                      onPressed:
                          isLoading ? null : _openSignup,
                      child: const Text(
                        'Sign Up',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}