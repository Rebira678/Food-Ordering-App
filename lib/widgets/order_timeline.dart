import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class OrderTimeline extends StatelessWidget {
  final String status; // 'Placed' | 'Preparing' | 'Delivering' | 'Delivered'
  const OrderTimeline({super.key, required this.status});

  static const _steps = ['Placed', 'Preparing', 'Delivering', 'Delivered'];

  int get _activeIndex => _steps.indexOf(status);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_steps.length, (i) {
        final isDone = i <= _activeIndex;
        final isActive = i == _activeIndex;
        return Expanded(
          child: Row(
            children: [
              Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: isDone ? AppColors.success : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _steps[i],
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight:
                          isActive ? FontWeight.w700 : FontWeight.w400,
                      color: isDone
                          ? (isActive
                              ? AppColors.primary
                              : AppColors.success)
                          : Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              if (i < _steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: i < _activeIndex
                        ? AppColors.success
                        : Colors.grey.shade300,
                    margin: const EdgeInsets.only(bottom: 20),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
