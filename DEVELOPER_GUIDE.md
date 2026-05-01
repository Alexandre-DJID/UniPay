# Guide de Développement - UniPay

## 🎯 Vue d'ensemble Architecture

UniPay suit strictement une **Clean Architecture** avec séparation des responsabilités :

```
Domain (Règles Métier)
    ↓
Presentation (UI)  ←→  State Management (Provider)
    ↓                            ↓
Data (Models)     ←→    Core (Utils, Constants)
```

---

## 📂 Structure Détaillée

### `/lib/core`

#### `constants/app_colors.dart`
- Centralise toutes les couleurs du design system
- Palettes prédéfinies (primary, secondary, success, error, etc.)
- Gradients et ombres réutilisables
- À utiliser partout au lieu de couleurs hardcodées

```dart
// ✓ BON
Container(color: AppColors.primaryColor)

// ✗ MAUVAIS
Container(color: Color(0xFF1E3A8A))
```

#### `utils/currency_formatter.dart`
- Formatage FCFA centralisé
- Support des décimales et séparateurs de milliers
- Fonctions compactes pour affichage réduit

```dart
CurrencyFormatter.formatFCFA(50000)      // "50 000 FCFA"
CurrencyFormatter.formatCompact(1000000) // "1.0M FCFA"
```

### `/lib/data/models`

#### `models.dart`
Contient 5 classes principales :

**1. TypeReglement (Enum)**
```dart
enum TypeReglement {
  especes('Espèces'),
  mobileMoney('Mobile Money');
}
```

**2. Etudiant**
```dart
class Etudiant {
  final String id;              // UUID unique
  final String matricule;       // Identifiant officiel
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String niveau;          // L1, L2, L3, M1, M2, etc.
  final DateTime dateInscription;
  
  String get nomComplet => '$prenom $nom';
}
```

**3. Reglement**
```dart
class Reglement {
  final String id;              // UUID
  final double montant;         // En FCFA
  final TypeReglement type;     // Enum
  final String? referenceTransaction; // Obligatoire si Mobile Money
  final DateTime dateReglement;
  final String notes;
}
```

**4. Tranche**
```dart
class Tranche {
  final String id;
  final int numero;             // 1, 2, 3...
  final double montantTotal;
  final double montantRegle;    // Cumul des paiements
  final DateTime dateEcheance;
  final List<Reglement> reglements;
  
  // Propriétés calculées
  double get resteAPayer => montantTotal - montantRegle;
  bool get estPayee => resteAPayer <= 0;
  bool get estEchue => DateTime.now().isAfter(dateEcheance) && !estPayee;
}
```

**5. FicheEngagement**
```dart
class FicheEngagement {
  final String id;
  final Etudiant etudiant;
  final int anneeAcademique;    // 2025, 2026...
  final double montantTotal;    // Total de toutes tranches
  final List<Tranche> tranches;
  final String notes;
  final DateTime dateCreation;
  
  // Méthode clé
  double calculerResteAPayer() {
    // Somme tous les montants regles de chaque tranche
    // Retourne le reste à payer global
  }
  
  bool get estSoldee => calculerResteAPayer() <= 0;
}
```

### `/lib/presentation/state`

#### `fiche_provider.dart`
Gestion d'état avec `ChangeNotifier` et `Provider`

**FicheEngagementNotifier**
```dart
class FicheEngagementNotifier extends ChangeNotifier {
  FicheEngagement? _fiche;
  
  void chargerFicheParMatricule(String matricule) {
    // Mock: retourne _crierFicheMock()
    // Production: appel API REST
  }
  
  void ajouterReglement(int numeroTrache, Reglement reglement) {
    // Ajoute le reglement à la tranche
    // Notifie les listeners
  }
}
```

**Utilisation dans les widgets**
```dart
// Lecture simple
final fiche = context.read<FicheEngagementNotifier>().fiche;

// Observation avec rebuild
Consumer<FicheEngagementNotifier>(
  builder: (context, notifier, _) {
    return Text(notifier.fiche?.etudiant.nomComplet ?? 'Aucun');
  },
)
```

### `/lib/presentation/widgets`

#### `fiche_widgets.dart`
Composants réutilisables :

1. **StudentInfoCard**
   - Affiche les infos étudiant
   - Grille 2x2 des champs
   - Props: matricule, nomComplet, email, telephone, niveau

2. **FicheResumCard**
   - Résumé de la fiche d'engagement
   - Affiche montant total, reste à payer
   - Barre de progression
   - Props: montantTotal, resteAPayer, pourcentagePaiement, estSoldee

