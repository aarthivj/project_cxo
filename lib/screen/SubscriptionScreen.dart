import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_cxo/model/ClientResponse.dart';
import 'package:flutter_application_cxo/model/SubscriptionResponse.dart';
import 'package:flutter_application_cxo/service/ApiService.dart';
import 'package:flutter_application_cxo/widget/CustomWidget.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return SubscriptionScreenState();
  }
}

class SubscriptionScreenState extends State<SubscriptionScreen> {
  late ApiService apiService = ApiService();
  final TextEditingController searchController = TextEditingController();

  List<SubscriptionResponse> _allSubscriptions = [];
  List<SubscriptionResponse> _filteredSubscriptions = []; 
 List<SubscriptionResponse> subscription = []; 
  
  int page = 1;
  final int pageSize = 10; // Use 'final' as this shouldn't change
  bool isLoading = false;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
    fetchsubscription(); 
  }
  void _applyFiltersAndPagination() {
    _filteredSubscriptions = _allSubscriptions.where((sub) {
      if (searchQuery.isEmpty) return true;
      final query = searchQuery.toLowerCase();
    
      final companyName = sub.clientData?.companyName?.toLowerCase() ?? '';
      final plan = sub.plan?.toLowerCase() ?? '';
      final contactPerson = sub.clientData?.contactPerson?.toLowerCase() ?? '';

      return companyName.contains(query) ||
          plan.contains(query) ||
          contactPerson.contains(query);
    }).toList();

    final startIndex = (page - 1) * pageSize;
    final endIndex = startIndex + pageSize;

    if (startIndex < _filteredSubscriptions.length) {
      subscription = _filteredSubscriptions.sublist(
        startIndex,
        endIndex > _filteredSubscriptions.length ? _filteredSubscriptions.length : endIndex,
      );
    } else {
      subscription = []; 
      if (_filteredSubscriptions.isNotEmpty) page = 1;
    }
  }

  Future<void> fetchsubscription() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await apiService.getsubscription(); 
      if (response != null) {
        _allSubscriptions = response; 
        
        setState(() {
          _applyFiltersAndPagination();
        });
      }
    } catch (e) {
      debugPrint("Failed to fetch subscriptions: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void onSearchChanged(String value) {
    searchQuery = value;
    page = 1; 
    setState(() {
      _applyFiltersAndPagination();
    });
  }

  void nextPage() {
    if (page * pageSize < _filteredSubscriptions.length) {
      page++;
      setState(() {
        _applyFiltersAndPagination();
      });
    }
  }

  void prevPage() {
    if (page > 1) {
      page--;
      setState(() {
        _applyFiltersAndPagination();
      });
    }
  }

  // --- UI Widget Build ---
  
  @override
  Widget build(BuildContext context) {
    final bool hasNextPage = (page * pageSize) < _filteredSubscriptions.length;

    return Scaffold(
        appBar: const CustomAppBar(title: "Subscriptions"),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                    hintText: "Search subscriptions...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    )),
                onChanged: onSearchChanged,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : subscription.isEmpty
                      ? Center(child: Text(searchQuery.isNotEmpty ? "No results found for '$searchQuery'" : "No subscriptions found"))
                      : ListView.builder(
                          itemCount: subscription.length, 
                          itemBuilder: (context, index) {
                            final subscriptions = subscription[index];
                            final clientData = subscriptions.clientData;
                            String initials = "N/A";
                            if (clientData?.companyName != null &&
                                clientData!.companyName!.isNotEmpty) {
                              final companyName = clientData.companyName!;
                              final words = companyName.split(" ");
                              if (words.length >= 2) {
                                initials =
                                    "${words[0][0]}${words[1][0]}".toUpperCase();
                              } else if (words.isNotEmpty) {
                                initials = words[0][0].toUpperCase();
                              }
                            }

                            final keyString =
                                subscriptions.id?.toString() ?? 'Subscription_$index';

                            return Dismissible(
                              key: Key(keyString),
                              background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.only(left: 20),
                                  child: const Icon(Icons.delete,
                                      color: Colors.white)),
                              secondaryBackground: Container(
                                  color: Colors.blue,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(Icons.edit,
                                      color: Colors.white)),
                              confirmDismiss: (direction) async {
                                return false; // Placeholder for logic
                              },
                              onDismissed: (direction) {
                                // Placeholder for logic
                              },
                              child: Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center, 
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.blueAccent,
                                        child: Text(
                                          initials,
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      const SizedBox(width: 16.0), // Spacer

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              clientData?.companyName ?? "N/A",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.black),
                                            ),
                                            const SizedBox(height: 4.0), // Small spacer
Text(
    "Plan: ${subscriptions.plan ?? "N/A"}",
    style: TextStyle(
        color: (subscriptions.plan?.toLowerCase() == "standard")
            ? Colors.blue
            : (subscriptions.plan?.toLowerCase() == "enterprise")
                ? Colors.deepPurple // Using deepPurple for violet color
                : Colors.black, // Default color if neither matches
    ),
),                                            Text("No of subscriptions: ${subscriptions.planOrder ?? "N/A"}", style: TextStyle(color: Colors.black)),
                                            Text("From date: ${subscriptions.fromDate ?? "N/A"}", style: TextStyle(color: Colors.black)),
                                            Text("To date: ${subscriptions.toDate ?? "N/A"}", style: TextStyle(color: Colors.black)),
                                            Text("Status: ${subscriptions.status ?? "N/A"}", style: TextStyle(color: Colors.black)),
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

            // ⬅️➡️ Pagination Control
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button is disabled when on page 1
                  ElevatedButton(
                    onPressed: page > 1 ? prevPage : null,
                    child: const Text("Previous"),
                  ),
                  Text("Page $page"),
                  // Next button is disabled if the last page of the filtered data has been reached
                  ElevatedButton(
                    onPressed: hasNextPage ? nextPage : null,
                    child: const Text("Next"),
                  ),
                ],
              ),
            ),
          ],
        ));
  }


}