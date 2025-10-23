import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_cxo/model/ClientonchartResponse.dart';
import 'package:flutter_application_cxo/model/MetricsResponse.dart';
import 'package:flutter_application_cxo/model/TranschartResponse.dart';
import 'package:flutter_application_cxo/screen/ActivityScreen.dart';
import 'package:flutter_application_cxo/screen/AknowledgementScreen.dart';
import 'package:flutter_application_cxo/screen/ClientScreen.dart';
import 'package:flutter_application_cxo/screen/LicenseScreen.dart';
import 'package:flutter_application_cxo/screen/MachineScreen.dart';
import 'package:flutter_application_cxo/screen/PerformanceScreen.dart';
import 'package:flutter_application_cxo/screen/ProjectScreen.dart';
import 'package:flutter_application_cxo/screen/SubscriptionScreen.dart';
import 'package:flutter_application_cxo/screen/UserScreen.dart';
import 'package:flutter_application_cxo/service/ApiService.dart';
import 'package:flutter_application_cxo/widget/CustomWidget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
// --- UPDATED MOCK DATA FOR METRIC CARDS (SIMULATING API RESPONSE) ---
// Each metric card now contains an 'innerData' list with dynamic 'count', 'label', and 'icon'.
final List<Map<String, dynamic>> _keyMetricsData = [
  {
    'title': 'Customers',
    'icon': Icons.people,
    'color': Colors.blue,
    'items': 4,
    'innerData': [
      {
        'count': 55,
        'icon': Icons.business_center,
        'label': 'Customers',
      }, // Count set from API
      {
        'count': 12,
        'icon': Icons.person_add,
        'label': 'AI Agents',
      }, // Icon and label changed
      {'count': 3, 'icon': Icons.sentiment_dissatisfied, 'label': 'Subscribers'},
      {'count': 1, 'icon': Icons.star, 'label': 'Free Trials'},
    ],
  },
  {
    'title': 'Machines',
    'icon': Icons.shield_outlined,
    'color': Colors.orange,
    'items': 3,
    'innerData': [
      {'count': 150, 'icon': Icons.vpn_key, 'label': 'Dev'},
      {'count': 10, 'icon': Icons.alarm, 'label': 'Prod'},
      {'count': 5, 'icon': Icons.block, 'label': 'Internal'},
      {'count': 5, 'icon': Icons.block, 'label': 'Azure'},

    ],
  },
  {
    'title': 'Licenses',
    'icon': Icons.print_rounded,
    'color': Colors.red,
    'items': 2,
    'innerData': [
      {'count': 78, 'icon': Icons.memory, 'label': 'Dev License'},
      {'count': 5, 'icon': Icons.wifi_off, 'label': 'Prod License'},
      {'count': 12, 'icon': Icons.system_update_alt, 'label': 'Client Hosted'},
    ],
  },
  {
    'title': 'Transactions',
    'icon': Icons.folder_open,
    'color': Colors.green,
    'items': 4,
    'innerData': [
      {'count': 57, 'icon': Icons.layers, 'label': 'This Month'},
      {'count': 18, 'icon': Icons.trending_up, 'label': 'This Year'},
    
    ],
  },
  {
    'title': 'Users',
    'icon': Icons.person,
    'color': Colors.purple,
    'items': 6,
    'innerData': [
      {'count': 25, 'icon': Icons.psychology_alt, 'label': 'AI'},
      {'count': 40, 'icon': Icons.computer, 'label': 'SWE'},
      {'count': 10, 'icon': Icons.school, 'label': 'Interns'},
      {'count': 7, 'icon': Icons.chair, 'label': 'In Bench'},
      {'count': 12, 'icon': Icons.support_agent, 'label': 'Prod Support'},
      {'count': 5, 'icon': Icons.free_breakfast, 'label': 'Free Trial'},
    ],
  },
];

