// Provider
import 'package:flutter/cupertino.dart';

import '../models/print_order_model.dart';

class OrderProvider extends ChangeNotifier {
  List<PrintOrder> _activeOrders = [];
  List<PrintOrder> _pastOrders = [];

  List<PrintOrder> get activeOrders => _activeOrders;
  List<PrintOrder> get pastOrders => _pastOrders;

  // Dummy data for demonstration
  void loadDummyData() {
    _activeOrders = [
      PrintOrder(
        id: 'ORD-1001',
        status: 'Processing',
        dateTime: DateTime.now().subtract(Duration(hours: 2)),
        cost: 15.50,
        documents: ['Assignment_CS101.pdf'],
        printPreferences: {
          'color': 'Black & White',
          'sides': 'Double-sided',
          'copies': 1,
          'binding': 'None',
        },
        isPaid: true,
      ),
      PrintOrder(
        id: 'ORD-1002',
        status: 'Order Placed',
        dateTime: DateTime.now().subtract(Duration(hours: 1)),
        cost: 32.75,
        documents: ['Research_Paper.pdf', 'Statistics.pdf'],
        printPreferences: {
          'color': 'Color',
          'sides': 'Single-sided',
          'copies': 2,
          'binding': 'Spiral',
        },
        additionalNotes: 'Please use high quality paper for the charts',
        isPaid: true,
      ),
    ];

    _pastOrders = [
      PrintOrder(
        id: 'ORD-985',
        status: 'Received',
        dateTime: DateTime.now().subtract(Duration(days: 5)),
        cost: 8.25,
        documents: ['Notes_Physics.pdf'],
        printPreferences: {
          'color': 'Black & White',
          'sides': 'Double-sided',
          'copies': 1,
          'binding': 'Staple',
        },
        isPaid: true,
      ),
      PrintOrder(
        id: 'ORD-972',
        status: 'Received',
        dateTime: DateTime.now().subtract(Duration(days: 10)),
        cost: 45.00,
        documents: ['Project_Report.pdf'],
        printPreferences: {
          'color': 'Color',
          'sides': 'Double-sided',
          'copies': 3,
          'binding': 'Hard Cover',
        },
        isPaid: true,
      ),
    ];
    notifyListeners();
  }

  void cancelOrder(String orderId) {
    final orderIndex = _activeOrders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      // Only allow cancellation if order is in "Order Placed" status
      if (_activeOrders[orderIndex].status == 'Order Placed') {
        _activeOrders.removeAt(orderIndex);
        notifyListeners();
      }
    }
  }
}