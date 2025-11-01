// screens/history_screen.dart
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/database_helper.dart';
import '../models/attendence.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<AttendanceRecord> _allAttendance = [];
  List<AttendanceRecord> _filteredAttendance = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAttendanceHistory();
  }

  Future<void> _loadAttendanceHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final attendance = await DatabaseHelper.instance.getAllAttendance();
      setState(() {
        _allAttendance = attendance;
        _filteredAttendance = attendance;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading attendance history: $e')),
      );
    }
  }

  void _filterAttendance(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredAttendance = _allAttendance;
      } else {
        _filteredAttendance = _allAttendance.where((record) =>
        record.studentName.toLowerCase().contains(query.toLowerCase()) ||
            record.studentId.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
    });
  }

  void _filterByDate(String filter) {
    setState(() {
      _selectedFilter = filter;
      final now = DateTime.now();

      switch (filter) {
        case 'Today':
          final today = now.toString().split(' ')[0];
          _filteredAttendance = _allAttendance.where((record) =>
              record.scanTime.startsWith(today)
          ).toList();
          break;
        case 'This Week':
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          _filteredAttendance = _allAttendance.where((record) {
            final recordDate = DateTime.parse(record.scanTime);
            return recordDate.isAfter(weekStart.subtract(Duration(days: 1)));
          }).toList();
          break;
        case 'This Month':
          final monthStart = DateTime(now.year, now.month, 1);
          _filteredAttendance = _allAttendance.where((record) {
            final recordDate = DateTime.parse(record.scanTime);
            return recordDate.isAfter(monthStart.subtract(Duration(days: 1)));
          }).toList();
          break;
        default:
          _filteredAttendance = _allAttendance;
      }
    });
  }

  Future<void> _exportData() async {
    if (_filteredAttendance.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No data to export')),
      );
      return;
    }

    try {
      // Create CSV content
      String csvContent = 'Student Name,Student ID,Date,Time,Status\n';

      for (var record in _filteredAttendance) {
        final dateTime = DateTime.parse(record.scanTime);
        final date = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
        final time = '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';

        csvContent += '${record.studentName},${record.studentId},$date,$time,${record.status}\n';
      }

      // Get directory for saving file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/attendance_export_$timestamp.csv');

      // Write to file
      await file.writeAsString(csvContent);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Attendance Report Export',
        subject: 'Attendance Data Export',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data exported successfully!'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search and Filter Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name or ID...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: _filterAttendance,
                ),

                SizedBox(height: 10),

                // Filter Buttons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Today', 'This Week', 'This Month']
                        .map((filter) => Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(filter),
                        selected: _selectedFilter == filter,
                        onSelected: (selected) {
                          if (selected) _filterByDate(filter);
                        },
                        selectedColor: Colors.blue.withOpacity(0.3),
                        checkmarkColor: Colors.blue,
                      ),
                    ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),

          // Statistics Section
          if (_filteredAttendance.isNotEmpty)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '${_filteredAttendance.length}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text('Total Records'),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '${_filteredAttendance.map((e) => e.studentId).toSet().length}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text('Unique Students'),
                    ],
                  ),
                ],
              ),
            ),

          SizedBox(height: 16),

          // Attendance List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredAttendance.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 50, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    'No attendance records found',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _filteredAttendance.length,
              itemBuilder: (context, index) {
                final record = _filteredAttendance[index];
                final dateTime = DateTime.parse(record.scanTime);
                final isToday = dateTime.toString().split(' ')[0] ==
                    DateTime.now().toString().split(' ')[0];

                return Card(
                  margin: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isToday ? Colors.green : Colors.blue,
                      child: Text(
                        record.studentName.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      record.studentName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ID: ${record.studentId}'),
                        Text(
                          record.formattedTime,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    trailing: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        record.status,
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // Export Button
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _exportData,
            backgroundColor: Colors.green,
            heroTag: 'export',
            child: Icon(Icons.download, color: Colors.white),
            tooltip: 'Export Data',
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _loadAttendanceHistory,
            backgroundColor: Colors.blue,
            heroTag: 'refresh',
            child: Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}