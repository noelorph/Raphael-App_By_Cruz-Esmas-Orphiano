import 'package:flutter/material.dart';

import '../services/measurement_service.dart';

class MeasurementEntryField extends StatelessWidget {
  const MeasurementEntryField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.isDark,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final bool isDark;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [MeasurementService.inputFormatter],
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            hintText: hintText,
            counterText: '',
            hintStyle: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF111212) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF35E0A1), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
