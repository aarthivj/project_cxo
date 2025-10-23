import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_cxo/model/ClientResponse.dart';
import 'package:flutter_application_cxo/service/ApiService.dart';
import 'package:flutter_application_cxo/widget/AppTheme.dart';
import 'package:flutter_application_cxo/widget/CustomWidget.dart';

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return ClientScreenState();
  }
}

class ClientScreenState extends State<ClientScreen> {
  late ApiService apiService;
  List<ClientResponse> clients = [];
  List<ClientResponse> filteredclients = [];
  int? selectedIndex;
  final TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    apiService = ApiService();
    fetchClients();
  }

  Future<void> fetchClients() async {
    try {
      final response = await apiService.getclient();
      if (response != null) {
        setState(() {
          clients = response;
          filteredclients = clients;
        });
      }
    } catch (e) {
      // Handle exception gracefully
      print('Failed to fetch clients: $e');
    }
  }

  void filterclients(String query) {
    final filtered = clients.where((user) {
      final name = user.companyName?.toLowerCase() ?? '';
      final role = user.country?.toLowerCase() ?? '';
      return name.contains(query.toLowerCase()) ||
          role.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredclients = filtered;
    });
  }

  String getInitials(String fullName) {
    if (fullName.trim().isEmpty) return "";
    List<String> parts = fullName.trim().split(RegExp(r"\s+"));
    String initials = parts.map((word) => word[0].toUpperCase()).join();
    return initials;
  }

  String safeText(String? value, {String fallback = "N/A"}) {
    if (value == null || value.trim().isEmpty) {
      return fallback;
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 600 ? 3 : 2; // responsive columns

    return Scaffold(
      appBar: CustomAppBar(title: "Clients"),

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
                      hintText: 'Search clients...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    onChanged: filterclients,
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

          Expanded(
            child: filteredclients.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.60,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filteredclients.length,
                    itemBuilder: (context, index) {
                      final client = filteredclients[index];
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
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Card(
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            child: Stack(
                              children: [
                                // card content (avatar, text, etc.)
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Avatar
                                      Center(
                                        child: LayoutBuilder(
                                          builder: (context, constraints) {
                                            double avatarRadius =
                                                constraints.maxWidth * 0.2;
                                            return CircleAvatar(
                                              radius: avatarRadius,
                                              backgroundColor: AppTheme
                                                  .lightTheme
                                                  .primaryColor,
                                              backgroundImage:
                                                  (client.profilePicture !=
                                                          null &&
                                                      client
                                                          .profilePicture!
                                                          .isNotEmpty)
                                                  ? NetworkImage(
                                                      client.profilePicture!,
                                                    )
                                                  : null,
                                              child:
                                                  (client.profilePicture ==
                                                          null ||
                                                      client
                                                          .profilePicture!
                                                          .isEmpty)
                                                  ? Text(
                                                      getInitials(
                                                        client.companyName ??
                                                            "N/A",
                                                      ),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize:
                                                            avatarRadius * 0.6,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    )
                                                  : null,
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      // Company Name
                                      Text(
                                        safeText(client.companyName),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: true,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),

                                      // Contact Person
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.perm_contact_cal_outlined,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              safeText(client.contactPerson),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),

                                      // Onboard Date
                                      Text(
                                        client.clientOnboardDate?.toString() ??
                                            "N/A",
                                        softWrap: true,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),

                                      // Email
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.email_outlined,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              safeText(client.contactEmail),
                                              softWrap: true,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Blur overlay only when selected
                                if (isSelected)
                                  Positioned.fill(
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 5,
                                        sigmaY: 5,
                                      ),
                                      child: Container(
                                        color: Colors.black.withOpacity(0.3),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  // Handle edit action
                                                },
                                                icon: Icon(
                                                  Icons.edit,
                                                  color: AppTheme
                                                      .lightTheme
                                                      .primaryColor,
                                                  size: 28,
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  // Handle delete action
                                                },
                                                icon: Icon(
                                                  Icons.delete,
                                                  color: AppTheme
                                                      .lightTheme
                                                      .primaryColor,
                                                  size: 28,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
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

      // ✅ Floating action button in default bottom-right
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
