import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_cxo/model/ClientResponse.dart';
import 'package:flutter_application_cxo/model/ClientDebarredResponse.dart';
import 'package:flutter_application_cxo/service/ApiService.dart';
import 'package:flutter_application_cxo/widget/AppTheme.dart';
import 'package:flutter_application_cxo/widget/CustomWidget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
// In your models file (or at the top of ClientScreen.dart)

class Province {
  final int id;
  final String name;
  final String iso2; // We need this

  Province({required this.id, required this.name, required this.iso2});

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(id: json['id'], name: json['name'], iso2: json['iso2']);
  }
}

class Country {
  final int id;
  final String name;
  final String iso2; // We need this

  Country({required this.id, required this.name, required this.iso2});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(id: json['id'], name: json['name'], iso2: json['iso2']);
  }
}

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

  List<ClientResponse> liveClients = [];
  List<ClientDebarredResponse> debarredClients = [];
  List<ClientResponse> filteredLiveClients = [];
  List<ClientDebarredResponse> filteredDebarredClients = [];

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

  // ✅ NEW HELPER: Safely get properties from different client types
  dynamic _getProperty(Object? client, String propertyName) {
    if (client == null) return null;

    // --- For Live Clients ---
    if (client is ClientResponse) {
      switch (propertyName) {
        case 'companyName':
          return client.companyName;
        case 'contactPerson':
          return client.contactPerson;
        case 'contactEmail':
          return client.contactEmail;
        case 'contactAddress':
          return client.contactAddress;
        case 'clientOnboardDate':
          return client.clientOnboardDate;
        case 'additionalEmail':
          return client.additionalEmail;
        case 'country':
          return client.country;
        case 'state':
          return client.state;
        case 'profilePicture':
          return client.profilePicture;
      }
    }
    // --- For Debarred Clients ---
    else if (client is ClientDebarredResponse) {
      switch (propertyName) {
        case 'companyName':
          return client.companyName;
        case 'contactPerson':
          return client.contactPerson;
        case 'contactEmail':
          return client.contactEmail;
        case 'contactAddress':
          return client.contactAddress;
        // This is the "Churned Date" based on your card logic
        case 'debarredDate':
          return client.clientOnboardDate;
        case 'additionalEmail':
          return client.additionalEmail;
        case 'country':
          return client.country;
        case 'state':
          return client.state;
        case 'profilePicture':
          return client.profilePicture;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
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
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list),
                ),
              ],
            ),
          ),

          // TabBar
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
                      _buildLiveClientGrid(filteredLiveClients),
                      _buildDebarredClientGrid(filteredDebarredClients),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // ✅ UPDATED: Call dialog with no client to "Create"
          _showEditDialog(context, liveClients);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLiveClientGrid(List<ClientResponse> clientList) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 600 ? 3 : 2;

    if (clientList.isEmpty) {
      return Center(
        child: Text(
          "No live clients found.",
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: clientList.length,
      itemBuilder: (context, index) {
        final client = clientList[index];
        bool isSelected = selectedItem == client;

        return GestureDetector(
          onLongPress: () =>
              setState(() => selectedItem = isSelected ? null : client),
          onTap: () => setState(() {
            if (isSelected) selectedItem = null;
          }),
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
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: _buildLiveCardColumn(client), // ✅ Live Card
                  ),
                  if (isSelected) _buildCardOverlay(client: client),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDebarredClientGrid(List<ClientDebarredResponse> clientList) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 600 ? 3 : 2;

    if (clientList.isEmpty) {
      return Center(
        child: Text(
          "No debarred clients found.",
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: clientList.length,
      itemBuilder: (context, index) {
        final client = clientList[index];
        bool isSelected = selectedItem == client;

        return GestureDetector(
          onLongPress: () =>
              setState(() => selectedItem = isSelected ? null : client),
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
                      child: _buildDebarredCardColumn(
                        client,
                      ), // ✅ Debarred Card
                    ),
                  ),
                  if (isSelected) _buildCardOverlay(client: client),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLiveCardColumn(ClientResponse client) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildAvatar(client.profilePicture, client.companyName),
        const SizedBox(height: 12),
        _buildText(safeText(client.companyName), isTitle: true),
        const SizedBox(height: 4),
        _buildRow(
          Icons.perm_contact_cal_outlined,
          safeText(client.contactPerson),
          isBold: true,
        ),
        const SizedBox(height: 4),

        // ✅ Onboard Date
        _buildRow(
          Icons.calendar_today_outlined,
          "Onboard: ${safeText(client.clientOnboardDate.toString())}",
        ), // TODO: Format this date

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
        _buildRow(
          Icons.perm_contact_cal_outlined,
          safeText(client.contactPerson),
          isBold: true,
        ),
        const SizedBox(height: 4),

        // ✅ Churn Date
        _buildRow(
          Icons.calendar_today_outlined,
          "Churned: ${safeText(client.clientOnboardDate)}",
        ), // TODO: Format this date

        const SizedBox(height: 4),
        _buildRow(Icons.email_outlined, safeText(client.contactEmail)),
      ],
    );
  }

  /// Builds the Avatar circle
  Widget _buildAvatar(String? profilePicture, String? companyName) {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth * 0.6; // Adjust the size
          double height = width * 0.6; // Rectangular ratio (optional)

          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.transparent, // Transparent background
              borderRadius: BorderRadius.circular(8), // Rounded corners
              border: Border.all(
                color: const Color.fromARGB(255, 255, 255, 255),
              ), // Optional border
              image: (profilePicture != null && profilePicture.isNotEmpty)
                  ? DecorationImage(
                      image: NetworkImage(profilePicture),
                      fit: BoxFit
                          .contain, // Ensures entire image fits inside box
                    )
                  : null,
            ),
            child: (profilePicture == null || profilePicture.isEmpty)
                ? Center(
                    child: Text(
                      getInitials(companyName ?? "N/A"),
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: width * 0.3,
                        fontWeight: FontWeight.bold,
                      ),
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
    // ... (Your existing _buildText code is correct) ...
    // ... (No changes needed here) ...
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
    // ... (Your existing _buildRow code is correct) ...
    // ... (No changes needed here) ...
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

  Widget _buildCardOverlay({
    required Object client, // The clicked client
  }) {
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
                    // Determine which list to pass
                    if (client is ClientResponse) {
                      _showEditDialog(context, liveClients, client: client);
                    } else if (client is ClientDebarredResponse) {
                      _showEditDialog(context, debarredClients, client: client);
                    }
                    setState(() => selectedItem = null);
                  },
                  icon: Icon(
                    Icons.edit,
                    color: AppTheme.lightTheme.primaryColor,
                    size: 28,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // TODO: handle delete for live or debarred clients
                    setState(() => selectedItem = null);
                  },
                  icon: Icon(
                    Icons.delete,
                    color: AppTheme.lightTheme.primaryColor,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog<T>(BuildContext context, List<T> clients, {T? client}) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController personController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    final List<TextEditingController> emailControllers = [
      TextEditingController(),
    ];
    final TextEditingController agentemail = TextEditingController();
  final TextEditingController contractEndDateController = TextEditingController();
  final TextEditingController onboardDateController = TextEditingController();
    bool isDialogOpen = true;
    File? userImage;
    bool _isPicking = false;
    bool isDebarred = false;
    DateTime? onboardDate;
    DateTime? contractEndDate;

    final picker = ImagePicker();

    // 🌍 Dropdown data
    List<dynamic> countries = [];
    List<String> states = [];
    String? selectedCountry;
    String? selectedState;
    bool isLoadingCountries = true;
    bool isLoadingStates = false;

  if (client != null) {
  if (client is ClientResponse) {
    nameController.text = client.companyName ?? "";
    personController.text = client.contactPerson ?? "";
    addressController.text = client.contactAddress ?? "";
    agentemail.text = client.contactEmail ?? "";

    // Onboard date
    if (client.clientOnboardDate != null) {
      onboardDate = client.clientOnboardDate!;
      if (onboardDate != null) {
        onboardDateController.text = DateFormat('dd/MM/yyyy').format(onboardDate!);
      }
    }

    // Offboard / Debarred date
    if (client.offboardedDate != null) {
      contractEndDate = client.offboardedDate!;
      if (contractEndDate != null) {
        contractEndDateController.text = DateFormat('dd/MM/yyyy').format(contractEndDate!);
      }
    }

    // Emails
    emailControllers.clear();
    if (client.additionalEmail != null && client.additionalEmail!.isNotEmpty) {
      for (var emailObj in client.additionalEmail!) {
        emailControllers.add(TextEditingController(text: emailObj.email?.trim() ?? ""));
      }
    } else {
      emailControllers.add(TextEditingController());
    }
  } else if (client is ClientDebarredResponse) {
    // same logic for debarred clients
    nameController.text = client.companyName ?? "";
    personController.text = client.contactPerson ?? "";
    addressController.text = client.contactAddress ?? "";
    agentemail.text = client.contactEmail ?? "";
    isDebarred = true;

    if (client.clientOnboardDate != null) {
      onboardDate = DateTime.tryParse(client.clientOnboardDate!);
      if (onboardDate != null) {
        onboardDateController.text = DateFormat('dd/MM/yyyy').format(onboardDate!);
      }
    }

    if (client.offboardedDate != null) {
      contractEndDate = DateTime.tryParse(client.offboardedDate!);
      if (contractEndDate != null) {
        contractEndDateController.text = DateFormat('dd/MM/yyyy').format(contractEndDate!);
      }
    }

    emailControllers.clear();
    if (client.additionalEmail != null && client.additionalEmail!.isNotEmpty) {
      for (var emailObj in client.additionalEmail!) {
        emailControllers.add(TextEditingController(text: emailObj.email?.trim() ?? ""));
      }
    } else {
      emailControllers.add(TextEditingController());
    }
  }
}


    // Load states
    void loadStates(
      String countryName,
      void Function(void Function()) setState,
    ) {
      if (!isDialogOpen) return;
      setState(() {
        isLoadingStates = true;
        states = [];
      });

      final countryData = countries.firstWhere(
        (c) => c['name'] == countryName,
        orElse: () => null,
      );

      if (countryData != null) {
        final stateList = countryData['states'] as List<dynamic>;
        if (!isDialogOpen) return;
        setState(() {
          states = stateList.map((s) => s['name'].toString()).toList();
          isLoadingStates = false;
        });
      } else {
        if (!isDialogOpen) return;
        setState(() => isLoadingStates = false);
      }
    }

    // Fetch countries
    Future<void> fetchCountries(void Function(void Function()) setState) async {
      try {
        final response = await Dio().get(
          'https://countriesnow.space/api/v0.1/countries/states',
        );
        if (!isDialogOpen) return;
        setState(() {
          countries = response.data['data'];
          isLoadingCountries = false;
          if (selectedCountry != null) {
            loadStates(selectedCountry!, setState);
          }
        });
      } catch (e) {
        if (!isDialogOpen) return;
        setState(() => isLoadingCountries = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load countries")),
        );
      }
    }

    // Image picker
    Future<void> pickImage(void Function(void Function()) setState) async {
      if (_isPicking) return;
      _isPicking = true;
      try {
        final picked = await picker.pickImage(source: ImageSource.gallery);
        if (picked != null && Navigator.of(context).mounted && isDialogOpen) {
          setState(() {
            userImage = File(picked.path);
          });
        }
      } catch (e) {
        debugPrint("Error picking image: $e");
      } finally {
        _isPicking = false;
      }
    }

    // Show dialog
    showDialog(
      context: context,
      barrierDismissible: false, // prevent outside tap dismiss
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            if (isLoadingCountries && countries.isEmpty) {
              fetchCountries(setState);
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(client == null ? "Create Client" : "Edit Client"),
              content: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 600,
                  minWidth: 300,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Image picker
                      GestureDetector(
                        onTap: () async => await pickImage(setState),
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                            image: userImage != null
                                ? DecorationImage(
                                    image: FileImage(userImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: userImage == null
                              ? const Icon(
                                  Icons.add,
                                  size: 30,
                                  color: Colors.black54,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Other form fields...
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Company Name",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: personController,
                        decoration: const InputDecoration(
                          labelText: "Contact Person",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: agentemail,
                        decoration: const InputDecoration(
                          labelText: "Agent Email",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: addressController,
                        decoration: const InputDecoration(
                          labelText: "Address",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                     TextField(
  readOnly: true,
  controller: onboardDateController,
  decoration: InputDecoration(
    labelText: "Client Onboarded Date",
    border: const OutlineInputBorder(),
    suffixIcon: IconButton(
      icon: const Icon(Icons.calendar_today_outlined),
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: onboardDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          setState(() {
            onboardDate = picked;
            onboardDateController.text = DateFormat('dd/MM/yyyy').format(picked);
          });
        }
      },
    ),
  ),
),
 const SizedBox(height: 10),
                      // Country dropdown
                      isLoadingCountries
                          ? const Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<String>(
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: "Select Country",
                                border: OutlineInputBorder(),
                              ),
                              value:
                                  (selectedCountry != null &&
                                      countries.any(
                                        (c) => c['name'] == selectedCountry,
                                      ))
                                  ? selectedCountry
                                  : null,
                              items: countries
                                  .map<DropdownMenuItem<String>>(
                                    (c) => DropdownMenuItem<String>(
                                      value: c['name'],
                                      child: Text(c['name']),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedCountry = value;
                                  selectedState = null;
                                });
                                if (value != null) loadStates(value, setState);
                              },
                            ),
                      const SizedBox(height: 10),

                      // State dropdown
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: "Select State / Province",
                          border: OutlineInputBorder(),
                        ),
                        value:
                            (selectedState != null &&
                                states.contains(selectedState))
                            ? selectedState
                            : null,
                        items: states
                            .map<DropdownMenuItem<String>>(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                        onChanged: states.isEmpty
                            ? null
                            : (value) => setState(() => selectedState = value),
                      ),

                      // 🚫 Debarred Checkbox
                      CheckboxListTile(
                        title: const Text("Client Debarred"),
                        value: isDebarred,
                        onChanged: (val) =>
                            setState(() => isDebarred = val ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),

                      // 📅 Debarred Date
                      TextField(
  readOnly: true,
  controller: contractEndDateController,
  decoration: InputDecoration(
    labelText: "Client Debarred Date",
    border: const OutlineInputBorder(),
    suffixIcon: IconButton(
      icon: const Icon(Icons.calendar_today_outlined),
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: contractEndDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          setState(() {
            contractEndDate = picked;
            contractEndDateController.text = DateFormat('dd/MM/yyyy').format(picked);
          });
        }
      },
    ),
  ),
)
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    isDialogOpen = false;
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    log(
                      "Saved: ${nameController.text}, ${selectedCountry}, ${selectedState}",
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          client == null
                              ? "Client created successfully!"
                              : "Client updated successfully!",
                        ),
                      ),
                    );
                  },
                  child: Text(client == null ? "Create" : "Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

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

  /// ✅ MOVED INSIDE STATE
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
                Icon(icon, color: Colors.white, size: 20),
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
