/// Centralized route paths and names for go_router.
class Routes {
  const Routes._();

  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';

  // Shell tabs
  static const home = '/home';
  static const search = '/search';
  static const favorites = '/favorites';
  static const requests = '/requests';
  static const account = '/account';

  // Details & flows (top-level, above the shell)
  static const property = '/property'; // + /:id
  static String propertyDetails(String id) => '/property/$id';
  static String viewingRequest(String id) => '/property/$id/viewing';
  static String bookingRequest(String id) => '/property/$id/booking';

  static const notifications = '/notifications';
  static const settings = '/settings';

  // Post-submission confirmation (top-level).
  static const requestSuccess = '/request-success';
}
