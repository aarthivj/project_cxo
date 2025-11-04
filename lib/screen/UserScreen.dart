import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_cxo/model/UserResponse.dart';
import 'package:flutter_application_cxo/service/ApiService.dart';
import 'package:flutter_application_cxo/widget/AppTheme.dart';
import 'package:flutter_application_cxo/widget/CustomWidget.dart';
import 'dart:ui';

import 'package:image_picker/image_picker.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart'; // Import this for BackdropFilter

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
            child:users.isEmpty? const Center(
            child: Text(
            "No User data available",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),

            ): filteredUsers.isEmpty
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
                                            _showEditDialog(context, users, user: user);
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
      floatingActionButton: FloatingActionButton(onPressed: (){},
      child: IconButton(onPressed: (){
       _showEditDialog(context, users);
      }, icon: Icon(Icons.add)),),
    );
  }
  


void _showEditDialog(BuildContext context, List<UserResponse> users,
      {UserResponse? user}) {
    final TextEditingController nameController =
        TextEditingController(text: user?.userName ?? '');
    final TextEditingController emailcontroller =
        TextEditingController(text: user?.userEmail ?? '');
    final TextEditingController passwordcontroller =
        TextEditingController(); // keep empty for security

    File? userImage;
    bool production = user?.productionSupport ?? false;
    bool isStatusActive = user?.isActive ?? true;
    String? selectedLocation = user?.workLocation;
    String? selectedDesignation = user?.designation;
    int? selectedRoleId = user?.roleDetail?.id;

    bool _isPicking = false;
    final List<String> designations = users
        .map((u) => u.designation ?? '')
        .where((d) => d.isNotEmpty)
        .toSet()
        .toList();

    final List<Map<String, dynamic>> roles = [];
    for (var u in users) {
      if (u.roleDetail != null &&
          !roles.any((r) => r['id'] == u.roleDetail!.id)) {
        roles.add({
          'id': u.roleDetail!.id,
          'name': u.roleDetail!.name,
        });
      }
    }

    final List<String> Location = ['Chennai', 'Coimbatore'];
    final picker = ImagePicker();

    Future<void> pickImage(
      bool isUserImage,
      void Function(void Function()) setState,
    ) async {
      if (_isPicking) return;
      _isPicking = true;
      try {
        final picked = await picker.pickImage(source: ImageSource.gallery);
        if (picked != null) {
          setState(() {
            if (isUserImage) userImage = File(picked.path);
          });
        }
      } catch (e) {
        debugPrint("Error picking image: $e");
      } finally {
        _isPicking = false;
      }
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
              title: Text(user == null ? "Create User" : "Edit User"),
              content: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 550,
                  minWidth: 300,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🟢 Avatar Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            const Text(
                              "User Image",
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
                                    backgroundImage: userImage != null
                                        ? FileImage(userImage!)
                                        : null,
                                    child: userImage == null
                                        ? const Icon(Icons.add,
                                            size: 30, color: Colors.black54)
                                        : null,
                                  ),
                                  if (userImage != null)
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.edit,
                                            size: 18, color: Colors.blue),
                                      ),
                                    ),
                                  if (_isPicking)
                                    const Positioned.fill(
                                      child: Center(
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
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

                    // 🟢 Scrollable Form Fields
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 15),
                            TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: "User Name",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: emailcontroller,
                              decoration: const InputDecoration(
                                labelText: "Email",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: passwordcontroller,
                              decoration: const InputDecoration(
                                labelText: "Password",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 15),
                            // 🟢 Designation Dropdown
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: "Designation",
                                border: OutlineInputBorder(),
                              ),
                              value: selectedDesignation != null &&
                                      designations.contains(selectedDesignation)
                                  ? selectedDesignation
                                  : null,
                              isExpanded: true,
                              items: designations.map((designation) {
                                return DropdownMenuItem<String>(
                                  value: designation,
                                  child: Text(
                                    designation,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => selectedDesignation = value);
                              },
                            ),
                            const SizedBox(height: 10),

                            // 🟢 Role Dropdown
                            DropdownButtonFormField<int>(
                              decoration: const InputDecoration(
                                labelText: "Role",
                                border: OutlineInputBorder(),
                              ),
                              value: roles.any((role) => role['id'] == selectedRoleId)
                                  ? selectedRoleId
                                  : null, // ✅ ensures valid value only
                              isExpanded: true,
                              items: roles.map((role) {
                                return DropdownMenuItem<int>(
                                  value: role['id'] as int,
                                  child: Text(role['name'] ?? ''),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => selectedRoleId = value);
                              },
                            ),

                            const SizedBox(height: 10),

                            // 🟢 Location Dropdown
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: "Location",
                                border: OutlineInputBorder(),
                              ),
                              value: selectedLocation != null &&
                                      Location.contains(selectedLocation)
                                  ? selectedLocation
                                  : null,
                              isExpanded: true,
                              items: Location.map((loc) {
                                return DropdownMenuItem<String>(
                                  value: loc,
                                  child: Text(loc),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => selectedLocation = value);
                              },
                            ),
                            const SizedBox(height: 15),

                            // ✅ Checkbox
                            CheckboxListTile(
                              title: const Text("Production Support"),
                              value: production,
                              onChanged: (val) {
                                setState(() => production = val ?? false);
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            ),

                            const SizedBox(height: 10),

                            // ✅ Status Toggle
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Active Status:",
                                  style: TextStyle(fontSize: 16),
                                ),
                                Switch(
                                  value: isStatusActive,
                                  onChanged: (value) {
                                    setState(() => isStatusActive = value);
                                  },
                                  activeColor: Colors.green,
                                  inactiveThumbColor: Colors.red,
                                ),
                              ],
                            ),
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
                    // 1. Define the base common parameters
                    final String name = nameController.text;
                    final String email = emailcontroller.text;
                    final String? imagePath = userImage?.path;
                    final String? location = selectedLocation;
                    final bool prodSupport = production;
                    final bool isActive = isStatusActive;
                    final String? designation = selectedDesignation;
                    final int? roleId = selectedRoleId;

                    // if (!isValid()) return; // You might want to add validation here

                    if (user == null) {
                      // 🟢 CREATE user payload
                      final String password = passwordcontroller.text;

                      final Map<String, dynamic> createPayload = {
                        'user_name': name,
                        'user_email': email,
                        'password': password,
                        'profile_picture': imagePath,
                        'work_location': location,
                        'production_support': prodSupport,
                        'is_active': isActive,
                        'designation': designation,
                        'role_id': roleId,
                      };

                      log('CREATE Payload: $createPayload');

                      final response = await apiService.postusers(
                        name,
                        email,
                        password,
                        imagePath,
                        location,
                        prodSupport,
                        isActive,
                        designation,
                        roleId,
                      );

                      Navigator.pop(context);

                      if (response != null) {
                        // ✅ FIX: Added showTopSnackBar wrapper
                        showTopSnackBar(
                          Overlay.of(this.context),
                          _buildCustomSnackbar(
                            message: "✅ User created successfully",
                            color: Colors.green.shade700,
                            icon: Icons.check_circle_outline,
                          ),
                        );
                        await fetchUsers();
                      } else {
                        _showErrorSnackBar(apiService.lastError);
                      }
                    } else {
                      // 🟠 UPDATE user payload
                      final int userId = user.id!;
                      final String? password = passwordcontroller.text.isEmpty
                          ? null
                          : passwordcontroller.text;

                      final Map<String, dynamic> updatePayload = {
                        'id': userId,
                        'user_name': name,
                        'user_email': email,
                        'password': password, // Only send if not empty
                        'profile_picture': imagePath,
                        'user_location': location,
                        'production_support': prodSupport,
                        'is_active': isActive,
                        'designation': designation,
                        'role_id': roleId,
                      };

                      // 🛑 PRINT PAYLOAD BEFORE API CALL
                      log('UPDATE Payload: $updatePayload');

                      // Call API Service
                      final response = await apiService.updateusers(
                        userId,
                        name,
                        email,
                        password, // Pass the nullable password variable
                        imagePath,
                        location,
                        prodSupport,
                        isActive,
                        designation,
                        roleId,
                      );

                      // Navigate only after the API call
                      Navigator.pop(context);

                      if (response != null) {
                        // ✅ FIX: Added showTopSnackBar wrapper
                        showTopSnackBar(
                          Overlay.of(this.context),
                          _buildCustomSnackbar(
                            message: "✅ User updated successfully",
                            color: Colors.green.shade700,
                            icon: Icons.check_circle_outline,
                          ),
                        );
                        await fetchUsers();
                      } else {
                        _showErrorSnackBar(apiService.lastError);
                      }
                    
                    }
                  },
                  child: Text(user == null ? "Save" : "Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }





// In _UserScreenState
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