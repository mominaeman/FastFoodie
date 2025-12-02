# Supabase Integration Guide

## Setup Complete! ✓

Your Flutter project is now configured to work with Supabase. Here's what was done:

### 1. Installed Dependencies
- Added `supabase_flutter: ^2.8.0` to `pubspec.yaml`
- Ran `flutter pub get` to install the package

### 2. Created Configuration File
- Created `lib/supabase_config.dart` to store your Supabase credentials

### 3. Initialized Supabase
- Updated `lib/main.dart` to initialize Supabase before the app runs
- Added a global `supabase` client reference for easy access throughout your app

## Next Steps

### 1. Get Your Supabase Credentials

1. Go to your Supabase project dashboard: https://supabase.com/dashboard
2. Click on your project
3. Go to **Settings** > **API**
4. Copy the following values:
   - **Project URL** (URL)
   - **anon public** key (API Key)

### 2. Update Your Configuration

Open `lib/supabase_config.dart` and replace the placeholder values:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://your-project.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key-here';
}
```

### 3. Usage Examples

#### Authentication Example
```dart
// Sign up
final response = await supabase.auth.signUp(
  email: 'user@example.com',
  password: 'password123',
);

// Sign in
final authResponse = await supabase.auth.signInWithPassword(
  email: 'user@example.com',
  password: 'password123',
);

// Sign out
await supabase.auth.signOut();

// Get current user
final user = supabase.auth.currentUser;
```

#### Database Example
```dart
// Insert data
await supabase
  .from('orders')
  .insert({'user_id': 123, 'total': 50.0, 'status': 'pending'});

// Query data
final data = await supabase
  .from('orders')
  .select()
  .eq('user_id', 123)
  .order('created_at', ascending: false);

// Update data
await supabase
  .from('orders')
  .update({'status': 'completed'})
  .eq('id', orderId);

// Delete data
await supabase
  .from('orders')
  .delete()
  .eq('id', orderId);
```

#### Real-time Subscriptions
```dart
final subscription = supabase
  .from('orders')
  .stream(primaryKey: ['id'])
  .listen((List<Map<String, dynamic>> data) {
    // Handle real-time updates
    print('New data: $data');
  });

// Don't forget to cancel when done
subscription.cancel();
```

#### Storage Example
```dart
// Upload file
final file = File('path/to/image.jpg');
await supabase.storage
  .from('avatars')
  .upload('public/avatar.jpg', file);

// Get public URL
final imageUrl = supabase.storage
  .from('avatars')
  .getPublicUrl('public/avatar.jpg');

// Download file
final data = await supabase.storage
  .from('avatars')
  .download('public/avatar.jpg');
```

### 4. Important Security Notes

⚠️ **Never commit your Supabase credentials to version control!**

Add `lib/supabase_config.dart` to your `.gitignore`:

```
# Supabase credentials
lib/supabase_config.dart
```

For better security in production, consider using environment variables or Flutter's build configurations.

### 5. Database Setup

Create tables in your Supabase dashboard for your food delivery system:

**Suggested Tables:**
- `users` - User profiles
- `restaurants` - Restaurant information
- `menu_items` - Food items
- `orders` - Customer orders
- `order_items` - Items in each order
- `delivery_addresses` - User addresses
- `reviews` - Restaurant/food reviews

### 6. Row Level Security (RLS)

Don't forget to enable Row Level Security on your tables:

1. Go to **Authentication** > **Policies** in Supabase dashboard
2. Enable RLS on each table
3. Create policies to control access (e.g., users can only see their own orders)

## Additional Resources

- [Supabase Flutter Documentation](https://supabase.com/docs/reference/dart/introduction)
- [Flutter Authentication Guide](https://supabase.com/docs/guides/auth/auth-helpers/flutter-auth-ui)
- [Database Guide](https://supabase.com/docs/guides/database/overview)
- [Storage Guide](https://supabase.com/docs/guides/storage)

## Testing the Connection

Run your app to test the Supabase connection:

```bash
flutter run
```

If there are any connection issues, check:
1. Your credentials are correct in `supabase_config.dart`
2. Your internet connection is working
3. Your Supabase project is active

Happy coding! 🚀