final List<Map<String, dynamic>> _dataCards = [
  {
    'title': 'Project Alpha Updated',
    'subtitle': 'Edited by John at 10:30 AM',
    'icon': Icons.update,
    'color': Colors.blue,
  },
  {
    'title': 'License Expiring Soon',
    'subtitle': '3 licenses will expire in 5 days',
    'icon': Icons.warning_amber_rounded,
    'color': Colors.orange,
  },
  {
    'title': 'New Customer Added',
    'subtitle': 'Droidal Inc. joined on Oct 6',
    'icon': Icons.person_add_alt_1,
    'color': Colors.green,
  },
  {
    'title': 'Machine Connected',
    'subtitle': 'Device M210 active since 2 hrs',
    'icon': Icons.settings_remote,
    'color': Colors.purple,
  },
  {
    'title': 'Transaction Completed',
    'subtitle': 'Invoice #2034 processed',
    'icon': Icons.check_circle,
    'color': Colors.teal,
  },
];

// 🏠 Rest of your HomeScreen code (unchanged)

List<Map<String, dynamic>> _dataCardsrenew = []; // initialize empty


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedItem = 'Dashboard';
  Map<String, dynamic>? _apiMetrics;

  late ApiService apiService = ApiService();
    bool loading = true;
      List<double> chartData = [];
  List<String> labels = [];
  int selectedYear = DateTime.now().year;
  final int currentCalendarYear = DateTime.now().year; 


  List<double> onboardedData = [];
  List<double> debarredData = [];
  List<String> chartLabels = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
    fetchmetrics();
    _apiMetrics = _keyMetricsData.first;
    loadChart();
    fetchDataForYear(selectedYear); 
    fetchupcomingrenewals();

  }

String formatNumber(int n) {
  if (n < 1000) {
    return n.toString();
  } else if (n < 1000000) {
    final value = (n / 1000);
    return value.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '') + 'K';
  } else if (n < 1000000000) {
    final value = (n / 1000000);
    return value.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '') + 'M';
  } else {
    final value = (n / 1000000000);
    return value.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '') + 'B';
  }
}

Future<void> fetchmetrics() async {
  final response = await apiService.getmetrics();
  final userresponse = await apiService.getusermetrics();

  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);
  final yearStart = DateTime(now.year, 1, 1);
  final monthEndSafe = DateTime(now.year, now.month, now.day + 1); 
  final yearEndSafe = DateTime(now.year, now.month, now.day + 1); 
    // Format dates (using the safer end date)
  String formatDate(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  final monthStartStr = formatDate(monthStart);
  final monthEndStr = formatDate(monthEndSafe); 
  final yearStartStr = formatDate(yearStart);
  final yearEndStr = formatDate(yearEndSafe); 

  final transMonthResponse = await apiService.gettranschart(monthStartStr, monthEndStr);
  final transYearResponse = await apiService.gettranschart(yearStartStr, yearEndStr);

  int sumTransactions(dynamic responseData) {
    if (responseData == null || responseData is! List) return 0;
    
    return responseData.fold<int>(0, (sum, item) {
      if (item is ChartData) { 
        return sum + item.transaction; 
      } 
      else if (item is Map<String, dynamic>) { 
        final value = item['transaction'] ?? 0;
        return sum + (value is int ? value : int.tryParse(value.toString()) ?? 0);
      }
      return sum;
    });
  }

  // Calculate totals as RAW INTEGERS
  final monthTotal = sumTransactions(transMonthResponse?.chartData); 
  final yearTotal = sumTransactions(transYearResponse?.chartData);

  // *** ONLY SHOW FORMATTED NUMBER IN LOGS ***
  print("📊 This Month Total Transactions: ${formatNumber(monthTotal)}"); 
  print("📅 This Year Total Transactions: ${formatNumber(yearTotal)}");
  // ****************************************

  // ✅ Step 4: Map API counts
  // *** CHANGE MAP TYPE TO dynamic TO ALLOW BOTH int AND String ***
  final Map<String, dynamic> apiCounts = {
    'Customers': response?.numClients ?? 0,
    'AI Agents': 0,
    'Subscribers': response?.numSubscriptions ?? 0,
    'Free Trials': response?.numDevmachine ?? 0,
    'Dev': response?.numDevmachine ?? 0,
    'Prod': response?.numProdmachine ?? 0,
    'Internal': response?.numInternalmachine ?? 0,
    'Azure': 0,
    'Dev License': response?.numDevlicense ?? 0,
    'Prod License': response?.numProdlicense ?? 0,
    'Client Hosted': response?.numClienthosted ?? 0,
    'This Month': formatNumber(monthTotal), // Now correctly stores String
    'This Year': formatNumber(yearTotal),   // Now correctly stores String
    'AI': userresponse?.aiUser ?? 0,
    'SWE': userresponse?.seUser ?? 0,
    'Interns': userresponse?.internUser ?? 0,
    'In Bench': 0,
    'Prod Support': userresponse?.supportUser ?? 0,
    'Free Trial': 0,
  };

  // ✅ Step 5: Update UI
  setState(() {
    for (var metric in _keyMetricsData) {
      for (var item in metric['innerData']) {
        final label = item['label'] as String;
        if (apiCounts.containsKey(label)) {
          // item['count'] will now be assigned either an int or a String ("362K")
          item['count'] = apiCounts[label];
        }
      }
    }
  });
}

 
 
   Future<void> loadChart() async {
    setState(() {
      loading = true;
    });
DateTime now = DateTime.now();
DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0); // 0th day of next month = last day of current month

