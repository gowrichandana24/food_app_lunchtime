import 'package:flutter/material.dart';
import 'login_page.dart';
import 'detail_page.dart';
import 'cafeteria_page.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'notification_page.dart'; // Added import

class ProfilePage extends StatelessWidget {
  final VoidCallback toggleTheme; 

  ProfilePage({super.key, required this.toggleTheme});

  final List<Map<String, dynamic>> menuItems = [
    {"title": "Personal Info", "icon": Icons.person},
    {"title": "Favorite Items", "icon": Icons.favorite},
    {"title": "Order Details", "icon": Icons.receipt},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final background = isDark ? const Color(0xFF020617) : const Color(0xFFF4F6F9);
    final cardColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF10254E);
    final subtitleColor = isDark ? Colors.white70 : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: background,
      extendBody: true, 
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              SafeArea(
                bottom: false,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                       onTap: () {
  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  } else {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => CafeteriaPage(toggleTheme: toggleTheme),
      ),
      (route) => false,
    );
  }
},
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F4CFF).withOpacity(0.2) : const Color(0xFF0F4CFF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFF0F4CFF),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Profile",
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: toggleTheme,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F4CFF).withOpacity(0.2) : const Color(0xFF0F4CFF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                            color: const Color(0xFF0F4CFF),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          // Notification action fixed
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => NotificationPage()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F4CFF).withOpacity(0.2) : const Color(0xFF0F4CFF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.notifications_none,
                            color: Color(0xFF0F4CFF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 10, bottom: 120), 
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [const Color(0xFF020617), const Color(0xFF0F172A)]
                              : [const Color(0xFF0F4CFF), const Color(0xFF4F8CFF)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.white24, Colors.white10],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
  Text(
    FirebaseAuth.instance.currentUser?.displayName ?? 'User',
    style: const TextStyle(
      fontFamily: 'Nunito',
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),
  const SizedBox(height: 4),
  Text(
    FirebaseAuth.instance.currentUser?.email ?? '',
    style: const TextStyle(
      fontFamily: 'Inter',
      color: Colors.white70,
      fontSize: 13,
    ),
  ),
],
                                ),
                              ),
                            ],  
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.15)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Nevark Corporate',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Office cafeteria member',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                              blurRadius: 25,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          children: menuItems.map((item) {
                            final index = menuItems.indexOf(item);
                            return Column(
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F4CFF).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      item['icon'],
                                      color: const Color(0xFF0F4CFF),
                                    ),
                                  ),
                                  title: Text(
                                    item['title'],
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      color: textColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: subtitleColor,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DetailPage(title: item['title']),
                                      ),
                                    );
                                  },
                                ),
                                if (index != menuItems.length - 1)
                                  Divider(
                                    color: isDark ? Colors.white12 : Colors.grey.shade200,
                                  ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: SizedBox(
                        width: 280,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F4CFF),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),  
                          ),
                     onPressed: () async {
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    // 🔥 Sign out from Google
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.signOut(); // good
    }

    // 🔥 Sign out from Firebase
    await FirebaseAuth.instance.signOut();

  } catch (e) {
    print("Logout error: $e");
  }

  // ✅ THIS IS WHAT YOU MISSED
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (_) => LoginPage(toggleTheme: toggleTheme),
    ),
    (route) => false,
  );
},
                          child: const Text(
                            'Logout',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomFloatingNavBar(
        currentIndex: 2, 
        isDark: isDark,
        toggleTheme: toggleTheme,
      ),
    );
  }
}
Future<void> logout(BuildContext context) async {
  final GoogleSignIn googleSignIn = GoogleSignIn();

  await googleSignIn.signOut(); // 🔥 THIS clears Google session
  await FirebaseAuth.instance.signOut(); // Firebase logout

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => LoginPage()),
    (route) => false,
  );
}
