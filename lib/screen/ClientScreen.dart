import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_cxo/model/ClientResponse.dart';
// 1. Import your new Debarred model
import 'package:flutter_application_cxo/model/ClientDebarredResponse.dart';
import 'package:flutter_application_cxo/service/ApiService.dart';
import 'package:flutter_application_cxo/widget/AppTheme.dart';
import 'package:flutter_application_cxo/widget/CustomWidget.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return ClientScreenState();
  }
}

class ClientScreenState extends State<ClientScreen>
    with TickerProviderStateMixin {
  late ApiService apiService;
  late TabController _tabController;

  // 2. Create separate master lists for the tabs
  List<ClientResponse> liveClients = [];
  List<ClientDebarredResponse> debarredClients = [];

  // 3. Create separate filtered lists
  List<ClientResponse> filteredLiveClients = [];
  List<ClientDebarredResponse> filteredDebarredClients = [];

  // 4. Use a generic Object? for the selected item
  Object? selectedItem;
  final TextEditingController searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          selectedItem = null; // Clear selection on tab change
        });
      }
    });
    fetchAllClients();
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  // 5. Fetch data for BOTH tabs
  Future<void> fetchAllClients() async {
    setState(() => _isLoading = true);
    try {
      final responses = await Future.wait([
        apiService.getclient(),
        apiService.getdebarredclient(),
      ]);

      setState(() {
        liveClients = responses[0] as List<ClientResponse>? ?? [];
        filteredLiveClients = liveClients;

        debarredClients = responses[1] as List<ClientDebarredResponse>? ?? [];
        filteredDebarredClients = debarredClients;

        _isLoading = false;
      });
    } catch (e) {
      print('Failed to fetch clients: $e');
      setState(() => _isLoading = false);
    }
  }

  // 6. Filter BOTH lists
  void filterclients(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredLiveClients = liveClients.where((client) {
        final name = client.companyName?.toLowerCase() ?? '';
        final role = client.country?.toLowerCase() ?? '';
        return name.contains(lowerQuery) || role.contains(lowerQuery);
      }).toList();

      filteredDebarredClients = debarredClients.where((client) {
        final name = client.companyName?.toLowerCase() ?? '';
        final role = client.country?.toLowerCase() ?? '';
        return name.contains(lowerQuery) || role.contains(lowerQuery);
      }).toList();
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
    return Scaffold(
      appBar: CustomAppBar(title: "Clients"),
      body: Column(
        children: [
          // Search bar (Unchanged)
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
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list),
                ),
              ],
            ),
          ),

          // TabBar (Unchanged)
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.lightTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.lightTheme.primaryColor,
            tabs: const [
              Tab(text: "LIVE"),
              Tab(text: "DEBARRED"),
            ],
          ),

          // TabBarView
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // 7. Call the Live grid builder
                      _buildLiveClientGrid(filteredLiveClients),
                      // 8. Call the Debarred grid builder
                      _buildDebarredClientGrid(filteredDebarredClients),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement your _showEditDialog call
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // -----------------------------------------------------------------
  // LIVE CLIENT GRID
  // -----------------------------------------------------------------
  Widget _buildLiveClientGrid(List<ClientResponse> clientList) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 600 ? 3 : 2;

    if (clientList.isEmpty) {
      return Center(
          child:
              Text("No live clients found.", style: TextStyle(color: Colors.grey[600])));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.60,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: clientList.length,
      itemBuilder: (context, index) {
        final client = clientList[index];
        bool isSelected = selectedItem == client;

        return GestureDetector(
          onLongPress: () => setState(() => selectedItem = isSelected ? null : client),
          onTap: () => setState(() {
            if (isSelected) selectedItem = null;
          }),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: _buildLiveCardColumn(client), // ✅ Live Card
                  ),
                  if (isSelected) _buildCardOverlay(client), // ✅ Overlay
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // -----------------------------------------------------------------
  // DEBARRED CLIENT GRID
  // -----------------------------------------------------------------
  Widget _buildDebarredClientGrid(List<ClientDebarredResponse> clientList) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 600 ? 3 : 2;

    if (clientList.isEmpty) {
      return Center(
          child: Text("No debarred clients found.",
              style: TextStyle(color: Colors.grey[600])));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.60,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: clientList.length,
      itemBuilder: (context, index) {
        final client = clientList[index];
        bool isSelected = selectedItem == client;

        return GestureDetector(
          onLongPress: () => setState(() => selectedItem = isSelected ? null : client),
          onTap: () => setState(() {
            if (isSelected) selectedItem = null;
          }),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                // ✅ STYLING: Red border
                side: BorderSide(color: Colors.red.shade300, width: 2),
              ),
              elevation: 4,
              child: Stack(
                children: [
                  // ✅ STYLING: Opacity for "disabled" look
                  Opacity(
                    opacity: 0.6,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: _buildDebarredCardColumn(client), // ✅ Debarred Card
                    ),
                  ),
                  if (isSelected) _buildCardOverlay(client), // ✅ Overlay
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // -----------------------------------------------------------------
  // CARD CONTENT WIDGETS
  // -----------------------------------------------------------------

  /// Builds the content for a LIVE client card
  Widget _buildLiveCardColumn(ClientResponse client) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildAvatar(client.profilePicture, client.companyName),
        const SizedBox(height: 12),
        _buildText(safeText(client.companyName), isTitle: true),
        const SizedBox(height: 4),
        _buildRow(Icons.perm_contact_cal_outlined, safeText(client.contactPerson),
            isBold: true),
        const SizedBox(height: 4),
        
        // ✅ Onboard Date
        _buildRow(Icons.calendar_today_outlined,
            "Onboard: ${safeText(client.clientOnboardDate.toString())}"),
            
        const SizedBox(height: 4),
        _buildRow(Icons.email_outlined, safeText(client.contactEmail)),
      ],
    );
  }

  /// Builds the content for a DEBARRED client card
  Widget _buildDebarredCardColumn(ClientDebarredResponse client) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildAvatar(client.profilePicture, client.companyName),
        const SizedBox(height: 12),
        _buildText(safeText(client.companyName), isTitle: true),
        const SizedBox(height: 4),
        _buildRow(Icons.perm_contact_cal_outlined, safeText(client.contactPerson),
            isBold: true),
        const SizedBox(height: 4),

        // ✅ Churn Date
        _buildRow(Icons.calendar_today_outlined,
            "Churned: ${safeText(client.clientOnboardDate)}"), 
            
        const SizedBox(height: 4),
        _buildRow(Icons.email_outlined, safeText(client.contactEmail)),
      ],
    );
  }

  // -----------------------------------------------------------------
  // REUSABLE HELPER WIDGETS
  // -----------------------------------------------------------------

  /// Builds the Avatar circle
  Widget _buildAvatar(String? profilePicture, String? companyName) {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          double avatarRadius = constraints.maxWidth * 0.2;
          return CircleAvatar(
            radius: avatarRadius,
            backgroundColor: AppTheme.lightTheme.primaryColor,
            backgroundImage:
                (profilePicture != null && profilePicture.isNotEmpty)
                    ? NetworkImage(profilePicture)
                    : null,
            child: (profilePicture == null || profilePicture.isEmpty)
                ? Text(
                    getInitials(companyName ?? "N/A"),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: avatarRadius * 0.6,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }

  /// Builds a text row for the card
  Widget _buildText(String text, {bool isTitle = false}) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: isTitle ? FontWeight.bold : FontWeight.normal,
        fontSize: isTitle ? 16 : 12,
        color: Colors.black,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
      textAlign: TextAlign.center,
    );
  }

  /// Builds an icon/text row for the card
  Widget _buildRow(IconData icon, String text, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 14 : 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Builds the long-press overlay
  Widget _buildCardOverlay(Object client) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    // Handle edit action
                    // TODO: Implement your _showEditDialog call
                    // Pass 'client' which can be either type
                  },
                  icon: Icon(Icons.edit,
                      color: AppTheme.lightTheme.primaryColor, size: 28),
                ),
                IconButton(
                  onPressed: () {
                    // Handle delete action
                  },
                  icon: Icon(Icons.delete,
                      color: AppTheme.lightTheme.primaryColor, size: 28),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}