3. **TrancheWidget**
   - Une tranche de paiement
   - Affiche statut (Payée/Échue/En cours)
   - Props: numero, montantTotal, montantRegle, dateEcheance, estPayee, estEchue

### `/lib/presentation/screens`

#### `caissiere_dashboard.dart`
Écran principal avec 2 composants :

**CaissiereDashboard** (StatefulWidget)
- Barre de recherche
- Affichage conditionnel (empty state / data)
- Layout responsive

**_EncaissementModal** (StatefulWidget)
- Modal bottom sheet pour nouvel encaissement
- Formulaire avec validation
- Champs: tranche, montant, type, référence (si MoMo), notes

---

## 🔌 Flux de Données

### Recherche d'Étudiant

```
Utilisateur entre matricule
        ↓
Appuie sur "Chercher"
        ↓
CaissiereDashboard._rechercherEtudiant()
        ↓
context.read<FicheEngagementNotifier>().chargerFicheParMatricule(matricule)
        ↓
FicheEngagementNotifier._fiche = _crierFicheMock()
        ↓
notifyListeners()
        ↓
Consumer reconstruit avec la nouvelle fiche
        ↓
UI affiche les infos et tranches
```

### Enregistrement d'Encaissement

```
Utilisateur remplit formulaire
        ↓
Clic "Enregistrer"
        ↓
_EncaissementModal._enregistrerEncaissement()
        ↓
Validation (montant > 0, ref si MoMo)
        ↓
Créer Reglement object
        ↓
context.read<FicheEngagementNotifier>().ajouterReglement(...)
        ↓
Reglement ajouté à Tranche.reglements
        ↓
notifyListeners()
        ↓
Consumer reconstruit
        ↓
FicheResumCard recalcule resteAPayer()
        ↓
UI met à jour avec nouvelle progression
```

---

## 🚀 Extension du Système

### 1. Remplacer les Données Mock par une API

**Avant** (`fiche_provider.dart` - ligne ~15)
```dart
FicheEngagement _crierFicheMock() {
  // Retourne des données hardcodées
}
```

**Après** - Créer un service
```dart
// lib/data/services/fiche_service.dart
class FicheService {
  Future<FicheEngagement> chargerParMatricule(String matricule) async {
    final response = await http.get(Uri.parse(
      'https://api.university.edu/fiches/$matricule'
    ));
    
    if (response.statusCode == 200) {
      return FicheEngagement.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Étudiant non trouvé');
    }
  }
  
  Future<void> enregistrerReglement(
    String ficheId,
    int numeroTrache,
    Reglement reglement,
  ) async {
    await http.post(
      Uri.parse('https://api.university.edu/fiches/$ficheId/reglements'),
      body: jsonEncode({...}),
    );
  }
}
```

Adapter `FicheEngagementNotifier` :
```dart
class FicheEngagementNotifier extends ChangeNotifier {
  final FicheService _service = FicheService();
  FicheEngagement? _fiche;
  
  Future<void> chargerFicheParMatricule(String matricule) async {
    try {
      _fiche = await _service.chargerParMatricule(matricule);
      notifyListeners();
    } catch (e) {
      // Gestion erreur
    }
  }
}
```

### 2. Ajouter l'Authentification

```dart
// lib/presentation/state/auth_provider.dart
class AuthNotifier extends ChangeNotifier {
  User? _currentUser;
  
  Future<void> login(String email, String password) async {
    // Authentifier avec le serveur
    _currentUser = await AuthService.login(email, password);
    notifyListeners();
  }
}

// main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthNotifier()),
    // ... autres providers
  ],
)
```

### 3. Ajouter des Filtres et Tri

```dart
// lib/presentation/screens/reglements_list.dart
class ReglementsListScreen extends StatefulWidget {
  @override
  State<ReglementsListScreen> createState() => _ReglementsListScreenState();
}

class _ReglementsListScreenState extends State<ReglementsListScreen> {
  late FilterNotifier _filterNotifier;
  
  List<Reglement> _applyFilters(List<Reglement> reglements) {
    var filtered = reglements;
    
    // Filtrer par type
    if (_filterNotifier.selectedType != null) {
      filtered = filtered.where((r) => r.type == _filterNotifier.selectedType).toList();
    }
    
    // Filtrer par date
    if (_filterNotifier.dateRange != null) {
      filtered = filtered.where((r) =>
        r.dateReglement.isAfter(_filterNotifier.dateRange!.start) &&
        r.dateReglement.isBefore(_filterNotifier.dateRange!.end)
      ).toList();
    }
    
    return filtered;
  }
}
```

