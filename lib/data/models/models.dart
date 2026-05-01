import 'package:uuid/uuid.dart';

/// Type d'encaissement (Règlement)
enum TypeReglement {
  especes('Espèces'),
  mobileMoney('Mobile Money');

  final String label;

  const TypeReglement(this.label);
}

/// Représente un étudiant dans le système UniPay
class Etudiant {
  final String id;
  final String matricule;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String niveau; // L1, L2, L3, M1, M2, Doctorat, etc.
  final DateTime dateInscription;

  Etudiant({
    String? id,
    required this.matricule,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.niveau,
    DateTime? dateInscription,
  }) : id = id ?? const Uuid().v4(),
       dateInscription = dateInscription ?? DateTime.now();

  // Getter pour nom complet
  String get nomComplet => '$prenom $nom';

  @override
  String toString() => 'Etudiant(matricule: $matricule, nom: $nomComplet)';
}

/// Représente un reglement (encaissement d'argent)
class Reglement {
  final String id;
  final double montant;
  final TypeReglement type;
  final String? referenceTransaction; // Requis pour Mobile Money
  final DateTime dateReglement;
  final String notes;

  Reglement({
    String? id,
    required this.montant,
    required this.type,
    this.referenceTransaction,
    DateTime? dateReglement,
    this.notes = '',
  }) : id = id ?? const Uuid().v4(),
       dateReglement = dateReglement ?? DateTime.now() {
    // Validation: Mobile Money doit avoir une référence
    if (type == TypeReglement.mobileMoney && referenceTransaction == null) {
      throw ArgumentError(
        'Une référence de transaction est requise pour Mobile Money',
      );
    }
  }

  @override
  String toString() =>
      'Reglement(montant: $montant, type: ${type.label}, date: $dateReglement)';
}

/// Représente une tranche de paiement
class Tranche {
  final String id;
  final int numero; // 1, 2, 3, etc.
  final double montantTotal;
  final double montantRegle;
  final DateTime dateEcheance;
  final List<Reglement> reglements;

  Tranche({
    String? id,
    required this.numero,
    required this.montantTotal,
    this.montantRegle = 0,
    required this.dateEcheance,
    List<Reglement>? reglements,
  }) : id = id ?? const Uuid().v4(),
       reglements = reglements ?? [];

  // Montant restant à payer pour cette tranche
  double get resteAPayer =>
      (montantTotal - montantRegle).clamp(0, double.infinity);

  // Pourcentage de paiement de la tranche
  double get pourcentagePaiement =>
      montantTotal > 0 ? (montantRegle / montantTotal * 100).clamp(0, 100) : 0;

  // Statut de la tranche
  bool get estPayee => resteAPayer <= 0;
  bool get estEchue => DateTime.now().isAfter(dateEcheance) && !estPayee;
  bool get estEnCours => !estPayee && !estEchue;

  @override
  String toString() =>
      'Tranche(numero: $numero, total: $montantTotal, regle: $montantRegle)';
}

/// Représente une Fiche d'Engagement annuelle pour un étudiant
class FicheEngagement {
  final String id;
  final Etudiant etudiant;
  final int anneeAcademique; // 2024, 2025, etc.
  final double montantTotal;
  final List<Tranche> tranches;
  final String notes;
  final DateTime dateCreation;

  FicheEngagement({
    String? id,
    required this.etudiant,
    required this.anneeAcademique,
    required this.montantTotal,
    List<Tranche>? tranches,
    this.notes = '',
    DateTime? dateCreation,
  }) : id = id ?? const Uuid().v4(),
       tranches = tranches ?? [],
       dateCreation = dateCreation ?? DateTime.now();

  /// Calcule dynamiquement le reste à payer
  double calculerResteAPayer() {
    double totalRegle = 0;
    for (final tranche in tranches) {
      totalRegle += tranche.montantRegle;
    }
    return (montantTotal - totalRegle).clamp(0, double.infinity);
  }

  /// Retourne le statut de paiement de la fiche
  bool get estSoldee => calculerResteAPayer() <= 0;

  /// Retourne le pourcentage global de paiement
  double get pourcentagePaiementGlobal => montantTotal > 0
      ? ((montantTotal - calculerResteAPayer()) / montantTotal * 100).clamp(
          0,
          100,
        )
      : 0;

  /// Ajoute un reglement à une tranche
  void ajouterReglement(int numeroTrache, Reglement reglement) {
    if (numeroTrache < 1 || numeroTrache > tranches.length) {
      throw ArgumentError('Numéro de tranche invalide');
    }
    final tranche = tranches[numeroTrache - 1];
    tranche.reglements.add(reglement);
  }

  /// Retourne l'historique complet des reglements (toutes tranches)
  List<Reglement> obtenirHistoriqueReglements() {
    final historique = <Reglement>[];
    for (final tranche in tranches) {
      historique.addAll(tranche.reglements);
    }
    // Tri par date décroissante (plus récent d'abord)
    historique.sort((a, b) => b.dateReglement.compareTo(a.dateReglement));
    return historique;
  }

  /// Retourne les tranches impayées
  List<Tranche> obtenirTranchesImpayees() {
    return tranches.where((t) => !t.estPayee).toList();
  }

  /// Retourne les tranches échues non payées
  List<Tranche> obtenirTranchesEchues() {
    return tranches.where((t) => t.estEchue).toList();
  }

  @override
  String toString() =>
      'FicheEngagement(etudiant: ${etudiant.nomComplet}, total: $montantTotal, reste: ${calculerResteAPayer()})';
}
