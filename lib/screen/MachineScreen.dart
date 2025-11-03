import 'package:flutter/material.dart';
import 'package:flutter_application_cxo/model/MachineResponse.dart';
import 'package:flutter_application_cxo/model/ProjectResponse.dart';
import 'package:flutter_application_cxo/service/ApiService.dart';
import 'package:flutter_application_cxo/widget/CustomWidget.dart';
class FilterMappings {
  static const Map<String, String> hostedMap = {
    "All": "",
    "Droidal": "droidal",
    "Client": "client",
  };

  static const Map<String, String> environmentMap = {
    "All": "",
    "Production": "Prod",
    "Development": "Dev",
    "Internal": "Internal",
  };
}
class MachineScreen extends StatefulWidget {
  const MachineScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return MachineScreenState();
  }
}

class MachineScreenState extends State<MachineScreen> {
  late ApiService apiService;

  // Data
  List<MachineResult> machines = [];

  // Pagination
  int page = 1;
  int pageSize = 10;
  bool isLoading = false;

  // Filters
  String? hostedFilter;
  String? environmentFilter;
  String searchQuery = "";

  // Common filter value mappings for dropdowns → API values


  // Controllers
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
    fetchMachines();
  }

  Future<void> fetchMachines() async {
    setState(() => isLoading = true);

    try {
      final response = await apiService.getmachines(
        page,
        pageSize,
        hostedFilter,
        environmentFilter,
        searchQuery,
      );

      if (response != null) {
        setState(() {
        machines = response; // ✅ assign the actual results

        });
      }
    } catch (e) {
      debugPrint("Failed to fetch machines: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void onSearchChanged(String value) {
    searchQuery = value;
    page = 1; // reset page on new search
    fetchMachines();
  }

  void onHostedChanged(String? value) {
    hostedFilter = value;
    page = 1;
    fetchMachines();
  }

  void onEnvironmentChanged(String? value) {
    environmentFilter = value;
    page = 1;
    fetchMachines();
  }

  void nextPage() {
    page++;
    fetchMachines();
  }

  void prevPage() {
    if (page > 1) {
      page--;
      fetchMachines();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Machines Screen"),
      body: Column(
        children: [
          // 🔎 Search bar
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search machines...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: onSearchChanged,
            ),
          ),

          // ⬇️ Filters row
      Padding(
  padding: const EdgeInsets.symmetric(horizontal: 8.0),
  child: Row(
    children: [
      // 🔹 Hosted Dropdown
      Expanded(
        child: DropdownButtonFormField<String>(
          value: FilterMappings.hostedMap.entries
              .firstWhere(
                (entry) => entry.value == (hostedFilter ?? ""),
                orElse: () => const MapEntry("All", ""),
              )
              .key,
          hint: const Text("Select Hosted"),
          isExpanded: true,
          items: FilterMappings.hostedMap.keys
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              hostedFilter = FilterMappings.hostedMap[value] ?? "";
              page = 1;
            });
            fetchMachines();
          },
        ),
      ),
      const SizedBox(width: 8),

      // 🔹 Environment Dropdown
      Expanded(
        child: DropdownButtonFormField<String>(
          value: FilterMappings.environmentMap.entries
              .firstWhere(
                (entry) => entry.value == (environmentFilter ?? ""),
                orElse: () => const MapEntry("All", ""),
              )
              .key,
          hint: const Text("Select Environment"),
          isExpanded: true,
          items: FilterMappings.environmentMap.keys
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              environmentFilter = FilterMappings.environmentMap[value] ?? "";
              page = 1;
            });
            fetchMachines();
          },
        ),
      ),
    ],
  ),
),
 
          const SizedBox(height: 10),
