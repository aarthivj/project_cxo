import 'package:flutter/material.dart';
import 'package:flutter_application_cxo/model/ActivityLogResponse.dart';
import 'package:flutter_application_cxo/model/ActivityResponse.dart';
import 'package:flutter_application_cxo/model/ActivityScreenResponse.dart';
import 'package:flutter_application_cxo/service/ApiService.dart';
import 'package:intl/intl.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<StatefulWidget> createState() => ActivityScreenState();
}

class ActivityScreenState extends State<ActivityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ApiService apiService = ApiService();

  ActivityScreenResponse? _activityScreenResponse;
  Map<String, List<ActivityResponse>> groupedProjects = {};
  Map<String, dynamic> projectCreatedAtMap = {}; // dynamic to handle String or DateTime
  bool _loading = true;

  // Pagination & activity log
  int _currentPage = 1;
  int _pageSize = 10;
  bool _logLoading = true;
  ActivityLogResponse? _activityLogResponse;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      setState(() {
        _searchController.clear();
      });
    });

    fetchActivities();
    fetchActivityLog(page: _currentPage);
  }

  // Fetch Projects
  Future<void> fetchActivities() async {
    try {
      final response = await apiService.getActivities();
      final Map<String, List<ActivityResponse>> grouped = {};
      final Map<String, dynamic> createdAtMap = {};

      for (var projectItem in response.results ?? []) {
        final projectName = projectItem.project?.projectName ?? "No Name";
        grouped[projectName] = projectItem.activities ?? [];
        createdAtMap[projectName] = projectItem.project?.createdAt; // dynamic
      }

      setState(() {
        _activityScreenResponse = response;
        groupedProjects = grouped;
        projectCreatedAtMap = createdAtMap;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      print("Error fetching activities: $e");
    }
  }

  // Fetch Activity Log
  Future<void> fetchActivityLog({int page = 1}) async {
    setState(() => _logLoading = true);
    try {
      final response = await apiService.getActivitylog(page, _pageSize);
      setState(() {
        _activityLogResponse = response;
        _currentPage = page;
        _logLoading = false;
      });
    } catch (e) {
      setState(() => _logLoading = false);
      print("Error fetching activity log: $e");
    }
  }

  String formatDate(dynamic dateStr) {
    if (dateStr == null) return "N/A";
    try {
      DateTime dateTime;
      if (dateStr is String) {
        dateTime = DateTime.parse(dateStr);
      } else if (dateStr is DateTime) {
        dateTime = dateStr;
      } else {
        return dateStr.toString();
      }
      return DateFormat('dd-MM-yyyy HH:mm').format(dateTime);
    } catch (e) {
      return dateStr.toString();
    }
  }

  // Generate missing payment activities for all months from project created date to now
  List<ActivityResponse> generateMissingPaymentActivities(
      dynamic createdAt, List<ActivityResponse> existingActivities) {
    if (createdAt == null) return [];

    DateTime start;

    if (createdAt is String) {
      start = DateTime.tryParse(createdAt) ?? DateTime.now();
    } else if (createdAt is DateTime) {
      start = createdAt;
    } else {
      return [];
    }

    final now = DateTime.now();
    if (start.isAfter(now)) return [];

    final existingMonths = existingActivities
        .where((a) => a.stage?.toLowerCase().contains('payment') ?? false)
        .map((a) => a.stage!.toLowerCase())
        .toList();

    List<ActivityResponse> generated = [];
    DateTime current = DateTime(start.year, start.month + 1);

    while (current.isBefore(now) ||
        (current.year == now.year && current.month == now.month)) {
      final monthLabel = DateFormat('MMMM yyyy').format(current);
      final alreadyExists =
          existingMonths.any((em) => em.contains(monthLabel.toLowerCase()));
      if (!alreadyExists) {
        generated.add(
          ActivityResponse(
            stage: 'payment_$monthLabel',
            remarks: '', // empty remarks
            checked: false,
          ),
        );
      }
      current = DateTime(current.year, current.month + 1);
    }

    return generated;
  }

  String formatStageName(String? stage) {
    if (stage == null || stage.trim().isEmpty) return "No Stage Name";

    String s = stage.trim();
    final numberMatch = RegExp(r'^(\d+)[_\-\s]').firstMatch(s);
    String? prefix;

    if (numberMatch != null) {
      final number = int.tryParse(numberMatch.group(1) ?? '');
      if (number != null) {
        String suffix;
        if (number % 10 == 1 && number % 100 != 11) {
          suffix = 'st';
        } else if (number % 10 == 2 && number % 100 != 12) {
          suffix = 'nd';
        } else if (number % 10 == 3 && number % 100 != 13) {
          suffix = 'rd';
        } else {
          suffix = 'th';
        }
        prefix = '$number$suffix';
        s = s.replaceFirst(numberMatch.group(0)!, '');
      }
    }

    s = s.replaceAll(RegExp(r'poc_demo', caseSensitive: false), 'free trial');
    s = s.replaceAllMapped(
      RegExp(r'(^|[_\-\s])bot($|[_\-\s])', caseSensitive: false),
      (m) {
        final left = m.group(1) ?? '';
        final right = m.group(2) ?? '';
        return '$left agent $right';
      },
    );
    s = s.replaceAll('bot', 'agent');
    s = s.replaceAll('_', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    s = s
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');

    if (prefix != null) s = '$prefix $s';
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Activities"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: const [
              Tab(text: "Projects"),
              Tab(text: "Activity Log"),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: _tabController.index == 0
                    ? "Search projects..."
                    : "Search activity logs...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Projects Tab
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        children: groupedProjects.entries.map((entry) {
                          final projectName = entry.key;
                          final projectCreatedAt =
                              projectCreatedAtMap[projectName];
                          final List<ActivityResponse> apiActivities = entry.value;

                          final List<ActivityResponse> extraPayments =
                              generateMissingPaymentActivities(
                                  projectCreatedAt, apiActivities);

                          final List<ActivityResponse> allActivities = [
                            ...apiActivities,
                            ...extraPayments
                          ];

                          if (_searchController.text.isNotEmpty &&
                              !projectName
                                  .toLowerCase()
                                  .contains(_searchController.text.toLowerCase())) {
                            return const SizedBox.shrink();
                          }

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    projectName,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  const SizedBox(height: 12),
                                  Column(
                                    children: allActivities.map((activity) {
                                      return Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: CheckboxListTile(
                                          activeColor: Colors.green,
                                          value: activity.checked,
                                          onChanged: (val) {
                                            setState(() {
                                              activity.checked = val ?? false;
                                            });
                                          },
                                          title: Text(
                                            formatStageName(activity.stage),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
                                          subtitle: Text(
                                            activity.remarks?.isNotEmpty == true
                                                ? activity.remarks!
                                                : "No remarks yet",
                                            style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 13),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                // Activity Log Tab
                _logLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount:
                                  _activityLogResponse?.results?.length ?? 0,
                              itemBuilder: (context, index) {
                                final log = _activityLogResponse!.results![index];

                                if (_searchController.text.isNotEmpty &&
                                    !((log.projectData?.projectName ?? "")
                                        .toLowerCase()
                                        .contains(_searchController.text
                                            .toLowerCase()))) {
                                  return const SizedBox.shrink();
                                }

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  elevation: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          log.projectData?.projectName ??
                                              "No Project Name",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.black),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Stage: ${log.stage ?? "N/A"}",
                                          style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 121, 121, 121)),
                                        ),
                                        Text(
                                          "Updated at: ${formatDate(log.updatedAt)}",
                                          style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 121, 121, 121)),
                                        ),
                                        Text(
                                          "Created at: ${formatDate(log.createdAt)}",
                                          style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 121, 121, 121)),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: _currentPage > 1
                                      ? () =>
                                          fetchActivityLog(page: _currentPage - 1)
                                      : null,
                                  child: const Text("Previous"),
                                ),
                                ElevatedButton(
                                  onPressed:
                                      (_activityLogResponse?.next != null)
                                          ? () => fetchActivityLog(
                                              page: _currentPage + 1)
                                          : null,
                                  child: const Text("Next"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
