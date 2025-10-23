import 'package:flutter/material.dart';
import 'package:flutter_application_cxo/model/UserResponse.dart';
import 'package:flutter_application_cxo/service/ApiService.dart';
import 'package:flutter_application_cxo/widget/CustomWidget.dart'; // Assuming CustomAppBar is here

class ProjectoverviewScreen extends StatefulWidget {
  final int? projectid;
  final String? projectname;

  const ProjectoverviewScreen({Key? key, this.projectid, this.projectname}) : super(key: key);

  @override
  State<ProjectoverviewScreen> createState() => ProjectoverviewScreenState();
}

class ProjectoverviewScreenState extends State<ProjectoverviewScreen> {
  String logoUrl = "";
  String? projectName = "Project Name";
  String? projectdescription = "N/A";
  String? createdat = "N/A";
  String? logo;
  int prodsubsnum = 0;
  int devmachinenum = 0;
  int prodmachinenum = 0;
  late ApiService apiservice;
  String baseurl = "";
  String profilepic = "";
  String bussinessDev ="N/A";
   List<_PersonData> projectTeam = [];

  // Helper function to extract initials from a name
  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'N/A';
    // Use the first letter of the first and last name, if available
    final parts = name.trim().split(RegExp(r'\s+'));
    String initials = '';
    if (parts.isNotEmpty) {
      initials += parts.first[0];
    }
    if (parts.length > 1) {
      initials += parts.last[0];
    }
    return initials.toUpperCase();
  }
    _PersonData _userToPersonData(UserResponse user, String defaultRole, String baseUrl) {
    final name = user.userName ?? 'N/A';
    final role = user.designation ?? defaultRole;
    final initials = _getInitials(name);
    final profilePic = user.profilePicture;
    final url = profilePic != null ? baseUrl + profilePic : null;
    
    return _PersonData(name: name, initials: initials, role: role);
  }
    @override
  void initState() {
    super.initState();
    apiservice = ApiService();
    projectName = widget.projectname ?? "Project Name";
    print("Project Name: $projectName");
    fetchdata(); // this will always print now
  }


  // Example data for the activity list
  final List<Map<String, String>> activities = const [
    {"title": "Welcome Call", "date": "June 9, 2025"},
    {"title": "Requirement Call", "date": "June 9, 2025"},
    {"title": "IT Setup", "date": "June 9, 2025"},
    {"title": "SOW", "date": "June 9, 2025"},
    {"title": "First Agent Live", "date": "June 27, 2025"},
    {"title": "QA Completion", "date": "July 1, 2025"},
    {"title": "Project Sign-off", "date": "August 6, 2025"},
    {"title": "Final Review", "date": "August 10, 2025"}, // Not completed yet
  ];
  Future<void> fetchdata() async {
  final response = await apiservice.getprojectdetail(widget.projectid ?? 0);

  projectName = response?.projectName ?? "Project Name";
  projectdescription = response?.projectDescription ?? "N/A";
  createdat = response?.createdAt.toString().split(' ').first ?? "N/A";

  // Get profile picture from clientData
  profilepic = response?.clientData.isNotEmpty == true
      ? response!.clientData.first.profilePicture ?? ""
      : "";

  baseurl = "https://cxo.droidal.com/";
  logoUrl = baseurl + (profilepic.isNotEmpty ? profilepic : "uploads/default.png");

  prodsubsnum = response?.numSubscriptions ?? 0;
  devmachinenum = response?.devMachineCount ?? 0;
  prodmachinenum = response?.prodMachineCount ?? 0;
   // LOGIC TO COMBINE ALL TEAM MEMBERS:
      final String currentBaseUrl = baseurl;

      projectTeam = [
        ...response!.projectManagerData.map((u) => _userToPersonData(u, 'Project Manager', currentBaseUrl)),
        ...response!.businessDeveloperData.map((u) => _userToPersonData(u, 'Business Developer', currentBaseUrl)),
        ...response!.teamLeadData.map((u) => _userToPersonData(u, 'Team Lead', currentBaseUrl)),
        ...response!.developerData.map((u) => _userToPersonData(u, 'Developer', currentBaseUrl)),
        ...response!.internsData.map((u) => _userToPersonData(u, 'Intern', currentBaseUrl)),
        ...response!.financeData.map((u) => _userToPersonData(u, 'Finance', currentBaseUrl)),
        ...response!.itSupportData.map((u) => _userToPersonData(u, 'IT Support', currentBaseUrl)),
      ];
  setState(() {}); // Refresh UI
  print("Fetched Logo URL: $logoUrl");
}
  
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Projects Overview"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title section
            const SizedBox(height: 4),
            Text(
              "Essential project information",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Project Card (Main Info) - (UNCHANGED)
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project Logo and Text
                    Row(
                      children: [
                        SizedBox(
                          height: 80,
                          width: 80,
                          child: Card(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
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
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                                projectName ?? "Project Name",
                              style: Theme.of(context).textTheme.bodyLarge,                              
                            ),
                            const SizedBox(height: 8),
                            Text("Description: ${projectdescription}"),
                            const SizedBox(height: 4),
                            Text("Created On: ${createdat}"),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(height: 1, thickness: 1),
                    const SizedBox(height: 16),

                    // Stats section (Horizontally Scrollable Info Cards)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _InfoCard(title: "Agents", value: "0", icon: Icons.person_outline),
                          _InfoCard(title: "Subscriptions", value: prodsubsnum.toString(), icon: Icons.subscriptions_outlined),
                          _InfoCard(title: "Prod Machine", value: prodmachinenum.toString(), icon: Icons.laptop_windows_outlined),
                          _InfoCard(title: "Dev Machine", value: devmachinenum.toString(), icon: Icons.desktop_mac_outlined),
                          _InfoCard(title: "Servers", value: "5", icon: Icons.storage_outlined), 
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            
            _TeamCard(teamMembers: projectTeam), 

            const SizedBox(height: 20),

            // Project Activity Title 
            Text(
              "Project Activity",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            // Project Activity Card (STANDALONE CARD)
            _ActivityCard(
              completed: 7, 
              total: 8, 
              activities: activities,
            ),

            const SizedBox(height: 30),

            // ROI Tracker Title (Added to match the Activity card pattern)
            Text(
              "Return On Investment",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // ROI Tracker Card (STANDALONE CARD)
            const _ROICard(),
          ],
        ),
      ),
    );
  }


}


