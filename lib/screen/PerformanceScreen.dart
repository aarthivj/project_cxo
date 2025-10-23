import 'package:flutter/material.dart';
import 'package:flutter_application_cxo/model/PerformanceResponse.dart';
import 'package:flutter_application_cxo/service/ApiService.dart';
import 'package:flutter_application_cxo/widget/CustomWidget.dart';
import 'package:month_year_picker/month_year_picker.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => PerformanceState();
}

class PerformanceState extends State<PerformanceScreen> {
  late ApiService apiService = ApiService();
  final TextEditingController searchController = TextEditingController();

  List<PerformanceResponse> allPerformance = [];
  List<PerformanceResponse> _filteredPerformance = [];
  List<PerformanceResponse> Performance = [];

  int page = 1;
  final int pageSize = 10;
  bool isLoading = false;
  String searchQuery = "";

  // For calendar filter
  String _dateFilterApi = "";
  String _dateFilterDisplay = "";
  String _startDate = "";
  String _endDate = "";
  String monthyear = ""; 

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
    fetchPerformance();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _applyFiltersAndPagination() {
    _filteredPerformance = allPerformance.where((sub) {
      if (searchQuery.isEmpty) return true;
      final query = searchQuery.toLowerCase();
      final username = sub.userName?.toLowerCase() ?? '';
      return username.contains(query);
    }).toList();

    final startIndex = (page - 1) * pageSize;
    final endIndex = startIndex + pageSize;

    if (startIndex < _filteredPerformance.length) {
      Performance = _filteredPerformance.sublist(
        startIndex,
        endIndex > _filteredPerformance.length
            ? _filteredPerformance.length
            : endIndex,
      );
    } else {
      Performance = [];
      if (_filteredPerformance.isNotEmpty) page = 1;
    }
  }

  Future<void> fetchPerformance() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await apiService.getperformance(
        page,
        pageSize,
        searchQuery,
        monthyear,
        _startDate,
        _endDate,
      );

      if (response != null) {
        allPerformance = response;
        setState(() {
          _applyFiltersAndPagination();
        });
      }
    } catch (e) {
      debugPrint("Failed to fetch Performances: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void onSearchChanged(String value) {
    searchQuery = value;
    page = 1;
    setState(() {
      _applyFiltersAndPagination();
    });
  }

  void nextPage() {
    if (page * pageSize < _filteredPerformance.length) {
      page++;
      setState(() {
        _applyFiltersAndPagination();
      });
    }
  }

  void prevPage() {
    if (page > 1) {
      page--;
      setState(() {
        _applyFiltersAndPagination();
      });
    }
  }

  Future<void> _pickMonthYear() async {
    final picked = await showMonthYearPicker(
      context: context,
      initialDate: _dateFilterApi.isNotEmpty
          ? DateTime.parse("$_dateFilterApi-01")
          : DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple, // header bg
              onPrimary: Colors.white, // header text
              onSurface: Colors.black, // body text
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepPurple,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
  final startDate = DateTime(picked.year, picked.month, 1);
  final endDate = DateTime(picked.year, picked.month + 1, 0);

  setState(() {
    // ✅ month_year string
    monthyear = "${picked.year}-${picked.month.toString().padLeft(2, '0')}";

    // ✅ display value
    _dateFilterDisplay = "${picked.month}/${picked.year}";

    // ✅ start and end dates
    _startDate = startDate.toIso8601String().split('T').first;
    _endDate = endDate.toIso8601String().split('T').first;

    page = 1;
  });

  debugPrint("Sending to API => month_year=$monthyear, start=$_startDate, end=$_endDate");
  fetchPerformance();
}
  }

  // Helper function to generate initials
  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'N/A';
    final words = name.split(" ");
    if (words.length >= 2) {
      return "${words[0][0]}${words[1][0]}".toUpperCase();
    } else if (words.isNotEmpty && words[0].isNotEmpty) {
      return words[0][0].toUpperCase();
    }
    return 'N/A';
  }


  @override
  Widget build(BuildContext context) {
    final bool hasNextPage = (page * pageSize) < _filteredPerformance.length;

    // Extract pagination controls for bottomNavigationBar
    final paginationControls = Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: page > 1 ? prevPage : null,
            child: const Text("Previous"),
          ),
          Text(
            "Page $page", 
            style: const TextStyle(fontWeight: FontWeight.bold)
          ),
          ElevatedButton(
            onPressed: hasNextPage ? nextPage : null,
            child: const Text("Next"),
          ),
        ],
      ),
    );


    return Scaffold(
      appBar: const CustomAppBar(title: "Performances"),
      
      // The body now only contains the search bar and the list content
      body: Column(
        children: [
          // Search + Calendar Row
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search Performances...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: onSearchChanged,
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.blue),
                  onPressed: _pickMonthYear,
                ),
              ],
            ),
          ),
          
          // Tab content (Expanded to fill the space above the bottomNavigationBar)
          // Note: Keeping the conditional logic you had for showing the list
          if (_dateFilterDisplay.isNotEmpty)
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Performance.isEmpty
                    ? Center(
                        child: Text(searchQuery.isNotEmpty
                            ? "No results found for '$searchQuery'"
                            : "No Performances found"),
                      )
                    : ListView.builder(
                        itemCount: Performance.length,
                        itemBuilder: (context, index) {
                          final Performances = Performance[index];
                          final initials = _getInitials(Performances.userName);

                          final keyString = Performances.userId?.toString() ??
                              'Performance_$index';

                          return Dismissible(
                            key: Key(keyString),
                            background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 20),
                                child: const Icon(Icons.delete,
                                    color: Colors.white)),
                            secondaryBackground: Container(
                                color: Colors.blue,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(Icons.edit,
                                    color: Colors.white)),
                            confirmDismiss: (direction) async {
                              return false;
                            },
                            onDismissed: (direction) {},
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.blueAccent,
                                      child: Text(
                                        initials,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 16.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            Performances.userName ?? "N/A",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.black),
                                          ),
                                          const SizedBox(height: 4.0),
                                          Text(
                                              "User: ${Performances.userName ?? "N/A"}",
                                              style: const TextStyle(
                                                  color: Colors.black)),
                                          Text(
                                              "Current projects: ${Performances.currentProjects ?? "N/A"}",
                                              style: const TextStyle(
                                                  color: Colors.black)),
                                          Text(
                                              "Number of activities: ${Performances.numActivities ?? "N/A"}",
                                              style: const TextStyle(
                                                  color: Colors.black)),
                                          Text(
                                              "Ratings: ${Performances.rating ?? "N/A"}",
                                              style: const TextStyle(
                                                  color: Colors.black)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      // Pagination controls are now placed in bottomNavigationBar to ensure they stick to the bottom.
      bottomNavigationBar: paginationControls,
    );
  }
}