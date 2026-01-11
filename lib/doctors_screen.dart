import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Doctor {
  final String name;
  final String specialty;
  final String address;
  final String phone;
  final String email;
  final double rating;
  final int reviewsCount;
  final String imageUrl;
  final List<String> workingHours;
  final String description;
  final List<String> services;

  Doctor({
    required this.name,
    required this.specialty,
    required this.address,
    required this.phone,
    required this.email,
    required this.rating,
    required this.reviewsCount,
    required this.imageUrl,
    required this.workingHours,
    required this.description,
    required this.services,
  });
}

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedGovernorate = 'Cairo';
  String _selectedCenter = 'Nasr City';
  List<Doctor> _filteredDoctors = [];

  // Colors inspired by the logo
  static const Color primaryTeal = Color(0xFF2DB5A5);
  static const Color darkTeal = Color(0xFF1A8B7F);
  static const Color lightTeal = Color(0xFF4DD0C0);
  static const Color accentTeal = Color(0xFF7FDED6);

  final Map<String, List<String>> _governorateCenters = {
    'Cairo': ['Nasr City', 'Maadi', 'Zamalek', 'Heliopolis', 'Mokattam'],
    'Giza': ['Dokki', 'Mohandessin', 'Haram', 'Faisal', '6th of October'],
    'Alexandria': ['Sidi Gaber', 'Ibrahimia', 'Smouha', 'Montaza', 'Agami'],
    'Kafr El-Sheikh': ['City Center', 'Desouk', 'Fowa', 'Bella', 'Hamoul'],
  };

  final List<Doctor> _allDoctors = [
    Doctor(
      name: 'Dr. Ahmed Mohamed Ali',
      specialty: 'Psychiatrist and Mental Health Consultant',
      address: 'Tahrir Street, Nasr City, Cairo',
      phone: '+20 123 456 7890',
      email: 'dr.ahmed@example.com',
      rating: 4.8,
      reviewsCount: 156,
      imageUrl: '',
      workingHours: ['Saturday - Thursday: 9:00 AM - 8:00 PM', 'Friday: 2:00 PM - 6:00 PM'],
      description: '15 years of experience in treating depression, anxiety, and mood disorders',
      services: ['Depression Treatment', 'Anxiety Treatment', 'Psychotherapy', 'Couples Counseling'],
    ),
    Doctor(
      name: 'Dr. Fatma Hassan Mahmoud',
      specialty: 'Psychologist and Behavioral Therapist',
      address: 'Haram Street, Giza',
      phone: '+20 123 456 7891',
      email: 'dr.fatma@example.com',
      rating: 4.9,
      reviewsCount: 203,
      imageUrl: '',
      workingHours: ['Saturday - Thursday: 10:00 AM - 7:00 PM', 'Friday: Closed'],
      description: 'Specialized in cognitive behavioral therapy and child disorders',
      services: ['Behavioral Therapy', 'Child Therapy', 'Behavior Modification', 'Family Therapy'],
    ),
    Doctor(
      name: 'Dr. Mohamed Abdel Rahman',
      specialty: 'Psychiatric Consultant',
      address: 'Nile Corniche, Maadi, Cairo',
      phone: '+20 123 456 7892',
      email: 'dr.mohamed@example.com',
      rating: 4.7,
      reviewsCount: 89,
      imageUrl: '',
      workingHours: ['Sunday - Thursday: 11:00 AM - 9:00 PM', 'Friday & Saturday: 3:00 PM - 7:00 PM'],
      description: 'Expert in addiction treatment and personality disorders',
      services: ['Addiction Treatment', 'Personality Disorders', 'Group Therapy', 'Rehabilitation'],
    ),
    Doctor(
      name: 'Dr. Sara Ahmed Ibrahim',
      specialty: 'Psychiatrist and Psychotherapist',
      address: 'Fouad Street, Alexandria',
      phone: '+20 123 456 7893',
      email: 'dr.sara@example.com',
      rating: 4.6,
      reviewsCount: 134,
      imageUrl: '',
      workingHours: ['Saturday - Thursday: 9:30 AM - 6:30 PM', 'Friday: 1:00 PM - 5:00 PM'],
      description: 'Specialized in treating anxiety disorders and OCD',
      services: ['Anxiety Treatment', 'OCD Treatment', 'Sleep Disorders', 'Psychotherapy'],
    ),
    Doctor(
      name: 'Dr. Khaled Mohamed Saad',
      specialty: 'Mental Health Consultant',
      address: 'Republic Street, Kafr El-Sheikh',
      phone: '+20 123 456 7894',
      email: 'dr.khaled@example.com',
      rating: 4.5,
      reviewsCount: 67,
      imageUrl: '',
      workingHours: ['Saturday - Thursday: 8:00 AM - 5:00 PM', 'Friday: 12:00 PM - 4:00 PM'],
      description: 'Experienced in treating mood disorders and psychological trauma',
      services: ['Mood Disorders', 'Trauma Treatment', 'Psychotherapy', 'Mental Health Counseling'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _filterDoctors();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _filterDoctors() {
    setState(() {
      _filteredDoctors = _allDoctors.where((doctor) {
        return doctor.address.contains(_selectedGovernorate) ||
               doctor.address.contains(_selectedCenter);
      }).toList();
    });
  }

  void _showDoctorDetails(Doctor doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DoctorDetailsSheet(doctor: doctor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Doctors'),
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
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildSearchFilters(),
              Expanded(
                child: _buildDoctorsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: Colors.white),
              const SizedBox(width: 8),
              const Text(
                'Choose Location',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedGovernorate,
                    dropdownColor: darkTeal,
                    style: const TextStyle(color: Colors.white),
                    underline: const SizedBox(),
                    isExpanded: true,
                    items: _governorateCenters.keys.map((governorate) {
                      return DropdownMenuItem(
                        value: governorate,
                        child: Text(governorate),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedGovernorate = value;
                          _selectedCenter = _governorateCenters[value]!.first;
                        });
                        _filterDoctors();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedCenter,
                    dropdownColor: darkTeal,
                    style: const TextStyle(color: Colors.white),
                    underline: const SizedBox(),
                    isExpanded: true,
                    items: _governorateCenters[_selectedGovernorate]!.map((center) {
                      return DropdownMenuItem(
                        value: center,
                        child: Text(center),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCenter = value;
                        });
                        _filterDoctors();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsList() {
    if (_filteredDoctors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Colors.white70,
            ),
            const SizedBox(height: 16),
            const Text(
              'No doctors found in this area',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try searching in another area',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredDoctors.length,
      itemBuilder: (context, index) {
        final doctor = _filteredDoctors[index];
        return _buildDoctorCard(doctor);
      },
    );
  }

  Widget _buildDoctorCard(Doctor doctor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDoctorDetails(doctor),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: lightTeal.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            doctor.specialty,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildRatingWidget(doctor.rating, doctor.reviewsCount),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        doctor.address,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.phone_rounded, color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      doctor.phone,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _makePhoneCall(doctor.phone),
                        icon: const Icon(Icons.phone_rounded),
                        label: const Text('Call'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: lightTeal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showDoctorDetails(doctor),
                        icon: const Icon(Icons.info_rounded),
                        label: const Text('Details'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingWidget(double rating, int reviewsCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.orange, size: 16),
          const SizedBox(width: 4),
          Text(
            rating.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '($reviewsCount)',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to make a call to $phoneNumber'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class DoctorDetailsSheet extends StatelessWidget {
  final Doctor doctor;

  const DoctorDetailsSheet({super.key, required this.doctor});

  static const Color primaryTeal = Color(0xFF2DB5A5);
  static const Color darkTeal = Color(0xFF1A8B7F);
  static const Color lightTeal = Color(0xFF4DD0C0);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: darkTeal,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: lightTeal.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            doctor.specialty,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.orange, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                '${doctor.rating} (${doctor.reviewsCount} reviews)',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection('About the Doctor', doctor.description),
                    const SizedBox(height: 20),
                    _buildServicesSection(),
                    const SizedBox(height: 20),
                    _buildContactSection(),
                    const SizedBox(height: 20),
                    _buildWorkingHoursSection(),
                    const SizedBox(height: 30),
                    _buildActionButtons(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkTeal,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Services',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkTeal,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: doctor.services.map((service) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: lightTeal.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: lightTeal),
              ),
              child: Text(
                service,
                style: const TextStyle(
                  color: darkTeal,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkTeal,
          ),
        ),
        const SizedBox(height: 12),
        _buildContactItem(Icons.location_on_rounded, 'Address', doctor.address),
        _buildContactItem(Icons.phone_rounded, 'Phone', doctor.phone),
        _buildContactItem(Icons.email_rounded, 'Email', doctor.email),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryTeal, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingHoursSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Working Hours',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkTeal,
          ),
        ),
        const SizedBox(height: 8),
        ...doctor.workingHours.map((hours) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.access_time_rounded, color: primaryTeal, size: 16),
                const SizedBox(width: 8),
                Text(
                  hours,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _makePhoneCall(doctor.phone),
            icon: const Icon(Icons.phone_rounded),
            label: const Text('Call'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _sendEmail(doctor.email),
            icon: const Icon(Icons.email_rounded),
            label: const Text('Send Email'),
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryTeal,
              side: const BorderSide(color: primaryTeal),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Appointment Inquiry&body=Hello, I would like to book an appointment for a consultation.',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }
}