// ➕ Add Machine button (aligned right)
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              _showEditDialog(context,machines);
            },
            icon: const Icon(Icons.add),
            label: const Text("Add Machine"),
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
          // 📋 Machine cards or loader
        Expanded(
  child: isLoading
      ? const Center(child: CircularProgressIndicator())
      : machines.isEmpty
          ? const Center(child: Text("No machines found"))
          : ListView.builder(
              itemCount: machines.length,
              itemBuilder: (context, index) {
                final machine = machines[index];

                // Get initials from project name
                String initials = "";
                if (machine.projectData?.projectName != null &&
                    machine.projectData!.projectName!.isNotEmpty) {
                  final words = machine.projectData!.projectName!.split(" ");
                  if (words.length >= 2) {
                    initials =
                        "${words[0][0]}${words[1][0]}".toUpperCase();
                  } else {
                    initials = words[0][0].toUpperCase();
                  }
                }

                return Dismissible(
                  key: Key(machine.id.toString()),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.blue,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      // Swipe right → Delete
                      return await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Confirm Delete"),
                          content: const Text(
                              "Are you sure you want to delete this machine?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                      );
                    } else {
                      // Swipe left → Edit
                      return await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Confirm Edit"),
                          content: const Text(
                              "Are you sure you want to edit this machine?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                  _showEditDialog(context,machines);
                              },
                              child: const Text("Edit"),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  onDismissed: (direction) {
                    if (direction == DismissDirection.startToEnd) {
                    
                      // setState(() {
                      //   machines.removeAt(index);
                      // });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Machine deleted")),
                      );
                    } else {
                  
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Edit machine")),
                      );
                    }
                  },
                  child: Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Text(
                          initials,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(machine.projectData?.projectName ?? "N/A",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("IP: ${machine.ipAddress ?? "N/A"}"),
                          Text("Machine name:${machine.missionName ?? "N/A"}"),
                          Text("Environment: ${machine.environment ?? "N/A"}"),
                          Text("RAM: ${machine.ram ?? "N/A"}"),
                          Text("Processor: ${machine.processor ?? "N/A"}"),
                          Text("Hosted: ${machine.hosted ?? "N/A"}",),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
),



          // ⬅️➡️ Pagination
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: page > 1 ? prevPage : null,
                  child: const Text("Previous"),
                ),
                Text("Page $page"),
                ElevatedButton(
                  onPressed: machines.length == pageSize ? nextPage : null,
                  child: const Text("Next"),
                ),
              ],
            ),
          ),
        
        ],
      ),

    
    );
  }
  
