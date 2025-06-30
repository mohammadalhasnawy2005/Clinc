import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/specialization_model.dart';

class SpecializationCard extends StatelessWidget {
  final SpecializationModel specialization;
  final VoidCallback onTap;

  const SpecializationCard({
    super.key,
    required this.specialization,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getSpecializationColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getSpecializationIcon(),
                color: _getSpecializationColor(),
                size: 24,
              ),
            ),

            const SizedBox(height: 8),

            // Name
            Text(
              _getDisplayName(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _getDisplayName() {
    // تقصير النص للعرض
    final name = specialization.name.replaceAll('أخصائي ', '');
    return name;
  }

  IconData _getSpecializationIcon() {
    final name = specialization.normalizedName.toLowerCase();

    if (name.contains('internal') || name.contains('medicine'))
      return Icons.favorite_rounded;
    if (name.contains('ent') || name.contains('ear'))
      return Icons.hearing_rounded;
    if (name.contains('cardiolog')) return Icons.monitor_heart_rounded;
    if (name.contains('ophthalmolog') || name.contains('eye'))
      return Icons.visibility_rounded;
    if (name.contains('dermatolog')) return Icons.face_rounded;
    if (name.contains('neurolog')) return Icons.psychology_rounded;
    if (name.contains('surgeon')) return Icons.local_hospital_rounded;
    if (name.contains('orthopedic')) return Icons.accessibility_new_rounded;
    if (name.contains('gynecolog') || name.contains('obstetric'))
      return Icons.pregnant_woman_rounded;
    if (name.contains('pediatric')) return Icons.child_care_rounded;
    if (name.contains('oncolog')) return Icons.coronavirus_rounded;
    if (name.contains('nephrolog')) return Icons.water_drop_rounded;
    if (name.contains('gastroenterolog')) return Icons.restaurant_rounded;
    if (name.contains('endocrinolog')) return Icons.science_rounded;
    if (name.contains('plastic')) return Icons.face_retouching_natural_rounded;
    if (name.contains('neurosurgeon')) return Icons.engineering_rounded;
    if (name.contains('anesthesiolog')) return Icons.local_pharmacy_rounded;
    if (name.contains('family')) return Icons.family_restroom_rounded;
    if (name.contains('psychiatr')) return Icons.psychology_alt_rounded;
    if (name.contains('infectious')) return Icons.biotech_rounded;
    if (name.contains('radiolog')) return Icons.medical_services_rounded;
    if (name.contains('emergency')) return Icons.emergency_rounded;
    if (name.contains('rheumatolog')) return Icons.back_hand_rounded;
    if (name.contains('pulmonolog')) return Icons.air_rounded;
    if (name.contains('occupational')) return Icons.work_rounded;
    if (name.contains('sports')) return Icons.sports_rounded;
    if (name.contains('hematolog')) return Icons.bloodtype_rounded;
    if (name.contains('physiotherap')) return Icons.self_improvement_rounded;
    if (name.contains('nutrition')) return Icons.restaurant_menu_rounded;
    if (name.contains('speech')) return Icons.record_voice_over_rounded;

    return Icons.medical_services_rounded;
  }

  Color _getSpecializationColor() {
    // ألوان مختلفة للتخصصات حسب النوع
    final colors = [
      AppColors.primary,
      AppColors.info,
      AppColors.success,
      AppColors.warning,
      AppColors.error,
      AppColors.primaryLight,
      AppColors.primaryDark,
    ];

    return colors[specialization.id % colors.length];
  }
}
