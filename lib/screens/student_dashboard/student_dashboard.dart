import 'package:flutter/material.dart';
import 'package:printify/screens/student_dashboard/past_orders_tab.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/order_provider.dart';
import 'active_orders_tab.dart';
import 'new_order_screen.dart';

// Main Dashboard Screen
class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load dummy data when dashboard is initialized
    Future.microtask(() {
      Provider.of<OrderProvider>(context, listen: false).loadDummyData();
    });
  }

  void navigateTo(String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get user name from your auth provider, using a placeholder for now
    final userName = "Rahul";

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Printify',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
          actions: [
      IconButton(
      icon: const Icon(Icons.settings, color: Colors.white),
      onPressed: () => navigateTo('/settings'),
    )]
      ),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      // Greeting Section
      Padding(
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 26),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 95, vertical: 20),
          decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
          BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 12,
          offset: Offset(0, 4),
          )],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hi, $userName!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.backgroundColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Need a print today?',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ),
    ),

    // Tab Bar
    Padding(
    padding: EdgeInsets.symmetric(horizontal: 16),
    child: Container(
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
    BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 12,
    offset: Offset(0, 4),
    )],
    ),
    child: TabBar(
    controller: _tabController,
    labelColor: AppTheme.primaryColor,
    unselectedLabelColor: Colors.grey,
    indicator: BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    color: AppTheme.primaryColor.withOpacity(0.1),
    ),
    labelStyle: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    ),
    unselectedLabelStyle: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    ),
    tabs: [
    Tab(text: 'Active Orders'),
    Tab(text: 'Past Orders'),
    ],
    ),
    ),
    ),

    // Tab Bar View
    Expanded(
    child: Padding(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    child: TabBarView(
    controller: _tabController,
    children: [
    // Active Orders Tab
    ActiveOrdersTab(),

    // Past Orders Tab
    PastOrdersTab(),
    ],
    ),
    ),
    ),
    ],
    ),
    floatingActionButton: Container(
    margin: EdgeInsets.only(bottom: 16, right: 16),
    child: FloatingActionButton.extended(
    onPressed: () {
    // Navigate to New Order Screen
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => NewOrderScreen()),
    );
    },
    icon: Icon(Icons.add, color: Colors.white),
    label: Text(
    'New Order',
    style: TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    ),
    ),
    backgroundColor: AppTheme.accentColor,
    elevation: 6,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    ),
    ),
    ),
    );
  }
}