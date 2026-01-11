import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ لازم تضيف ده
import 'package:safe_space/about_screen.dart';
import 'package:safe_space/contact_us_screen.dart';
import 'package:safe_space/disclaimer_screen.dart';
import 'package:safe_space/doctors_screen.dart';
import 'package:safe_space/chat_screen.dart';
import 'package:safe_space/firestore_seed.dart';
import 'package:safe_space/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color primaryTeal = Color(0xFF2DB5A5);
  static const Color darkTeal = Color(0xFF1A8B7F);
  static const Color lightTeal = Color(0xFF4DD0C0);
  static const Color accentTeal = Color(0xFF7FDED6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Safe Space - Home',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryTeal,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryTeal, darkTeal],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              children: [
                _buildFeatureCard(
                  context,
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Chat',
                  description: 'Start a conversation with your personal assistant.',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatScreen()));
                  },
                
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.medical_services_outlined,
                  title: 'Doctors',
                  description: 'Find specialized doctors.',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const DoctorsScreen()));
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.info_outline_rounded,
                  title: 'About the App',
                  description: 'Learn about Safe Space and our mission.',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()));
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.contact_mail_outlined,
                  title: 'Contact Us',
                  description: 'Connect with us for inquiries and support.',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactUsScreen()));
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.warning_amber_rounded,
                  title: 'Disclaimer',
                  description: 'Read the terms of use and disclaimer.',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const DisclaimerScreen()));
                  },
                ),
                // ✅ زرار تسجيل الخروج
                _buildFeatureCard(
                  context,
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  description: 'Sign out from your account.',
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context,
      {required IconData icon,
      required String title,
      required String description,
      required VoidCallback onTap}) {
    return Card(
      color: lightTeal.withOpacity(0.9),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
