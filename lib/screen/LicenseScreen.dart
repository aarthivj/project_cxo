import 'package:flutter/material.dart';
import 'package:flutter_application_cxo/model/LicenseResponse.dart';
import 'package:flutter_application_cxo/model/MachineResponse.dart';
import 'package:flutter_application_cxo/service/ApiService.dart';
import 'package:flutter_application_cxo/widget/CustomWidget.dart';

class LicenseScreen extends StatefulWidget {
  const LicenseScreen({super.key});

  @override
  State<StatefulWidget> createState() => LicenseScreenState();
}

class LicenseScreenState extends State<LicenseScreen> {
  late ApiService apiService = ApiService();

  List<LicenseResponse> allLicenses = []; // Full data
  List<LicenseResponse> filteredLicenses = []; // Filtered data for search
  List<LicenseResponse> paginatedLicenses = []; // Data shown per page

  int page = 1;
  int pageSize = 10;
  bool isLoading = false;
  String searchQuery = "";

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
    fetchLicenses();
  }

  Future<void> fetchLicenses() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await apiService.getlicenses();
      if (response != null) {
        setState(() {
          allLicenses = response;
          applyFilters();
        });
      }
    } catch (e) {
      debugPrint("Failed to fetch licenses: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Apply search and pagination logic
  void applyFilters() {
    // Search filter
    if (searchQuery.isNotEmpty) {
      filteredLicenses = allLicenses.where((license) {
        final projectName =
            license.projectData?.projectName?.toLowerCase() ?? '';
        return projectName.contains(searchQuery.toLowerCase());
      }).toList();
    } else {
      filteredLicenses = List.from(allLicenses);
    }

    // Pagination logic
    int startIndex = (page - 1) * pageSize;
    int endIndex = startIndex + pageSize;
    if (startIndex > filteredLicenses.length) {
      startIndex = 0;
      page = 1;
    }
    if (endIndex > filteredLicenses.length) {
      endIndex = filteredLicenses.length;
    }

    paginatedLicenses = filteredLicenses.sublist(startIndex, endIndex);
  }

  void onSearchChanged(String value) {
    setState(() {
      searchQuery = value;
      page = 1;
      applyFilters();
    });
  }

  void nextPage() {
    if ((page * pageSize) < filteredLicenses.length) {
      setState(() {
        page++;
        applyFilters();
      });
    }
  }

  void prevPage() {
    if (page > 1) {
      setState(() {
        page--;
        applyFilters();
      });
    }
  }

  Widget _buildInfoRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle ??
                  const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "License"),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search licenses",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: onSearchChanged,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : paginatedLicenses.isEmpty
                    ? const Center(child: Text("No licenses found"))
                    : ListView.builder(
                        itemCount: paginatedLicenses.length,
                        itemBuilder: (context, index) {
  final license = paginatedLicenses[index];
  final machine = license.machineData;
  final project = license.projectData;
  final projectName = project?.projectName ?? "N/A";
  final machineName = machine?.ipAddress ?? 'N/A';
  final environment = machine?.environment ?? "N/A";

  final environmentColor =
      environment.toLowerCase() == 'dev'
          ? Colors.green
          : environment.toLowerCase() == 'prod'
              ? Colors.blue
              : Colors.black;

  String initials = "N/A";
  if (projectName.isNotEmpty && projectName != "N/A") {
    final words = projectName.split(" ");
    if (words.length >= 2) {
      initials = "${words[0][0]}${words[1][0]}".toUpperCase();
    } else if (words.isNotEmpty) {
      initials = words[0][0].toUpperCase();
    }
  }

  final keyString = license.id?.toString() ?? 'license_$index';

  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.blueAccent,
            child: Text(
              initials,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  projectName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8.0),
                _buildInfoRow("Machine Name", machineName),
                _buildInfoRow(
                  "Environment",
                  environment,
                  valueStyle: TextStyle(
                    color: environmentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildInfoRow("License", license.license ?? "N/A"),
                _buildInfoRow(
                  "Created At",
                  license.createdAt != null
                      ? license.createdAt!.toString().split(' ')[0]
                      : "N/A",
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

                     
                      ),
          ),

          // Pagination controls
          if (!isLoading && filteredLicenses.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: page > 1 ? prevPage : null,
                    child: const Text("Previous"),
                  ),
                  Text("Page $page of ${((filteredLicenses.length - 1) ~/ pageSize) + 1}"),
                  ElevatedButton(
                    onPressed: (page * pageSize) < filteredLicenses.length
                        ? nextPage
                        : null,
                    child: const Text("Next"),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}


