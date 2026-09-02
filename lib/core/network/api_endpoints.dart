/// All backend route paths for the tenant app, relative to [AppConfig.baseUrl].
///
/// Only tenant-facing endpoints are declared here. Owner/admin status-mutation
/// routes are intentionally omitted — the tenant app never calls them.
class ApiEndpoints {
  const ApiEndpoints._();

  // Auth
  static const login = '/api/auth/login';
  static const register = '/api/auth/register';

  // Properties
  static const properties = '/api/properties';
  static String property(String id) => '/api/properties/$id';
  static String propertyMedia(String id) => '/api/properties/$id/media';

  // Amenities
  static const amenities = '/api/amenities';

  // Viewing requests
  static const viewingRequests = '/api/viewingrequests';
  static String viewingRequest(String id) => '/api/viewingrequests/$id';

  // Booking requests
  static const bookingRequests = '/api/bookingrequests';
  static String bookingRequest(String id) => '/api/bookingrequests/$id';
}