class _ProjectActivityItem extends StatelessWidget {
  final String title;
  final String date;
  final bool isCompleted;

  const _ProjectActivityItem({
    required this.title,
    required this.date,
    this.isCompleted = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompleted ? Colors.green.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: isCompleted ? Colors.green : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          if (isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Completed",
                style: TextStyle(
                  color: Colors.green.shade800,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}


/// Project Activity Card (Corrected to be a standalone card)
class _ActivityCard extends StatelessWidget {
  final int completed;
  final int total;
  final List<Map<String, String>> activities;

  const _ActivityCard({
    required this.completed,
    required this.total,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    double progressPercent = completed / total;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Keep column size minimal
          children: [
            // Progress Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "$completed of $total completed",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  "${(progressPercent * 100).toStringAsFixed(0)}%",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Progress Bar
            LinearProgressIndicator(
              value: progressPercent,
              minHeight: 10,
              borderRadius: BorderRadius.circular(8),
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation(Colors.green),
            ),
            const SizedBox(height: 16),
            
            // List of Activities
            SizedBox(
              height: 250, // Constrain height to prevent unbounded size and allow scrolling
              child: SingleChildScrollView(
                child: Column(
                  children: activities.map((activity) {
                    int index = activities.indexOf(activity);
                    bool isDone = index < completed; 
                    return _ProjectActivityItem(
                      title: activity["title"]!,
                      date: activity["date"]!,
                      isCompleted: isDone,
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/// Represents the ROI Chart section from the screenshot.
class _ROICard extends StatelessWidget {
  const _ROICard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Title and Dropdowns
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // FIX: Wrap the title/icon Row in Expanded to force it to shrink 
                // and give space to the Dropdowns.
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.insights, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      // Added overflow handling and softWrap: false to the text
                      Flexible( 
                        child: Text( 
                          "Return On Investment",
                          style: Theme.of(context).textTheme.titleMedium,
                          softWrap: false, 
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // Dropdowns (Sized by their intrinsic content)
                Row(
                  children: const [
                    _DropdownButton(label: "All"),
                    SizedBox(width: 8),
                    _DropdownButton(label: "All"),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text("Track ROI and cost savings over time", style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),

            // Legend
            const _ChartLegend(),
            const SizedBox(height: 20),

            // Chart Placeholder Area
            Container(
              height: 250, 
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100, 
              ),
              child: const Text(
                "No ROI Data Found",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
/// Helper widget for the small dropdown buttons in the ROI card.
class _DropdownButton extends StatelessWidget {
  final String label;

  const _DropdownButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const Icon(Icons.keyboard_arrow_down, size: 16),
        ],
      ),
    );
  }
}

/// Helper widget for the chart legend in the ROI card.
class _ChartLegend extends StatelessWidget {
  const _ChartLegend();

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 2,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.black54),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildLegendItem(Colors.orange, "Cumulative Cost"),
          _buildLegendItem(Colors.green, "Cumulative Savings"),
          _buildLegendItem(Colors.red, "Manual Cost"),
          _buildLegendItem(Colors.black, "Breakeven Point"),
        ],
      ),
    );
  }
}


// -------------------------------------------------------------
// EXISTING WIDGETS (Team Card and Info Card)
// -------------------------------------------------------------

// Helper data class for team members (UNCHANGED)
class _PersonData {
  final String name;
  final String initials;
  final String role;
  const _PersonData({required this.name, required this.initials, required this.role});
}

// THE WIDGET FOR HORIZONTAL TEAM MEMBERS (UNCHANGED)
class _TeamCard extends StatelessWidget {
  final List<_PersonData> teamMembers;
  const _TeamCard({super.key, required this.teamMembers});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 16, left: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 16.0, bottom: 8.0), 
              child: Text(
                "Project Team",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), 
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: teamMembers.map((member) {
                  return Container(
                    width: 140, 
                    margin: const EdgeInsets.only(right: 12),
                    child: _PersonTile(
                      name: member.name,
                      initials: member.initials,
                      role: member.role,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// PERSON TILE (UNCHANGED)
class _PersonTile extends StatelessWidget {
  final String name;
  final String initials;
  final String role; 

  const _PersonTile({super.key, required this.name, required this.initials, required this.role});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, 
      children: [
        CircleAvatar(
          radius: 25, 
          backgroundColor: Colors.blueAccent,
          child: Text(
            initials,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(
          role, 
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

// INFO CARD (UNCHANGED)
class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;

  const _InfoCard({super.key, required this.title, required this.value, this.icon = Icons.computer});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130, 
      margin: const EdgeInsets.only(right: 8.0), 
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            mainAxisSize: MainAxisSize.min, 
            children: [
              Icon(icon, size: 20, color: Colors.blueGrey), 
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}