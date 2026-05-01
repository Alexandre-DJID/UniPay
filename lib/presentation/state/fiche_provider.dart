import 'package:flutter/material.dart';
import 'package:unipay/data/models/models.dart';

/// Provider de gestion d'état pour l'application UniPay
/// Utilise ChangeNotifier avec Provider pour la gestion centralisée de l'état

// ============================================================================
// DONNÉES MOCK POUR LE MVP
// ============================================================================

/// Crée des données de test
FicheEngagement _crierFicheMock() {
  // Création d'un étudiant mock
  final etudiant = Etudiant(
    matricule: 'ETU-2025-001',
    nom: 'Kouassi',
    prenom: 'Jean',
    email: 'jean.kouassi@university.edu',
    telephone: '+225 07 12 34 56 78',
    niveau: 'L2',
  );

  // Création des tranches
  final tranches = [
    Tranche(
      numero: 1,
      montantTotal: 150000,
      montantRegle: 150000,
      dateEcheance: DateTime(2025, 9, 30),
      reglements: [
        Reglement(
          montant: 150000,
          type: TypeReglement.especes,
          notes: 'Paiement 1ère tranche',
        ),
      ],
    ),
    Tranche(
      numero: 2,
      montantTotal: 150000,
      montantRegle: 100000,
      dateEcheance: DateTime(2025, 12, 31),
      reglements: [
        Reglement(
          montant: 75000,
          type: TypeReglement.mobileMoney,
          referenceTransaction: 'MTN-2025-001',
          notes: 'Paiement Mobile Money',
        ),
        Reglement(
          montant: 25000,
          type: TypeReglement.especes,
          notes: 'Complément espèces',
        ),
      ],
    ),
    Tranche(
      numero: 3,
      montantTotal: 150000,
      montantRegle: 0,
      dateEcheance: DateTime(2026, 3, 31),
      reglements: [],
    ),
  ];

  return FicheEngagement(
    etudiant: etudiant,
    anneeAcademique: 2025,
    montantTotal: 450000,
    tranches: tranches,
    notes: 'Fiche d\'engagement standard',
  );
}

// ============================================================================
// NOTIFIERS / CHANGE NOTIFIERS
// ============================================================================

/// ChangeNotifier pour gérer l'état de la fiche d'engagement
class FicheEngagementNotifier extends ChangeNotifier {
  FicheEngagement? _fiche;

  FicheEngagement? get fiche => _fiche;

  /// Charge une fiche par matricule (mock)
  void chargerFicheParMatricule(String matricule) {
    // En production, cela ferait un appel API
    if (matricule.isNotEmpty) {
      _fiche = _crierFicheMock();
      notifyListeners();
    } else {
      _fiche = null;
      notifyListeners();
    }
  }

  /// Ajoute un reglement à une tranche
  void ajouterReglement(int numeroTrache, Reglement reglement) {
    if (_fiche != null) {
      _fiche!.ajouterReglement(numeroTrache, reglement);
      notifyListeners();
    }
  }

  /// Réinitialise l'état
  void reinitialiser() {
    _fiche = null;
    notifyListeners();
  }
}

/// État du formulaire d'encaissement (immutable)
class FormulaireEncaissement {
  final int numeroTrache;
  final double montant;
  final TypeReglement typeReglement;
  final String? referenceTransaction;
  final String notes;

  FormulaireEncaissement({
    this.numeroTrache = 1,
    this.montant = 0,
    this.typeReglement = TypeReglement.especes,
    this.referenceTransaction,
    this.notes = '',
  });

  /// Copie avec modifications
  FormulaireEncaissement copyWith({
    int? numeroTrache,
    double? montant,
    TypeReglement? typeReglement,
    String? referenceTransaction,
    String? notes,
  }) {
    return FormulaireEncaissement(
      numeroTrache: numeroTrache ?? this.numeroTrache,
      montant: montant ?? this.montant,
      typeReglement: typeReglement ?? this.typeReglement,
      referenceTransaction: referenceTransaction ?? this.referenceTransaction,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() =>
      'FormulaireEncaissement(tranche: $numeroTrache, montant: $montant, type: ${typeReglement.label})';
}

/// ChangeNotifier pour le formulaire d'encaissement
class FormulaireEncaissementNotifier extends ChangeNotifier {
  FormulaireEncaissement _formulaire = FormulaireEncaissement();

  FormulaireEncaissement get formulaire => _formulaire;

  void setNumeroTrache(int numero) {
    _formulaire = _formulaire.copyWith(numeroTrache: numero);
    notifyListeners();
  }

  void setMontant(double montant) {
    _formulaire = _formulaire.copyWith(montant: montant);
    notifyListeners();
  }

  void setTypeReglement(TypeReglement type) {
    _formulaire = _formulaire.copyWith(typeReglement: type);
    notifyListeners();
  }

  void setReferenceTransaction(String? reference) {
    _formulaire = _formulaire.copyWith(referenceTransaction: reference);
    notifyListeners();
  }

  void setNotes(String notes) {
    _formulaire = _formulaire.copyWith(notes: notes);
    notifyListeners();
  }

  void reinitialiser() {
    _formulaire = FormulaireEncaissement();
    notifyListeners();
  }
}
