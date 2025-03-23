// Order Details Screen
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/print_order_model.dart';
import '../../providers/order_provider.dart';

class OrderDetailsScreen extends StatelessWidget {
  final PrintOrder order;

  const OrderDetailsScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final canCancel = order.status == 'Order Placed';

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID and Status
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order ID',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          order.id,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Status',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(order.status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            order.status,
                            style: TextStyle(
                              color: _getStatusColor(order.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Order Summary
            _buildSectionTitle('Order Summary'),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date and Time
                    _buildDetailRow(
                      icon: Icons.calendar_today,
                      title: 'Date & Time',
                      value: DateFormat('MMM d, yyyy • hh:mm a').format(order.dateTime),
                    ),

                    Divider(height: 24),

                    // Payment Status
                    _buildDetailRow(
                      icon: Icons.payment,
                      title: 'Payment Status',
                      value: order.isPaid ? 'Paid' : 'Pending',
                      valueColor: order.isPaid ? Colors.green : Colors.red,
                    ),

                    Divider(height: 24),

                    // Total Cost
                    _buildDetailRow(
                      icon: Icons.account_balance_wallet,
                      title: 'Total Cost',
                      value: '₹${order.cost.toStringAsFixed(2)}',
                      valueColor: AppTheme.accentColor,
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Document Details
            _buildSectionTitle('Document Details'),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Document List
                    ...order.documents.map((doc) => Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.insert_drive_file,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(doc),
                          ),
                        ],
                      ),
                    )).toList(),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Print Preferences
            _buildSectionTitle('Print Preferences'),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      icon: Icons.palette,
                      title: 'Type',
                      value: order.printPreferences['color'] ?? 'N/A',
                    ),

                    SizedBox(height: 12),

                    _buildDetailRow(
                      icon: Icons.flip,
                      title: 'Sides',
                      value: order.printPreferences['sides'] ?? 'N/A',
                    ),

                    SizedBox(height: 12),

                    _buildDetailRow(
                      icon: Icons.content_copy,
                      title: 'Copies',
                      value: '${order.printPreferences['copies'] ?? 'N/A'}',
                    ),

                    SizedBox(height: 12),

                    _buildDetailRow(
                      icon: Icons.book,
                      title: 'Binding',
                      value: order.printPreferences['binding'] ?? 'N/A',
                    ),
                  ],
                ),
              ),
            ),

            // Additional Notes (if any)
            if (order.additionalNotes != null && order.additionalNotes!.isNotEmpty) ...[
              SizedBox(height: 16),
              _buildSectionTitle('Additional Notes'),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(order.additionalNotes!),
                ),
              ),
            ],

            SizedBox(height: 24),

            // Cancel Button (only for orders in "Order Placed" status)
            if (canCancel)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Show confirmation dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Cancel Order'),
                        content: Text('Are you sure you want to cancel this order?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('No'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Cancel the order
                              Provider.of<OrderProvider>(context, listen: false)
                                  .cancelOrder(order.id);

                              // Close dialog and navigate back
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: Text('Yes, Cancel'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text('Cancel Order'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.textColor,
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        SizedBox(width: 8),
        Text(
          '$title:',
          style: TextStyle(
            color: Colors.grey[700],
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Order Placed':
        return Colors.blue;
      case 'Processing':
        return Colors.orange;
      case 'Printed':
        return Colors.green;
      case 'On Hold':
        return Colors.red;
      case 'Received':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}