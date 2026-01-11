import 'package:flutter/material.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Colors inspired by the logo
  static const Color primaryTeal = Color(0xFF2DB5A5);
  static const Color darkTeal = Color(0xFF1A8B7F);
  static const Color lightTeal = Color(0xFF4DD0C0);
  static const Color accentTeal = Color(0xFF7FDED6);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Safe Space'),
        backgroundColor: primaryTeal,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
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
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 30),
                    _buildInstituteInfo(),
                    const SizedBox(height: 30),
                    _buildMissionVision(),
                    const SizedBox(height: 30),
                    _buildTeamSection(),
                    const SizedBox(height: 30),
                    _buildContactInfo(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.asset(
                'assets/images/logoo.jpg',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: primaryTeal,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Higher Institute of Engineering and Technology',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'Kafr El Sheikh',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Towards a more mentally aware community',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInstituteInfo() {
    return _buildInfoCard(
      title: 'About the Project',
      icon: Icons.info_rounded,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Safe Space is a graduation project from the Higher Institute of Engineering and Technology in Kafr El Sheikh, aiming to provide a safe and supportive environment for individuals needing psychological help and emotional support.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureItem('Safe initial psychological support'),
          _buildFeatureItem('User-friendly interface'),
          _buildFeatureItem('Complete privacy and security'),
          _buildFeatureItem('Advanced AI technologies'),
          _buildFeatureItem('Multi-language support'),
        ],
      ),
    );
  }

  Widget _buildMissionVision() {
    return Column(
      children: [
        _buildInfoCard(
          title: 'Our Vision',
          icon: Icons.visibility_rounded,
          content: const Text(
            'To contribute to breaking the barrier of fear in seeking psychological help, and to be a safe starting point for everyone needing mental health support on their journey to better well-being.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          title: 'Our Mission',
          icon: Icons.flag_rounded,
          content: const Text(
            'We are committed to providing a safe and comfortable space to express feelings and thoughts, ensuring complete privacy and offering initial support to help users take the first step toward professional help.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamSection() {
    return _buildInfoCard(
      title: 'Our Team',
      icon: Icons.group_rounded,
      content: Column(
        children: [
          const Text(
            'The Safe Space team consists of distinguished students from the Higher Institute of Engineering and Technology in Kafr El Sheikh:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          _buildTeamMember(
            name: 'Ahmed Osama Ahmed Saeed',
            role: 'App Developer and Software Engineer',
            icon: Icons.code_rounded,
          ),
          _buildTeamMember(
            name: 'Ahmed Abdelrahman Elfar',
            role: 'UI Developer and UX Designer',
            icon: Icons.design_services_rounded,
          ),
          _buildTeamMember(
            name: 'Ibrahim Mohamed Elbahnsy',
            role: 'Database and Security Engineer',
            icon: Icons.security_rounded,
          ),
          _buildTeamMember(
            name: 'Ahmed Samir Elkhouly',
            role: 'AI Developer',
            icon: Icons.psychology_rounded,
          ),
          _buildTeamMember(
            name: 'Ahmed Essam Ghazi',
            role: 'Network and Server Engineer',
            icon: Icons.cloud_rounded,
          ),
          _buildTeamMember(
            name: 'Amr Mohamed Abdeltawab Ghoniem',
            role: 'App Developer and Systems Analyst',
            icon: Icons.analytics_rounded,
          ),
          _buildTeamMember(
            name: 'Mohamed Ibrahim Mohamed abodesoky',
            role: 'Developer and Testing Engineer',
            icon: Icons.bug_report_rounded,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: lightTeal.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: lightTeal.withOpacity(0.5)),
            ),
            child: const Text(
              'Under the supervision of professors at the Higher Institute of Engineering and Technology in Kafr El Sheikh',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return _buildInfoCard(
      title: 'Institute Information',
      icon: Icons.contact_mail_rounded,
      content: Column(
        children: [
          _buildContactItem(
            icon: Icons.location_on_rounded,
            title: 'Address',
            value: 'Kafr El Sheikh, Egypt',
          ),
          _buildContactItem(
            icon: Icons.school_rounded,
            title: 'Institute',
            value: 'Higher Institute of Engineering and Technology',
          ),
          _buildContactItem(
            icon: Icons.code_rounded,
            title: 'Major',
            value: 'Department of Computers and Control',
          ),
          _buildContactItem(
            icon: Icons.calendar_today_rounded,
            title: 'Graduation Year',
            value: '2025',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: lightTeal.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: lightTeal,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMember({
    required String name,
    required String role,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentTeal.withOpacity(0.3),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: lightTeal,
            size: 20,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}