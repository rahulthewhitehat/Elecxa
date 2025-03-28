/* © [2024] [Rahul Babu M P]
All Rights Reserved.
This file is part of the Elecxa project and contains proprietary and
confidential information. Unauthorized copying, distribution, or use
of this file, via any medium, is strictly prohibited.
Proprietary information should not be shared without prior written permission. */

import 'package:elecxa/screens/browse_products_screen.dart';
import 'package:elecxa/screens/browse_stores_screen.dart';
import 'package:elecxa/screens/messages_list_screen.dart';
import 'package:elecxa/screens/product_management_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'screens/profile_view_edit_customer.dart';
import 'screens/profile_view_edit_store_owner.dart';
import 'screens/about_screen.dart';
import 'screens/customer_requests_screen.dart';
import 'screens/store_owner_notifications_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
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
        '/browseProducts': (context) => BrowseProductsScreen(),
        '/about': (context) => AboutScreen(),
        '/customerRequests': (context) => CustomerRequestsScreen(),
        '/storeOwnerRequests': (context) => NotificationsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/messages') {
          User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            return MaterialPageRoute(
              builder: (context) => MessagesListScreen(userId: user.uid),
            );
          } else {
            return MaterialPageRoute(
              builder: (context) => LoginScreen(role: 'customer'),
            );
          }
        }
        return null;
      },
    );
  }
}
