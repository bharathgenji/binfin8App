import 'package:flutter/material.dart';

class BeneficiaryManagementScreen extends StatefulWidget {
  const BeneficiaryManagementScreen({Key? key}) : super(key: key);

  @override
  _BeneficiaryManagementScreenState createState() => _BeneficiaryManagementScreenState();
}

class _BeneficiaryManagementScreenState extends State<BeneficiaryManagementScreen> {
  final List<Map<String, String>> _beneficiaries = []; // List to store beneficiary data

  // Controllers for the add beneficiary form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  // Function to add a new beneficiary
  void _addBeneficiary() {
    if (_nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _contactController.text.isNotEmpty) {
      setState(() {
        _beneficiaries.add({
          'name': _nameController.text,
          'email': _emailController.text,
          'contact': _contactController.text,
        });
        _nameController.clear();
        _emailController.clear();
        _contactController.clear();
        Navigator.of(context).pop(); // Close the add beneficiary dialog
      });
    } else {
      // Show an error if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  // Function to remove a beneficiary
  void _removeBeneficiary(int index) {
    setState(() {
      _beneficiaries.removeAt(index);
    });
  }

  // Function to show the add beneficiary dialog
  void _showAddBeneficiaryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Beneficiary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _contactController,
              decoration: const InputDecoration(labelText: 'Contact'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addBeneficiary,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Beneficiaries'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Beneficiary Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showAddBeneficiaryDialog,
              child: const Text('Add Beneficiary'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _beneficiaries.isEmpty
                  ? const Center(child: Text('No beneficiaries added yet.'))
                  : ListView.builder(
                      itemCount: _beneficiaries.length,
                      itemBuilder: (context, index) {
                        final beneficiary = _beneficiaries[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(beneficiary['name'] ?? ''),
                            subtitle: Text('${beneficiary['email']} \n${beneficiary['contact']}'),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeBeneficiary(index),
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
