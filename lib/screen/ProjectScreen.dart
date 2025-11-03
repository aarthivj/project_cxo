import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_application_cxo/model/ClientResponse.dart';
import 'package:flutter_application_cxo/model/ProjectResponse.dart';
import 'package:flutter_application_cxo/model/UserResponse.dart';
import 'package:flutter_application_cxo/screen/ProjectoverviewScreen.dart';
import 'package:flutter_application_cxo/service/ApiService.dart';
import 'package:flutter_application_cxo/widget/CustomWidget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  late ApiService apiService;
  List<ProjectResponse> projects = [];
  List<ProjectResponse> filteredProjects = [];
  final TextEditingController searchController = TextEditingController();
  int? selectedIndex; // for long press selection

  // keep a list of unique managers
  List<Map<String, dynamic>> managers = [];

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    final response = await apiService.getprojects();
    if (response != null) {
      setState(() {
        projects = response;
        filteredProjects = response;

        /// collect all managers (unique by id)
        final seen = <int>{};
        managers = [];
        for (var p in response) {
          var data = p.projectManagerData;

          for (var m in data ?? []) {
            if (m.id != null && !seen.contains(m.id)) {
              seen.add(m.id!);
              managers.add({"id": m.id, "name": m.userName});
            }
          }
        }
      });
    } else {
      print("No project manager data found");
    }
  }

  void filterProjects(String query) {
    final results = projects.where((project) {
      final titleLower = project.projectName?.toLowerCase();
      final searchLower = query.toLowerCase();
      return titleLower?.contains(searchLower) ?? false;
    }).toList();

    setState(() {
      filteredProjects = results;
    });
  }

  void filterByManager(int? managerId) {
    if (managerId == null || managerId == -1) {
      setState(() {
        filteredProjects = projects;
      });
    } else {
      setState(() {
        filteredProjects = projects
            .where((p) => p.projectManagerData!.any((m) => m.id == managerId))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 600 ? 3 : 2;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Projects Screen',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search bar with filter
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search projects...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: filterProjects,
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<int>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (value) {
                    filterByManager(value);
                  },
                  itemBuilder: (BuildContext context) {
                    final List<PopupMenuEntry<int>> items = [];
                    items.add(
                      const PopupMenuItem<int>(
                        value: -1,
                        child: Text("All Projects"),
                      ),
                    );
                    for (var manager in managers) {
                      items.add(
                        PopupMenuItem<int>(
                          value: manager["id"],
                          child: Text(manager["name"]),
                        ),
                      );
                    }
                    return items;
                  },
                ),
              ],
            ),
          ),

          // Projects grid
          Expanded(

            child: projects.isEmpty? const Center(
              child: Text(
            "No project data available",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ):filteredProjects.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(10.0),
                    itemCount: filteredProjects.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.9,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                    ),
                    itemBuilder: (context, index) {
                      final project = filteredProjects[index];
                      bool isSelected = selectedIndex == index;

                      return GestureDetector(
                        onLongPress: () {
                          setState(() {
                            selectedIndex = isSelected ? null : index;
                          });
                        },
                        onTap: () {
                          if (isSelected) {
                            setState(() {
                              selectedIndex = null;
                            });
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProjectoverviewScreen(
                                  projectid: project.id,
                                  projectname: project.projectName,
                                ),
                              ),
                            );

                            print(
                              "Navigating with projectName: ${project.projectName} - ${project.id}",
                            );
                          }
                        },
                        child: Stack(
                          children: [
                            ProjectCard(
                              title: project.projectName ?? "",
                              description: project.projectDescription ?? "",
                              startDate: project.createdAt is DateTime
                                  ? project.createdAt as DateTime
                                  : DateTime.tryParse(
                                          project.createdAt?.toString() ?? "",
                                        ) ??
                                        DateTime.now(),
                              deadlineDate: project.updatedAt is DateTime
                                  ? project.updatedAt as DateTime
                                  : DateTime.tryParse(
                                          project.updatedAt?.toString() ?? "",
                                        ) ??
                                        DateTime.now(),
                              logoUrl: project.clientData!.isNotEmpty
                                  ? project.clientData?.first.profilePicture ??
                                        ""
                                  : "",
                            ),
                            if (isSelected)
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 5.0,
                                      sigmaY: 5.0,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            // Your edit action here
                                            print(
                                              "Edit project: ${project.projectName}",
                                            );
                                            _showEditDialog(context, projects,project: project,);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showEditDialog(context,projects);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  List<T> removeDuplicates<T>(List<T> list, String? Function(T) keyExtractor) {
  final seen = <String>{};
  return list.where((item) => seen.add(keyExtractor(item) ?? '')).toList();
}

void _showEditDialog(BuildContext context, List<ProjectResponse> projects, {ProjectResponse? project}) {
  final ProjectResponse? projectToEdit = project;

  // 1. Text fields
  final TextEditingController nameController = TextEditingController(
    text: projectToEdit?.projectName ?? '',
  );
  final TextEditingController descController = TextEditingController(
    text: projectToEdit?.projectDescription ?? '',
  );

  bool _isPicking = false;
  File? projectLogo;
  File? clientLogo;

  // --- State Variables ---
  String? selectedType = projectToEdit?.projectType;

  // 🎯 FIX: Single-select fields are int?
  int? selectedClientPk = projectToEdit?.clientData?.isNotEmpty == true
      ? projectToEdit!.clientData!.first.id
      : null;
  int? selectedPMPk = projectToEdit?.projectManagerData?.isNotEmpty == true
      ? projectToEdit!.projectManagerData!.first.id
      : null;
  int? selectedBDPk = projectToEdit?.businessDeveloperData?.isNotEmpty == true
      ? projectToEdit!.businessDeveloperData!.first.id
      : null;
  int? selectedFinancePk = projectToEdit?.financeData?.isNotEmpty == true
      ? projectToEdit!.financeData!.first.id
      : null;
  int? selectedITPk = projectToEdit?.itSupportData?.isNotEmpty == true
      ? projectToEdit!.itSupportData!.first.id
      : null;

  // 🎯 FIX: Multi-select fields are List<int>
  List<int> selectedDeveloperPks = projectToEdit?.developerData?.map((u) => u.id!).whereType<int>().toList() ?? [];
  List<int> selectedTLPks = projectToEdit?.teamLeadData?.map((u) => u.id!).whereType<int>().toList() ?? [];
  List<int> selectedInternPks = projectToEdit?.internsData?.map((u) => u.id!).whereType<int>().toList() ?? [];

  // --- Data Collection (Unchanged) ---
  // (allPMs, allBDs, allDevelopers, etc. lists)
  List<UserResponse> allPMs = [];
  List<UserResponse> allBDs = [];
  List<UserResponse> allDevelopers = [];
  List<UserResponse> allInterns = [];
  List<UserResponse> allTLs = [];
  List<UserResponse> allFinance = [];
  List<UserResponse> allIT = [];
  List<ClientResponse> allClients = [];

  for (var p in projects) {
    allPMs.addAll(p.projectManagerData ?? []);
    allBDs.addAll(p.businessDeveloperData ?? []);
    allDevelopers.addAll(p.developerData ?? []);
    allInterns.addAll(p.internsData ?? []);
    allTLs.addAll(p.teamLeadData ?? []);
    allFinance.addAll(p.financeData ?? []);
    allIT.addAll(p.itSupportData ?? []);
    allClients.addAll(p.clientData ?? []);
  }

  final List<UserResponse> projectManagers = removeDuplicates(allPMs, (u) => u.userName);
  final List<UserResponse> businessDevelopers = removeDuplicates(allBDs, (u) => u.userName);
  final List<UserResponse> developers = removeDuplicates(allDevelopers, (u) => u.userName);
  final List<UserResponse> interns = removeDuplicates(allInterns, (u) => u.userName);
  final List<UserResponse> teamLeads = removeDuplicates(allTLs, (u) => u.userName);
  final List<UserResponse> finance = removeDuplicates(allFinance, (u) => u.userName);
  final List<UserResponse> itSupport = removeDuplicates(allIT, (u) => u.userName);
  final List<ClientResponse> clients = removeDuplicates(allClients, (c) => c.companyName);

 final Map<String, String> projectTypeOptions = {
  'RPA': 'RPA',
  'PRODUCT': 'Product', 
};
  final picker = ImagePicker();

  // --- Helper Function for Multi-Select Display ---
  String getDisplayNamesUser(List<int> ids, List<UserResponse> allUsers) {
    if (ids.isEmpty) return '';
    return ids.map((id) {
      try {
        return allUsers.firstWhere((u) => u.id == id).userName;
      } catch (e) {
        return null;
      }
    }).whereType<String>().join(', ');
  }

  // --- Initialize Display Strings for Multi-Select fields ---
  String? selectedDeveloperDisplay = getDisplayNamesUser(selectedDeveloperPks, developers);
  String? selectedTLDisplay = getDisplayNamesUser(selectedTLPks, teamLeads);
  String? selectedInternDisplay = getDisplayNamesUser(selectedInternPks, interns);

  Future<void> pickImage(
    bool isProjectLogo,
    void Function(void Function()) setState,
  ) async {
    setState(() => _isPicking = true);
    final picked = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (picked != null) {
        if (isProjectLogo) {
          projectLogo = File(picked.path);
        } else {
          clientLogo = File(picked.path);
        }
      }
      _isPicking = false;
    });
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(projectToEdit == null ? "Add Project" : "Edit Project"),
            content: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 500,
                minWidth: 300,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ... (UI Code for Logos - Unchanged) ...
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Project Logo
                      Column(
                        children: [
                          const Text(
                            "Project Logo",
                            style: TextStyle(color: Colors.black),
                          ),
                          GestureDetector(
                            onTap: () async {
                              if (_isPicking) return;
                              await pickImage(true, setState);
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 35,
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage: projectLogo != null
                                      ? FileImage(projectLogo!)
                                      : null,
                                  child: projectLogo == null
                                      ? const Icon(
                                          Icons.add,
                                          size: 30,
                                          color: Colors.black54,
                                        )
                                      : null,
                                ),
                                if (projectLogo != null)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        size: 18,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                        ],
                      ),
                      const SizedBox(width: 25),

                      // Client Logo (SOC Upload)
                      Column(
                        children: [
                          const Text(
                            "Upload Soc",
                            style: TextStyle(color: Colors.black),
                          ),
                          GestureDetector(
                            onTap: () async {
                              if (_isPicking) return;
                              await pickImage(false, setState);
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 35,
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage: clientLogo != null
                                      ? FileImage(clientLogo!)
                                      : null,
                                  child: clientLogo == null
                                      ? const Icon(
                                          Icons.add,
                                          size: 30,
                                          color: Colors.black54,
                                        )
                                      : null,
                                ),
                                if (clientLogo != null)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        size: 18,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                        ],
                      ),
                    ],
                  ),

                  // 🔹 Scrollable form fields
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 15),
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: "Project Name",
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 15),

                          DropdownButtonFormField<String>(
  decoration: const InputDecoration(
    labelText: "Project Type",
    border: OutlineInputBorder(),
  ),
  value: selectedType, // This will now be 'RPA' or 'PRODUCT'
  items: projectTypeOptions.entries.map((entry) {
    return DropdownMenuItem<String>(
      value: entry.key,     // The value is the DB key (e.g., 'PRODUCT')
      child: Text(entry.value), // The child is the display name (e.g., 'Product')
    );
  }).toList(),
  onChanged: (value) {
    setState(() => selectedType = value); // This now stores 'PRODUCT'
  },
),
                          const SizedBox(height: 10),

                          // 🎯 FIX: Client is back to DropdownButtonFormField<int>
                          DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              labelText: "Client",
                              border: OutlineInputBorder(),
                            ),
                            isExpanded: true,
                            value: selectedClientPk,
                            items: clients.map((client) {
                              return DropdownMenuItem<int>(
                                value: client.id,
                                child: Text(
                                  client.companyName ?? 'Unnamed Client',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => selectedClientPk = value);
                            },
                          ),

                          const SizedBox(height: 10),

                          // 🎯 FIX: Project Manager is back to DropdownButtonFormField<int>
                          DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              labelText: "Project Manager",
                              border: OutlineInputBorder(),
                            ),
                            isExpanded: true,
                            value: selectedPMPk,
                            items: projectManagers.map((pm) {
                              return DropdownMenuItem<int>(
                                value: pm.id,
                                child: Text(
                                  pm.userName ?? 'Unnamed PM',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => selectedPMPk = value);
                            },
                          ),

                          const SizedBox(height: 10),

                          // 🎯 FIX: Business Developer is back to DropdownButtonFormField<int>
                          DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              labelText: "Business Developer",
                              border: OutlineInputBorder(),
                            ),
                            isExpanded: true,
                            value: selectedBDPk,
                            items: businessDevelopers.map((bd) {
                              return DropdownMenuItem<int>(
                                value: bd.id,
                                child: Text(
                                  bd.userName ?? 'Unnamed BD',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => selectedBDPk = value);
                            },
                          ),

                          const SizedBox(height: 10),

                          // 🎯 FIX: Finance is back to DropdownButtonFormField<int>
                          DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              labelText: "Finance",
                              border: OutlineInputBorder(),
                            ),
                            isExpanded: true,
                            value: selectedFinancePk,
                            items: finance.map((f) {
                              return DropdownMenuItem<int>(
                                value: f.id,
                                child: Text(
                                  f.userName ?? 'Unnamed Finance',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => selectedFinancePk = value);
                            },
                          ),

                          const SizedBox(height: 10),

                          // 🎯 FIX: IT support is back to DropdownButtonFormField<int>
                          DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              labelText: "IT support",
                              border: OutlineInputBorder(),
                            ),
                            isExpanded: true,
                            value: selectedITPk,
                            items: itSupport.map((it) {
                              return DropdownMenuItem<int>(
                                value: it.id,
                                child: Text(
                                  it.userName ?? 'Unnamed IT',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => selectedITPk = value);
                            },
                          ),

                          const SizedBox(height: 10),

                          // 🎯 Developer is MULTI-SELECT
                          MultiSelectDialogField<UserResponse>(
                             decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            title: const Text("Developers"),
                            buttonText: Text(selectedDeveloperDisplay?.isNotEmpty == true ? selectedDeveloperDisplay! : 'Select Developer(s)'),
                            initialValue: developers.where((u) => selectedDeveloperPks.contains(u.id)).toList(),
                            items: developers.map((u) => MultiSelectItem<UserResponse>(u, u.userName ?? 'Unnamed')).toList(),
                            listType: MultiSelectListType.CHIP,
                            onConfirm: (List<UserResponse> values) {
                              setState(() {
                                selectedDeveloperPks = values.map((u) => u.id!).whereType<int>().toList();
                                selectedDeveloperDisplay = getDisplayNamesUser(selectedDeveloperPks, developers);
                              });
                            },
                          ),

                          const SizedBox(height: 10),

                          // 🎯 Team Lead is MULTI-SELECT
                          MultiSelectDialogField<UserResponse>(
                             decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            title: const Text("Team Leads"),
                            buttonText: Text(selectedTLDisplay?.isNotEmpty == true ? selectedTLDisplay! : 'Select Team Lead(s)'),
                            initialValue: teamLeads.where((user) => selectedTLPks.contains(user.id)).toList(), 
                            items: teamLeads.map((user) => MultiSelectItem<UserResponse>(user, user.userName ?? 'Unnamed')).toList(),
                            listType: MultiSelectListType.CHIP,
                            onConfirm: (List<UserResponse> values) {
                              setState(() {
                                selectedTLPks = values.map((u) => u.id!).whereType<int>().toList();
                                selectedTLDisplay = getDisplayNamesUser(selectedTLPks, teamLeads);
                              });
                            },
                          ),

                          const SizedBox(height: 10),
                          
                          // 🎯 Intern is MULTI-SELECT
                          MultiSelectDialogField<UserResponse>(
                             decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            title: const Text("Interns"),
                            buttonText: Text(selectedInternDisplay?.isNotEmpty == true ? selectedInternDisplay! : 'Select Intern(s)'),
                            initialValue: interns.where((user) => selectedInternPks.contains(user.id)).toList(), 
                            items: interns.map((user) => MultiSelectItem<UserResponse>(user, user.userName ?? 'Unnamed')).toList(),
                            listType: MultiSelectListType.CHIP,
                            onConfirm: (List<UserResponse> values) {
                              setState(() {
                                selectedInternPks = values.map((u) => u.id!).whereType<int>().toList();
                                selectedInternDisplay = getDisplayNamesUser(selectedInternPks, interns);
                              });
                            },
                          ),
                          
                          const SizedBox(height: 10),
                          TextField(
                            controller: descController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: "Project Description",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final String name = nameController.text.trim();
                  final String description = descController.text.trim();
                  final String? projectType = selectedType;
                  
                  // 🎯 FIX: Convert single-select IDs to Lists
                  final List<int> clientPksList = selectedClientPk != null ? [selectedClientPk!] : [];
                  final List<int> pmPksList = selectedPMPk != null ? [selectedPMPk!] : [];
                  final List<int> bdPksList = selectedBDPk != null ? [selectedBDPk!] : [];
                  final List<int> financePksList = selectedFinancePk != null ? [selectedFinancePk!] : [];
                  final List<int> itPksList = selectedITPk != null ? [selectedITPk!] : [];
                  
                  // 🎯 FIX: Use multi-select lists directly
                  final List<int> developerList = selectedDeveloperPks;
                  final List<int> teamLeadsList = selectedTLPks;
                  final List<int> internsList = selectedInternPks;
                  
                  final bool isUpdate = projectToEdit != null;

                  if (!isUpdate) {
                    final response = await apiService.postproject(
                      name: name,
                      projectType: projectType,
                      description: description,
                      projectLogoFile: projectLogo, // Pass File object
                      socUploadFile: clientLogo, // Pass File object
                      
                      // Pass all values as Lists
                      client: clientPksList, 
                      project_manager: pmPksList,
                      business_developer: bdPksList,
                      finance: financePksList,
                      it_support: itPksList,
                      team_lead: teamLeadsList,
                      developer: developerList,
                      interns: internsList,
                    );

                    if (response != null) {
                      Navigator.pop(context);
                      showTopSnackBar(
                        Overlay.of(context),
                        _buildCustomSnackbar(
                          message: "✅ Project created successfully",
                          color: Colors.green.shade700,
                          icon: Icons.check_circle_outline,
                        ),
                      );
                      await fetchProjects();
                    } else {
                      _showErrorSnackBar(apiService.lastError);
                    }
                  } else {
                    // 🟠 UPDATE Project Payload
                    final int projectId = projectToEdit!.id!;

                    final response = await apiService.updateproject(
                      projectId: projectId,
                     name: name,
                      projectType: projectType,
                      description: description,
                      projectLogoFile: projectLogo, // Pass File object
                      socUploadFile: clientLogo, // Pass File object
                      
                      // Pass all values as Lists
                      client: clientPksList, 
                      project_manager: pmPksList,
                      business_developer: bdPksList,
                      finance: financePksList,
                      it_support: itPksList,
                      team_lead: teamLeadsList,
                      developer: developerList,
                      interns: internsList,
                    );

                    Navigator.pop(context);

                    if (response != null) {
                      showTopSnackBar(
                        Overlay.of(context),
                        _buildCustomSnackbar(
                          message: "✅ Project updated successfully",
                          color: Colors.green.shade700,
                          icon: Icons.check_circle_outline,
                        ),
                      );
                      await fetchProjects();
                    } else {
                      _showErrorSnackBar(apiService.lastError);
                    }
                  }
                },
                child: Text(projectToEdit == null ? "Save" : "Update"),
              ),
            ],
          );
        },
      );
    },
  );
}

