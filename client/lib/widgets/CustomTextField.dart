import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final TextEditingController?
  passwordController; // Reference for confirm password
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final Function(String)? onChanged; // Added onChanged parameter

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.controller,
    this.passwordController,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.onChanged, // Initialize the parameter
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;

    // Listeners for controllers remain but without validation logic
    widget.controller?.addListener(() {
      // No validation logic
    });

    widget.passwordController?.addListener(() {
      // No validation logic
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 5.h),
        TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          obscureText:
              widget.label.toLowerCase().contains("password")
                  ? _obscureText
                  : false,
          onChanged:
              widget.onChanged, // Pass the onChanged callback to TextField
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(
              widget.prefixIcon,
              size: 20.sp,
              color: Colors.black87,
            ),
            hintText: widget.hintText,
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black45,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: 10.h,
              horizontal: 12.w,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide.none,
            ),
            suffixIcon:
                widget.label.toLowerCase().contains("password")
                    ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.black54,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                    : null,
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }
}
