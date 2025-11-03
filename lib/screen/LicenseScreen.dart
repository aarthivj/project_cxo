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

  List<LicenseResponse> allLicenses = [];
  List<LicenseResponse> filteredLicenses = [];
  List<LicenseResponse> paginatedLicenses = [];

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

  void applyFilters() {
    if (searchQuery.isNotEmpty) {
      filteredLicenses = allLicenses.where((license) {
        final projectName =
            license.projectData?.projectName?.toLowerCase() ?? '';
        return projectName.contains(searchQuery.toLowerCase());
      }).toList();
    } else {
      filteredLicenses = List.from(allLicenses);
    }

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
// ➕ Add Machine button (aligned right)
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              _showEditDialog(context,allLicenses);
            },
            icon: const Icon(Icons.add),
            label: const Text("Add License"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
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
                              initials =
                                  "${words[0][0]}${words[1][0]}".toUpperCase();
                            } else if (words.isNotEmpty) {
                              initials = words[0][0].toUpperCase();
                            }
                          }

                          return Dismissible(
                            key: Key(license.id.toString()),
                        
  background: const SizedBox.shrink(),

                            secondaryBackground: Container(
                              color: Colors.blue,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.edit, color: Colors.white),
                            ),
                            confirmDismiss: (direction) async {
    if (direction == DismissDirection.endToStart) {
      _showEditDialog(context, allLicenses);
      return false;
    }
    return false;
  },
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
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
                                            projectName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 8.0),
                                          _buildInfoRow(
                                              "Machine Name", machineName),
                                          _buildInfoRow(
                                            "Environment",
                                            environment,
                                            valueStyle: TextStyle(
                                              color: environmentColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          _buildInfoRow(
                                              "License",
                                              license.license ?? "N/A"),
                                          _buildInfoRow(
                                            "Created At",
                                            license.createdAt != null
                                                ? license.createdAt!
                                                    .toString()
                                                    .split(' ')[0]
                                                : "N/A",
                                          ),
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
                  Text(
                    "Page $page of ${((filteredLicenses.length - 1) ~/ pageSize) + 1}",
                  ),
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

void _showEditDialog(BuildContext context, List<LicenseResponse> licenses) {
  final TextEditingController licenseController = TextEditingController();
  String? selectedProject;
  String? selectedMachine;

  // 🟢 Extract unique project names
  final List<String> projectNames = licenses
      .map((u) => u.projectData?.projectName ?? '')
      .where((name) => name.isNotEmpty)
      .toSet()
      .toList();

  // 🟢 Helper to get unique machines for the selected project
  List<Map<String, String>> getMachinesForProject(String projectName) {
    final machines = licenses
        .where((u) => u.projectData?.projectName == projectName)
        .map((u) => {
              'ip': u.machineData?.ipAddress ?? '',
              'env': u.machineData?.environment ?? '',
            })
        .where((data) => data['ip']!.isNotEmpty)
        .toList();

    // 🟣 Deduplicate by IP address manually
    final uniqueMachines = <String, Map<String, String>>{};
    for (var machine in machines) {
      uniqueMachines[machine['ip']!] = machine;
    }

    return uniqueMachines.values.toList();
  }

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // 🟡 Filter machine list based on selected project
          final List<Map<String, String>> filteredMachines = selectedProject != null
              ? getMachinesForProject(selectedProject!)
              : [];

          return AlertDialog(
            title: const Text("Edit License"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔵 License key text field
                TextField(
                  controller: licenseController,
                  decoration: const InputDecoration(
                    labelText: "License ",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),

                // 🔵 Project dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Select Project",
                    border: OutlineInputBorder(),
                  ),
                  value: selectedProject,
                  isExpanded: true,
                  items: projectNames.map((project) {
                    return DropdownMenuItem<String>(
                      value: project,
                      child: Text(
                        project,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedProject = value;
                      selectedMachine = null; // reset when project changes
                    });
                  },
                ),
                const SizedBox(height: 15),

                // 🔵 Machine IP dropdown with colored environment label
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Machine IP Address",
                    border: OutlineInputBorder(),
                  ),
                  value: selectedMachine != null &&
                          filteredMachines.any((m) => m['ip'] == selectedMachine)
                      ? selectedMachine
                      : null,
                  isExpanded: true,
                  items: filteredMachines.map((machine) {
                    final ip = machine['ip'] ?? '';
                    final env = (machine['env'] ?? '').toLowerCase();

                    Color envColor = Colors.black;
                    if (env == 'dev') envColor = Colors.green;
                    if (env == 'prod') envColor = Colors.purple;

                    return DropdownMenuItem<String>(
                      value: ip,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ip,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          if (env.isNotEmpty)
                            Text(
                              env[0].toUpperCase() + env.substring(1),
                              style: TextStyle(
                                color: envColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedMachine = value);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "License updated for $selectedProject → $selectedMachine",
                      ),
                    ),
                  );
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      );
    },
  );
}



}
