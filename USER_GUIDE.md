# Guide Utilisateur - UniPay Dashboard Caissière

## 📱 Interface Principale

L'application affiche un dashboard complet avec :

### 1. Barre de Recherche
- **Fonction**: Rechercher un étudiant par son matricule
- **Format**: `ETU-YYYY-NNN` (exemple: `ETU-2025-001`)
- **Action**: Appuyer sur "Chercher" ou appuyer sur Entrée

### 2. Fiche d'Engagement
Une fois l'étudiant trouvé, vous verrez :

#### Profil Étudiant
- Nom complet
- Matricule unique
- Email
- Téléphone
- Niveau d'études (L1, L2, L3, M1, M2, etc.)

#### Résumé de la Fiche
- **Montant Total** : Total dues par l'étudiant
- **Reste à Payer** : Montant encore dû (en rouge si dû, en vert si soldé)
- **Progression** : Barre de progression du paiement en pourcentage
- **Statut** : SOLDÉE ou NON PAYÉE

### 3. Bouton "Enregistrer un Encaissement"
Apparaît seulement si la fiche n'est pas encore soldée.

### 4. Tranches de Paiement
Liste des tranches avec :
- **Montant de la tranche**
- **Montant déjà payé**
- **Montant restant**
- **Statut** : Payée ✓ | En cours | Échue ⚠️
- **Date d'échéance**
- **Barre de progression** pour chaque tranche

### 5. Historique des Réglements
Chronologie complète de tous les paiements reçus avec :
- Type de paiement (Espèces / Mobile Money)
- Date et heure exactes
- Montant reçu
- Référence de transaction (si Mobile Money)

---

## 💳 Enregistrer un Encaissement

### Étapes

1. **Cliquer sur le bouton "Enregistrer un Encaissement"**
   - Un formulaire modal s'affiche

2. **Sélectionner la Tranche**
   - Choisir la tranche à payer
   - Seules les tranches non payées sont proposées

3. **Entrer le Montant**
   - Format: nombre décimal (ex: 50000 ou 50000.50)
   - Le montant est obligatoire et doit être > 0

4. **Sélectionner le Type de Paiement**
   - **Espèces** : Paiement direct en cash
   - **Mobile Money** : Paiement via Mobile Money (MTN, Orange, etc.)

5. **Si Mobile Money : Entrer la Référence de Transaction**
   - Format: code unique fourni par le prestataire
   - Exemple: `MTN-2025-001` ou `OMN-TX-12345`
   - **Obligatoire pour Mobile Money**

6. **Notes (Optionnel)**
   - Ajouter des commentaires ou détails additionnels
   - Exemple: "Paiement partiel", "Versé par père", etc.

7. **Cliquer sur "Enregistrer"**
   - Le système enregistre le paiement
   - La fiche se met à jour automatiquement
   - Un message de confirmation apparaît

---

## ✅ Validations & Règles

### Montant
- ✓ Doit être un nombre > 0
- ✓ Peut être décimal (ex: 50000.50)
- ✓ Pas de limite maximale (mais ne peut pas dépasser le reste à payer)

### Type de Paiement
- **Espèces**: Pas de champ supplémentaire requis
- **Mobile Money**: Référence de transaction **obligatoire**

### Tranche
- ✓ Ne peut payer que les tranches non encore payées
- ✓ Une tranche est considérée payée quand montant_regle ≥ montant_total

---

## 📊 Statuts & Indicateurs

### Couleurs
| Couleur | Signification | Situation |
|---------|---------------|-----------|
| 🟢 Vert | Succès / Payé | Tranche complètement payée |
| 🔴 Rouge | Erreur / Dû | Montant encore à payer |
| 🟡 Ambre | Alerte | Tranche en cours ou échue |

### Icônes de Statut
- ✓ Circle (vert) = Tranche payée
- ⏱️ Schedule (ambre) = Tranche en cours, avant échéance
- ⚠️ Error (rouge) = Tranche échue et non payée

---

## 🔄 Flux Complet d'Utilisation

```
1. Ouvrir l'application
        ↓
2. Entrer le matricule étudiant (Ex: ETU-2025-001)
        ↓
3. Cliquer "Chercher"
        ↓
4. Consulter les informations et fiches
        ↓
5. Si des paiements sont dus:
   - Cliquer "Enregistrer un Encaissement"
   - Remplir le formulaire
   - Confirmer l'enregistrement
        ↓
6. Vérifier la mise à jour instantanée:
   - Reste à Payer diminue
   - Progression barre augmente
   - Historique mis à jour
```

---

## ⚠️ Cas d'Usage Courants

### Cas 1 : Paiement Partiel en Espèces
```
Tranche 1 : 150 000 FCFA
Versement reçu: 100 000 FCFA

- Sélectionner Tranche 1
- Montant: 100000
- Type: Espèces
- Cliquer Enregistrer

Résultat: Reste à payer = 50 000 FCFA
```

### Cas 2 : Paiement Mobile Money avec Référence
```
Étudiant reçoit via MTN:
75 000 FCFA avec ref "MTN-2025-001"

- Sélectionner la Tranche appropriée
- Montant: 75000
- Type: Mobile Money
- Référence: MTN-2025-001
- Cliquer Enregistrer

Résultat: Historique met à jour avec la référence
```

### Cas 3 : Fiche Complètement Payée
```
Si Reste à Payer = 0 FCFA

- Badge "SOLDÉE" apparaît
- Bouton "Enregistrer Encaissement" disparaît
- Statut: Fiche d'Engagement complètement payée
```

---

## 🆘 Dépannage

### "Montant invalide"
- ✓ Vérifier que c'est un nombre
- ✓ S'assurer que c'est > 0
- ✓ Ne pas utiliser de caractères spéciaux

### "Référence transaction requise"
- ✓ Vous avez sélectionné "Mobile Money"
- ✓ Entrer obligatoirement la référence fournie par l'opérateur

### "Aucun étudiant trouvé"
- ✓ Vérifier l'orthographe du matricule
- ✓ Format attendu: `ETU-2025-001`
- ✓ Vérifier auprès de l'administration si le matricule existe

### La fiche ne se met pas à jour
- ✓ Recharger en effectuant une nouvelle recherche
- ✓ Vérifier que le paiement a bien été confirmé

---

## 📝 Notes Importantes

1. **Données Mock**: Cette version MVP contient des données de démonstration
2. **Validation**: Tous les champs obligatoires sont validés avant enregistrement
3. **Traçabilité**: Chaque paiement enregistré est horodaté et traçable
4. **Responsivité**: L'interface s'adapte à la taille de l'écran (mobile, tablet, desktop)

---

## 🎓 Documentation Complémentaire

Pour les développeurs : Voir [ARCHITECTURE.md](./ARCHITECTURE.md)

---

**Dernière mise à jour**: Mai 2026  
**Version**: 1.0.0 MVP
