class GCPConfig {
  // Google Cloud SQL Configuration Example
  // Copy this file to gcp_config.dart and fill in your actual values

  static const String host = 'YOUR_GCP_PUBLIC_IP'; // e.g., '34.123.45.67'
  static const int port = 5432;
  static const String database = 'fastfoodie';
  static const String username = 'postgres';
  static const String password = 'IZijPuxgY+8Gm(D@';

  // Connection string format
  static String get connectionString =>
      'postgresql://$username:$password@$host:$port/$database';
}
