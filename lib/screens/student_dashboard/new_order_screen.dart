import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/upload_provider.dart';

// New Order Screen
class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  _NewOrderScreenState createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  bool _isUploading = false;
  int _currentStep = 0;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    try {
      setState(() {
        _isUploading = true;
      });

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null) {
        Provider.of<UploadProvider>(context, listen: false).addFiles(result.files);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking files: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _submitOrder() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Get the provider
      final uploadProvider = Provider.of<UploadProvider>(context, listen: false);

      // In a real app, you would upload files to storage and save order to Firestore
      // For now, just show success and reset

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text('Order Placed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              SizedBox(height: 16),
              Text(
                'Your order has been submitted successfully!',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Total: ₹${uploadProvider.totalCost.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Reset the provider
                uploadProvider.reset();

                // Navigate back to dashboard
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close new order screen
              },
              child: Text('Back to Dashboard'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Order'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          physics: ScrollPhysics(),
          currentStep: _currentStep,
          onStepTapped: (step) {
            setState(() {
              _currentStep = step;
            });
          },
          onStepContinue: () {
            if (_currentStep < 2) {
              // Don't proceed if no files are selected on the first step
              if (_currentStep == 0 &&
                  Provider.of<UploadProvider>(context, listen: false).selectedFiles.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please select at least one PDF file')),
                );
                return;
              }

              setState(() {
                _currentStep += 1;
              });
            } else {
              _submitOrder();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep -= 1;
              });
            } else {
              Navigator.pop(context);
            }
          },
          steps: [
            // Step 1: Upload Documents
            Step(
              title: Text('Upload PDFs'),
              content: _buildUploadStep(),
              isActive: _currentStep >= 0,
            ),

            // Step 2: Print Preferences
            Step(
              title: Text('Print Options'),
              content: _buildPrintOptionsStep(),
              isActive: _currentStep >= 1,
            ),

            // Step 3: Review & Submit
            Step(
              title: Text('Review & Submit'),
              content: _buildReviewStep(),
              isActive: _currentStep >= 2,
            ),
          ],
          controlsBuilder: (context, details) {
            return Padding(
              padding: EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(_currentStep < 2 ? 'Continue' : 'Submit Order'),
                  ),
                  SizedBox(width: 12),
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: Text(_currentStep > 0 ? 'Back' : 'Cancel'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Step 1: Upload Documents UI
  Widget _buildUploadStep() {
    return Consumer<UploadProvider>(
      builder: (context, uploadProvider, child) {
        final selectedFiles = uploadProvider.selectedFiles;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload button
            Center(
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickFiles,
                icon: Icon(Icons.upload_file),
                label: Text('Select PDF Files'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),

            SizedBox(height: 16),

            // Loading indicator when uploading
            if (_isUploading)
              Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Preparing files...'),
                  ],
                ),
              ),

            // Selected files list
            if (selectedFiles.isNotEmpty) ...[
              Text(
                'Selected Files:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: selectedFiles.length,
                itemBuilder: (context, index) {
                  final file = selectedFiles[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(Icons.picture_as_pdf, color: Colors.red),
                      title: Text(
                        file.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text('${(file.size / 1024).toStringAsFixed(2)} KB'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red[300]),
                        onPressed: () {
                          uploadProvider.removeFile(index);
                        },
                      ),
                    ),
                  );
                },
              ),

              if (selectedFiles.length > 1)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      uploadProvider.clearFiles();
                    },
                    icon: Icon(Icons.delete_sweep, size: 20),
                    label: Text('Clear All'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
            ] else ...[
              // Empty state
              Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No PDFs selected yet',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  // Step 2: Print Options UI
  Widget _buildPrintOptionsStep() {
    return Consumer<UploadProvider>(
      builder: (context, uploadProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color Option
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Print Type',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text('Black & White'),
                            value: 'Black & White',
                            groupValue: uploadProvider.printPreferences['color'],
                            onChanged: (value) {
                              uploadProvider.updatePreference('color', value);
                            },
                            activeColor: AppTheme.primaryColor,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text('Color'),
                            value: 'Color',
                            groupValue: uploadProvider.printPreferences['color'],
                            onChanged: (value) {
                              uploadProvider.updatePreference('color', value);
                            },
                            activeColor: AppTheme.primaryColor,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Sides Option
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sides',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text('Single-sided'),
                            value: 'Single-sided',
                            groupValue: uploadProvider.printPreferences['sides'],
                            onChanged: (value) {
                              uploadProvider.updatePreference('sides', value);
                            },
                            activeColor: AppTheme.primaryColor,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text('Double-sided'),
                            value: 'Double-sided',
                            groupValue: uploadProvider.printPreferences['sides'],
                            onChanged: (value) {
                              uploadProvider.updatePreference('sides', value);
                            },
                            activeColor: AppTheme.primaryColor,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Copies Option
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Number of Copies',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        IconButton(
                          onPressed: uploadProvider.printPreferences['copies'] > 1
                              ? () {
                            uploadProvider.updatePreference(
                              'copies',
                              uploadProvider.printPreferences['copies'] - 1,
                            );
                          }
                              : null,
                          icon: Icon(Icons.remove_circle_outline),
                          color: AppTheme.primaryColor,
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              uploadProvider.printPreferences['copies'].toString(),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            uploadProvider.updatePreference(
                              'copies',
                              uploadProvider.printPreferences['copies'] + 1,
                            );
                          },
                          icon: Icon(Icons.add_circle_outline),
                          color: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Binding Option
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Binding',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: uploadProvider.printPreferences['binding'],
                      onChanged: (value) {
                        uploadProvider.updatePreference('binding', value);
                      },
                      items: [
                        'None',
                        'Staple',
                        'Spiral',
                        'Hard Cover',
                      ].map((option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Additional Notes
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Additional Notes (Optional)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        hintText: 'Any special instructions for the shop owner?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        uploadProvider.setAdditionalNotes(value);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Step 3: Review & Submit UI
  Widget _buildReviewStep() {
    return Consumer<UploadProvider>(
      builder: (context, uploadProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Divider(height: 24),

                    // Files
                    Row(
                      children: [
                        Icon(Icons.description, color: Colors.grey[600], size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${uploadProvider.selectedFiles.length} file${uploadProvider.selectedFiles.length > 1 ? 's' : ''}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    // Print Type
                    Row(
                      children: [
                        Icon(Icons.palette, color: Colors.grey[600], size: 20),
                        SizedBox(width: 8),
                        Text('Print Type:'),
                        Spacer(),
                        Text(
                          uploadProvider.printPreferences['color'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    // Sides
                    Row(
                      children: [
                        Icon(Icons.flip, color: Colors.grey[600], size: 20),
                        SizedBox(width: 8),
                        Text('Sides:'),
                        Spacer(),
                        Text(
                          uploadProvider.printPreferences['sides'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    // Copies
                    Row(
                      children: [
                        Icon(Icons.content_copy, color: Colors.grey[600], size: 20),
                        SizedBox(width: 8),
                        Text('Copies:'),
                        Spacer(),
                        Text(
                          uploadProvider.printPreferences['copies'].toString(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    // Binding
                    Row(
                      children: [
                        Icon(Icons.book, color: Colors.grey[600], size: 20),
                        SizedBox(width: 8),
                        Text('Binding:'),
                        Spacer(),
                        Text(
                          uploadProvider.printPreferences['binding'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    if (uploadProvider.additionalNotes != null &&
                        uploadProvider.additionalNotes!.isNotEmpty) ...[
                      SizedBox(height: 16),
                      Divider(),
                      SizedBox(height: 8),

                      // Additional Notes
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Additional Notes:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(uploadProvider.additionalNotes!),
                        ],
                      ),
                    ],

                    SizedBox(height: 16),
                    Divider(),

                    // Total Cost
                    Row(
                      children: [
                        Text(
                          'Total Cost:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        Text(
                          '₹${uploadProvider.totalCost.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Payment Note
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'You will be redirected to the payment gateway after submitting your order',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}