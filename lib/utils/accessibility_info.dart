import 'package:flutter/material.dart';
import 'package:mobirural/constants/appconstants.dart';

class AccessibilityInfoWidget extends StatelessWidget {
  final String? specialParking;
  final String? accessRamps;
  final String? elevator;
  final String? adaptedBathroom;
  final String? tactilePaving;

  const AccessibilityInfoWidget({
    super.key,
    this.specialParking,
    this.accessRamps,
    this.elevator,
    this.adaptedBathroom,
    this.tactilePaving,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildAccessibilityInfoItem("Vagas Especiais: ", specialParking),
        _buildAccessibilityInfoItem("Rampas de Acesso: ", accessRamps),
        _buildAccessibilityInfoItem("Elevadores: ", elevator),
        _buildAccessibilityInfoItem("Banheiro Adaptado: ", adaptedBathroom),
        _buildAccessibilityInfoItem("Piso Tátil: ", tactilePaving),
      ],
    );
  }

  Widget _buildAccessibilityInfoItem(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            value ?? 'N/A',
            style: TextStyle(
              fontSize: 17,
              color: value != null ? AppColors.textColor : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
