import 'package:flutter/material.dart';
import 'package:healthy_pathway/home/medication_reminder/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationDebugScreen extends StatefulWidget {
  const NotificationDebugScreen({super.key});

  @override
  State<NotificationDebugScreen> createState() => _NotificationDebugScreenState();
}

class _NotificationDebugScreenState extends State<NotificationDebugScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _serviceStatus = {};

  @override
  void initState() {
    super.initState();
    _loadServiceStatus();
  }

  Future<void> _loadServiceStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final status = await NotificationService.getServiceStatus();
      setState(() {
        _serviceStatus = {'initialized': status == 'Initialized'};
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _serviceStatus = {'error': e.toString()};
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Debug'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadServiceStatus,
            tooltip: 'Refresh Status',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(),
                  const SizedBox(height: 16),
                  _buildPermissionCard(),
                  const SizedBox(height: 16),
                  _buildPendingNotificationsCard(),
                  const SizedBox(height: 16),
                  _buildTestButtonsCard(),
                  const SizedBox(height: 16),
                  _buildTroubleshootingCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Service Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildStatusRow('Notification Service', _serviceStatus['initialized'] ?? false),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionCard() {
    final permissions = _serviceStatus['permissions'] as Map<String, dynamic>? ?? {};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Permissions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildStatusRow('Notification Permission', permissions['notification'] ?? false),
            _buildStatusRow('Alarm Permission', permissions['alarm'] ?? false),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await openAppSettings();
              },
              child: const Text('Open App Settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingNotificationsCard() {
    final pendingCount = _serviceStatus['pendingNotificationsCount'] ?? 0;
    final pendingNotifications = _serviceStatus['pendingNotifications'] as List<dynamic>? ?? [];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pending Notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Count: $pendingCount'),
            if (pendingNotifications.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Details:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...pendingNotifications.take(5).map((n) => Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Text('• ${n['title']} (ID: ${n['id']})'),
              )),
              if (pendingNotifications.length > 5)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Text('... and ${pendingNotifications.length - 5} more'),
                ),
            ],
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await NotificationService.cancelAllNotifications();
                _loadServiceStatus();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All notifications cancelled')),
                  );
                }
              },
              child: const Text('Cancel All'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButtonsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test Notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await NotificationService.showTestNotification();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Test notification sent!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.notification_add),
                    label: const Text('Test Now'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await NotificationService.scheduleTestFor1Minute();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Test scheduled for 1 minute!'),
                              backgroundColor: Colors.blue,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.schedule),
                    label: const Text('Test 1 Min'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await NotificationService.scheduleTestFor2Minutes();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Test scheduled for 2 minutes!'),
                              backgroundColor: Colors.purple,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.schedule),
                    label: const Text('Test 2 Min'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await NotificationService.scheduleTestForExactTime();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Test scheduled for exact time!'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.access_time),
                    label: const Text('Test Exact Time'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTroubleshootingCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Troubleshooting',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'If notifications are not working:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('1. Check device notification settings'),
            const Text('2. Disable battery optimization for this app'),
            const Text('3. Grant all required permissions'),
            const Text('4. Restart the app after granting permissions'),
            const Text('5. Check if Do Not Disturb is enabled'),
            const Text('6. Keep the app in background for scheduled notifications'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, bool status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            status ? Icons.check_circle : Icons.error,
            color: status ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(label),
          const Spacer(),
          Text(
            status ? 'OK' : 'FAILED',
            style: TextStyle(
              color: status ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
} 