String formattedStart = "${firstDayOfMonth.year}-${firstDayOfMonth.month.toString().padLeft(2,'0')}-${firstDayOfMonth.day.toString().padLeft(2,'0')}";
String formattedEnd = "${lastDayOfMonth.year}-${lastDayOfMonth.month.toString().padLeft(2,'0')}-${lastDayOfMonth.day.toString().padLeft(2,'0')}";

// Pass to API
    try {
final response = await apiService.getsubschart(formattedStart, formattedEnd);
      if (response != null && response.chartData.isNotEmpty) {
        final data = response.chartData.map((e) => e.total.toDouble()).toList();
        final labelData = response.chartData.map((e) => e.projectName).toList();

        setState(() {
          chartData = data;
          labels = labelData;
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      print("Error loading chart: $e");
      setState(() {
        loading = false;
      });
    }
  }
  String getMonthShortName(String monthYear) {
    try {
      final month = int.parse(monthYear.split('-').last);
      const names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return names[month - 1];
    } catch (_) {
      return 'N/A';
    }
  }

 Future<void> fetchDataForYear(int year) async {
    setState(() {
      loading = true;
      errorMessage= null;
      onboardedData = [];
      debarredData = [];
      chartLabels = [];
    });

    try {
      final response = await apiService.getclientonchart(year.toString()); // Adjust API call as necessary
            List<ChartItemclient> allItems = [...response!.onboarded, ...response.debarred];
      allItems.sort((a, b) => a.month.compareTo(b.month));
      List<String> uniqueMonths = allItems.map((item) => item.month).toSet().toList()..sort();
      List<double> tempOnboardedData = [];
      List<double> tempDebarredData = [];
      List<String> tempLabels = [];
      for (String month in uniqueMonths) {
        int onboardedCount = response!.onboarded.firstWhere((item) => item.month == month, orElse: () => ChartItemclient(month: month, count: 0)).count;
        int debarredCount = response.debarred.firstWhere((item) => item.month == month, orElse: () => ChartItemclient(month: month, count: 0)).count;

        tempOnboardedData.add(onboardedCount.toDouble());
        tempDebarredData.add(debarredCount.toDouble());
        tempLabels.add(getMonthShortName(month));
      }

      setState(() {
        onboardedData = tempOnboardedData;
        debarredData = tempDebarredData;
        chartLabels = tempLabels;
      });

    } catch (e) {
      print("Error fetching trend data: $e");
      setState(() {
        errorMessage = "Failed to load data. Please check connection.";
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void _selectYear(int year) {
  if (year != selectedYear && year <= currentCalendarYear) {
    setState(() {
      selectedYear = year;
    });
     fetchDataForYear(year); 
  }
}
Widget _buildYearButton(int year) {
  final bool isSelected = year == selectedYear;
  final bool isSelectable = year <= currentCalendarYear; 

  return GestureDetector(
    onTap: isSelectable ? () => _selectYear(year) : null,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected 
            ? Colors.blue // Blue when selected
            : isSelectable ? Colors.grey.shade200 : Colors.grey.shade400, // Dimmer if not clickable
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        year.toString(),
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    ),
  );
}

// Assuming your API service has a baseUrl, or you define it here
static String _apiBaseUrl = "https://cxo.droidal.com/"; // <--- IMPORTANT: Replace with your actual base URL

Future<void> fetchupcomingrenewals() async {
  try {
    final response = await apiService.getupcomingrenewals();

    if (response != null) {
      final now = DateTime.now();
      final List<Map<String, dynamic>> tempRenewals = [];

      for (var item in response) {
        final DateTime? renewalDate = item.renewalDate != null
            ? DateTime.tryParse(item.renewalDate!)
            : null;

        if (renewalDate != null) {
          final int daysUntil = renewalDate.difference(now).inDays;

          if (daysUntil > 0 && daysUntil < 90) { // Added a lower bound to avoid showing ancient "overdue" items if API sends them
            String? fullImageUrl;
            if (item.clientAvatar != null && !item.clientAvatar!.startsWith('http') && !item.clientAvatar!.startsWith('https')) {
              // Prepend base URL if it's a relative path like /media/...
              fullImageUrl = '$_apiBaseUrl${item.clientAvatar}';
            } else {
              fullImageUrl = item.clientAvatar; // It's already a full URL or null
            }

            tempRenewals.add({
              'title': item.clientName ?? 'Unknown Client',
              'planName': item.planName ?? 'N/A',
              'daysUntilRenewal': daysUntil,
              'imageUrl': fullImageUrl, // Use the constructed full URL
              'renewalDateTime': renewalDate,
            });
          }
        }
      }
      setState(() {
        // Sort by daysUntilRenewal so the most urgent appear first
        tempRenewals.sort((a, b) => a['daysUntilRenewal'].compareTo(b['daysUntilRenewal']));
        _dataCardsrenew = tempRenewals;
      });
    } else {
      if (kDebugMode) print("No upcoming renewals found.");
      setState(() {
        _dataCardsrenew = [];
      });
    }
  } catch (e) {
    if (kDebugMode) print("Error fetching upcoming renewals: $e");
    setState(() {
      _dataCardsrenew = [];
    });
  }
}
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: CustomAppBar(
        title: ('Home Screen'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: CustomDrawer(
        username: 'Droidal',
        child: ListView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: <Widget>[
            // ... (Your existing CustomDrawerItems)
            CustomDrawerItem(
              icon: Icons.dashboard,
              title: 'Dashboard',
              isSelected: _selectedItem == 'Dashboard',
              onTap: () {
                setState(() {
                  _selectedItem = 'Dashboard';
                });
                Navigator.pop(context);
              },
            ),
            CustomDrawerItem(
              icon: Icons.storage,
              title: 'Projects',
              isSelected: _selectedItem == 'Projects',
              onTap: () {
                setState(() {
                  _selectedItem = 'Projects';
                });
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProjectScreen(),
                  ),
                );
              },
            ),
            CustomDrawerItem(
              icon: Icons.person,
              title: 'Users',
              isSelected: _selectedItem == 'Users',
              onTap: () {
                setState(() {
                  _selectedItem = 'Users';
                });
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserScreen()),
                );
              },
            ),
            CustomDrawerItem(
              icon: Icons.approval_rounded,
              title: 'Roles',
              isSelected: _selectedItem == 'Roles',
              onTap: () {
                setState(() {
                  _selectedItem = 'Roles';
                });
                Navigator.pop(context);
              },
            ),
            CustomDrawerItem(
              icon: Icons.local_activity,
              title: 'Activity',
              isSelected: _selectedItem == 'Activity',
              onTap: () {
                setState(() {
                  _selectedItem = 'Activity';
                });
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ActivityScreen(),
                  ),
                );
              },
            ),
            CustomDrawerItem(
              icon: Icons.people,
              title: 'Customers',
              isSelected: _selectedItem == 'Customers',
              onTap: () {
                setState(() {
                  _selectedItem = 'Customers';
                });
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ClientScreen()),
                );
              },
            ),
            CustomDrawerItem(
              icon: Icons.print_rounded,
              title: 'Machines',
              isSelected: _selectedItem == 'Machines',
              onTap: () {
                setState(() {
                  _selectedItem = 'Machines';
                });
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MachineScreen(),
                  ),
                );
              },
            ),
            CustomDrawerItem(
              icon: Icons.shield_outlined,
              title: 'Licenses',
              isSelected: _selectedItem == 'Licenses',
              onTap: () {
                setState(() {
                  _selectedItem = 'Licenses';
                });
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LicenseScreen(),
                  ),
                );
              },
            ),
            CustomDrawerItem(
              icon: Icons.subscriptions_outlined,
              title: 'Subscriptions',
              isSelected: _selectedItem == 'Subscriptions',
              onTap: () {
                setState(() {
                  _selectedItem = 'Subscriptions';
                });
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubscriptionScreen(),
                  ),
                );
              },
            ),
            CustomDrawerItem(
              icon: Icons.token_sharp,
              title: 'A5',
              isSelected: _selectedItem == 'A5',
              onTap: () {
                setState(() {
                  _selectedItem = 'A5';
                });
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AcknowledgementScreen(),
                  ),
                );
              },
            ),
            CustomDrawerItem(
              icon: Icons.star_border_outlined,
              title: 'Performance',
              isSelected: _selectedItem == 'Performance',
              onTap: () {
                setState(() {
                  _selectedItem = 'Performance';
                });
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PerformanceScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.01),
              Text(
                "Key Metrics",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.045,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: screenHeight * 0.015),

              // --- HORIZONTAL CARDS (UPDATED) ---
              SizedBox(
                height:
                    screenHeight *
                    0.28, // Increased height to accommodate the nested grid
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _keyMetricsData.length,
                  itemBuilder: (context, index) {
                    final metric = _keyMetricsData[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.015,
                      ),
                      child: _MetricCard(
                        title: metric['title']! as String,
                        icon: metric['icon']! as IconData,
                        color: metric['color']! as Color,
                        items: metric['items']! as int,
                        innerData:
                            metric['innerData']
                                as List<
                                  Map<String, dynamic>
                                >, // PASS INNER DATA
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              // 🎨 Chart 1
              TransactionTrendsCard(),

              // 🎨 Chart 2
Card(
  elevation: 5,
  // ... (Card styling)
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: SizedBox(
        // Give a fixed height to the chart section (e.g., 300)
        height: 300, 
        child: ReusableLineChart(
            data: chartData, // Your List<double> from Subscriptions data
            labels: labels, // Your List<String> of x-axis labels
            title: "Subscriptions vs Resources", // Chart title
            startColor: Colors.blue.shade300,
            endColor: Colors.blue.shade700,
            labelWidth: 80.0, // Allocate 80 units of width per data point for scrolling
        ),
    ),
  ),
),
              // 🎨 Chart 3
              FancyBarChart(
                title: "Stage wise Distribution",
                data: [12, 18, 14, 10, 20, 17, 19],
                labels: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
                gradientColors: [
                  [Colors.orangeAccent, Colors.deepOrange],
                  [Colors.yellowAccent, Colors.amber],
                  [Colors.lightGreenAccent, Colors.green],
                  [Colors.cyanAccent, Colors.blueAccent],
                  [Colors.purpleAccent, Colors.indigo],
                  [Colors.pinkAccent, Colors.redAccent],
                  [Colors.tealAccent, Colors.teal],
                ],
              ),

              SizedBox(height: screenHeight * 0.02),

              // 📊 Data List Card Section 1
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.timer, size: 50.0, color: Colors.orange),
                          const SizedBox(width: 10.0),

                          // Expanded ensures the text section takes up the rest of the space
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Row for title and count
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Overdue Alerts",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: screenWidth * 0.04,
                                        color: Colors.blueGrey.shade800,
                                      ),
                                    ),
                                    Text(
                                      "53",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: screenWidth * 0.045,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: 
                                    
                                    Text(
                                      "Track your project deadlines",
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.03,
                                        color: Colors.black,
                                      ),
                                    ),),

                                    Expanded(child: Text(
                                      "Renewals",
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.03,
                                        color: Colors.black,
                                      ),
                                    ),),
                                    
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Scrollable List inside Card
                     SizedBox(
  height: screenHeight * 0.4, // height of list view (adjust as needed)
  child: _dataCardsrenew.isEmpty // Check if the list is empty
      ? const Center(child: Text("No upcoming renewals"))
      : ListView.builder(
          itemCount: _dataCardsrenew.length,
          itemBuilder: (context, index) {
            final item = _dataCardsrenew[index];
            return DataCard(
              title: item['title']?.toString() ?? 'Unknown Client',
              planName: item['planName']?.toString() ?? 'N/A',
              // Pass the actual DateTime object
              renewalDateTime: item['renewalDateTime'] as DateTime?,
              daysUntilRenewal: item['daysUntilRenewal'] ?? 0,
              imageUrl: item['imageUrl'] as String?,
            );
          },
        ),
),

                    ],
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.02),
              // 📊 Data List Card Section 2
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.timer, size: 50.0, color: Colors.orange),
                          const SizedBox(width: 10.0),

                          // Expanded ensures the text section takes up the rest of the space
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Row for title and count
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Upcoming Alerts",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: screenWidth * 0.04,
                                        color: Colors.blueGrey.shade800,
                                      ),
                                    ),
                                    Text(
                                      "23",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: screenWidth * 0.045,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Track your project deadlines",
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.03,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      "Renewals",
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.03,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Scrollable List inside Card
                   SizedBox(
  height: screenHeight * 0.4, // height of list view (adjust as needed)
  child: _dataCardsrenew.isEmpty // Check if the list is empty
      ? const Center(child: Text("No upcoming renewals"))
      : ListView.builder(
          itemCount: _dataCardsrenew.length,
          itemBuilder: (context, index) {
            final item = _dataCardsrenew[index];
            return DataCard(
              title: item['title']?.toString() ?? 'Unknown Client',
              planName: item['planName']?.toString() ?? 'N/A',
              // Pass the actual DateTime object
              renewalDateTime: item['renewalDateTime'] as DateTime?,
              daysUntilRenewal: item['daysUntilRenewal'] ?? 0,
              imageUrl: item['imageUrl'] as String?,
            );
          },
        ),
),

                    ],
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

                      // ✨ Line Chart ✨
