import 'package:flutter/material.dart';

/// Constantes de couleurs pour le design system UniPay
/// Thème épuré style Dashboard Admin
class AppColors {
  // Couleurs primaires et secondaires
  static const Color primaryColor = Color(0xFF1E3A8A); // Bleu foncé
  static const Color secondaryColor = Color(0xFF3B82F6); // Bleu clair

  // Couleurs de statut
  static const Color successColor = Color(0xFF10B981); // Vert
  static const Color errorColor = Color(0xFFEF4444); // Rouge
  static const Color warningColor = Color(0xFFFBBF24); // Ambre

  // Couleurs de background et neutrales
  static const Color backgroundColor = Color(0xFFF9FAFB); // Fond clair
  static const Color surfaceColor = Color(0xFFFFFFFF); // Blanc pur
  static const Color cardColor = Color(0xFFF3F4F6); // Gris très clair

  // Couleurs de texte
  static const Color textDark = Color(0xFF1F2937); // Texte sombre
  static const Color textSecondary = Color(0xFF6B7280); // Texte secondaire
  static const Color textLight = Color(0xFF9CA3AF); // Texte léger

  // Couleurs de bordures et dividers
  static const Color borderColor = Color(0xFFE5E7EB); // Bordure grise
  static const Color dividerColor = Color(0xFFF3F4F6); // Divider gris clair

  // Gradient pour les éléments importants
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Ombres
  static const BoxShadow lightShadow = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  static const BoxShadow mediumShadow = BoxShadow(
    color: Color(0x26000000),
    blurRadius: 16,
    offset: Offset(0, 4),
  );
}
