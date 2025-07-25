import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WeightInputDialog extends StatefulWidget {
  final double? currentWeight;
  final bool isTargetAchieved;
  final Function(double) onWeightSaved;

  const WeightInputDialog({
    super.key,
    this.currentWeight,
    this.isTargetAchieved = false,
    required this.onWeightSaved,
  });

  @override
  State<WeightInputDialog> createState() => _WeightInputDialogState();
}

class _WeightInputDialogState extends State<WeightInputDialog> {
  final TextEditingController currentWeightController = TextEditingController();
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.currentWeight != null) {
      currentWeightController.text = widget.currentWeight!.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    currentWeightController.dispose();
    super.dispose();
  }

  void submitWeight() async {
    final currentWeightText = currentWeightController.text.trim();

    if (currentWeightText.isEmpty) {
      _showError('Please enter your current weight');
      return;
    }

    final currentWeight = double.tryParse(currentWeightText);
    if (currentWeight == null || currentWeight <= 0 || currentWeight > 500) {
      _showError('Please enter a valid current weight (1-500 kg)');
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    Navigator.of(context).pop();
    widget.onWeightSaved(currentWeight);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: widget.isTargetAchieved
                    ? Colors.green.withOpacity(0.1)
                    : const Color(0xFF0066FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                widget.isTargetAchieved
                    ? Icons.emoji_events
                    : Icons.monitor_weight_outlined,
                color: widget.isTargetAchieved
                    ? Colors.green
                    : const Color(0xFF0066FF),
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Update Your Weight',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E2B3C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.isTargetAchieved
                  ? 'Congratulations on achieving your target!'
                  : 'Please enter your current weight',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Weight',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E2B3C),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: currentWeightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E2B3C),
                    ),
                    decoration: InputDecoration(
                      hintText: '0.0',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        color: Colors.grey.shade400,
                      ),
                      suffixText: 'kg',
                      suffixStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: isSubmitting
                        ? null
                        : () {
                            Navigator.of(context).pop();
                          },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : submitWeight,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isTargetAchieved
                          ? Colors.green
                          : const Color(0xFF0066FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Save',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}