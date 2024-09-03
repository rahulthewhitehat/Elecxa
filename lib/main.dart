import 'package:elecxa/screens/browse_products_screen.dart';
import 'package:elecxa/screens/browse_stores_screen.dart';
import 'package:elecxa/screens/product_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/login_screen.dart';
import 'screens/customer_details_screen.dart';
import 'screens/store_owner_details_screen.dart';
import 'dashboards/customer_dashboard.dart';
import 'dashboards/store_owner_dashboard.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_view_edit_customer.dart'; // Import customer profile screen
import 'screens/profile_view_edit_store_owner.dart'; // Import store owner profile screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ElecxaApp());
}

class ElecxaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elecxa',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/roleSelection': (context) => RoleSelectionScreen(),
        '/customerLogin': (context) => LoginScreen(role: 'customer'),
        '/storeOwnerLogin': (context) => LoginScreen(role: 'storeOwner'),
        '/customerDetails': (context) => CustomerDetailsScreen(),
        '/storeOwnerDetails': (context) => StoreOwnerDetailsScreen(),
        '/customerDashboard': (context) => CustomerDashboard(),
        '/storeOwnerDashboard': (context) => StoreOwnerDashboard(),
        '/settings': (context) => SettingsScreen(),
        '/customerProfile': (context) => CustomerProfileViewEditScreen(),
        '/storeOwnerProfile': (context) => StoreOwnerProfileViewEditScreen(),
        '/productManagement': (context) => ManageProductsScreen(),
        '/browseStores': (context) => BrowseStoresScreen(),
        '/browseProducts': (context) => BrowseProductsScreen()
      },
    );
  }
}