// ⚠️ You will also need this utility function at the top level or in a helper class


void _showErrorSnackBar(dynamic errorResponse) {
    String errorMessage = "Something went wrong";

    if (errorResponse != null) {
      if (errorResponse is Map<String, dynamic>) {
        if (errorResponse.containsKey('password')) {
          errorMessage = (errorResponse['password'] as List).join("\n");
        } else if (errorResponse.containsKey('error')) {
          errorMessage = errorResponse['error'];
        }
      } else if (errorResponse is String) {
        errorMessage = errorResponse;
      }
    }

    showTopSnackBar(
      Overlay.of(context),
      _buildCustomSnackbar(
        message: "❌ $errorMessage",
        color: Colors.red.shade700,
        icon: Icons.error_outline,
      ),
    );
  }


Widget _buildCustomSnackbar({
    required String message,
    required Color color,
    required IconData icon,
  }) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(5.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min, // Constrain width
              children: [
                Icon(icon, color: Colors.white, size:20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

class ProjectCard extends StatelessWidget {
  final String logoUrl;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime deadlineDate;

  const ProjectCard({
    super.key,
    required this.logoUrl,
    required this.title,
    required this.description,
    required this.startDate,
    required this.deadlineDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            SizedBox(
              height: 30,
              width: double.infinity,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    logoUrl.isNotEmpty
                        ? logoUrl
                        : 'https://via.placeholder.com/150',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 30),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
             'Start: ${DateFormat('dd/MM/yyyy').format(startDate)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Deadline: ${DateFormat('dd/MM/yyyy').format(deadlineDate)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
