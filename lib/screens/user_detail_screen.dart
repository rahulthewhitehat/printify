import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/custom_button.dart';
import '../models/user_model.dart';

class UserDetailScreen extends StatefulWidget {
  final UserModel user;

  const UserDetailScreen({super.key, required this.user});

  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  late bool _isEditing;
  late UserModel _currentUser;

  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _rollNoController;

  // Dropdown values
  String? _selectedDepartment;
  String? _selectedSection;
  int? _selectedYear;

  @override
  void initState() {
    super.initState();
    _isEditing = false;
    _currentUser = widget.user;

    // Initialize controllers
    _nameController = TextEditingController(text: _currentUser.fullName);
    _emailController = TextEditingController(text: _currentUser.email);
    _phoneController = TextEditingController(text: _currentUser.phoneNumber);
    _rollNoController = TextEditingController(text: _currentUser.rollNumber);

    _selectedDepartment = _currentUser.department;
    _selectedSection = _currentUser.section;
    _selectedYear = _currentUser.year;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _rollNoController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveChanges() async {
    // Implement save logic
    final updatedUserData = {
      'fullName': _nameController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'department': _selectedDepartment,
      'section': _selectedSection,
      'year': _selectedYear,
      'rollNumber': _rollNoController.text.trim(),
      'isVerified': false,
    };

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.updateUserProfile(
        widget.user.uid,
        updatedUserData,
    );

    if (success) {
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  // Modify the phone number field to include both call and WhatsApp icons
  Widget _buildContactField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool showActionIcons = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: Icon(icon, color: Colors.grey),
                enabled: _isEditing,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
          ),
          if (!_isEditing && showActionIcons && controller.text.isNotEmpty)
            Row(
              children: [
                // Call icon
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View / Edit Details'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: _toggleEditMode,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture
              CircleAvatar(

              ),
              SizedBox(height: 16),
              Text(
                _currentUser.fullName,
                style: Theme
                    .of(context)
                    .textTheme
                    .titleLarge,
              ),

              SizedBox(height: 30),
              Text(
                'Personal Details',
                style: Theme
                    .of(context)
                    .textTheme
                    .titleMedium,
              ),
              SizedBox(height: 10),

              // Editable Fields
              _buildEditableField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person,
                isEditable: _isEditing,
              ),

              _buildEditableField(
                controller: _rollNoController,
                label: 'Roll Number',
                icon: Icons.numbers_outlined,
                isEditable: _isEditing,
              ),


              // Email Field with Mail Icon
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email, color: Colors.grey),
                          enabled: false,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              _buildContactField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone,
                showActionIcons: true,
              ),

              _buildDepartmentSection(),

              if (_isEditing)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: CustomButton(
                    text: 'Save Changes',
                    onPressed: _saveChanges,
                    isFullWidth: true,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isEditable = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey),
          enabled: isEditable,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        keyboardType: keyboardType,
      ),
    );
  }


  Widget _buildDepartmentSection() {
    // Dropdown options (you might want to move these to a constants file)
    final List<String> departments = [
      'CSE', 'IT', 'CSBS', 'CSE-CS', 'CSD',
      'AIML', 'AIDS', 'ECE', 'EEE', 'OTHERS'
    ];
    final List<String> sections = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];
    final List<int> years = [1, 2, 3, 4];

    if (!_isEditing) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Department Details',
              style: Theme
                  .of(context)
                  .textTheme
                  .titleMedium,
            ),
            SizedBox(height: 8),
            // Department Read-only Box
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200],
              ),
              child: Text(
                'Department: $_selectedDepartment',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
            SizedBox(height: 16),
            // Section and Year Row
            Row(
              children: [
                // Section Read-only Box
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[200],
                    ),
                    child: Text(
                      'Section: $_selectedSection',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                // Year Read-only Box
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[200],
                    ),
                    child: Text(
                      'Year: $_selectedYear',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Department Dropdown
        DropdownButtonFormField<String>(
          value: _selectedDepartment,
          decoration: InputDecoration(
            labelText: 'Department',
            prefixIcon: Icon(Icons.business, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          items: departments.map((department) {
            return DropdownMenuItem(
              value: department,
              child: Text(department),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedDepartment = value!;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a department';
            }
            return null;
          },
        ),
        SizedBox(height: 16),

        // Section and Year Row
        Row(
          children: [
            // Section Dropdown
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedSection,
                decoration: InputDecoration(
                  labelText: 'Section',
                  prefixIcon: Icon(Icons.group, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: sections.map((section) {
                  return DropdownMenuItem(
                    value: section,
                    child: Text(section),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSection = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a section';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 16),

            // Year Dropdown
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _selectedYear,
                decoration: InputDecoration(
                  labelText: 'Year',
                  prefixIcon: Icon(Icons.calendar_today, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: years.map((year) {
                  return DropdownMenuItem(
                    value: year,
                    child: Text('Year $year'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedYear = value!;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a year';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}