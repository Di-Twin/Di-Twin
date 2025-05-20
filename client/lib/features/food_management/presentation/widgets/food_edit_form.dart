import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class FoodEditForm extends StatefulWidget {
  final Map<String, dynamic> food;
  final Function(Map<String, dynamic>) onSave;

  const FoodEditForm({
    super.key,
    required this.food,
    required this.onSave,
  });

  @override
  State<FoodEditForm> createState() => _FoodEditFormState();
}

class _FoodEditFormState extends State<FoodEditForm> {
  late Map<String, dynamic> _foodBeingEdited;

  @override
  void initState() {
    super.initState();
    _foodBeingEdited = Map<String, dynamic>.from(widget.food);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle and header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Title with close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Food',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Color(0xFF64748B),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Food edit form
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food name
                  Text(
                    'Food Name',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    initialValue: _foodBeingEdited['name'],
                    decoration: InputDecoration(
                      hintText: 'Enter food name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _foodBeingEdited['name'] = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),

                  // Calories
                  Text(
                    'Calories',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    initialValue: _foodBeingEdited['calories'].toString(),
                    decoration: InputDecoration(
                      hintText: 'Enter calories',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixText: 'kcal',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _foodBeingEdited['calories'] = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                  SizedBox(height: 20),

                  // Weight
                  Text(
                    'Weight',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    initialValue: _foodBeingEdited['weight'],
                    decoration: InputDecoration(
                      hintText: 'Enter weight (e.g. 250g)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _foodBeingEdited['weight'] = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),

                  // Time
                  Text(
                    'Time',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      // Parse current time
                      final timeStr = _foodBeingEdited['time'] as String;
                      final format = DateFormat('h:mm a');
                      final time = format.parse(timeStr);
                      final initialTime = TimeOfDay(
                        hour: time.hour,
                        minute: time.minute,
                      );

                      final TimeOfDay? selectedTime = await showTimePicker(
                        context: context,
                        initialTime: initialTime,
                      );

                      if (selectedTime != null) {
                        setState(() {
                          final hour = selectedTime.hourOfPeriod;
                          final minute = selectedTime.minute;
                          final period = selectedTime.period == DayPeriod.am
                              ? 'AM'
                              : 'PM';
                          _foodBeingEdited['time'] =
                              '$hour:${minute.toString().padLeft(2, '0')} $period';
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _foodBeingEdited['time'],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Icon(
                            Icons.access_time,
                            color: Color(0xFF64748B),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Meal Type
                  Text(
                    'Meal Type',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _foodBeingEdited['mealType'] as String,
                        isExpanded: true,
                        items: [
                          DropdownMenuItem(
                            value: 'breakfast',
                            child: Text('Breakfast'),
                          ),
                          DropdownMenuItem(
                            value: 'lunch',
                            child: Text('Lunch'),
                          ),
                          DropdownMenuItem(
                            value: 'dinner',
                            child: Text('Dinner'),
                          ),
                          DropdownMenuItem(
                            value: 'snack',
                            child: Text('Snack'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _foodBeingEdited['mealType'] = value;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Macronutrients
                  Text(
                    'Macronutrients',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Protein, Carbs, Fat
                  Row(
                    children: [
                      // Protein
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Protein (g)',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            SizedBox(height: 4),
                            TextFormField(
                              initialValue:
                                  _foodBeingEdited['protein'].toString(),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  _foodBeingEdited['protein'] =
                                      int.tryParse(value) ?? 0;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),

                      // Carbs
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Carbs (g)',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            SizedBox(height: 4),
                            TextFormField(
                              initialValue:
                                  _foodBeingEdited['carbs'].toString(),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  _foodBeingEdited['carbs'] =
                                      int.tryParse(value) ?? 0;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),

                      // Fat
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fat (g)',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            SizedBox(height: 4),
                            TextFormField(
                              initialValue: _foodBeingEdited['fat'].toString(),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  _foodBeingEdited['fat'] =
                                      int.tryParse(value) ?? 0;
                                });
                              },
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

          // Save button
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0F67FE),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  widget.onSave(_foodBeingEdited);
                  Navigator.pop(context);
                },
                child: Text(
                  'Save Changes',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
