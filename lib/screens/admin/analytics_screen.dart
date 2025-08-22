import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../dashboard/access_analytics.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.analytics, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              'System Analytics',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    Colors.blue.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.bar_chart,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Access Analytics Dashboard',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Monitor system usage patterns and access trends',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Analytics Component
            const AccessAnalytics(isAdmin: true),
          ],
        ),
      ),
    );
  }
}