// Models
class PrintOrder {
  final String id;
  final String status;
  final DateTime dateTime;
  final double cost;
  final List<String> documents;
  final Map<String, dynamic> printPreferences;
  final String? additionalNotes;
  final bool isPaid;

  PrintOrder({
    required this.id,
    required this.status,
    required this.dateTime,
    required this.cost,
    required this.documents,
    required this.printPreferences,
    this.additionalNotes,
    required this.isPaid,
  });
}
