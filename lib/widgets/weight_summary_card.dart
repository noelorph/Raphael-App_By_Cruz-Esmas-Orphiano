import 'package:flutter/material.dart';

class WeightSummaryCard extends StatelessWidget {
  const WeightSummaryCard({
    super.key,
    required this.latestDate,
    required this.weightText,
    required this.bmiText,
    required this.bmiStatus,
    required this.bmiStatusBackgroundColor,
    required this.bmiStatusTextColor,
  });

  final String latestDate;
  final String weightText;
  final String bmiText;
  final String bmiStatus;
  final Color bmiStatusBackgroundColor;
  final Color bmiStatusTextColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: 'Latest Entry: ',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: latestDate,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        weightText,
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: Text('kg', style: TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Weight', style: TextStyle(color: Colors.grey)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bmiText,
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('BMI', style: TextStyle(color: Colors.grey)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: bmiStatusBackgroundColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  bmiStatus,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: bmiStatusTextColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
