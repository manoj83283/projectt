class Assets {
  Assets._();

  // =====================================================
  // IMAGES
  // =====================================================

  static const Images images = Images();

  // =====================================================
  // ICONS
  // =====================================================

  static const IconsAssets icons =
      IconsAssets();

  // =====================================================
  // ANIMATIONS
  // =====================================================

  static const Animations animations =
      Animations();

  // =====================================================
  // SVG
  // =====================================================

  static const SvgAssets svg =
      SvgAssets();
}

class Images {
  const Images();

  final String logo =
      'assets/images/logo.png';

  final String logoDark =
      'assets/images/logo_dark.png';

  final String splashLogo =
      'assets/images/splash_logo.png';

  final String adminAvatar =
      'assets/images/admin_avatar.png';

  final String placeholder =
      'assets/images/placeholder.png';

  final String noData =
      'assets/images/no_data.png';

  final String emptyState =
      'assets/images/empty_state.png';

  final String loginBanner =
      'assets/images/login_banner.png';

  final String dashboardBanner =
      'assets/images/dashboard_banner.png';

  final String profilePlaceholder =
      'assets/images/profile_placeholder.png';
}

class IconsAssets {
  const IconsAssets();

  final String dashboard =
      'assets/icons/dashboard.png';

  final String customer =
      'assets/icons/customer.png';

  final String provider =
      'assets/icons/provider.png';

  final String booking =
      'assets/icons/booking.png';

  final String order =
      'assets/icons/order.png';

  final String payment =
      'assets/icons/payment.png';

  final String report =
      'assets/icons/report.png';

  final String analytics =
      'assets/icons/analytics.png';

  final String notification =
      'assets/icons/notification.png';

  final String settings =
      'assets/icons/settings.png';
}

class SvgAssets {
  const SvgAssets();

  final String logo =
      'assets/svg/logo.svg';

  final String emptyData =
      'assets/svg/empty_data.svg';

  final String noInternet =
      'assets/svg/no_internet.svg';

  final String maintenance =
      'assets/svg/maintenance.svg';

  final String analytics =
      'assets/svg/analytics.svg';

  final String dashboard =
      'assets/svg/dashboard.svg';

  final String login =
      'assets/svg/login.svg';
}

class Animations {
  const Animations();

  final String loading =
      'assets/animations/loading.json';

  final String success =
      'assets/animations/success.json';

  final String error =
      'assets/animations/error.json';

  final String noData =
      'assets/animations/no_data.json';

  final String empty =
      'assets/animations/empty.json';

  final String notification =
      'assets/animations/notification.json';
}