import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AccessAnalytics extends StatefulWidget {
  final bool isAdmin;
  final String? userId;

  const AccessAnalytics({Key? key, required this.isAdmin, this.userId}) : super(key: key);

  @override
  State<AccessAnalytics> createState() => _AccessAnalyticsState();
}

class _AccessAnalyticsState extends State<AccessAnalytics> {
  String _selectedTimeRange = 'week'; // 'today', 'week', 'month', or 'all'

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with Time Range Filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quick Overview',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTimeRange,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    items: const [
                      DropdownMenuItem(value: 'today', child: Text('Today')),
                      DropdownMenuItem(value: 'week', child: Text('Past Week')),
                      DropdownMenuItem(value: 'month', child: Text('Past Month')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedTimeRange = value;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildDailyAccessChart(),
        const SizedBox(height: 24),
        _buildAccessResultPieChart(),
      ],
    );
  }

  Widget _buildDailyAccessChart() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getAccessLogsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 250, child: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return SizedBox(height: 250, child: Center(child: Text('Error: ${snapshot.error}')));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox(height: 250, child: Center(child: Text('No access logs found')));
        }

        // Process data based on selected time range
        final logs = snapshot.data!.docs;
        final Map<String, Map<String, int>> dailyData = {};
        final now = DateTime.now();
        
        // Determine time range and initialize data
        int daysToShow;
        
        switch (_selectedTimeRange) {
          case 'today':
            daysToShow = 1;
            break;
          case 'week':
            daysToShow = 7;
            break;
          case 'month':
            daysToShow = 30;
            break;
          default:
            daysToShow = 7;
        }

        // Initialize the time period
        for (int i = daysToShow - 1; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          final dateStr = _selectedTimeRange == 'today' 
              ? DateFormat('HH:mm').format(date) // Show hours for today
              : DateFormat('MM/dd').format(date); // Show dates for other ranges
          dailyData[dateStr] = {'allowed': 0, 'denied': 0};
        }

        // Count logs by day and result
        for (var log in logs) {
          final data = log.data() as Map<String, dynamic>;
          final timestamp = (data['timestamp'] as Timestamp).toDate().toLocal();
          final result = data['result'] as String? ?? 'unknown';
          
          // Filter based on selected time range
          bool includeLog = false;
          String dateKey = '';
          
          switch (_selectedTimeRange) {
            case 'today':
              final today = DateTime(now.year, now.month, now.day);
              final logDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
              includeLog = logDate.isAtSameMomentAs(today);
              dateKey = DateFormat('HH:mm').format(timestamp);
              break;
            case 'week':
              includeLog = now.difference(timestamp).inDays < 7;
              dateKey = DateFormat('MM/dd').format(timestamp);
              break;
            case 'month':
              includeLog = now.difference(timestamp).inDays < 30;
              dateKey = DateFormat('MM/dd').format(timestamp);
              break;
          }
          
          if (includeLog) {
            // For "today" view, group by hour
            if (_selectedTimeRange == 'today') {
              final hourKey = DateFormat('HH:00').format(timestamp);
              if (!dailyData.containsKey(hourKey)) {
                dailyData[hourKey] = {'allowed': 0, 'denied': 0};
              }
              if (result == 'allowed') {
                dailyData[hourKey]!['allowed'] = (dailyData[hourKey]!['allowed'] ?? 0) + 1;
              } else if (result == 'denied') {
                dailyData[hourKey]!['denied'] = (dailyData[hourKey]!['denied'] ?? 0) + 1;
              }
            } else {
              // For other views, group by day
              if (dailyData.containsKey(dateKey)) {
                if (result == 'allowed') {
                  dailyData[dateKey]!['allowed'] = (dailyData[dateKey]!['allowed'] ?? 0) + 1;
                } else if (result == 'denied') {
                  dailyData[dateKey]!['denied'] = (dailyData[dateKey]!['denied'] ?? 0) + 1;
                }
              }
            }
          }
        }

        // Convert to bar chart data
        final List<BarChartGroupData> barGroups = [];
        int index = 0;
        dailyData.forEach((date, counts) {
          barGroups.add(
            BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: counts['allowed']!.toDouble(),
                  color: Colors.green,
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
                BarChartRodData(
                  toY: counts['denied']!.toDouble(),
                  color: Colors.red,
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          );
          index++;
        });

        // For "Past Month", use horizontal scroll to prevent crowded labels
        if (_selectedTimeRange == 'month') {
          return Container(
            height: 250,
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: dailyData.length * 50.0, // 50px per day for more spacing
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceEvenly,
                    maxY: barGroups.isEmpty ? 10 : null,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (group) => Colors.blueGrey.shade800,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final date = dailyData.keys.elementAt(group.x.toInt());
                          final value = rod.toY.round();
                          final type = rodIndex == 0 ? 'Allowed' : 'Denied';
                          return BarTooltipItem(
                            '$date\n$type: $value',
                            const TextStyle(color: Colors.white),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 5, // Show every 5th date to reduce crowding
                          getTitlesWidget: (value, meta) {
                            if (value < 0 || value >= dailyData.length) return const Text('');
                            // Only show labels for every 5th day
                            if (value.toInt() % 5 != 0) return const Text('');
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                dailyData.keys.elementAt(value.toInt()),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            if (value == 0) return const Text('0');
                            return Text(value.toInt().toString());
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: true),
                    borderData: FlBorderData(show: false),
                    barGroups: barGroups,
                  ),
                ),
              ),
            ),
          );
        }

        // For "Today" and "Past Week", use normal layout
        return Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: barGroups.isEmpty ? 10 : null,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) => Colors.blueGrey.shade800,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final date = dailyData.keys.elementAt(group.x.toInt());
                    final value = rod.toY.round();
                    final type = rodIndex == 0 ? 'Allowed' : 'Denied';
                    return BarTooltipItem(
                      '$date\n$type: $value',
                      const TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value < 0 || value >= dailyData.length) return const Text('');
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          dailyData.keys.elementAt(value.toInt()),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) return const Text('0');
                      return Text(value.toInt().toString());
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: true),
              borderData: FlBorderData(show: false),
              barGroups: barGroups,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccessResultPieChart() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getAccessLogsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox(height: 200, child: Center(child: Text('No data')));
        }

        final logs = snapshot.data!.docs;
        final now = DateTime.now();
        int allowed = 0;
        int denied = 0;

        // Filter logs by selected time range and count results
        for (var log in logs) {
          final data = log.data() as Map<String, dynamic>;
          final timestamp = (data['timestamp'] as Timestamp).toDate().toLocal();
          final result = data['result'] as String? ?? 'unknown';
          
          // Filter based on selected time range
          bool includeLog = false;
          
          switch (_selectedTimeRange) {
            case 'today':
              final today = DateTime(now.year, now.month, now.day);
              final logDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
              includeLog = logDate.isAtSameMomentAs(today);
              break;
            case 'week':
              includeLog = now.difference(timestamp).inDays < 7;
              break;
            case 'month':
              includeLog = now.difference(timestamp).inDays < 30;
              break;
          }
          
          if (includeLog) {
            if (result == 'allowed') {
              allowed++;
            } else if (result == 'denied') {
              denied++;
            }
          }
        }

        final total = allowed + denied;
        final allowedPercentage = total > 0 ? (allowed / total * 100).toStringAsFixed(1) : '0';
        final deniedPercentage = total > 0 ? (denied / total * 100).toStringAsFixed(1) : '0';

        return Column(
          children: [
            Text(
              'Access Results',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: allowed.toDouble(),
                      title: '$allowedPercentage%',
                      color: Colors.green,
                      radius: 60,
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    PieChartSectionData(
                      value: denied.toDouble(),
                      title: '$deniedPercentage%',
                      color: Colors.red,
                      radius: 60,
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Allowed', Colors.green),
                const SizedBox(width: 16),
                _buildLegendItem('Denied', Colors.red),
              ],
            ),
          ],
        );
      },
    );
  }



  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }



  Stream<QuerySnapshot> _getAccessLogsStream() {
    // Simplified query to avoid index requirements
    return FirebaseFirestore.instance
        .collection('access_logs')
        .orderBy('timestamp', descending: true)
        .limit(1000)
        .snapshots();
  }
}