void _showEditDialog(BuildContext context, List<MachineResult> machines) {
  final TextEditingController ipController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController storageController = TextEditingController();
  final TextEditingController processorController = TextEditingController();
  final TextEditingController coreController = TextEditingController();
  final TextEditingController ramController = TextEditingController(text: "8");

  String? selectedProvider;
  String? selectedProject;
  String? selectedEnvironment = "Development";
  String? selectedHosted = "Client Hosted";
  String? selectedUnit = "GB";

  final List<String> providers = ["AWS", "Azure"];
  final List<String> environments = ["Development", "Production", "Internal"];
  final List<String> hosted = ["Client Hosted", "Droidal Hosted"];
  final List<String> units = ["MB", "GB", "TB"];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      List<ProjectResponse> projects = [];
      bool isLoading = true;

      // 👇 Using StatefulBuilder so we can call setState inside dialog
      return StatefulBuilder(
        builder: (context, setState) {
          // Fetch project list only once (when dialog opens)
          Future.delayed(Duration.zero, () async {
            if (isLoading) {
              try {
                // Replace this with your actual API call
                final fetchedProjects = await apiService.getprojects();
                setState(() {
                  projects = fetchedProjects!;
                  isLoading = false;
                });
              } catch (e) {
                debugPrint("❌ Error fetching projects: $e");
                setState(() => isLoading = false);
              }
            }
          });

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text("Add New Machine"),
            content: SizedBox(
              width: 400,
              height: 450,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // IP Address
                    TextField(
                      controller: ipController,
                      decoration: const InputDecoration(
                        labelText: "Machine IP Address",
                        hintText: "192.168.1.100",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Machine Name
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Machine Name",
                        hintText: "Enter Machine name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Provider Dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Provider",
                        border: OutlineInputBorder(),
                      ),
                      value: selectedProvider,
                      isExpanded: true,
                      items: providers
                          .map((p) => DropdownMenuItem(
                                value: p,
                                child: Text(p),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => selectedProvider = v),
                    ),
                    const SizedBox(height: 12),

                    // Project Dropdown (Loaded inside dialog)
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: "Projects",
                              border: OutlineInputBorder(),
                            ),
                            value: selectedProject,
                            isExpanded: true,
                            items: projects.map((proj) {
                              return DropdownMenuItem<String>(
                                value: proj.projectName,
                                child: Text(
                                  proj.projectName ?? "",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => selectedProject = v),
                          ),
                    const SizedBox(height: 12),

                    // Environment
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Environment",
                        border: OutlineInputBorder(),
                      ),
                      value: selectedEnvironment,
                      isExpanded: true,
                      items: environments
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => selectedEnvironment = v),
                    ),
                    const SizedBox(height: 12),

                    // Hosted
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Hosted",
                        border: OutlineInputBorder(),
                      ),
                      value: selectedHosted,
                      isExpanded: true,
                      items: hosted
                          .map((h) => DropdownMenuItem(
                                value: h,
                                child: Text(h),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => selectedHosted = v),
                    ),
                    const SizedBox(height: 12),

                    // Storage + Unit together
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: storageController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Storage",
                              border: const OutlineInputBorder(),
                              suffixIcon: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      int current =
                                          int.tryParse(storageController.text) ?? 0;
                                      storageController.text =
                                          (current + 1).toString();
                                    },
                                    child: const Icon(Icons.arrow_drop_up),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      int current =
                                          int.tryParse(storageController.text) ?? 0;
                                      if (current > 0) {
                                        storageController.text =
                                            (current - 1).toString();
                                      }
                                    },
                                    child: const Icon(Icons.arrow_drop_down),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: "Unit",
                              border: OutlineInputBorder(),
                            ),
                            value: selectedUnit,
                            isExpanded: true,
                            items: units
                                .map((u) => DropdownMenuItem(
                                      value: u,
                                      child: Text(u),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() => selectedUnit = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Processor
                    TextField(
                      controller: processorController,
                      decoration: const InputDecoration(
                        labelText: "Processor",
                        hintText: "e.g. Standard_E4as_v4",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Core
                    TextField(
                      controller: coreController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Core",
                        border: const OutlineInputBorder(),
                        suffixIcon: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                int current =
                                    int.tryParse(coreController.text) ?? 0;
                                coreController.text =
                                    (current + 1).toString();
                              },
                              child: const Icon(Icons.arrow_drop_up),
                            ),
                            InkWell(
                              onTap: () {
                                int current =
                                    int.tryParse(coreController.text) ?? 0;
                                if (current > 0) {
                                  coreController.text =
                                      (current - 1).toString();
                                }
                              },
                              child: const Icon(Icons.arrow_drop_down),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // RAM
                    TextField(
                      controller: ramController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "RAM (GB)",
                        border: const OutlineInputBorder(),
                        suffixIcon: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                int current =
                                    int.tryParse(ramController.text) ?? 0;
                                ramController.text =
                                    (current + 1).toString();
                              },
                              child: const Icon(Icons.arrow_drop_up),
                            ),
                            InkWell(
                              onTap: () {
                                int current =
                                    int.tryParse(ramController.text) ?? 0;
                                if (current > 0) {
                                  ramController.text =
                                      (current - 1).toString();
                                }
                              },
                              child: const Icon(Icons.arrow_drop_down),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  print("✅ Create Machine clicked");
                  print("IP: ${ipController.text}");
                  print("Provider: $selectedProvider");
                  print("Project: $selectedProject");
                  print("Environment: $selectedEnvironment");
                  print("Hosted: $selectedHosted");
                  print("Storage: ${storageController.text} $selectedUnit");
                  print("RAM: ${ramController.text} GB");

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Machine Created Successfully")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text("Create Machine"),
              ),
            ],
          );
        },
      );
    },
  );
}


}                                 