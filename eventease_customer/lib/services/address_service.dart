import '../models/address_model.dart';
import 'api_service.dart';

class AddressService {
  AddressService._();

  static final AddressService instance =
      AddressService._();

  // ==========================================
  // GET ALL ADDRESSES
  // ==========================================

  Future<List<AddressModel>> getAddresses() async {
    final response =
        await ApiService.instance.get(
      '/addresses',
    );

    final List addresses =
        response.data['data'] ??
            response.data['addresses'] ??
            [];

    return addresses
        .map(
          (e) => AddressModel.fromMap(e),
        )
        .toList();
  }

  // ==========================================
  // GET ADDRESS BY ID
  // ==========================================

  Future<AddressModel> getAddressById(
    String addressId,
  ) async {
    final response =
        await ApiService.instance.get(
      '/addresses/$addressId',
    );

    return AddressModel.fromMap(
      response.data['data'] ??
          response.data['address'],
    );
  }

  // ==========================================
  // ADD ADDRESS
  // ==========================================

  Future<AddressModel> addAddress({
    required String title,
    required String fullName,
    required String mobile,
    required String addressLine1,
    String? addressLine2,
    required String landmark,
    required String city,
    required String state,
    required String country,
    required String postalCode,
    required double latitude,
    required double longitude,
    bool isDefault = false,
  }) async {
    final response =
        await ApiService.instance.post(
      '/addresses',
      data: {
        'title': title,
        'fullName': fullName,
        'mobile': mobile,
        'addressLine1': addressLine1,
        'addressLine2': addressLine2,
        'landmark': landmark,
        'city': city,
        'state': state,
        'country': country,
        'postalCode': postalCode,
        'latitude': latitude,
        'longitude': longitude,
        'isDefault': isDefault,
      },
    );

    return AddressModel.fromMap(
      response.data['data'] ??
          response.data['address'],
    );
  }

  // ==========================================
  // UPDATE ADDRESS
  // ==========================================

  Future<AddressModel> updateAddress({
    required String addressId,
    required Map<String, dynamic> data,
  }) async {
    final response =
        await ApiService.instance.patch(
      '/addresses/$addressId',
      data: data,
    );

    return AddressModel.fromMap(
      response.data['data'] ??
          response.data['address'],
    );
  }

  // ==========================================
  // DELETE ADDRESS
  // ==========================================

  Future<bool> deleteAddress(
    String addressId,
  ) async {
    await ApiService.instance.delete(
      '/addresses/$addressId',
    );

    return true;
  }

  // ==========================================
  // SET DEFAULT ADDRESS
  // ==========================================

  Future<bool> setDefaultAddress(
    String addressId,
  ) async {
    await ApiService.instance.patch(
      '/addresses/$addressId/default',
    );

    return true;
  }

  // ==========================================
  // GET DEFAULT ADDRESS
  // ==========================================

  Future<AddressModel?> getDefaultAddress() async {
    final response =
        await ApiService.instance.get(
      '/addresses/default',
    );

    final data =
        response.data['data'] ??
            response.data['address'];

    if (data == null) return null;

    return AddressModel.fromMap(data);
  }

  // ==========================================
  // GET CURRENT LOCATION ADDRESS
  // ==========================================

  Future<Map<String, dynamic>>
      getCurrentLocationAddress({
    required double latitude,
    required double longitude,
  }) async {
    final response =
        await ApiService.instance.post(
      '/addresses/reverse-geocode',
      data: {
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    return response.data['data'] ??
        response.data;
  }

  // ==========================================
  // SEARCH ADDRESS
  // ==========================================

  Future<List<AddressModel>>
      searchAddress(
    String keyword,
  ) async {
    final response =
        await ApiService.instance.get(
      '/addresses/search',
      queryParameters: {
        'keyword': keyword,
      },
    );

    final List addresses =
        response.data['data'] ??
            response.data['addresses'] ??
            [];

    return addresses
        .map(
          (e) => AddressModel.fromMap(e),
        )
        .toList();
  }

  // ==========================================
  // VALIDATE SERVICE AREA
  // ==========================================

  Future<bool> validateServiceArea({
    required double latitude,
    required double longitude,
  }) async {
    final response =
        await ApiService.instance.post(
      '/addresses/validate-service-area',
      data: {
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    return response.data['serviceable'] ??
        response.data['data']
            ?['serviceable'] ??
        false;
  }
}