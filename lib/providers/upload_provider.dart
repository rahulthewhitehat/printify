// File Upload Provider
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';

class UploadProvider extends ChangeNotifier {
  List<PlatformFile> _selectedFiles = [];
  Map<String, dynamic> _printPreferences = {
    'color': 'Black & White',
    'sides': 'Single-sided',
    'copies': 1,
    'binding': 'None',
  };
  String? _additionalNotes;
  double _totalCost = 0.0;

  List<PlatformFile> get selectedFiles => _selectedFiles;
  Map<String, dynamic> get printPreferences => _printPreferences;
  String? get additionalNotes => _additionalNotes;
  double get totalCost => _totalCost;

  void addFiles(List<PlatformFile> files) {
    _selectedFiles.addAll(files);
    _calculateCost();
    notifyListeners();
  }

  void removeFile(int index) {
    _selectedFiles.removeAt(index);
    _calculateCost();
    notifyListeners();
  }

  void clearFiles() {
    _selectedFiles.clear();
    _calculateCost();
    notifyListeners();
  }

  void updatePreference(String key, dynamic value) {
    _printPreferences[key] = value;
    _calculateCost();
    notifyListeners();
  }

  void setAdditionalNotes(String notes) {
    _additionalNotes = notes;
    notifyListeners();
  }

  void _calculateCost() {
    // Base cost per page
    double baseCost = _printPreferences['color'] == 'Color' ? 10.0 : 2.0;

    // Calculate total pages (for simplicity, assume 1 page per file for now)
    // In a real app, you would extract page count from PDFs
    num totalPages = _selectedFiles.length;

    // Adjust for copies
    totalPages *= _printPreferences['copies'];

    // Double-sided discount (if applicable)
    double sidesFactor = _printPreferences['sides'] == 'Double-sided' ? 0.8 : 1.0;

    // Binding cost
    double bindingCost = 0.0;
    switch(_printPreferences['binding']) {
      case 'Staple':
        bindingCost = 5.0;
        break;
      case 'Spiral':
        bindingCost = 25.0;
        break;
      case 'Hard Cover':
        bindingCost = 100.0;
        break;
      default:
        bindingCost = 0.0;
    }

    // Calculate total cost
    _totalCost = (baseCost * totalPages * sidesFactor) + bindingCost;
  }

  // Reset everything when done
  void reset() {
    _selectedFiles.clear();
    _printPreferences = {
      'color': 'Black & White',
      'sides': 'Single-sided',
      'copies': 1,
      'binding': 'None',
    };
    _additionalNotes = null;
    _totalCost = 0.0;
    notifyListeners();
  }
}