import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ditwin_alert/input_field_alert.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final TextEditingController?
  passwordController; // Reference for confirm password
  final FocusNode? focusNode; // ✅ Added FocusNode
  final TextInputType keyboardType; // ✅ Added Keyboard Type

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.controller,
    this.passwordController,
    this.focusNode, // ✅ Initialize
    this.keyboardType = TextInputType.text, // ✅ Default to text input
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  String? _errorMessage;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;

    // Listen for changes in the confirm password field
    widget.controller?.addListener(() {
      if (widget.label.toLowerCase() == "confirm password") {
        _validateInput();
      }
    });

    // Listen for changes in the password field (important!)
    widget.passwordController?.addListener(() {
      if (widget.label.toLowerCase() == "confirm password") {
        _validateInput();
      }
    });
  }

  void _validateInput() {
    setState(() {
      if (widget.controller?.text.isEmpty ?? true) {
        _errorMessage = "${widget.label} cannot be empty";
      } else if (widget.label.toLowerCase() == "email address") {
        if (!RegExp(
          r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
        ).hasMatch(widget.controller!.text)) {
          _errorMessage = "Enter a valid email address";
        } else {
          _errorMessage = null;
        }
      } else if (widget.label.toLowerCase() == "password") {
        if (widget.controller!.text.length < 6) {
          _errorMessage = "Password must be at least 6 characters";
        } else if (!RegExp(r'(?=.*[A-Z])').hasMatch(widget.controller!.text)) {
          _errorMessage = "Must contain at least one uppercase letter";
        } else if (!RegExp(r'(?=.*\d)').hasMatch(widget.controller!.text)) {
          _errorMessage = "Must contain at least one number";
        } else if (!RegExp(
          r'(?=.*[@$!%*?&])',
        ).hasMatch(widget.controller!.text)) {
          _errorMessage =
              "Must contain at least one special character (@\$!%*?&)";
        } else {
          _errorMessage = null;
        }
      } else if (widget.label.toLowerCase() == "confirm password") {
        if (widget.passwordController != null &&
            widget.controller!.text != widget.passwordController!.text) {
          _errorMessage = "Passwords do not match";
        } else {
          _errorMessage = null;
        }
      } else {
        _errorMessage = null;
      }
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
          focusNode: widget.focusNode, // ✅ Assign focusNode
          keyboardType: widget.keyboardType, // ✅ Assign keyboardType
          obscureText:
              widget.label.toLowerCase().contains("password")
                  ? _obscureText
                  : false,
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
              // ✅ Styled hint text
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black45, // Light gray color
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
          onChanged: (value) => _validateInput(),
        ),

        if (_errorMessage != null)
          Padding(
            padding: EdgeInsets.only(top: 5.h),
            child: InputFieldAlert(
              message: _errorMessage!,
              alertType: AlertType.error,
              width: double.infinity,
              height: 45,
              borderRadius: 10,
              fontSize: 14,
              backgroundColor: Colors.red[100],
              textColor: Colors.red,
            ),
          ),
        SizedBox(height: 20.h),
      ],
    );
  }
}