// Replace your existing Card block with this:
Card(
  elevation: 4,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      children: [
       // --- Card Header (Title and Year Picker) ---
// --- Card Header (Title and Year Picker) ---
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    // FIX 1: Use Flexible to allow the title to shrink (Fixes Overflow)
    const Flexible(
      child: Text(
        "Client Onboard Trends",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,
      ),
    ),
    const SizedBox(width: 8), // Gap after the title
    
    // --- Custom Year Toggle (Conditional 2 or 3 button logic) ---
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Always show the Previous Year button (e.g., 2021 when viewing 2022)
        if (selectedYear > 2000)
          _buildYearButton(selectedYear - 1),
        
        if (selectedYear > 2000)
          const SizedBox(width: 8),

        // 2. Always show the Currently Selected Year button
        _buildYearButton(selectedYear),

        // 3. Conditional "Jump Home" button (2025)
        // If the selected year is not the current calendar year (2025), show the 2025 button
        if (selectedYear < currentCalendarYear)
          const SizedBox(width: 8),
          
        if (selectedYear < currentCalendarYear)
          _buildYearButton(currentCalendarYear), // This is the jump forward button
      ],
    ),
  ],
),
  
  
        const SizedBox(height: 16),

        SizedBox(
          height: 250, // Keep the chart area a fixed size
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)))
                  : chartLabels.isEmpty
                      ? const Center(child: Text("No data available for this year."))
                      : MultiLineChart(
                            data1: onboardedData,
                            data2: debarredData,
                            labels: chartLabels,
                            color1: Colors.green, // Onboarded
                            color2: Colors.red, // Debarred
                          ),
        ),
      ],
    ),
  ),
),

               SizedBox(height: screenHeight * 0.01),

                      // 📊 Data List Card Section 3
               Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.timer, size: 50.0, color: Colors.orange),
                          const SizedBox(width: 10.0),

                          // Expanded ensures the text section takes up the rest of the space
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Row for title and count
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Upcoming Renewals",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: screenWidth * 0.04,
                                        color: Colors.blueGrey.shade800,
                                      ),
                                    ),
                                    Text(
                                      "1",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: screenWidth * 0.045,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Text(
                                      "Track subscription renewals and revenue",
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.03,
                                        color: Colors.black,
                                      ),
                                    ),),
                                    
                                    Text(
                                      "Renewals",
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.03,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Scrollable List inside Card
                     SizedBox(
  height: screenHeight * 0.4, // height of list view (adjust as needed)
  child: _dataCardsrenew.isEmpty // Check if the list is empty
      ? const Center(child: Text("No upcoming renewals"))
      : ListView.builder(
          itemCount: _dataCardsrenew.length,
          itemBuilder: (context, index) {
            final item = _dataCardsrenew[index];
            return DataCard(
              title: item['title']?.toString() ?? 'Unknown Client',
              planName: item['planName']?.toString() ?? 'N/A',
              // Pass the actual DateTime object
              renewalDateTime: item['renewalDateTime'] as DateTime?,
              daysUntilRenewal: item['daysUntilRenewal'] ?? 0,
              imageUrl: item['imageUrl'] as String?,
            );
          },
        ),
),

                    ],
                  ),
                ),
              ),  
               SizedBox(height: screenHeight * 0.02),

            ],
          ),
        ),
      ),
    );
  }
}

