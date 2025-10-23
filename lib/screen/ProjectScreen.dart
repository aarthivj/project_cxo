import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_application_cxo/model/ProjectResponse.dart';
import 'package:flutter_application_cxo/screen/ProjectoverviewScreen.dart';
import 'package:flutter_application_cxo/service/ApiService.dart';
import 'package:flutter_application_cxo/widget/CustomWidget.dart';

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
              managers.add({
                "id": m.id,
                "name": m.userName,
              });
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
            child: filteredProjects.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(10.0),
                    itemCount: filteredProjects.length,
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
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
                          }else{
                            Navigator.push(context,
                             MaterialPageRoute(builder: (context)=>ProjectoverviewScreen(projectid:project.id,projectname : project.projectName)));
                          
                          print("Navigating with projectName: ${project.projectName} - ${project.id}");

                          }
                        },
                        child: Stack(
                          children: [
                            ProjectCard(
                              title: project.projectName??"",
                              description:
                                  project.projectDescription ?? "",
                              startDate: project.createdAt is DateTime
                                  ? project.createdAt as DateTime
                                  : DateTime.tryParse(project.createdAt?.toString() ?? "") ?? DateTime.now(),
                              deadlineDate: project.updatedAt is DateTime
                                  ? project.updatedAt as DateTime
                                  : DateTime.tryParse(project.updatedAt?.toString() ?? "") ?? DateTime.now(),
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
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
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
                print("Edit project: ${project.projectName}");
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
        onPressed: () {},
        child: const Icon(Icons.add),
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
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text('Start: $startDate',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text('Deadline: $deadlineDate',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
