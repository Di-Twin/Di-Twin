import 'package:flutter/material.dart';
import 'package:client/features/medication_management/data/providers/medication_service.dart';

class AddMedicationPage extends StatefulWidget {
  const AddMedicationPage({Key? key}) : super(key: key);

  @override
  State<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _frequencyController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Medication Name'),
                validator: (value) {
                  if (value == null || value.isEmpty()) {
                    return 'Please enter a medication name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(labelText: 'Dosage'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty()) {
                    return 'Please enter a dosage';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _frequencyController,
                decoration: const InputDecoration(labelText: 'Frequency'),
                validator: (value) {
                  if (value == null || value.isEmpty()) {
                    return 'Please enter the frequency';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Process data.
                      _addMedication();
                    }
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addMedication() async {
    try {
      await MedicationService().addMedication(
        name: _nameController.text,
        dosage: _dosageController.text,
        frequency: _frequencyController.text,
        notes: _notesController.text,
      );

      // Show a success message or navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medication added successfully!')),
      );

      Navigator.pop(context); // Go back to the previous screen
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add medication: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
