import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:lio/providers/theme_provider.dart';
import './AddAppliancePage.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:flutter/foundation.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    } else {
      return Platform.isAndroid
          ? 'http://10.0.2.2:3000/api' // Android emulator special address
          : 'http://localhost:3000/api'; // iOS simulator
    }
  }

  List appliances = [];
  List filteredAppliances = [];
  Map<DateTime, List<dynamic>> calendarEvents = {};
  TextEditingController searchController = TextEditingController();
  String selectedCategory = 'All';
  bool isDarkMode = false;
  bool isCalendarView = false;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  // Map of appliance types to their respective icons
  final Map<String, IconData> applianceIcons = {
    'refrigerator': Icons.kitchen,
    'washer': Icons.local_laundry_service,
    'dryer': Icons.dry,
    'dishwasher': Icons.wash,
    'microwave': Icons.microwave,
    'oven': Icons.room_service,
    'tv': Icons.tv,
    'ac': Icons.ac_unit,
    'heater': Icons.whatshot,
    'vacuum': Icons.cleaning_services,
    'computer': Icons.computer,
    'printer': Icons.print,
    'fan': Icons.air,
    'water_heater': Icons.hot_tub,
    'coffee_maker': Icons.coffee,
    'unknown': Icons.help_outline,
    'null': Icons.help_outline,  
  };

  @override
  void initState() {
    super.initState();
    fetchAppliances();
  }

  void printAllApplianceTypes() {
    final types = appliances
        .map((a) => a['type']?.toString().toLowerCase() ?? 'null')
        .toSet();
    debugPrint('All appliance types in data: $types');
  }

  Future<void> fetchAppliances() async {
    try {
      final token =
          await Provider.of<AuthProvider>(context, listen: false).getToken();

      final response = await http.get(
        Uri.parse('$_baseUrl/appliances'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          appliances = json.decode(response.body);
          filterAppliances(searchController.text);
          updateCalendarEvents();
        });
      } else if (response.statusCode == 401) {
        // Handle unauthorized (token expired)
        await Provider.of<AuthProvider>(context, listen: false).logout();
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        throw Exception('Failed to load appliances');
      }
    } catch (e) {
      print('Error fetching appliances: $e');
    }
  }

  void updateCalendarEvents() {
    Map<DateTime, List<dynamic>> events = {};

    for (var appliance in appliances) {
      // Add purchase date event
      if (appliance['purchaseDate'] != null) {
        try {
          DateTime purchaseDate = DateTime.parse(appliance['purchaseDate']);
          DateTime normalizedPurchaseDate =
              DateTime(purchaseDate.year, purchaseDate.month, purchaseDate.day);

          if (events[normalizedPurchaseDate] == null) {
            events[normalizedPurchaseDate] = [];
          }
          events[normalizedPurchaseDate]!.add({
            'name': appliance['name'],
            'type': 'purchase',
            'appliance': appliance,
          });
        } catch (e) {
          print('Error parsing purchase date: $e');
        }
      }

      // Add expiry date event
      if (appliance['warrantyExpiryDate'] != null) {
        try {
          DateTime expiryDate = DateTime.parse(appliance['warrantyExpiryDate']);
          DateTime normalizedExpiryDate =
              DateTime(expiryDate.year, expiryDate.month, expiryDate.day);

          if (events[normalizedExpiryDate] == null) {
            events[normalizedExpiryDate] = [];
          }
          events[normalizedExpiryDate]!.add({
            'name': appliance['name'],
            'type': 'expiry',
            'appliance': appliance,
          });
        } catch (e) {
          print('Error parsing expiry date: $e');
        }
      }

      // Add maintenance events
      if (appliance['purchaseDate'] != null &&
          appliance['maintenanceDuration'] != null &&
          appliance['maintenanceDuration'] > 0) {
        try {
          DateTime purchaseDate = DateTime.parse(appliance['purchaseDate']);
          int maintenancePeriod = appliance['maintenanceDuration'];

          // Add multiple maintenance events until expiry date or for next 5 years
          DateTime nextMaintenance =
              purchaseDate.add(Duration(days: maintenancePeriod * 30));
          DateTime maxDate = DateTime.now().add(const Duration(days: 365 * 5));

          if (appliance['warrantyExpiryDate'] != null) {
            DateTime expiryDate =
                DateTime.parse(appliance['warrantyExpiryDate']);
            if (expiryDate.isBefore(maxDate)) {
              maxDate = expiryDate;
            }
          }

          while (nextMaintenance.isBefore(maxDate)) {
            DateTime normalizedMaintenance = DateTime(nextMaintenance.year,
                nextMaintenance.month, nextMaintenance.day);

            if (events[normalizedMaintenance] == null) {
              events[normalizedMaintenance] = [];
            }
            events[normalizedMaintenance]!.add({
              'name': appliance['name'],
              'type': 'maintenance',
              'appliance': appliance,
            });

            nextMaintenance =
                nextMaintenance.add(Duration(days: maintenancePeriod * 30));
          }
        } catch (e) {
          print('Error calculating maintenance dates: $e');
        }
      }
    }

    setState(() {
      calendarEvents = events;
    });
  }

  List<dynamic> getEventsForDay(DateTime day) {
    DateTime normalizedDay = DateTime(day.year, day.month, day.day);
    return calendarEvents[normalizedDay] ?? [];
  }

  void filterAppliances(String query) {
    setState(() {
      // First filter by search query
      var searchFiltered = query.isEmpty
          ? appliances
          : appliances.where((appliance) {
              String name = appliance['name'].toString().toLowerCase();
              return name.contains(query.toLowerCase());
            }).toList();

      // Then apply category filter
      switch (selectedCategory) {
        case 'Expired':
          filteredAppliances = searchFiltered.where((appliance) {
            if (appliance['warrantyExpiryDate'] == null) return false;
            try {
              DateTime expiryDate =
                  DateTime.parse(appliance['warrantyExpiryDate']);
              return DateTime.now().isAfter(expiryDate);
            } catch (e) {
              return false;
            }
          }).toList();
          break;
        case 'Needs Maintenance':
          filteredAppliances = searchFiltered.where((appliance) {
            return needsMaintenance(
              appliance['warrantyExpiryDate'],
              appliance['maintenanceDuration'] ?? 0,
              appliance['purchaseDate'],
            );
          }).toList();
          break;
        default: // 'All'
          filteredAppliances = searchFiltered;
      }
    });
  }

  Future<void> deleteAppliance(String id) async {
    try {
      final token =
          await Provider.of<AuthProvider>(context, listen: false).getToken();

      final response = await http.delete(
        Uri.parse('$_baseUrl/appliances/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          appliances.removeWhere((appliance) => appliance['_id'] == id);
          filterAppliances(searchController.text);
          updateCalendarEvents();
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Appliance deleted successfully')));
      } else if (response.statusCode == 401) {
        await Provider.of<AuthProvider>(context, listen: false).logout();
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete appliance')));
      }
    } catch (e) {
      print('Error deleting appliance: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error occurred while deleting')));
    }
  }

  void confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Appliance'),
          content:
              const Text('Are you sure you want to delete this appliance?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteAppliance(id);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  bool needsMaintenance(
      String? expiryDate, int maintenanceDuration, String? purchaseDate) {
    if (expiryDate == null ||
        expiryDate.isEmpty ||
        purchaseDate == null ||
        purchaseDate.isEmpty) return false;

    try {
      DateTime expiry = DateTime.parse(expiryDate);
      DateTime purchase = DateTime.parse(purchaseDate);
      DateTime nextMaintenanceDate =
          purchase.add(Duration(days: maintenanceDuration * 30));

      return DateTime.now().isAfter(nextMaintenanceDate) &&
          DateTime.now().isBefore(expiry);
    } catch (e) {
      print('Error parsing date: $e');
      return false;
    }
  }

  double calculateProgress(String purchaseDate, String expiryDate) {
    try {
      DateTime purchase = DateTime.parse(purchaseDate);
      DateTime expiry = DateTime.parse(expiryDate);
      DateTime now = DateTime.now();

      // Calculate total duration and elapsed duration
      int totalDuration = expiry.difference(purchase).inDays;
      int elapsedDuration = now.difference(purchase).inDays;

      // Calculate progress (0 to 1)
      double progress = elapsedDuration / totalDuration;

      // Clamp the value between 0 and 1
      return progress.clamp(0.0, 1.0);
    } catch (e) {
      print('Error calculating progress: $e');
      return 0.0;
    }
  }

  String formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'N/A';

    try {
      DateTime date = DateTime.parse(isoDate);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      print('Error formatting date: $isoDate - $e');
      return 'Invalid Date';
    }
  }

  String getRemainingWarrantyTime(String purchaseDate, String expiryDate) {
    try {
      DateTime expiry = DateTime.parse(expiryDate);
      DateTime now = DateTime.now();

      if (now.isAfter(expiry)) {
        return "Expired";
      }

      final difference = expiry.difference(now);
      final days = difference.inDays;

      if (days > 365) {
        final years = (days / 365).floor();
        final remainingDays = days % 365;
        final months = (remainingDays / 30).floor();
        return "$years yr${years > 1 ? 's' : ''}, $months mo${months > 1 ? 's' : ''}";
      } else if (days > 30) {
        final months = (days / 30).floor();
        final remainingDays = days % 30;
        return "$months mo${months > 1 ? 's' : ''}, $remainingDays day${remainingDays > 1 ? 's' : ''}";
      } else {
        return "$days day${days > 1 ? 's' : ''}";
      }
    } catch (e) {
      print('Error calculating remaining warranty time: $e');
      return "Unknown";
    }
  }

  Color getWarrantyStatusColor(String? expiryDate) {
    if (expiryDate == null || expiryDate.isEmpty) return Colors.grey;

    try {
      DateTime expiry = DateTime.parse(expiryDate);
      DateTime now = DateTime.now();

      if (now.isAfter(expiry)) {
        return Colors.red;
      }

      final difference = expiry.difference(now).inDays;

      if (difference < 30) {
        return Colors.orange;
      } else if (difference < 90) {
        return Colors.amber;
      } else {
        return Colors.green;
      }
    } catch (e) {
      return Colors.grey;
    }
  }

  IconData getApplianceIcon(String? type) {
    if (type == null || type.isEmpty) {
      debugPrint('Appliance type is null, using default icon');
      return Icons.help_outline;
    }

    final normalizedType = type.toLowerCase().trim();

    if (!applianceIcons.containsKey(normalizedType)) {
      debugPrint('No icon found for type: $normalizedType');
      return Icons.home_repair_service;
    }

    debugPrint('Found icon for type: $normalizedType');
    final lowerType = type.toLowerCase().trim();
    return applianceIcons[lowerType] ?? Icons.help_outline;
  }

  void toggleDarkMode() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.toggleTheme(!isDarkMode);
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  void toggleViewMode() {
    setState(() {
      isCalendarView = !isCalendarView;
    });
  }

  Widget buildCalendarView() {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          eventLoader: getEventsForDay,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: Colors.deepPurple,
              shape: BoxShape.circle,
            ),
            markerDecoration: const BoxDecoration(
              color: Colors.deepOrangeAccent,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Expanded(
          child: buildEventList(),
        ),
      ],
    );
  }

  Widget buildEventList() {
    final events = getEventsForDay(_selectedDay);

    if (events.isEmpty) {
      return Center(
        child: Text(
          'No events for ${DateFormat('yyyy-MM-dd').format(_selectedDay)}',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final appliance = event['appliance'];
        final eventType = event['type'];

        IconData icon;
        Color color;
        String title = appliance['name'];
        String description;

        switch (eventType) {
          case 'purchase':
            icon = Icons.shopping_cart;
            color = Colors.blue;
            description =
                'Purchased on ${formatDate(appliance['purchaseDate'])}';
            break;
          case 'maintenance':
            icon = Icons.build;
            color = Colors.orange;
            description = 'Scheduled maintenance';
            break;
          case 'expiry':
            icon = Icons.warning;
            color = Colors.red;
            description =
                'Warranty expires on ${formatDate(appliance['warrantyExpiryDate'])}';
            break;
          default:
            icon = Icons.info;
            color = Colors.grey;
            description = 'Event';
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: color.withOpacity(0.1),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            title: Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(description),
            trailing: Icon(getApplianceIcon(appliance['type'])),
          ),
        );
      },
    );
  }

  Widget buildListView() {
    return filteredAppliances.isEmpty
        ? const Center(child: Text('No appliances found'))
        : ListView.builder(
            itemCount: filteredAppliances.length,
            itemBuilder: (context, index) {
              var appliance = filteredAppliances[index];

              String id = appliance['_id'];
              String name = appliance['name'] ?? 'Unknown Appliance';
              String type = appliance['type'] ?? 'unknown';
              String purchaseDate = formatDate(appliance['purchaseDate']);
              String expiryDate = formatDate(appliance['warrantyExpiryDate']);
              int maintenanceDuration = appliance['maintenanceDuration'] ?? 0;

              bool maintenanceNeeded = needsMaintenance(
                  appliance['warrantyExpiryDate'],
                  maintenanceDuration,
                  appliance['purchaseDate']);

              bool isExpired = false;
              try {
                isExpired = DateTime.now().isAfter(DateTime.parse(
                    appliance['warrantyExpiryDate'] ??
                        DateTime.now().toIso8601String()));
              } catch (e) {
                // Handle date parsing errors
              }

              double progress = calculateProgress(
                  appliance['purchaseDate'] ??
                      DateTime.now()
                          .subtract(const Duration(days: 1))
                          .toIso8601String(),
                  appliance['warrantyExpiryDate'] ??
                      DateTime.now()
                          .add(const Duration(days: 1))
                          .toIso8601String());

              String warrantyRemaining = getRemainingWarrantyTime(
                  appliance['purchaseDate'] ?? '',
                  appliance['warrantyExpiryDate'] ?? '');

              Color warrantyColor =
                  getWarrantyStatusColor(appliance['warrantyExpiryDate']);

              return Dismissible(
                key: Key(id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerLeft,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                ),
                confirmDismiss: (direction) async {
                  bool confirm = false;
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Delete Appliance'),
                        content: const Text(
                            'Are you sure you want to delete this appliance?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              confirm = false;
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              confirm = true;
                            },
                            child: const Text('Delete',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm) {
                    deleteAppliance(id);
                  }
                  return confirm;
                },
                child: Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor:
                                  Colors.deepPurple.withOpacity(0.1),
                              child: Icon(
                                getApplianceIcon(type),
                                size: 30,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: warrantyColor.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border:
                                              Border.all(color: warrantyColor),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isExpired
                                                  ? Icons.warning
                                                  : Icons.shield,
                                              size: 14,
                                              color: warrantyColor,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              isExpired
                                                  ? 'Expired'
                                                  : warrantyRemaining,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: warrantyColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (maintenanceNeeded)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.orange.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: Colors.orange),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.build,
                                                size: 14,
                                                color: Colors.orange,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'Maintenance',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.orange,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => confirmDelete(id),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Circular progress indicator
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: 8,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        progress >= 0.8
                                            ? Colors.red
                                            : progress >= 0.6
                                                ? Colors.orange
                                                : Colors.blue),
                                  ),
                                  Text(
                                    "${(progress * 100).toInt()}%",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Purchased: $purchaseDate',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.event_available,
                                        size: 16,
                                        color: isExpired
                                            ? Colors.red
                                            : Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Expires: $expiryDate',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isExpired ? Colors.red : null,
                                          fontWeight: isExpired
                                              ? FontWeight.bold
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.update,
                                          size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Maintenance: Every $maintenanceDuration months',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeScheduler - Appliances'),
        actions: [
          IconButton(
            icon: Icon(isCalendarView ? Icons.view_list : Icons.calendar_month),
            onPressed: toggleViewMode,
            tooltip: isCalendarView
                ? 'Switch to List View'
                : 'Switch to Calendar View',
          ),
          IconButton(
            icon: Icon(themeProvider.themeMode == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: toggleDarkMode,
            tooltip: themeProvider.themeMode == ThemeMode.dark
                ? 'Switch to Light Mode'
                : 'Switch to Dark Mode',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (!isCalendarView)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: TextField(
                      controller: searchController,
                      onChanged: filterAppliances,
                      decoration: InputDecoration(
                        labelText: 'Search Appliance',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedCategory,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCategory = newValue!;
                              filterAppliances(searchController.text);
                            });
                          },
                          items: <String>['All', 'Expired', 'Needs Maintenance']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: isCalendarView ? buildCalendarView() : buildListView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddAppliancePage()),
          ).then((_) {
            fetchAppliances();
          });
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
