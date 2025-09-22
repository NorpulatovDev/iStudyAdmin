import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/payment_model.dart';

class UnpaidStudentCard extends StatelessWidget {
  final UnpaidStudentModel student;
  final VoidCallback? onMakePayment;

  const UnpaidStudentCard({
    super.key,
    required this.student,
    this.onMakePayment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Warning indicator
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person_off,
                color: Colors.orange,
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // Student details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          student.fullName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        NumberFormat('#,##0.0').format(student.remainingAmount),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(
                        Icons.group,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          student.groupName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'UNPAID',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Contact information
                  if (student.phoneNumber != null ||
                      student.parentPhoneNumber != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        if (student.phoneNumber != null) ...[
                          Text(
                            'Student: ${student.phoneNumber}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (student.parentPhoneNumber != null) ...[
                            const SizedBox(width: 12),
                            Text(
                              'Parent: ${student.parentPhoneNumber}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ] else if (student.parentPhoneNumber != null) ...[
                          Text(
                            'Parent: ${student.parentPhoneNumber}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Quick action buttons
                  Row(
                    children: [
                      // Call student button
                      if (student.phoneNumber != null)
                        _buildQuickActionButton(
                          icon: Icons.phone,
                          label: 'Call Student',
                          color: Colors.blue,
                          onPressed: () => _makePhoneCall(student.phoneNumber!),
                        ),

                      if (student.phoneNumber != null &&
                          student.parentPhoneNumber != null)
                        const SizedBox(width: 8),

                      // Call parent button
                      if (student.parentPhoneNumber != null)
                        _buildQuickActionButton(
                          icon: Icons.phone,
                          label: 'Call Parent',
                          color: Colors.green,
                          onPressed: () =>
                              _makePhoneCall(student.parentPhoneNumber!),
                        ),

                      const Spacer(),

                      // Make payment button
                      if (onMakePayment != null)
                        ElevatedButton.icon(
                          onPressed: onMakePayment,
                          icon: const Icon(Icons.payment, size: 16),
                          label: const Text('Make Payment'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 14),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) {
    // TODO: Implement phone call functionality
    // You can use url_launcher package to make phone calls
    // Example: launch('tel:$phoneNumber');
    print('Making call to: $phoneNumber');
  }
}
