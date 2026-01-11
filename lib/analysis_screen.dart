import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalysisScreen extends StatelessWidget {
  final Map<String, dynamic> analysisResult;
  final String userName;

  const AnalysisScreen({
    super.key,
    required this.analysisResult,
    required this.userName,
  });

  static const Color primaryTeal = Color(0xFF2DB5A5);
  static const Color darkTeal = Color(0xFF1A8B7F);
  static const Color lightTeal = Color(0xFF4DD0C0);
  static const Color accentTeal = Color(0xFF7FDED6);

  @override
  Widget build(BuildContext context) {
    final isEmpty = analysisResult['status'] == 'empty';
    final isError = analysisResult['status'] == 'error';
    final needsSpecialist = analysisResult['needs_specialist'] ?? false;
    final specialistType = analysisResult['specialist_type']?.toString() ?? 'Not specified';
    final dominantEmotion = isEmpty ? 'Unknown' : analysisResult['dominant_emotion']?.toString().capitalize() ?? 'Unknown';
    final advice = _parseAdvice(analysisResult['advice']);
    final riskLevel = _parseRiskLevel(analysisResult['risk_level']?.toString());

    return Scaffold(
      appBar: AppBar(
        title: Text('Mental Health Analysis - $userName'),
        backgroundColor: primaryTeal,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Arial',
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Re-analyze',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share Report',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Sharing feature will be added soon'),
                  backgroundColor: primaryTeal,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
          ),
        ],
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                if (isEmpty)
                  _buildEmptyAnalysisCard()
                else if (isError || analysisResult.isEmpty)
                  _buildErrorCard(isError)
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEmotionChart(dominantEmotion, riskLevel),
                      const SizedBox(height: 20),
                      _buildRiskIndicator(riskLevel),
                      const SizedBox(height: 20),
                      _buildAnalysisCard(
                        title: 'Dominant Emotional State',
                        content: dominantEmotion,
                        icon: Icons.psychology_rounded,
                      ),
                      const SizedBox(height: 16),
                      if (needsSpecialist)
                        _buildAnalysisCard(
                          title: 'Recommended Specialist',
                          content: specialistType,
                          icon: Icons.medical_services_rounded,
                          isImportant: true,
                        )
                      else
                        _buildAnalysisCard(
                          title: 'General Assessment',
                          content: 'Your mental state is stable',
                          icon: Icons.check_circle_rounded,
                          isPositive: true,
                        ),
                      const SizedBox(height: 16),
                      _buildAdviceList(advice),
                      const SizedBox(height: 20),
                      _buildActionButtons(),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.analytics_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mental Health Report',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Comprehensive analysis of your current mental state',
                  style: TextStyle(
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

  List<String> _parseAdvice(dynamic advice) {
    if (advice is List) {
      return advice.map((e) => e.toString()).toList();
    }
    return [];
  }

  String _parseRiskLevel(String? riskLevel) {
    final level = riskLevel?.toLowerCase() ?? 'low';
    return ['high', 'moderate', 'low'].contains(level) ? level : 'low';
  }

  Widget _buildEmotionChart(String dominantEmotion, String riskLevel) {
    final colorMap = {
      'positive': lightTeal,
      'negative': Colors.orange,
      'unknown': accentTeal,
    };
    final color = colorMap[dominantEmotion.toLowerCase()] ?? accentTeal;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Text(
            'Emotional State',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: 1,
                    title: dominantEmotion,
                    color: color,
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
                sectionsSpace: 0,
                centerSpaceRadius: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskIndicator(String riskLevel) {
    final config = {
      'high': {
        'color': Colors.red,
        'text': 'High Risk - Immediate attention recommended',
        'icon': Icons.warning_rounded
      },
      'moderate': {
        'color': Colors.orange,
        'text': 'Moderate Risk - Professional consultation recommended',
        'icon': Icons.info_rounded
      },
      'low': {
        'color': lightTeal,
        'text': 'Low Risk - Continue self-care practices',
        'icon': Icons.check_circle_rounded
      },
    }[riskLevel] ?? {
      'color': lightTeal,
      'text': 'Low Risk',
      'icon': Icons.check_circle_rounded
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (config['color'] as Color).withOpacity(0.15),
        border: Border.all(color: config['color'] as Color, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            config['icon'] as IconData,
            color: config['color'] as Color,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              config['text'] as String,
              style: TextStyle(
                color: config['color'] as Color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAnalysisCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.grey, size: 48),
          const SizedBox(height: 12),
          Text(
            analysisResult['message']?.toString() ?? 'Analysis data is empty during testing.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          _buildAnalysisCard(
            title: 'Dominant Emotional State',
            content: 'N/A',
            icon: Icons.psychology_rounded,
          ),
          const SizedBox(height: 16),
          _buildAnalysisCard(
            title: 'Recommended Specialist',
            content: 'N/A',
            icon: Icons.medical_services_rounded,
          ),
          const SizedBox(height: 16),
          _buildAdviceList([]),
          const SizedBox(height: 16),
          _buildRiskIndicator('low'),
        ],
      ),
    );
  }

  Widget _buildErrorCard(bool isError) {
    if (analysisResult.isEmpty || isError) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          border: Border.all(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_rounded, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(
              analysisResult['message']?.toString() ?? "There is not enough data yet for analysis.",
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildAnalysisCard({
    required String title,
    required String content,
    required IconData icon,
    bool isImportant = false,
    bool isPositive = false,
  }) {
    final color = isImportant
        ? Colors.orange
        : isPositive
            ? lightTeal
            : accentTeal;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceList(List<String> advice) {
    if (advice.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_rounded,
                color: accentTeal,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Recommended Tips and Practices:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...advice.asMap().entries.map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: accentTeal,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Add report saving functionality
            },
            icon: const Icon(Icons.save_rounded),
            label: const Text('Save Report'),
            style: ElevatedButton.styleFrom(
              backgroundColor: lightTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // Add report printing functionality
            },
            icon: const Icon(Icons.print_rounded),
            label: const Text('Print'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
