import 'package:intl/intl.dart';

/// Utilitaires de formatage monétaire pour UniPay
/// Support de la devise FCFA (Franc de la Communauté Financière Africaine)
class CurrencyFormatter {
  static const String currencySymbol = 'FCFA';
  static const String currencyCode = 'XOF'; // Code ISO pour FCFA

  /// Formate un montant en FCFA avec séparateurs de milliers
  /// Exemple: 50000 -> "50 000 FCFA"
  /// Exemple: 1234567.89 -> "1 234 567,89 FCFA"
  static String formatFCFA(num amount) {
    final formatter = NumberFormat('#,##0.##', 'fr_FR');
    final formattedAmount = formatter.format(amount);
    return '$formattedAmount $currencySymbol';
  }

  /// Formate un montant en FCFA sans symbole
  /// Exemple: 50000 -> "50 000"
  static String formatFCFAWithoutSymbol(num amount) {
    final formatter = NumberFormat('#,##0.##', 'fr_FR');
    return formatter.format(amount);
  }

  /// Formate un montant en FCFA avec virgule décimale (pour édition)
  /// Exemple: 50000.50 -> "50000.50"
  static String formatFCFAForInput(num amount) {
    return amount.toString();
  }

  /// Parse une chaîne formatée et retourne le montant numérique
  /// Exemple: "50 000,50 FCFA" -> 50000.50
  static num parseFCFA(String formatted) {
    // Supprime la devise et les espaces
    String cleaned = formatted
        .replaceAll(currencySymbol, '')
        .replaceAll(' ', '')
        .trim();

    // Remplace la virgule par un point pour le parsing
    cleaned = cleaned.replaceAll(',', '.');

    return num.tryParse(cleaned) ?? 0;
  }

  /// Retourne le format court de la devise (ex: "F")
  static String getCurrencyShortForm() {
    return 'F';
  }

  /// Formate un montant pour affichage en ligne (plus compact)
  /// Exemple: 50000 -> "50K"
  static String formatCompact(num amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M $currencySymbol';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K $currencySymbol';
    }
    return '$amount $currencySymbol';
  }
}
