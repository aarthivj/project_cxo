import 'package:flutter/material.dart';
import 'package:flutter_application_cxo/model/FiveAResponse.dart';
import 'package:flutter_application_cxo/service/ApiService.dart';
// Imports for models required by the screen logic and data parsing
import 'package:flutter_application_cxo/model/ProjectResponse.dart';
import 'package:flutter_application_cxo/model/ActivityResponse.dart';
// Assuming you have imported your new models:
// import 'package:flutter_application_cxo/model/ResultItem.dart'; 
// import 'package:flutter_application_cxo/model/FiveAResponse.dart';

// --- START: Corrected Model Wrappers ---
class ProjectDisplayItem {
  final ResultItem acknowledgementData;

  // Helper getter for backward compatibility with filter and other methods
  // This is correctly nullable, matching the fix in ResultItem.
  ProjectResponse? get projectData => acknowledgementData.projectData;

  ProjectDisplayItem({
    required this.acknowledgementData,
  });
}
// --- END: Corrected Model Wrappers ---


class AcknowledgementScreen extends StatefulWidget {
  const AcknowledgementScreen({super.key});

  @override
  State<AcknowledgementScreen> createState() => _AcknowledgementScreenState();
}

class _AcknowledgementScreenState extends State<AcknowledgementScreen>
    with SingleTickerProviderStateMixin {
  final ApiService apiService = ApiService();
  late final TabController _tabController;
  final TextEditingController searchController = TextEditingController();

  int page = 1;
  final int pageSize = 10;
  bool isLoading = false;
  String searchQuery = "";

  // Data lists
  final List<ProjectDisplayItem> _allRequests = [];
  final List<ProjectDisplayItem> _allHistory = [];
  final List<ProjectDisplayItem> _allAwards = [];

  // Filtered lists for pagination
  final List<ProjectDisplayItem> _filteredRequests = [];
  final List<ProjectDisplayItem> _filteredHistory = [];
  final List<ProjectDisplayItem> _filteredAwards = [];

  // Display lists (current page)
  final List<ProjectDisplayItem> _displayRequests = [];
  final List<ProjectDisplayItem> _displayHistory = [];
  final List<ProjectDisplayItem> _displayAwards = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      // Reset page and fetch data for the new tab
      setState(() {
        page = 1;
      });
      _fetchForCurrentTab();
    });

    _fetchForCurrentTab();
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }
  
  // --- Helper function to extract initials ---
  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'N/A';
    
    final parts = name.trim().split(' ');
    String initials = '';

    if (parts.length >= 1 && parts.first.isNotEmpty) {
      initials += parts.first[0].toUpperCase();
    }
    
    if (parts.length >= 2 && parts.last.isNotEmpty) {
      initials += parts.last[0].toUpperCase();
    }

    return initials.isEmpty ? 'N/A' : initials;
  }
  // --- End Helper function ---

  List<ProjectDisplayItem> _normalizeToDisplayList(dynamic resp) {
    final out = <ProjectDisplayItem>[];
    
    if (resp == null || resp is! Map<String, dynamic>) {
      debugPrint("Invalid or null response type: ${resp.runtimeType}");
      return out;
    }
    
    try {
      // 1. Deserialize the top-level response using the new model
      final fiveAResponse = FiveAResponse.fromJson(resp);
      
      // 2. Map the deserialized ResultItem objects to ProjectDisplayItem
      for (final resultItem in fiveAResponse.results) {
        // We pass the entire ResultItem now
        out.add(ProjectDisplayItem(acknowledgementData: resultItem));
      }

    } catch (e, st) {
      // This catch block now handles the error that was previously occurring.
      debugPrint("Error deserializing FiveAResponse or processing results: $e\n$st");
    }

    return out;
  }

  // --- Fetching Methods (No change) ---

  Future<void> _fetchForCurrentTab() async {
    final idx = _tabController.index;
    if (idx == 0) return fetchRequest();
    if (idx == 1) return fetchHistory();
    if (idx == 2) return fetchAwards();
  }

  Future<void> fetchRequest() async {
    setState(() => isLoading = true);
    try {
      // apiService.getfiveAreq now returns Future<Map<String, dynamic>>
      final resp = await apiService.getfiveAreq(page, pageSize, searchQuery);
      final list = _normalizeToDisplayList(resp);

      if (mounted) {
        setState(() {
          _allRequests
            ..clear()
            ..addAll(list);
          _applyFiltersAndPaginationForTab(0);
        });
      }
    } catch (e, st) {
      debugPrint("fetchRequest error: $e\n$st");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> fetchHistory() async {
    setState(() => isLoading = true);
    try {
      // apiService.getfiveAhis now returns Future<Map<String, dynamic>>
      final resp = await apiService.getfiveAhis(page, pageSize, searchQuery);
      final list = _normalizeToDisplayList(resp);

      if (mounted) {
        setState(() {
          _allHistory
            ..clear()
            ..addAll(list);
          _applyFiltersAndPaginationForTab(1);
        });
      }
    } catch (e, st) {
      debugPrint("fetchHistory error: $e\n$st");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> fetchAwards() async {
    // ... (fetchAwards implementation is commented out in your original code)
  }

  // --- Filtering and Pagination Logic (No functional change) ---

  void _applyFiltersAndPaginationForTab(int tabIndex) {
    List<ProjectDisplayItem> source;
    List<ProjectDisplayItem> filtered;

    switch (tabIndex) {
      case 0:
        source = _allRequests;
        filtered = source.where(_filterItem).toList();
        _filteredRequests
          ..clear()
          ..addAll(filtered);
        _applyPaging(filtered, _displayRequests);
        break;
      case 1:
        source = _allHistory;
        filtered = source.where(_filterItem).toList();
        _filteredHistory
          ..clear()
          ..addAll(filtered);
        _applyPaging(filtered, _displayHistory);
        break;
      case 2:
      default:
        source = _allAwards;
        filtered = source.where(_filterItem).toList();
        _filteredAwards
          ..clear()
          ..addAll(filtered);
        _applyPaging(filtered, _displayAwards);
        break;
    }
    // CRITICAL: Call setState after updating display lists
    setState(() {});
  }

  void _applyPaging(
      List<ProjectDisplayItem> filtered, List<ProjectDisplayItem> targetDisplay) {
    targetDisplay.clear();
    final startIndex = (page - 1) * pageSize;
    final endIndex = startIndex + pageSize;
    if (startIndex < filtered.length) {
      final slice = filtered.sublist(
          startIndex, endIndex > filtered.length ? filtered.length : endIndex);
      targetDisplay.addAll(slice);
    } else {
      // Logic for handling empty or small lists on the last page
      if (filtered.isNotEmpty && page > 1) {
        page = 1;
        final slice =
            filtered.sublist(0, pageSize > filtered.length ? filtered.length : pageSize);
        targetDisplay.addAll(slice);
      } else if (filtered.isNotEmpty && page == 1) {
          // Handle case where filtered list is smaller than page size
          final slice =
            filtered.sublist(0, pageSize > filtered.length ? filtered.length : pageSize);
          targetDisplay.addAll(slice);
      }
    }
  }

  // Uses null-safe access to projectData
  bool _filterItem(ProjectDisplayItem item) {
    if (searchQuery.isEmpty) return true;
    final q = searchQuery.toLowerCase();

    // Uses null-safe access (?.)
    final title = (item.projectData?.projectName ?? '').toLowerCase();

    // Uses null-safe access (?.)
    return title.contains(q) || (item.projectData?.projectType ?? '').toLowerCase().contains(q);
  }

  void _onSearchChanged(String value) {
    searchQuery = value;
    page = 1;
    _fetchForCurrentTab();
  }

  void nextPage() {
    final idx = _tabController.index;
    final total = idx == 0
        ? _filteredRequests.length
        : idx == 1
            ? _filteredHistory.length
            : _filteredAwards.length;
    if (page * pageSize < total) {
      page++;
      _applyFiltersAndPaginationForTab(idx);
    }
  }

  void prevPage() {
    if (page > 1) {
      page--;
      _applyFiltersAndPaginationForTab(_tabController.index);
    }
  }

  List<ProjectDisplayItem> _getDisplayForTab(int index) {
    if (index == 0) return _displayRequests;
    if (index == 1) return _displayHistory;
    return _displayAwards;
  }

  // --- Refactored _buildCard for Avatar and Details layout ---

  Widget _buildCard(ProjectDisplayItem item, int tabIndex) {
    // Get the core acknowledgement and project data
    final ResultItem acknowledgement = item.acknowledgementData;
    final ProjectResponse? project = item.projectData; 
    
    // --- Data Extraction from ResultItem ---
    
    // User name extraction (prioritizing userData, falling back to businessDeveloperData)
    final String rawUserName = acknowledgement.userData?.userName??"N/A";
    final String acknowledgementUserName = rawUserName ;
    final String initialsname = project?.projectName ?? "N/A";
    final String initials = _getInitials(initialsname); // Get initials from raw name

    // Status, Activity/Remarks, Rating are now directly from the acknowledgement item
    final String statusText = acknowledgement.status ?? (tabIndex == 1 ? "Approved" : "Pending");
    final String activityRemarks = acknowledgement.activity ?? acknowledgement.notes ?? "N/A";
    final String ratingText = acknowledgement.rating ?? "N/A";

    // Project Details
    final String projectTitle = project?.projectName ?? "Project N/A"; 
    final String projectType = project?.projectType ?? "Type N/A"; 
    
    // Date
    final String acknowledgementDateRaw = acknowledgement.createdAt?.toIso8601String()
        ?? project?.createdAt?.toIso8601String() ?? ''; 

    String formattedDate = "N/A";
    if (acknowledgementDateRaw.isNotEmpty) {
      try {
        final dateTime = DateTime.tryParse(acknowledgementDateRaw);
        if (dateTime != null) {
          formattedDate = '${dateTime.month}/${dateTime.day}, ${dateTime.year}';
        } 
      } catch (_) {
      }
    }
    
    // --- Card UI Construction ---

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row( // Main layout Row
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // LEFT SIDE: Circle Avatar with Initials
            CircleAvatar(
              radius: 24, 
              backgroundColor: Colors.teal.shade100,
              child: Text(
                initials,
                style: TextStyle(
                  color: Colors.teal.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            
            const SizedBox(width: 12), 

            // RIGHT SIDE: Expanded Column for Details (Each field on its own line)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                    
                    // 1. Project Name (Title) - Top of the details column
                    Text(projectTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),

                    // 3. User (Dedicated Row)
                    Row(
                      children: [
                        const Text("User: ", style: TextStyle(fontWeight: FontWeight.w600)),
                        Expanded(child: Text(acknowledgementUserName, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // 4. Date (Dedicated Row)
                    Row(
                      children: [
                        const Text("Date: ", style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(formattedDate, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // 5. Status (Dedicated Row)
                    Row(
                      children: [
                        const Text("Status: ", style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(statusText,
                            style: TextStyle(
                                color: statusText == 'Pending' ? Colors.orange : Colors.green,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // 6. Activity / Remarks (Dedicated Row)
                    Row(
                      children: [
                        const Text("Activity : ", style: TextStyle(fontWeight: FontWeight.w600)),
                        Expanded(child: Text(activityRemarks, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    
                    // 7. Rating (Conditional Dedicated Row)
                    if (tabIndex == 1) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text("Rating: ", style: TextStyle(fontWeight: FontWeight.w600)),
                          Text(ratingText), 
                        ],
                      ),
                    ],

                    const SizedBox(height: 8),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTabList(int tabIndex) {
    final list = _getDisplayForTab(tabIndex);
    if (isLoading) return const Center(child: CircularProgressIndicator());

    if (list.isEmpty) {
      return Center(
        child: Text(searchQuery.isNotEmpty
            ? "No results found for '$searchQuery'"
            : "No data found"),
      );
    }

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return _buildCard(item, tabIndex);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final idx = _tabController.index;
    final totalFilteredItems = idx == 0
        ? _filteredRequests.length
        : idx == 1
            ? _filteredHistory.length
            : _filteredAwards.length;
    final bool hasNextPage = page * pageSize < totalFilteredItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text("A⁵ Acknowledgement",
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          indicatorColor: Colors.teal,
          tabs: const [
            Tab(text: "Request"),
            Tab(text: "History"),
            Tab(text: "Awards"),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabList(0), // Request
                _buildTabList(1), // History
                _buildTabList(2), // Awards
              ],
            ),
          ),

          // Pagination controls
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              ElevatedButton(
                  onPressed: page > 1 ? prevPage : null,
                  child: const Text("Previous")),
              Text("Page $page", style: const TextStyle(fontWeight: FontWeight.bold)),
              ElevatedButton(
                  onPressed: hasNextPage ? nextPage : null,
                  child: const Text("Next")),
            ]),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}