import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/widgets/CustomActivityHeaderWidget.dart';
import 'package:client/features/medication_management/medication_management_list.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({Key? key}) : super(key: key);

  @override
  _MedicationsScreenState createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Medication> _filteredMedications = [];
  List<Medication> _allMedications = [
    Medication(name: 'Lisinopril', timing: 'Morning with or without food'),
    Medication(name: 'Metformin', timing: 'With meals'),
    Medication(name: 'Atorvastatin', timing: 'Evening or bedtime'),
    Medication(name: 'Levothyroxine', timing: 'Morning on empty stomach'),
    Medication(name: 'Omeprazole', timing: 'Before breakfast'),
  ];
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _filteredMedications = _allMedications;
  }

  void _filterMedications(String query) {
    setState(() {
      _filteredMedications =
          _allMedications
              .where(
                (medication) =>
                    medication.name.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    medication.timing.toLowerCase().contains(
                      query.toLowerCase(),
                    ),
              )
              .toList();
    });
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  void _editMedication(Medication medication) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Medication'),
          content: Text('Edit functionality for ${medication.name}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _deleteMedication(Medication medication) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Medication'),
          content: Text('Are you sure you want to delete ${medication.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _allMedications.removeWhere(
                    (item) => item.name == medication.name,
                  );
                  _filterMedications(_searchController.text);
                });
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final mediaQuery = MediaQuery.of(context);
          final keyboardHeight = mediaQuery.viewInsets.bottom;
          final isKeyboardVisible = keyboardHeight > 0;

          final headerHeight =
              isKeyboardVisible
                  ? constraints.maxHeight * 0.35
                  : constraints.maxHeight * 0.45;

          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Column(
              children: [
                SizedBox(
                  height: headerHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CustomActivityHeader(
                        title: 'Medications',
                        backgroundColor: Color(0xFF0F67FE),
                        buttonColor: Color(0xFF242E49),
                        buttonShadowColor: Color(0xFF242E49),
                        badgeText: 'Insomniac',
                        backgroundImagePath: './images/header_background.png',
                        score: '24',
                        subtitle: 'Medications',
                        showBadge: false,
                        buttonImage: 'images/SignInAddIcon.png',
                        onButtonTap: () {
                          print("Button clicked!");
                        },

                        bottomLeftRadius: 20.0,
                        bottomRightRadius: 20.0,
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.w),
                  child: Column(
                    children: [
                      SizedBox(height: 50.h),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Your Medications',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF242E49),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _toggleEditMode,
                            icon: Icon(
                              FontAwesomeIcons.edit,
                              size: 18.sp,
                              color: const Color(0xFF0F67FE),
                            ),
                            label: Text(
                              'Edit',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F67FE),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),

                      TextField(
                        controller: _searchController,
                        onChanged: _filterMedications,
                        style: GoogleFonts.plusJakartaSans(),
                        decoration: InputDecoration(
                          hintText: 'Search medications...',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            color: Colors.grey[600],
                          ),
                          prefixIcon: Icon(Icons.search, color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Column(
                        children: [
                          _filteredMedications.isEmpty
                              ? Center(
                                child: Text(
                                  'No medications found',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                              : MedicationsList(
                                medications: _filteredMedications,
                                isEditMode: _isEditMode,
                                onEdit: _editMedication,
                                onDelete: _deleteMedication,
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
