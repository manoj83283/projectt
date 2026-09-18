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
  bool _submitted = false;

  bool _returnToBooking = false;
  bool _routeArgumentsInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_routeArgumentsInitialized) {
      return;
    }

    _routeArgumentsInitialized = true;

    final arguments =
        ModalRoute.of(context)?.settings.arguments;

    if (arguments is Map) {
      _returnToBooking =
          arguments['returnToBooking'] == true;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  String _cleanError(
    Object? error,
  ) {
    if (error == null) {
      return '';
    }

    var message = error.toString().trim();

    const prefixes = <String>[
      'Exception: ',
      'FormatException: ',
      'Invalid argument(s): ',
    ];

    for (final prefix in prefixes) {
      if (message.startsWith(prefix)) {
        message = message
            .substring(prefix.length)
            .trim();
      }
    }

    return message;
  }

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

  void _onCredentialsChanged(
    String value,
  ) {
    final authProvider =
        context.read<AuthProvider>();

    if (authProvider.error != null) {
      authProvider.clearError();
    }

    if (_submitted) {
      _formKey.currentState?.validate();
    }
  }

  String? _validateEmail(
    String? value,
  ) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email is required';
    }

    final emailPattern = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailPattern.hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  String? _validatePassword(
    String? value,
  ) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 6) {
      return 'Password must contain at least 6 characters';
    }

    return null;
  }

  Future<void> _login() async {
    if (isLoading) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _submitted = true;
    });

    final formIsValid =
        _formKey.currentState?.validate() ??
            false;

    if (!formIsValid) {
      return;
    }

    final authProvider =
        context.read<AuthProvider>();

    authProvider.clearError();

    setState(() {
      isLoading = true;
    });

    try {
      final email = emailController.text
          .trim()
          .toLowerCase();

      final password =
          passwordController.text;

      debugPrint(
        'CUSTOMER LOGIN SUBMITTED',
      );

      debugPrint(
        'CUSTOMER LOGIN EMAIL: $email',
      );

      final success =
          await authProvider.login(
        email: email,
        password: password,
      );

      if (!mounted) {
        return;
      }

      if (!success) {
        final errorMessage = _cleanError(
          authProvider.error,
        );

        _showMessage(
          errorMessage.isEmpty
              ? 'Unable to sign in. Check your email and password.'
              : errorMessage,
          isError: true,
        );

        return;
      }

      final token =
          await AuthService.instance
              .getToken();

      if (!mounted) {
        return;
      }

      if (token == null ||
          token.trim().isEmpty) {
        throw Exception(
          'Sign-in succeeded, but the Customer authentication token was not saved.',
        );
      }

      ApiService.instance.setAuthToken(
        token,
      );

      if (!ApiService.instance.hasAuthToken) {
        throw Exception(
          'Sign-in succeeded, but Customer authentication could not be attached to API requests.',
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

      if (_returnToBooking &&
          Navigator.canPop(context)) {
        Navigator.of(context).pop(
          true,
        );

        return;
      }

      Navigator.of(context)
          .pushNamedAndRemoveUntil(
        RouteConfig.home,
        (route) => false,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'CUSTOMER SIGN-IN ERROR: $error',
      );

      debugPrint(
        'CUSTOMER SIGN-IN STACK TRACE: '
        '$stackTrace',
      );

      if (!mounted) {
        return;
      }

      final message =
          _cleanError(error);

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

  Future<void> _googleLogin() async {
    if (isLoading) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
    });

    try {
      final authProvider =
          context.read<AuthProvider>();

      authProvider.clearError();

      final success =
          await authProvider.googleLogin();

      if (!mounted) {
        return;
      }

      if (!success) {
        final message = _cleanError(
          authProvider.error,
        );

        _showMessage(
          message.isEmpty
              ? 'Unable to sign in with Google.'
              : message,
          isError: true,
        );

        return;
      }

      final token =
          await AuthService.instance
              .getToken();

      if (!mounted) {
        return;
      }

      if (token == null ||
          token.trim().isEmpty) {
        throw Exception(
          'Google sign-in succeeded, but the Customer authentication token was not saved.',
        );
      }

      ApiService.instance.setAuthToken(
        token,
      );

      if (!ApiService.instance.hasAuthToken) {
        throw Exception(
          'Unable to attach Google authentication to API requests.',
        );
      }

      if (_returnToBooking &&
          Navigator.canPop(context)) {
        Navigator.of(context).pop(
          true,
        );

        return;
      }

      Navigator.of(context)
          .pushNamedAndRemoveUntil(
        RouteConfig.home,
        (route) => false,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'GOOGLE SIGN-IN ERROR: $error',
      );

      debugPrint(
        'GOOGLE SIGN-IN STACK TRACE: '
        '$stackTrace',
      );

      if (!mounted) {
        return;
      }

      final message =
          _cleanError(error);

      _showMessage(
        message.isEmpty
            ? 'Unable to sign in with Google.'
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

  Future<void> _openSignup() async {
    if (isLoading) {
      return;
    }

    final result =
        await Navigator.of(context)
            .pushNamed(
      RouteConfig.signup,
      arguments: <String, dynamic>{
        if (_returnToBooking)
          'returnToBooking': true,
      },
    );

    if (!mounted) {
      return;
    }

    if (_returnToBooking &&
        result == true) {
      final token =
          await AuthService.instance
              .getToken();

      if (token != null &&
          token.trim().isNotEmpty) {
        ApiService.instance.setAuthToken(
          token,
        );

        if (!mounted) {
          return;
        }

        Navigator.of(context).pop(
          true,
        );
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior
                  .onDrag,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 24,
          ),
          child: Form(
            key: _formKey,
            autovalidateMode: _submitted
                ? AutovalidateMode
                    .onUserInteraction
                : AutovalidateMode
                    .disabled,
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 36,
                ),

                if (_returnToBooking)
                  Align(
                    alignment:
                        Alignment.centerLeft,
                    child: IconButton(
                      tooltip:
                          'Back to booking',
                      onPressed: isLoading
                          ? null
                          : () {
                              Navigator.of(
                                context,
                              ).pop(false);
                            },
                      icon: const Icon(
                        Icons.arrow_back,
                      ),
                    ),
                  ),

                const SizedBox(
                  height: 14,
                ),

                Container(
                  height: 100,
                  width: 100,
                  decoration:
                      BoxDecoration(
                    color: ThemeConfig
                        .primaryColor,
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: ThemeConfig
                            .primaryColor
                            .withValues(
                          alpha: 0.24,
                        ),
                        blurRadius: 18,
                        offset:
                            const Offset(
                          0,
                          8,
                        ),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.event_available,
                    size: 50,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                const Text(
                  'Welcome Back',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  _returnToBooking
                      ? 'Sign in to continue with your booking'
                      : 'Sign in to continue using EventEase',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color:
                        Colors.grey.shade600,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(
                  height: 40,
                ),

                TextFormField(
                  controller:
                      emailController,
                  enabled: !isLoading,
                  keyboardType:
                      TextInputType.emailAddress,
                  textInputAction:
                      TextInputAction.next,
                  autofillHints:
                      const <String>[
                    AutofillHints.email,
                    AutofillHints.username,
                  ],
                  autocorrect: false,
                  enableSuggestions: false,
                  onChanged:
                      _onCredentialsChanged,
                  decoration:
                      const InputDecoration(
                    labelText: 'Email',
                    hintText:
                        'Enter your email',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                    ),
                    border:
                        OutlineInputBorder(),
                  ),
                  validator:
                      _validateEmail,
                ),

                const SizedBox(
                  height: 16,
                ),

                TextFormField(
                  controller:
                      passwordController,
                  enabled: !isLoading,
                  obscureText:
                      obscurePassword,
                  textInputAction:
                      TextInputAction.done,
                  autofillHints:
                      const <String>[
                    AutofillHints.password,
                  ],
                  onChanged:
                      _onCredentialsChanged,
                  onFieldSubmitted: (_) {
                    if (!isLoading) {
                      _login();
                    }
                  },
                  decoration:
                      InputDecoration(
                    labelText: 'Password',
                    hintText:
                        'Enter your password',
                    prefixIcon:
                        const Icon(
                      Icons.lock_outline,
                    ),
                    border:
                        const OutlineInputBorder(),
                    suffixIcon:
                        IconButton(
                      tooltip:
                          obscurePassword
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
                            ? Icons
                                .visibility_off
                            : Icons
                                .visibility,
                      ),
                    ),
                  ),
                  validator:
                      _validatePassword,
                ),

                const SizedBox(
                  height: 10,
                ),

                Align(
                  alignment:
                      Alignment.centerRight,
                  child: TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.of(
                              context,
                            ).pushNamed(
                              RouteConfig
                                  .forgotPassword,
                            );
                          },
                    child: const Text(
                      'Forgot Password?',
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : _login,
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
                                  strokeWidth:
                                      2,
                                  color:
                                      Colors.white,
                                ),
                              ),
                              SizedBox(
                                width: 12,
                              ),
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

                const SizedBox(
                  height: 20,
                ),

                Row(
                  children: <Widget>[
                    Expanded(
                      child: Divider(
                        color: Colors
                            .grey.shade300,
                      ),
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      child: Text(
                        'OR',
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors
                            .grey.shade300,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 20,
                ),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child:
                      OutlinedButton.icon(
                    onPressed: isLoading
                        ? null
                        : _googleLogin,
                    icon: const Icon(
                      Icons.g_mobiledata,
                      size: 28,
                    ),
                    label: const Text(
                      'Continue with Google',
                    ),
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                Wrap(
                  alignment:
                      WrapAlignment.center,
                  crossAxisAlignment:
                      WrapCrossAlignment.center,
                  children: <Widget>[
                    const Text(
                      "Don't have an account?",
                    ),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : _openSignup,
                      child: const Text(
                        'Sign Up',
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}