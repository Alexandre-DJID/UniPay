# UniPay - Système de Gestion des Paiements Universitaires

## 🎯 Vue d'ensemble

UniPay est une application Flutter web/mobile destinée à gérer les paiements universitaires avec une architecture clean et une interface responsive. Le système permet aux caissiers de consulter les fiches d'engagement des étudiants et d'enregistrer les encaissements (Espèces ou Mobile Money).

## 📋 Structure du Projet (Clean Architecture)

```
lib/
├── core/
│   ├── constants/
│   │   └── app_colors.dart          # Palettes de couleurs et thème
│   └── utils/
│       └── currency_formatter.dart   # Formatage monétaire FCFA
│
├── data/
│   └── models/
│       └── models.dart               # Classes de données métier
│           ├── Etudiant
│           ├── FicheEngagement
│           ├── Tranche
│           ├── Reglement
│           └── TypeReglement (enum)
│
├── presentation/
│   ├── screens/
│   │   └── caissiere_dashboard.dart # Dashboard principal
│   ├── widgets/
│   │   └── fiche_widgets.dart       # Composants réutilisables
│   └── state/
│       └── fiche_provider.dart      # Gestion d'état (Provider)
│
└── main.dart                         # Point d'entrée
```

## 🎨 Branding & Design System

### Palette de Couleurs
- **Primaire**: #1E3A8A (Bleu foncé)
- **Secondaire**: #3B82F6 (Bleu clair)
- **Succès**: #10B981 (Vert)
- **Erreur**: #EF4444 (Rouge)
- **Avertissement**: #FBBF24 (Ambre)
- **Background**: #F9FAFB (Gris très clair)

### Typographie
- **Police**: Inter (via Google Fonts)
- **Style**: Dashboard Admin épuré avec hiérarchie claire

## 🚀 Démarrage Rapide

### Installation des dépendances

```bash
flutter pub get
```

### Lancer l'application

```bash
# En développement
flutter run

# Sur le web
flutter run -d chrome

# Sur Android
flutter run -d android
```

## 📦 Dépendances Principales

- **provider**: ^6.1.0 - Gestion d'état
- **google_fonts**: ^6.1.0 - Typographie Inter
- **intl**: ^0.19.0 - Formatage internationalisé
- **uuid**: ^4.0.0 - Génération d'IDs uniques

## 🎭 Modèles de Données

### Etudiant
```dart
final etudiant = Etudiant(
  matricule: 'ETU-2025-001',
  nom: 'Kouassi',
  prenom: 'Jean',
  email: 'jean.kouassi@university.edu',
  telephone: '+225 07 12 34 56 78',
  niveau: 'L2',
);
```

### FicheEngagement
```dart
final fiche = FicheEngagement(
  etudiant: etudiant,
  anneeAcademique: 2025,
  montantTotal: 450000,
  tranches: [...],
);

// Calcul du reste à payer
final reste = fiche.calculerResteAPayer();
final estSoldee = fiche.estSoldee;
```

### Reglement
```dart
final reglement = Reglement(
  montant: 100000,
  type: TypeReglement.mobileMoney,
  referenceTransaction: 'MTN-2025-001',
  notes: 'Paiement Mobile Money',
);
```

## 🔑 Fonctionnalités du MVP

### Dashboard Caissière
- ✅ Recherche d'étudiant par matricule
- ✅ Affichage des informations étudiant
- ✅ Consultation de la fiche d'engagement avec statut (Soldée/Non payée)
- ✅ Visualisation des tranches de paiement avec barres de progression
- ✅ Affichage du reste à payer en évidence (rouge/vert)
- ✅ Historique des réglements avec détails
- ✅ Modal pour enregistrer un encaissement
- ✅ Support Espèces et Mobile Money (avec référence)
- ✅ Notes d'encaissement optionnelles

## 💡 Utilisation de Provider (Gestion d'État)

### FicheEngagementNotifier
```dart
// Charger une fiche par matricule
context.read<FicheEngagementNotifier>().chargerFicheParMatricule('ETU-2025-001');

// Ajouter un reglement
context.read<FicheEngagementNotifier>().ajouterReglement(1, reglement);

// Observer les changements
Consumer<FicheEngagementNotifier>(
  builder: (context, notifier, _) {
    final fiche = notifier.fiche;
    return ...;
  },
)
```

### FormulaireEncaissementNotifier
Gère l'état du formulaire d'encaissement avec validation.

## 🧪 Données Mock

Le système est pré-chargé avec des données mockées pour la démonstration :
- Étudiant: Jean Kouassi (Matricule: ETU-2025-001)
- Fiche: 450,000 FCFA en 3 tranches
- Tranches 1 et 2 partiellement payées, Tranche 3 impayée

## 🔧 Logique Métier (Règles de Gestion)

### Calcul du Reste à Payer
```dart
double resteAPayer = montantTotal - montantRegle;
```

### Statuts de Tranche
- **Payée**: `montantRegle >= montantTotal`
- **Échue**: Après la date d'échéance ET non payée
- **En cours**: Avant la date d'échéance ET non payée

### Progression Globale
```dart
double progression = (montantTotal - resteAPayer) / montantTotal * 100;
```

## 📱 Responsivité Web

L'interface s'adapte automatiquement selon la taille de l'écran :
- **Mobile**: < 768px
- **Desktop**: >= 768px

## 🔐 Points d'Extensibilité Futurs

1. **Intégration API**: Remplacer les mocks par des appels API
2. **Authentification**: Ajouter login et gestion des rôles
3. **Reports**: Génération de rapports PDF
4. **Notifications**: SMS/Email de confirmation de paiement
5. **Multi-langue**: Internationalisation (EN/FR)
6. **Historique Audit**: Traçabilité complète des modifications
7. **Reconciliation**: Module de rapprochement bancaire

## 🎓 Architectures & Patterns Utilisés

- **Clean Architecture**: Séparation stricte des responsabilités
- **Provider Pattern**: Gestion d'état centralisée
- **Model-View-ViewModel**: Logique métier séparée de la présentation
- **Immutability**: Classes de données immuables
- **Composition**: Réutilisabilité des widgets

## 📝 Conventions de Code

- **Nommage**: camelCase pour variables/fonctions, PascalCase pour classes
- **Commentaires**: Documentés avec `///` pour les publics
- **Linting**: Suivi des recommandations Flutter Lints
- **Formatage**: Code formaté automatiquement

## 🚨 Gestion des Erreurs

- Validation des montants positifs
- Vérification des références Mobile Money obligatoires
- Messages utilisateur explicites via SnackBar
- Try-catch sur les opérations critiques

## 📞 Support

Pour des questions ou améliorations, consulter la documentation interne du projet.

---

**Version**: 1.0.0  
**Date**: Mai 2026  
**Université de Cocody**
