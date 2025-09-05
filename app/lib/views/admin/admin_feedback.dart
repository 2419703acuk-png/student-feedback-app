import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../models/feedback_model.dart';

class AdminFeedback extends StatefulWidget {
  const AdminFeedback({super.key});

  @override
  State<AdminFeedback> createState() => _AdminFeedbackState();
}

class _AdminFeedbackState extends State<AdminFeedback> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback Management'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => _selectedFilter = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Feedback')),
              const PopupMenuItem(value: 'pending', child: Text('Pending')),
              const PopupMenuItem(value: 'in_progress', child: Text('In Progress')),
              const PopupMenuItem(value: 'resolved', child: Text('Resolved')),
            ],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.filter_list),
                  const SizedBox(width: 4),
                  Text(_getFilterText(_selectedFilter)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Consumer<AdminViewModel>(
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
                  Text('Error', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(viewModel.errorMessage!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return _buildFeedbackList(viewModel);
        },
      ),
    );
  }

  String _getFilterText(String filter) {
    switch (filter) {
      case 'all':
        return 'All';
      case 'pending':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      default:
        return 'All';
    }
  }

  Widget _buildFeedbackList(AdminViewModel viewModel) {
    final filteredFeedbacks = _getFilteredFeedbacks(viewModel.feedbacks);

    if (filteredFeedbacks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedFilter == 'all' ? Icons.feedback_outlined : Icons.inbox_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _selectedFilter == 'all' ? 'No feedback found' : 'No ${_selectedFilter.replaceAll('_', ' ')} feedback',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text('Feedback will appear here as students submit it'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredFeedbacks.length,
      itemBuilder: (context, index) {
        final feedback = filteredFeedbacks[index];
        return _buildFeedbackCard(feedback, viewModel);
      },
    );
  }

  List<FeedbackModel> _getFilteredFeedbacks(List<FeedbackModel> feedbacks) {
    if (_selectedFilter == 'all') return feedbacks;
    return feedbacks.where((f) => f.status == _selectedFilter).toList();
  }

  Widget _buildFeedbackCard(FeedbackModel feedback, AdminViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          feedback.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Course: ${feedback.courseName}'),
            Text('Submitted: ${_formatDate(feedback.createdAt)}'),
          ],
        ),
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(feedback.status),
          child: Icon(
            _getStatusIcon(feedback.status),
            color: Colors.white,
            size: 20,
          ),
        ),
        trailing: Chip(
          label: Text(feedback.status.replaceAll('_', ' ').toUpperCase()),
          backgroundColor: _getStatusColor(feedback.status),
          labelStyle: const TextStyle(color: Colors.white, fontSize: 10),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Feedback Content:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(feedback.content),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('Type: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Chip(
                      label: Text(feedback.type.toUpperCase()),
                      backgroundColor: _getTypeColor(feedback.type),
                      labelStyle: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('Student: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(feedback.userName),
                  ],
                ),
                const SizedBox(height: 16),
                _buildStatusActions(feedback, viewModel),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange.shade600;
      case 'in_progress':
        return Colors.blue.shade600;
      case 'resolved':
        return Colors.green.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'in_progress':
        return Icons.work;
      case 'resolved':
        return Icons.check_circle;
      default:
        return Icons.feedback;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'suggestion':
        return Colors.blue.shade600;
      case 'complaint':
        return Colors.red.shade600;
      case 'general':
        return Colors.grey.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  Widget _buildStatusActions(FeedbackModel feedback, AdminViewModel viewModel) {
    if (feedback.status == 'resolved') {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600),
            const SizedBox(width: 8),
            Text(
              'This feedback has been resolved',
              style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Update Status:',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (feedback.status == 'pending')
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _updateStatus(feedback.id, 'in_progress', viewModel),
                  icon: const Icon(Icons.work),
                  label: const Text('Mark In Progress'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            if (feedback.status == 'pending' || feedback.status == 'in_progress') ...[
              if (feedback.status == 'pending') const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _updateStatus(feedback.id, 'resolved', viewModel),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Mark Resolved'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  void _updateStatus(String feedbackId, String newStatus, AdminViewModel viewModel) async {
    final success = await viewModel.updateFeedbackStatus(feedbackId, newStatus);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Feedback status updated to ${newStatus.replaceAll('_', ' ')}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
