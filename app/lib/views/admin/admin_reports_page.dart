import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/admin_viewmodel.dart';

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  String _selectedReportType = 'Overview';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportReport(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AdminViewModel>().refresh(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Consumer<AdminViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                    const SizedBox(height: 16),
                    Text('Error: ${viewModel.errorMessage}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => viewModel.refresh(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                _buildReportTypeSelector(),
                Expanded(
                  child: _buildReportContent(viewModel),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildReportTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Report Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  'Overview',
                  'User Analytics',
                  'Feedback Analytics',
                  'Performance Metrics',
                ].map((type) => ChoiceChip(
                  label: Text(type),
                  selected: _selectedReportType == type,
                  onSelected: (selected) {
                    setState(() {
                      _selectedReportType = type;
                    });
                  },
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportContent(AdminViewModel viewModel) {
    switch (_selectedReportType) {
      case 'Overview':
        return _buildOverviewReport(viewModel);
      case 'User Analytics':
        return _buildUserAnalyticsReport(viewModel);
      case 'Feedback Analytics':
        return _buildFeedbackAnalyticsReport(viewModel);
      case 'Performance Metrics':
        return _buildPerformanceMetricsReport(viewModel);
      default:
        return _buildOverviewReport(viewModel);
    }
  }

  Widget _buildOverviewReport(AdminViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSummaryCards(viewModel),
          const SizedBox(height: 16),
          _buildQuickStats(viewModel),
          const SizedBox(height: 16),
          _buildRecentActivity(viewModel),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(AdminViewModel viewModel) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 2.2,
      children: [
        _buildSummaryCard(
          'Total Users',
          viewModel.users.length.toString(),
          Icons.people,
          Colors.blue,
        ),
        _buildSummaryCard(
          'Total Feedback',
          viewModel.feedbacks.length.toString(),
          Icons.feedback,
          Colors.green,
        ),
        _buildSummaryCard(
          'Pending Issues',
          viewModel.feedbacks.where((f) => f.status == 'Pending').length.toString(),
          Icons.schedule,
          Colors.orange,
        ),
        _buildSummaryCard(
          'Resolved Issues',
          viewModel.feedbacks.where((f) => f.status == 'Resolved').length.toString(),
          Icons.check_circle,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(AdminViewModel viewModel) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Average Rating', '4.2/5', Icons.star, Colors.amber),
            _buildStatRow('Response Time', '2.3 days', Icons.timer, Colors.blue),
            _buildStatRow('Satisfaction Rate', '87%', Icons.sentiment_satisfied, Colors.green),
            _buildStatRow('Active Users', '${(viewModel.users.length * 0.75).round()}', Icons.person, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(AdminViewModel viewModel) {
    final recentFeedbacks = viewModel.feedbacks.take(5).toList();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (recentFeedbacks.isEmpty)
              const Center(
                child: Text('No recent activity'),
              )
            else
              ...recentFeedbacks.map((feedback) => _buildActivityItem(feedback)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(dynamic feedback) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: _getStatusColor(feedback.status).withValues(alpha: 0.2),
            child: Icon(
              _getStatusIcon(feedback.status),
              size: 16,
              color: _getStatusColor(feedback.status),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feedback.title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'By ${feedback.userName} • ${_formatDate(feedback.timestamp)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getStatusColor(feedback.status).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              feedback.status,
              style: TextStyle(
                fontSize: 12,
                color: _getStatusColor(feedback.status),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAnalyticsReport(AdminViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildUserDistributionChart(viewModel),
          const SizedBox(height: 24),
          _buildUserGrowthChart(viewModel),
          const SizedBox(height: 24),
          _buildUserActivityTable(viewModel),
        ],
      ),
    );
  }

  Widget _buildUserDistributionChart(AdminViewModel viewModel) {
    final roleCounts = <String, int>{};
    for (final user in viewModel.users) {
      roleCounts[user.role] = (roleCounts[user.role] ?? 0) + 1;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Distribution by Role',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...roleCounts.entries.map((entry) => _buildChartBar(entry.key, entry.value, viewModel.users.length)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartBar(String label, int value, int total) {
    final percentage = total > 0 ? (value / total * 100).round() : 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text('$value ($percentage%)'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: total > 0 ? value / total : 0,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(_getRoleColor(label)),
          ),
        ],
      ),
    );
  }

  Widget _buildUserGrowthChart(AdminViewModel viewModel) {
    // Generate sample data for user growth (in real app, this would come from database)
    final userGrowthData = _generateUserGrowthData(viewModel.users.length);
    
    // Debug: Print the data being generated
    print('User Growth Data: $userGrowthData');
    print('Users count: ${viewModel.users.length}');
    print('Data is empty: ${userGrowthData.isEmpty}');
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Growth Trend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: userGrowthData.isNotEmpty 
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Simple bar chart representation
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: userGrowthData.asMap().entries.map((entry) {
                              final height = (entry.value.value / userGrowthData.map((e) => e.value).reduce((a, b) => a > b ? a : b)) * 120;
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 30,
                                    height: height,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _getMonthLabels()[entry.key],
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Total Users: ${viewModel.users.length}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bar_chart, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'Chart data loading...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  List<MapEntry<int, double>> _generateUserGrowthData(int currentUserCount) {
    final data = <MapEntry<int, double>>[];
    
    // Ensure we have at least some data for the chart
    if (currentUserCount == 0) {
      // If no users, create sample data
      data.addAll([
        MapEntry(0, 5.0),
        MapEntry(1, 8.0),
        MapEntry(2, 12.0),
        MapEntry(3, 15.0),
        MapEntry(4, 18.0),
        MapEntry(5, 22.0),
      ]);
    } else {
      // Generate realistic growth data
      for (int i = 0; i < 6; i++) {
        int userCount = 0;
        if (i == 5) {
          userCount = currentUserCount;
        } else {
          userCount = (currentUserCount * (0.3 + (i * 0.15))).round();
        }
        data.add(MapEntry(i, userCount.toDouble()));
      }
    }
    
    return data;
  }

  List<String> _getMonthLabels() {
    return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
  }

  Widget _buildUserActivityTable(AdminViewModel viewModel) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Activity Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('User')),
                  DataColumn(label: Text('Role')),
                  DataColumn(label: Text('Feedback Count')),
                  DataColumn(label: Text('Last Active')),
                ],
                rows: viewModel.users.take(10).map((user) {
                  final userFeedbacks = viewModel.feedbacks.where((f) => f.userId == user.id).length;
                  return DataRow(cells: [
                    DataCell(Text(user.name)),
                    DataCell(Text(user.role)),
                    DataCell(Text(userFeedbacks.toString())),
                    DataCell(Text('Today')),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackAnalyticsReport(AdminViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFeedbackStatusChart(viewModel),
          const SizedBox(height: 24),
          _buildFeedbackCategoryChart(viewModel),
          const SizedBox(height: 24),
          _buildFeedbackTrendChart(viewModel),
        ],
      ),
    );
  }

  Widget _buildFeedbackStatusChart(AdminViewModel viewModel) {
    final statusCounts = <String, int>{};
    for (final feedback in viewModel.feedbacks) {
      statusCounts[feedback.status] = (statusCounts[feedback.status] ?? 0) + 1;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Feedback Status Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...statusCounts.entries.map((entry) => _buildChartBar(entry.key, entry.value, viewModel.feedbacks.length)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackCategoryChart(AdminViewModel viewModel) {
    final categoryCounts = <String, int>{};
    for (final feedback in viewModel.feedbacks) {
      categoryCounts[feedback.category] = (categoryCounts[feedback.category] ?? 0) + 1;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Feedback by Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...categoryCounts.entries.map((entry) => _buildChartBar(entry.key, entry.value, viewModel.feedbacks.length)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackTrendChart(AdminViewModel viewModel) {
    // Generate sample data for feedback trend (in real app, this would come from database)
    final feedbackTrendData = _generateFeedbackTrendData(viewModel.feedbacks.length);
    
    // Debug: Print the data being generated
    print('Feedback Trend Data: $feedbackTrendData');
    print('Feedbacks count: ${viewModel.feedbacks.length}');
    print('Data is empty: ${feedbackTrendData.isEmpty}');
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Feedback Submission Trend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: feedbackTrendData.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Simple bar chart representation
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: feedbackTrendData.asMap().entries.map((entry) {
                              final height = (entry.value.value / feedbackTrendData.map((e) => e.value).reduce((a, b) => a > b ? a : b)) * 120;
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 30,
                                    height: height,
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _getMonthLabels()[entry.key],
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Total Feedback: ${viewModel.feedbacks.length}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bar_chart, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'Chart data loading...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  List<MapEntry<int, double>> _generateFeedbackTrendData(int currentFeedbackCount) {
    final data = <MapEntry<int, double>>[];
    
    // Ensure we have at least some data for the chart
    if (currentFeedbackCount == 0) {
      // If no feedback, create sample data
      data.addAll([
        MapEntry(0, 3.0),
        MapEntry(1, 6.0),
        MapEntry(2, 9.0),
        MapEntry(3, 12.0),
        MapEntry(4, 15.0),
        MapEntry(5, 18.0),
      ]);
    } else {
      // Generate realistic feedback trend data
      for (int i = 0; i < 6; i++) {
        int feedbackCount = 0;
        if (i == 5) {
          feedbackCount = currentFeedbackCount;
        } else {
          feedbackCount = (currentFeedbackCount * (0.2 + (i * 0.18))).round();
        }
        data.add(MapEntry(i, feedbackCount.toDouble()));
      }
    }
    
    return data;
  }

  Widget _buildPerformanceMetricsReport(AdminViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPerformanceCards(viewModel),
          const SizedBox(height: 16),
          _buildResponseTimeMetrics(viewModel),
          const SizedBox(height: 16),
          _buildSatisfactionMetrics(viewModel),
        ],
      ),
    );
  }

  Widget _buildPerformanceCards(AdminViewModel viewModel) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 2.2,
      children: [
        _buildPerformanceCard('Avg Response Time', '2.3 days', Icons.timer, Colors.blue),
        _buildPerformanceCard('Resolution Rate', '87%', Icons.check_circle, Colors.green),
        _buildPerformanceCard('User Satisfaction', '4.2/5', Icons.star, Colors.amber),
        _buildPerformanceCard('System Uptime', '99.9%', Icons.cloud_done, Colors.purple),
      ],
    );
  }

  Widget _buildPerformanceCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResponseTimeMetrics(AdminViewModel viewModel) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Response Time Analysis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildMetricRow('Average Response Time', '2.3 days'),
            _buildMetricRow('Fastest Response', '30 minutes'),
            _buildMetricRow('Slowest Response', '5.2 days'),
            _buildMetricRow('Response Rate', '94%'),
          ],
        ),
      ),
    );
  }

  Widget _buildSatisfactionMetrics(AdminViewModel viewModel) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Satisfaction Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildMetricRow('Overall Satisfaction', '4.2/5'),
            _buildMetricRow('Very Satisfied', '45%'),
            _buildMetricRow('Satisfied', '42%'),
            _buildMetricRow('Neutral', '10%'),
            _buildMetricRow('Dissatisfied', '3%'),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'in progress':
        return Icons.work;
      case 'resolved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.feedback;
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'teacher':
        return Colors.orange;
      case 'student':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _exportReport() {
    // In a real app, this would generate and download a PDF/Excel report
    // For now, show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report export initiated! Check your downloads folder.'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
