import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/route_config.dart';
import '../../config/theme_config.dart';
import '../../providers/booking_provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../services/customer_realtime_service.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() {
    return _BookingScreenState();
  }
}

class _BookingScreenState extends State<BookingScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  DateTime? _selectedDate;

  String _selectedTime = '10:00 AM';
  String _selectedLocationType = 'Event Place';
  String _selectedPaymentMethod = 'COD';

  bool _isBooking = false;
  bool _argumentsInitialized = false;

  Map<String, dynamic> _service = <String, dynamic>{};

  String _serviceId = '';
  String _serviceName = 'Event Service';
  String _providerName = '';

  double _servicePrice = 0;
  double _platformFee = 0;

  final TextEditingController _guestsController = TextEditingController(
    text: '100',
  );

  final TextEditingController _addressController = TextEditingController();

  final TextEditingController _contactController = TextEditingController();

  final TextEditingController _alternateContactController =
      TextEditingController();

  final TextEditingController _landmarkController = TextEditingController();

  final TextEditingController _nearbyLocationController =
      TextEditingController();

  final TextEditingController _notesController = TextEditingController();

  final List<String> _timeSlots = <String>[
    '08:00 AM',
    '10:00 AM',
    '12:00 PM',
    '02:00 PM',
    '04:00 PM',
    '06:00 PM',
    '08:00 PM',
  ];

  final List<String> _locationTypes = <String>[
    'Home',
    'Office',
    'Event Place',
    'Provider Shop',
    'Other',
  ];

  final List<String> _paymentMethods = <String>['COD', 'UPI', 'CARD'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_argumentsInitialized) {
      return;
    }

    _argumentsInitialized = true;

    final dynamic arguments = ModalRoute.of(context)?.settings.arguments;

    _service = _convertArgumentsToServiceMap(arguments);

    _serviceId = _resolveServiceId(arguments, _service);

    _serviceName = _resolveServiceName(_service);

    _providerName = _resolveProviderName(_service);

    _servicePrice = _resolveServicePrice(_service);

    _platformFee = _toDouble(_service['platformFee'] ?? _service['serviceFee']);

    final address = _resolveAddress(_service);

    if (address.isNotEmpty) {
      _addressController.text = address;
    }

    final contact = _resolveContact(_service);

    if (contact.isNotEmpty) {
      _contactController.text = contact;
    }

    debugPrint(
      'BOOKING ROUTE ARGUMENT TYPE: '
      '${arguments.runtimeType}',
    );

    debugPrint(
      'BOOKING SERVICE ID AVAILABLE: '
      '${_serviceId.isNotEmpty}',
    );

    debugPrint(
      'BOOKING SERVICE NAME: '
      '$_serviceName',
    );
  }

  @override
  void dispose() {
    _guestsController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _alternateContactController.dispose();
    _landmarkController.dispose();
    _nearbyLocationController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map<String, dynamic>((dynamic key, dynamic item) {
        return MapEntry<String, dynamic>(key.toString(), item);
      });
    }

    return <String, dynamic>{};
  }

  Map<String, dynamic> _convertArgumentsToServiceMap(dynamic arguments) {
    if (arguments == null) {
      return <String, dynamic>{};
    }

    if (arguments is String) {
      final id = arguments.trim();

      return <String, dynamic>{'_id': id, 'id': id, 'serviceId': id};
    }

    if (arguments is Map) {
      return _unwrapServiceMap(_asMap(arguments));
    }

    try {
      final dynamic map = arguments.toMap();

      if (map is Map) {
        return _unwrapServiceMap(_asMap(map));
      }
    } catch (_) {
      // Try the next supported format.
    }

    try {
      final dynamic json = arguments.toJson();

      if (json is Map) {
        return _unwrapServiceMap(_asMap(json));
      }
    } catch (_) {
      // Try direct properties.
    }

    final result = <String, dynamic>{};

    try {
      final dynamic id = arguments.id;

      if (id != null) {
        result['_id'] = id.toString();

        result['id'] = id.toString();

        result['serviceId'] = id.toString();
      }
    } catch (_) {
      // Property unavailable.
    }

    try {
      final dynamic serviceId = arguments.serviceId;

      if (serviceId != null) {
        result['serviceId'] = serviceId.toString();
      }
    } catch (_) {
      // Property unavailable.
    }

    try {
      final dynamic name = arguments.name;

      if (name != null) {
        result['name'] = name.toString();
      }
    } catch (_) {
      // Property unavailable.
    }

    try {
      final dynamic price = arguments.price;

      if (price != null) {
        result['price'] = price;
      }
    } catch (_) {
      // Property unavailable.
    }

    try {
      final dynamic basePrice = arguments.basePrice;

      if (basePrice != null) {
        result['basePrice'] = basePrice;
      }
    } catch (_) {
      // Property unavailable.
    }

    try {
      final dynamic location = arguments.location;

      if (location != null) {
        result['location'] = location;
      }
    } catch (_) {
      // Property unavailable.
    }

    return result;
  }

  Map<String, dynamic> _unwrapServiceMap(Map<String, dynamic> arguments) {
    final dynamic service = arguments['service'];

    if (service is Map) {
      return <String, dynamic>{...arguments, ..._asMap(service)};
    }

    final dynamic data = arguments['data'];

    if (data is Map) {
      final dataMap = _asMap(data);

      final dynamic nestedService = dataMap['service'];

      if (nestedService is Map) {
        return <String, dynamic>{
          ...arguments,
          ...dataMap,
          ..._asMap(nestedService),
        };
      }

      if (_looksLikeServiceMap(dataMap)) {
        return <String, dynamic>{...arguments, ...dataMap};
      }
    }

    return arguments;
  }

  bool _looksLikeServiceMap(Map<String, dynamic> map) {
    return map.containsKey('_id') ||
        map.containsKey('id') ||
        map.containsKey('serviceId') ||
        map.containsKey('name') ||
        map.containsKey('price');
  }

  String _resolveServiceId(
    dynamic originalArguments,
    Map<String, dynamic> service,
  ) {
    final candidates = <dynamic>[
      service['_id'],
      service['id'],
      service['serviceId'],
      service['service_id'],
    ];

    final dynamic nestedService = service['service'];

    if (nestedService is Map) {
      final nestedMap = _asMap(nestedService);

      candidates.addAll(<dynamic>[
        nestedMap['_id'],
        nestedMap['id'],
        nestedMap['serviceId'],
      ]);
    } else if (nestedService is String) {
      candidates.add(nestedService);
    }

    final dynamic nestedData = service['data'];

    if (nestedData is Map) {
      final dataMap = _asMap(nestedData);

      candidates.addAll(<dynamic>[
        dataMap['_id'],
        dataMap['id'],
        dataMap['serviceId'],
      ]);
    }

    if (originalArguments is String) {
      candidates.add(originalArguments);
    }

    for (final candidate in candidates) {
      final id = _extractId(candidate);

      if (id.isNotEmpty) {
        return id;
      }
    }

    try {
      final id = _extractId(originalArguments.id);

      if (id.isNotEmpty) {
        return id;
      }
    } catch (_) {
      // Property unavailable.
    }

    try {
      final serviceId = _extractId(originalArguments.serviceId);

      if (serviceId.isNotEmpty) {
        return serviceId;
      }
    } catch (_) {
      // Property unavailable.
    }

    return '';
  }

  String _extractId(dynamic value) {
    if (value == null) {
      return '';
    }

    if (value is String) {
      return value.trim();
    }

    if (value is Map) {
      final map = _asMap(value);

      final candidates = <dynamic>[
        map['_id'],
        map['id'],
        map['serviceId'],
        map['service_id'],
      ];

      for (final candidate in candidates) {
        final id = candidate?.toString().trim() ?? '';

        if (id.isNotEmpty) {
          return id;
        }
      }
    }

    try {
      final dynamic id = value.id;

      if (id != null) {
        return id.toString().trim();
      }
    } catch (_) {
      // Property unavailable.
    }

    return '';
  }

  String _resolveServiceName(Map<String, dynamic> service) {
    final candidates = <dynamic>[
      service['name'],
      service['title'],
      service['serviceName'],
    ];

    for (final candidate in candidates) {
      final value = candidate?.toString().trim() ?? '';

      if (value.isNotEmpty) {
        return value;
      }
    }

    return 'Event Service';
  }

  String _resolveProviderName(Map<String, dynamic> service) {
    final directName = service['providerName']?.toString().trim() ?? '';

    if (directName.isNotEmpty) {
      return directName;
    }

    final provider = _asMap(service['provider']);

    final businessName = provider['businessName']?.toString().trim() ?? '';

    if (businessName.isNotEmpty) {
      return businessName;
    }

    final shopName = provider['shopName']?.toString().trim() ?? '';

    if (shopName.isNotEmpty) {
      return shopName;
    }

    final fullName = provider['fullName']?.toString().trim() ?? '';

    if (fullName.isNotEmpty) {
      return fullName;
    }

    final firstName = provider['firstName']?.toString().trim() ?? '';

    final lastName = provider['lastName']?.toString().trim() ?? '';

    return <String>[
      firstName,
      lastName,
    ].where((item) => item.isNotEmpty).join(' ').trim();
  }

  double _resolveServicePrice(Map<String, dynamic> service) {
    final candidates = <dynamic>[
      service['displayPrice'],
      service['discountedPrice'],
      service['price'],
      service['basePrice'],
      service['pricePerHour'],
      service['pricePerDay'],
      service['totalAmount'],
    ];

    for (final candidate in candidates) {
      final value = _toDouble(candidate);

      if (value > 0) {
        return value;
      }
    }

    return 0;
  }

  String _resolveAddress(Map<String, dynamic> service) {
    final address = service['address']?.toString().trim() ?? '';

    if (address.isNotEmpty) {
      return address;
    }

    final dynamic location = service['location'];

    if (location is String && location.trim().isNotEmpty) {
      return location.trim();
    }

    if (location is Map) {
      final locationMap = _asMap(location);

      final locationAddress =
          locationMap['address']?.toString().trim() ??
          locationMap['name']?.toString().trim() ??
          '';

      if (locationAddress.isNotEmpty) {
        return locationAddress;
      }
    }

    return '';
  }

  String _resolveContact(Map<String, dynamic> service) {
    final customer = _asMap(service['customer'] ?? service['user']);

    return customer['phone']?.toString().trim() ??
        customer['mobile']?.toString().trim() ??
        '';
  }

  double _toDouble(dynamic value, {double fallback = 0}) {
    if (value == null) {
      return fallback;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString().trim()) ?? fallback;
  }

  int _guestCount() {
    final value = int.tryParse(_guestsController.text.trim());

    if (value == null || value < 1) {
      return 1;
    }

    return value;
  }

  String _digitsOnly(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  bool _isValidPhone(String value) {
    final digits = _digitsOnly(value);

    return digits.length >= 10 && digits.length <= 15;
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? today,
      firstDate: today,
      lastDate: DateTime(today.year + 2, today.month, today.day),
    );

    if (pickedDate == null || !mounted) {
      return;
    }

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  String? _validateBooking() {
    if (_serviceId.trim().isEmpty) {
      return 'Service ID is missing. Please reopen the service.';
    }

    if (_selectedDate == null) {
      return 'Please select a booking date.';
    }

    if (_selectedTime.trim().isEmpty) {
      return 'Please select a booking time.';
    }

    if (_selectedLocationType.trim().isEmpty) {
      return 'Please select the service location type.';
    }

    if (_contactController.text.trim().isEmpty) {
      return 'Please enter the contact number.';
    }

    if (!_isValidPhone(_contactController.text)) {
      return 'Please enter a valid contact number.';
    }

    if (_alternateContactController.text.trim().isNotEmpty &&
        !_isValidPhone(_alternateContactController.text)) {
      return 'Please enter a valid alternate contact number.';
    }

    if (_addressController.text.trim().isEmpty) {
      return 'Please enter the complete service address.';
    }

    if (_guestCount() < 1) {
      return 'Guest count must be at least one.';
    }

    return null;
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError ? Colors.red.shade700 : Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('FormatException: ', '')
        .replaceFirst('Invalid argument(s): ', '')
        .replaceFirst('StateError: ', '')
        .trim();
  }

  Future<bool> _tryRestoreCustomerSession() async {
    try {
      String? token = await AuthService.instance.getToken();

      if (token == null || token.trim().isEmpty) {
        debugPrint('BOOKING SCREEN: RESTORING CUSTOMER SESSION');

        await AuthService.instance.restoreSession();

        token = await AuthService.instance.getToken();
      }

      if (token == null || token.trim().isEmpty) {
        debugPrint('BOOKING SCREEN AUTH FAILED: TOKEN UNAVAILABLE');

        return false;
      }

      final validatedToken = await AuthService.instance.ensureAuthenticated();

      if (validatedToken.trim().isEmpty) {
        return false;
      }

      ApiService.instance.setAuthToken(validatedToken.trim());

      final authenticated = ApiService.instance.hasAuthToken;

      debugPrint(
        'BOOKING SCREEN CUSTOMER AUTHENTICATED: '
        '$authenticated',
      );

      return authenticated;
    } catch (error, stackTrace) {
      debugPrint(
        'BOOKING SCREEN AUTH CHECK ERROR: '
        '$error',
      );

      debugPrint('$stackTrace');

      return false;
    }
  }

  Future<bool> _ensureCustomerAuthenticated() async {
    final alreadyAuthenticated = await _tryRestoreCustomerSession();

    if (alreadyAuthenticated) {
      return true;
    }

    if (!mounted) {
      return false;
    }

    final shouldSignIn = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Sign in required'),
          content: const Text(
            'Please sign in with a Customer account before confirming this booking.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Sign In'),
            ),
          ],
        );
      },
    );

    if (shouldSignIn != true || !mounted) {
      return false;
    }

    try {
      final dynamic loginResult = await Navigator.of(context).pushNamed(
        RouteConfig.login,
        arguments: <String, dynamic>{'returnToBooking': true},
      );

      debugPrint(
        'BOOKING LOGIN COMPLETED: '
        '${loginResult == true}',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'BOOKING LOGIN ROUTE ERROR: '
        '$error',
      );

      debugPrint('$stackTrace');

      if (mounted) {
        _showMessage(
          'Unable to open the Customer sign-in screen.',
          isError: true,
        );
      }

      return false;
    }

    if (!mounted) {
      return false;
    }

    final authenticatedAfterLogin = await _tryRestoreCustomerSession();

    if (!authenticatedAfterLogin) {
      _showMessage('Customer sign-in was not completed.', isError: true);

      return false;
    }

    return true;
  }

  Future<void> _createBooking() async {
    if (_isBooking) {
      return;
    }

    FocusScope.of(context).unfocus();

    final validationMessage = _validateBooking();

    if (validationMessage != null) {
      _showMessage(validationMessage, isError: true);

      return;
    }

    setState(() {
      _isBooking = true;
    });

    try {
      debugPrint('CONFIRM BOOKING STARTED');

      final authenticated = await _ensureCustomerAuthenticated();

      if (!authenticated) {
        debugPrint('BOOKING STOPPED: CUSTOMER SESSION UNAVAILABLE');

        return;
      }

      if (!mounted) {
        return;
      }

      final token = await AuthService.instance.ensureAuthenticated();

      if (token.trim().isEmpty) {
        throw Exception('Customer authentication token is unavailable.');
      }

      ApiService.instance.setAuthToken(token.trim());

      if (!ApiService.instance.hasAuthToken) {
        throw Exception(
          'Unable to attach Customer authentication before creating the booking.',
        );
      }

      final address = _addressController.text.trim();

      final contactNumber = _contactController.text.trim();

      final alternateContact = _alternateContactController.text.trim();

      final landmark = _landmarkController.text.trim();

      final nearbyLocation = _nearbyLocationController.text.trim();

      final notes = _notesController.text.trim();

      final bookingData = <String, dynamic>{
        'location': address,
        'locationType': _selectedLocationType,
        'serviceLocationType': _selectedLocationType,
        'contactNumber': contactNumber,
        'phone': contactNumber,
        'mobile': contactNumber,
        'guestCount': _guestCount(),
        if (alternateContact.isNotEmpty)
          'alternateContactNumber': alternateContact,
        if (landmark.isNotEmpty) 'landmark': landmark,
        if (nearbyLocation.isNotEmpty) 'nearbyLocation': nearbyLocation,
      };

      debugPrint(
        'CREATE BOOKING SERVICE ID AVAILABLE: '
        '${_serviceId.isNotEmpty}',
      );

      debugPrint(
        'AUTH TOKEN AVAILABLE BEFORE BOOKING: '
        '${AuthService.instance.hasToken}',
      );

      debugPrint(
        'API AUTH HEADER AVAILABLE BEFORE BOOKING: '
        '${ApiService.instance.hasAuthToken}',
      );

      final booking = await BookingService.instance.createBooking(
        serviceId: _serviceId.trim(),
        bookingDate: _selectedDate!,
        bookingTime: _selectedTime,
        address: address,
        notes: notes,
        paymentMethod: _selectedPaymentMethod,
        hoursBooked: 1,
        data: bookingData,
      );

      if (!mounted) {
        return;
      }

      if (booking.id.trim().isEmpty) {
        throw const FormatException(
          'The backend did not return a valid booking ID.',
        );
      }

      final bookingProvider = context.read<BookingProvider>();

      bookingProvider.upsertBooking(
        booking,
        updateCustomerList: true,
        updateProviderList: false,
        selectBooking: true,
        notify: true,
      );

      CustomerRealtimeService.instance.joinBookingRoom(booking.id);

      await bookingProvider.getMyBookings(
        page: 1,
        limit: 100,
        forceRefresh: true,
        showLoading: false,
      );

      if (!mounted) {
        return;
      }

      final refreshedBooking =
          bookingProvider.findBookingById(booking.id) ?? booking;

      bookingProvider.setSelectedBooking(refreshedBooking);

      debugPrint('BOOKING CREATED SUCCESSFULLY');

      debugPrint(
        'BACKEND BOOKING ID AVAILABLE: '
        '${refreshedBooking.id.isNotEmpty}',
      );

      debugPrint(
        'BOOKING NUMBER: '
        '${refreshedBooking.bookingNumber}',
      );

      debugPrint(
        'CUSTOMER BOOKINGS REFRESHED: '
        '${bookingProvider.myBookings.length}',
      );

      await Navigator.of(context).pushReplacementNamed(
        RouteConfig.orderSuccess,
        arguments: refreshedBooking,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'CREATE BOOKING ERROR: '
        '$error',
      );

      debugPrint(
        'CREATE BOOKING STACK TRACE: '
        '$stackTrace',
      );

      if (!mounted) {
        return;
      }

      final errorMessage = _cleanError(error);

      final normalizedError = errorMessage.toLowerCase();

      final authenticationError =
          normalizedError.contains('authentication') ||
          normalizedError.contains('unauthorized') ||
          normalizedError.contains('not authorized') ||
          normalizedError.contains('no token') ||
          normalizedError.contains('sign in') ||
          normalizedError.contains('jwt');

      if (authenticationError) {
        _showMessage(
          'Your Customer session is unavailable. Please sign in and try again.',
          isError: true,
        );
      } else {
        _showMessage(
          errorMessage.isEmpty
              ? 'Unable to create booking. Please try again.'
              : errorMessage,
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayedTotal = _servicePrice + _platformFee;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(title: const Text('Book Service')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildServiceCard(),
                const SizedBox(height: 20),
                _buildSectionTitle('Select Date'),
                const SizedBox(height: 10),
                _buildDateSelector(),
                const SizedBox(height: 20),
                _buildSectionTitle('Select Time Slot'),
                const SizedBox(height: 10),
                _buildTimeSlots(),
                const SizedBox(height: 20),
                _buildSectionTitle('Service Location Type'),
                const SizedBox(height: 10),
                _buildLocationType(),
                const SizedBox(height: 20),
                _buildSectionTitle('Contact Number'),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _contactController,
                  enabled: !_isBooking,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Enter contact number',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final phone = value?.trim() ?? '';

                    if (phone.isEmpty) {
                      return 'Contact number is required';
                    }

                    if (!_isValidPhone(phone)) {
                      return 'Enter a valid contact number';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('Alternate Contact Number (Optional)'),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _alternateContactController,
                  enabled: !_isBooking,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Enter alternate contact number',
                    prefixIcon: Icon(Icons.phone_android),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final phone = value?.trim() ?? '';

                    if (phone.isEmpty) {
                      return null;
                    }

                    if (!_isValidPhone(phone)) {
                      return 'Enter a valid alternate number';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('Guest Count'),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _guestsController,
                  enabled: !_isBooking,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Number of guests',
                    prefixIcon: Icon(Icons.group),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final guestCount = int.tryParse(value?.trim() ?? '');

                    if (guestCount == null || guestCount < 1) {
                      return 'Guest count must be at least one';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('Complete Service Address'),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _addressController,
                  enabled: !_isBooking,
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'House/building, street, city and postal code',
                    prefixIcon: Icon(Icons.location_on, color: Colors.red),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if ((value?.trim() ?? '').isEmpty) {
                      return 'Complete service address is required';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('Landmark (Optional)'),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _landmarkController,
                  enabled: !_isBooking,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Nearby landmark',
                    prefixIcon: Icon(Icons.place),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('Nearby Location (Optional)'),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nearbyLocationController,
                  enabled: !_isBooking,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Nearby known location',
                    prefixIcon: Icon(Icons.near_me),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('Payment Method'),
                const SizedBox(height: 10),
                _buildPaymentMethod(),
                const SizedBox(height: 20),
                _buildSectionTitle('Special Instructions'),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _notesController,
                  enabled: !_isBooking,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Write additional requirements...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 25),
                _buildSectionTitle('Booking Summary'),
                const SizedBox(height: 10),
                _buildSummaryCard(displayedTotal),
                const SizedBox(height: 20),
                _buildInformationBox(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(displayedTotal),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildServiceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                color: ThemeConfig.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.business_center,
                size: 35,
                color: ThemeConfig.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _serviceName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_providerName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _providerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    _servicePrice > 0
                        ? 'Starting from ₹${_formatAmount(_servicePrice)}'
                        : 'Price calculated by the backend',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
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

  Widget _buildDateSelector() {
    return InkWell(
      onTap: _isBooking ? null : _selectDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.calendar_month, color: ThemeConfig.primaryColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _selectedDate == null
                    ? 'Choose Date'
                    : DateFormat('dd MMM yyyy').format(_selectedDate!),
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlots() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          _timeSlots.map((time) {
            return ChoiceChip(
              label: Text(time),
              selected: _selectedTime == time,
              onSelected:
                  _isBooking
                      ? null
                      : (selected) {
                        if (!selected) {
                          return;
                        }

                        setState(() {
                          _selectedTime = time;
                        });
                      },
            );
          }).toList(),
    );
  }

  Widget _buildLocationType() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedLocationType,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.location_city),
        border: OutlineInputBorder(),
      ),
      items:
          _locationTypes.map((type) {
            return DropdownMenuItem<String>(value: type, child: Text(type));
          }).toList(),
      onChanged:
          _isBooking
              ? null
              : (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _selectedLocationType = value;
                });
              },
    );
  }

  Widget _buildPaymentMethod() {
    return DropdownButtonFormField<String>(
      value: _selectedPaymentMethod,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.payments),
        border: OutlineInputBorder(),
      ),
      items:
          _paymentMethods.map((method) {
            return DropdownMenuItem<String>(
              value: method,
              child: Text(method == 'COD' ? 'Cash on Service' : method),
            );
          }).toList(),
      onChanged:
          _isBooking
              ? null
              : (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _selectedPaymentMethod = value;
                });
              },
    );
  }

  Widget _buildSummaryCard(double displayedTotal) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            _summaryRow(
              'Service Fee',
              _servicePrice > 0
                  ? '₹${_formatAmount(_servicePrice)}'
                  : 'Calculated by server',
            ),
            _summaryRow(
              'Platform Fee',
              _platformFee > 0 ? '₹${_formatAmount(_platformFee)}' : '₹0',
            ),
            const Divider(),
            _summaryRow(
              'Estimated Total',
              displayedTotal > 0
                  ? '₹${_formatAmount(displayedTotal)}'
                  : 'Calculated by server',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformationBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'After booking, the request appears in My Bookings. '
              'The Provider can accept or reject it. After acceptance, '
              'the service OTP becomes available in the Customer app. '
              'Share the OTP only after the Provider arrives.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(double displayedTotal) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            onPressed: _isBooking ? null : _createBooking,
            child:
                _isBooking
                    ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Creating Booking...'),
                      ],
                    )
                    : Text(
                      displayedTotal > 0
                          ? 'Confirm Booking ₹${_formatAmount(displayedTotal)}'
                          : 'Confirm Booking',
                    ),
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String title, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? Colors.green : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    return NumberFormat('#,##0.##', 'en_IN').format(amount);
  }
}
