import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  NetworkInfo._();

  static final Connectivity _connectivity =
      Connectivity();

  // =====================================================
  // CHECK CONNECTION
  // =====================================================

  static Future<bool> isConnected() async {
    final result =
        await _connectivity.checkConnectivity();

    return !_isDisconnected(result);
  }

  // =====================================================
  // CONNECTION TYPE
  // =====================================================

  static Future<ConnectivityResult>
      getConnectionType() async {
    final result =
        await _connectivity.checkConnectivity();

    if (result.isNotEmpty) {
      return result.first;
    }

    return ConnectivityResult.none;
  }

  // =====================================================
  // WIFI
  // =====================================================

  static Future<bool> isWifi() async {
    final type =
        await getConnectionType();

    return type ==
        ConnectivityResult.wifi;
  }

  // =====================================================
  // MOBILE
  // =====================================================

  static Future<bool> isMobile() async {
    final type =
        await getConnectionType();

    return type ==
        ConnectivityResult.mobile;
  }

  // =====================================================
  // ETHERNET
  // =====================================================

  static Future<bool> isEthernet() async {
    final type =
        await getConnectionType();

    return type ==
        ConnectivityResult.ethernet;
  }

  // =====================================================
  // VPN
  // =====================================================

  static Future<bool> isVpn() async {
    final type =
        await getConnectionType();

    return type ==
        ConnectivityResult.vpn;
  }

  // =====================================================
  // CONNECTION STREAM
  // =====================================================

  static Stream<List<ConnectivityResult>>
      get onConnectivityChanged =>
          _connectivity.onConnectivityChanged;

  // =====================================================
  // PRIVATE
  // =====================================================

  static bool _isDisconnected(
    List<ConnectivityResult> result,
  ) {
    return result.contains(
          ConnectivityResult.none,
        ) &&
        result.length == 1;
  }
}