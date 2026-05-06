import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'screens/login_page.dart';
import 'screens/cafeteria_page.dart';
import 'screens/vendor/vendor_home_page.dart';

class AuthGate extends StatelessWidget {
  final VoidCallback toggleTheme;

  const AuthGate({super.key, required this.toggleTheme});

  Future<Widget> _getHome() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return LoginPage(toggleTheme: toggleTheme);
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) {
      return LoginPage(toggleTheme: toggleTheme);
    }

    final role = doc['role'] ?? 'user';

    if (role == 'vendor') {
      return VendorHomePage(toggleTheme: toggleTheme);
    } else {
      return CafeteriaPage(toggleTheme: toggleTheme);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getHome(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data!;
      },
    );
  }
}
