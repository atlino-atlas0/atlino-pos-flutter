class AppConstants {
  // Base URL of the backend API.
  // The Next.js frontend on Vercel proxies /api/* to the Express backend,
  // so we point directly at the frontend URL.
  // Change this to the production URL or your local IP for testing.
  static const String baseUrl =
      'https://bigrayn-pos-frontend.vercel.app';

  static const String appName = 'Atlino POS';
  static const String tokenKey = 'atlino_token';
  static const String userKey = 'atlino_user';

  // Default tax rates (can be overridden by product-level rates)
  static const double defaultCgst = 2.5;
  static const double defaultSgst = 2.5;
}
