class AppConstants {
  // Base URL of the backend API.
  // The Next.js frontend on Vercel proxies /api/* to the Express backend,
  // so we point directly at the frontend URL.
  // Change this to the production URL or your local IP for testing.
  // Production backend URL — verified working 2026-04-10.
  // If this stops working after a new deployment, update to the latest
  // Vercel production URL from the GitHub deployments page.
  static const String baseUrl =
      'https://bigrayn-pos-frontend-2wd0c8qov-atlino-atlas0s-projects.vercel.app';

  static const String appName = 'Atlino POS';
  static const String tokenKey = 'atlino_token';
  static const String userKey = 'atlino_user';

  // Default tax rates (can be overridden by product-level rates)
  static const double defaultCgst = 2.5;
  static const double defaultSgst = 2.5;
}
