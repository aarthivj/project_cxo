import 'package:flutter/material.dart';
import 'package:flutter_application_cxo/model/UserResponse.dart';
import 'package:flutter_application_cxo/service/ApiService.dart';
import 'package:flutter_application_cxo/widget/AppTheme.dart';
import 'package:flutter_application_cxo/widget/CustomWidget.dart';
import 'dart:ui'; // Import this for BackdropFilter

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  late ApiService apiService;
  List<UserResponse> users = [];
  List<UserResponse> filteredUsers = [];
  final TextEditingController searchController = TextEditingController();
  int? selectedIndex; // Added to handle long-press selection

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final response = await apiService.getusers();
      if (response != null) {
        setState(() {
          users = response;
          filteredUsers = users;
        });
      }
    } catch (e) {
      // Handle exception gracefully
      print('Failed to fetch users: $e');
    }
  }

  void filterUsers(String query) {
    final filtered = users.where((user) {
      final name = user.userName?.toLowerCase() ?? '';
      final role = user.designation?.toLowerCase() ?? '';
      return name.contains(query.toLowerCase()) || role.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredUsers = filtered;
    });
  }

  String getInitials(String fullName) {
    if (fullName.trim().isEmpty) return "";
    List<String> parts = fullName.trim().split(RegExp(r"\s+"));
    String initials = parts.map((word) => word[0].toUpperCase()).join();
    return initials;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 600 ? 3 : 2; // responsive columns
    const double cardHeight = 200; // Fixed height for all cards

    return Scaffold(
      appBar: CustomAppBar(title: 'Users'),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search users...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    onChanged: filterUsers,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    // Handle filter action
                  },
                  icon: const Icon(Icons.filter_list),
                ),
              ],
            ),
          ),
          // User cards
          Expanded(
            child: filteredUsers.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisExtent: cardHeight, // Use this for fixed height
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
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
                          }
                        },
                        child: Stack(
                          children: [
                            SizedBox(
                              height: cardHeight, // Ensures card has fixed height
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Avatar without the extra edit button
                                      Center(
                                        child: LayoutBuilder(
                                          builder: (context, constraints) {
                                            double avatarRadius = constraints.maxWidth * 0.2;
                                            return CircleAvatar(
                                              radius: avatarRadius,
                                              backgroundColor: AppTheme.lightTheme.primaryColor,
                                              child: Text(
                                                getInitials(user.userName ?? ""),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: avatarRadius * 0.6,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      // Name
                                      Text(
                                        user.userName ?? "Unknown",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                        softWrap: true,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      // Role
                                      Text(
                                        user.designation ?? "Unknown Role",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        softWrap: true,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      // Location
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.location_on, size: 14),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              user.workLocation ?? "Unknown",
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      // Email
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.email, size: 14),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              user.userEmail ?? "Unknown",
                                              softWrap: true,
                                              style: const TextStyle(fontSize: 12),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
                                          icon: Icon(
                                            Icons.edit,
                                            color: AppTheme.lightTheme.primaryColor,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            // Your edit action
                                            print("Edit user: ${user.userName}");
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
    );
  }
}