### 4. Ajouter Génération de Rapports PDF

```dart
// lib/presentation/screens/rapport_screen.dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void _genererRapportPDF(FicheEngagement fiche) {
  final pdf = pw.Document();
  
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Text('Fiche d\'Engagement - ${fiche.etudiant.nomComplet}'),
            pw.Table.fromTextArray(
              data: [
                ['Matricule', 'Montant Total', 'Reste à Payer'],
                [fiche.etudiant.matricule, '${fiche.montantTotal} FCFA', '${fiche.calculerResteAPayer()} FCFA'],
              ],
            ),
          ],
        );
      },
    ),
  );
  
  // Sauvegarder ou afficher le PDF
  pdf.save();
}
```

### 5. Ajouter Notifications SMS/Email

```dart
// lib/services/notification_service.dart
class NotificationService {
  Future<void> envoyerConfirmation(Reglement reglement, Etudiant etudiant) async {
    final message = '''
    Bonjour ${etudiant.prenom},
    
    Nous confirmons la réception de votre paiement:
    Montant: ${CurrencyFormatter.formatFCFA(reglement.montant)}
    Date: ${reglement.dateReglement}
    
    Cordialement,
    L'équipe UniPay
    ''';
    
    // Appel API pour envoyer SMS ou Email
    await ApiService.post('/notifications/send', {
      'type': 'sms',
      'phone': etudiant.telephone,
      'message': message,
    });
  }
}
```

---

## ✅ Bonnes Pratiques

### 1. Immutabilité des Models
```dart
// ✓ BON - Classes immuables
class Reglement {
  final double montant;
  final TypeReglement type;
  // Pas de setters
}

// ✗ MAUVAIS
class Reglement {
  double montant; // Mutable
  setMontant(double m) => montant = m;
}
```

### 2. Séparation des Responsabilités
```dart
// ✗ MAUVAIS - Trop de responsabilités
void enregistrerEncaissement() {
  // Validation
  // Appel API
  // Mise à jour UI
  // Persistance locale
  // Log
  // Notification
}

// ✓ BON - Chaque classe a une responsabilité
class ValidationService { } // Validation
class ApiService { }         // API
class StorageService { }     // Persistance
class LogService { }         // Logging
class NotificationService {} // Notifications
```

### 3. Utilisation de Consumer pour l'Observation
```dart
// ✓ BON - Utiliser Consumer pour écouter les changements
Consumer<FicheEngagementNotifier>(
  builder: (context, notifier, _) {
    if (notifier.fiche == null) {
      return Center(child: CircularProgressIndicator());
    }
    return FicheContent(fiche: notifier.fiche!);
  },
)

// ✗ MAUVAIS - Lire au moment de la construction
final fiche = context.read<FicheEngagementNotifier>().fiche;
// N'est jamais mis à jour!
```

### 4. Gestion des Erreurs
```dart
// ✓ BON
try {
  await service.chargerFiche(matricule);
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Erreur: ${e.toString()}')),
  );
}

// ✗ MAUVAIS
await service.chargerFiche(matricule);
// Peut planter l'app si erreur réseau
```

### 5. Nommer les Variables Clairement
```dart
// ✓ BON
final resteAPayer = montantTotal - montantRegle;
final pourcentagePaiement = (montantRegle / montantTotal) * 100;

// ✗ MAUVAIS
final r = m - p;
final pp = (p / m) * 100;
```

---

## 🧪 Tests Unitaires

```dart
// test/models/tranche_test.dart
void main() {
  group('Tranche', () {
    test('calculer le reste à payer correctement', () {
      final tranche = Tranche(
        numero: 1,
        montantTotal: 100000,
        montantRegle: 60000,
        dateEcheance: DateTime(2025, 12, 31),
      );
      
      expect(tranche.resteAPayer, 40000);
      expect(tranche.estPayee, false);
    });
    
    test('marquer comme payée quand complètement versée', () {
      final tranche = Tranche(
        numero: 1,
        montantTotal: 100000,
        montantRegle: 100000,
        dateEcheance: DateTime(2025, 12, 31),
      );
      
      expect(tranche.estPayee, true);
    });
  });
}
```

---

## 📚 Ressources

- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Documentation](https://pub.dev/packages/provider)
- [Clean Architecture (Uncle Bob)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)

---

**Dernière mise à jour**: Mai 2026  
**Mainteneur**: Équipe Développement UniPay