// --- UPDATED CUSTOM WIDGET FOR METRIC CARD ---
class _MetricCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final int items;
  // This list now holds the API/nested data for the inner grid
  final List<Map<String, dynamic>> innerData;

  const _MetricCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
    // Default to an empty list
    this.innerData = const [],
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth * 0.7;

    final data = innerData;

    // Define Grid Spacings
    final double crossAxisSpacing = screenWidth * 0.015;
    final double mainAxisSpacing = screenWidth * 0.015;
    const double childAspectRatio = 1.5;

    // Calculate item dimensions for a single card in the grid
    final double itemWidth = (cardWidth - (12 * 2) - crossAxisSpacing) / 2; // CardWidth - padding - spacing / 2
    final double itemHeight = itemWidth / childAspectRatio;

    // Determine how many rows to show based on screen width
    // You can adjust the `400` breakpoint as needed for your definition of "small mobile"
    final int maxRowsToShow = screenWidth < 400 ? 1 : 2; 

    // Calculate the height needed to display `maxRowsToShow` rows
    final double desiredGridHeight = (itemHeight * maxRowsToShow) + 
                                     (mainAxisSpacing * (maxRowsToShow - 1));

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP ROW (Title and Main Icon)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, color: color, size: screenWidth * 0.06),
              ],
            ),
            SizedBox(height: screenWidth * 0.03),
            
            SizedBox(
              height: desiredGridHeight, // Set the height based on `maxRowsToShow`
              child: GridView.builder(
                // Use ClampingScrollPhysics to allow scrolling if actual items exceed `maxRowsToShow`
                physics: const ClampingScrollPhysics(),
                shrinkWrap: true, // ShrinkWrap is safe here because of the parent SizedBox
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: crossAxisSpacing,
                  mainAxisSpacing: mainAxisSpacing,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // --- DYNAMIC COUNT ---
                              Text(
                                data[index]['count'].toString(),
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                data[index]['label']!
                                    as String, // Use label from API data
                                style: TextStyle(
                                  fontSize: screenWidth * 0.03,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          // --- DYNAMIC INNER ICON ---
                          Icon(
                            data[index]['icon']!
                                as IconData, // Use icon from API data
                            color: color,
                            size: screenWidth * 0.06,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class DataCard extends StatelessWidget {
  final String title;
  final String planName;
  final int daysUntilRenewal;
  final String? imageUrl;
  final DateTime? renewalDateTime;

  const DataCard({
    Key? key,
    required this.title,
    required this.planName,
    required this.daysUntilRenewal,
    this.imageUrl,
    this.renewalDateTime,
  }) : super(key: key);

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Map<String, dynamic> _getStatus() {
    if (daysUntilRenewal <= 0) {
      return {'text': 'Overdue', 'color': Colors.red};
    } else if (daysUntilRenewal <= 30) {
      return {'text': 'Expiring Soon', 'color': Colors.orange};
    } else {
      return {'text': 'Upcoming', 'color': Colors.blue};
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _getStatus();
    final renewalDateString = _formatDate(renewalDateTime);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Client Avatar/Image
            if (imageUrl != null && Uri.tryParse(imageUrl!)?.hasAbsolutePath == true)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(imageUrl!), // Assuming this is a network URL now
                  ),
                ),
              )
            else
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade300,
                ),
                child: Icon(Icons.business, color: Colors.grey.shade600),
              ),
            const SizedBox(width: 12),

            // Client Name and Plan Name with Status
            Expanded( // <--- This Expanded is crucial here
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis, // <--- Add this for the title
                  ),
                  const SizedBox(height: 4),
                  // Use a Flexible or Expanded for the Row's children if they are too wide
                  Row(
                    children: [
                      // Plan Name
                      Flexible( // <--- Use Flexible here
                        child: Text(
                          planName,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                          overflow: TextOverflow.ellipsis, // <--- Add this
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status button
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: status['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          status['text'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: status['color'],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Renewal Date and Days Left
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  renewalDateString,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$daysUntilRenewal days left',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
//transaction

class TransactionTrendsCard extends StatefulWidget {
  const TransactionTrendsCard({super.key});

  @override
  State<TransactionTrendsCard> createState() => _TransactionTrendsCardState();
}

class _TransactionTrendsCardState extends State<TransactionTrendsCard> {
  DateTime selectedDate = DateTime.now();
  List<int> chartData = [];
  List<String> chartLabels = [];
  bool isLoading = false;

  late ApiService apiService;

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
    fetchTransactionData(selectedDate);
  }

  Future<void> fetchTransactionData(DateTime date) async {
    setState(() {
      isLoading = true;
    });

    final startDate = DateTime(date.year, date.month, 1);
    final endDate = DateTime(date.year, date.month + 1, 0);

    final startDateStr =
        "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
    final endDateStr =
        "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

    try {
      final response = await apiService.gettranschart(startDateStr, endDateStr);

      if (response != null && response.chartData != null) {
        List<int> data = [];
        List<String> labels = [];

        for (ChartData item in response.chartData!) {
          data.add(item.transaction ?? 0);
          labels.add(item.name ?? 'N/A');
        }

        setState(() {
          chartData = data;
          chartLabels = labels;
        });
      } else {
        setState(() {
          chartData = [];
          chartLabels = [];
        });
      }
    } catch (e) {
      print("Error fetching transaction chart: $e");
      setState(() {
        chartData = [];
        chartLabels = [];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxYValue = chartData.isEmpty
        ? 100.0
        : (chartData.reduce((a, b) => a > b ? a : b) * 1.2).toDouble();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Transaction Trends (${selectedDate.month}-${selectedDate.year})",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (_) async {
                    final picked = await showMonthYearPicker( // Assuming showMonthYearPicker is available
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      locale: Localizations.localeOf(context),
                    );
                    if (picked != null && picked != selectedDate) {
                      setState(() => selectedDate = picked);
                      fetchTransactionData(picked);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 1,
                      child: Text("Select Month & Year"),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            isLoading
                ? const Center(child: CircularProgressIndicator())
                : chartData.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            "No data available for selected month.",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 300,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: max(screenWidth - 24, chartData.length * 100.0), // Adjusted width for more space per label
                            child: LineChart(
                              LineChartData(
                                minY: 0,
                                maxY: maxYValue,
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 70, // Increased vertical space for multiline labels
                                      interval: 1,
                                      getTitlesWidget: (value, meta) {
                                        int index = value.toInt();
                                        if (index >= 0 && index < chartLabels.length) {
                                          return SideTitleWidget(
                                            axisSide: meta.axisSide,
                                            space: 4, // Spacing between the chart and the label
                                            child: SizedBox(
                                              width: 80, // Explicit width for text wrapping
                                              child: Text(
                                                chartLabels[index],
                                                style: const TextStyle(
                                                  fontSize: 10, // Slightly smaller font for multiline
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 3, // Allow up to 3 lines
                                                overflow: TextOverflow.ellipsis, // Add ellipsis if it still overflows
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox();
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      interval: maxYValue / 4,
                                      getTitlesWidget: (value, meta) {
                                        return Text('${(value / 1000).toInt()}K', // Convert to 'K' format
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                          ),
                                          textAlign: TextAlign.left,
                                        );
                                      },
                                    ),
                                  ),
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                gridData: FlGridData(show: true, drawVerticalLine: false),
                                borderData: FlBorderData(show: true),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: List.generate(
                                      chartData.length,
                                      (index) => FlSpot(index.toDouble(), chartData[index].toDouble()),
                                    ),
                                    isCurved: true,
                                    barWidth: 3,
                                    gradient: LinearGradient(
                                      colors: [Colors.blueAccent, Colors.lightBlueAccent],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                    dotData: FlDotData(show: true),
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
    );
  }


}