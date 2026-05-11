# Backend API - UniPay

Documentation de l'API PHP pour la gestion des paiements universitaires.

## 📋 Structure

```
backend/
├── db.php                  # Connexion PDO et classe Database
├── cors.php               # Gestion CORS et utilitaires
├── init_db.sql           # Schéma SQL et données de test PostgreSQL
├── api/
│   ├── get_etudiant.php  # Endpoint GET: Récupère les infos étudiant
│   └── save_paiement.php # Endpoint POST: Enregistre un paiement
└── logs/                  # Dossier pour les logs (créé automatiquement)
```

## 🚀 Installation

### 1. Prérequis

- PHP 7.4+ avec PDO PostgreSQL
- PostgreSQL 12+
- Accès à une base de données PostgreSQL

### 2. Configuration de PostgreSQL

Créer la base de données et l'utilisateur:

```sql
CREATE DATABASE unipay_db;
CREATE USER unipay_admin WITH PASSWORD 'root1234';
ALTER ROLE unipay_admin CREATEDB;
GRANT ALL PRIVILEGES ON DATABASE unipay_db TO unipay_admin;
```

### 3. Charger le schéma

```bash
cd backend
psql -U unipay_admin -d unipay_db -f init_db.sql
```

Ou via PHP-CLI:

```bash
php -r "require 'db.php'; echo 'Connexion OK';"
```

### 4. Créer le dossier logs

```bash
mkdir -p backend/logs
chmod 755 backend/logs
```

## 📡 Endpoints

### GET `/api/get_etudiant.php`

Récupère les informations complètes d'un étudiant avec sa fiche d'engagement et ses tranches.

**Paramètres:**
- `matricule` (string, requis): Le matricule de l'étudiant (ex: `ETU-2025-001`)

**Exemple de requête:**

```bash
curl -X GET "http://localhost:8000/api/get_etudiant.php?matricule=ETU-2025-001" \
  -H "Accept: application/json"
```

**Réponse en cas de succès (200):**

```json
{
  "success": true,
  "message": "Données récupérées avec succès",
  "data": {
    "etudiant": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "matricule": "ETU-2025-001",
      "nom": "Kouassi",
      "prenom": "Jean",
      "email": "jean.kouassi@university.edu",
      "telephone": "+225 07 12 34 56 78",
      "niveau": "L2",
      "date_inscription": "2025-05-11T10:30:00+00:00",
      "actif": true
    },
    "fiche": {
      "id": "550e8400-e29b-41d4-a716-446655440001",
      "annee_academique": 2025,
      "montant_total": "450000.00",
      "montant_regle": "250000.00",
      "reste_a_payer": "200000.00",
      "pourcentage_paiement": 55.56,
      "statut": "PARTIELLEMENT_PAYEE",
      "notes": null,
      "date_creation": "2025-05-11T10:30:00+00:00",
      "date_modification": "2025-05-11T10:30:00+00:00",
      "tranches": [
        {
          "id": "550e8400-e29b-41d4-a716-446655440002",
          "numero": 1,
          "montant_total": "150000.00",
          "montant_regle": "150000.00",
          "reste_a_payer": "0.00",
          "pourcentage_paiement": 100,
          "date_echeance": "2025-09-30",
          "date_creation": "2025-05-11T10:30:00+00:00",
          "statut_tranche": "PAYEE"
        },
        {
          "id": "550e8400-e29b-41d4-a716-446655440003",
          "numero": 2,
          "montant_total": "150000.00",
          "montant_regle": "100000.00",
          "reste_a_payer": "50000.00",
          "pourcentage_paiement": 66.67,
          "date_echeance": "2025-12-31",
          "date_creation": "2025-05-11T10:30:00+00:00",
          "statut_tranche": "EN_COURS"
        },
        {
          "id": "550e8400-e29b-41d4-a716-446655440004",
          "numero": 3,
          "montant_total": "150000.00",
          "montant_regle": "0.00",
          "reste_a_payer": "150000.00",
          "pourcentage_paiement": 0,
          "date_echeance": "2026-03-31",
          "date_creation": "2025-05-11T10:30:00+00:00",
          "statut_tranche": "EN_COURS"
        }
      ],
      "reglements": [
        {
          "id": "550e8400-e29b-41d4-a716-446655440005",
          "montant": "150000.00",
          "type_reglement": "ESPECES",
          "reference_transaction": null,
          "notes": "Paiement 1ère tranche",
          "date_reglement": "2025-05-11T10:30:00+00:00",
          "utilisateur": "caissier_01",
          "numero_tranche": 1
        },
        {
          "id": "550e8400-e29b-41d4-a716-446655440006",
          "montant": "75000.00",
          "type_reglement": "MOBILE_MONEY",
          "reference_transaction": "MTN-2025-001",
          "notes": "Paiement Mobile Money",
          "date_reglement": "2025-05-11T10:30:00+00:00",
          "utilisateur": "caissier_01",
          "numero_tranche": 2
        }
      ]
    }
  },
  "timestamp": "2025-05-11 10:30:00"
}
```

**Erreurs possibles:**

- `400` - Le matricule est requis
- `404` - Étudiant non trouvé
- `500` - Erreur serveur

---

### POST `/api/save_paiement.php`

Enregistre un nouveau règlement et met à jour automatiquement la tranche et la fiche d'engagement.

**Body JSON:**

```json
{
  "matricule": "ETU-2025-001",
  "numeroTrache": 2,
  "montant": 50000,
  "type": "MOBILE_MONEY",
  "referenceTransaction": "MTN-2025-002",
  "notes": "Complément de paiement"
}
```

**Paramètres:**
- `matricule` (string, requis): Matricule de l'étudiant
- `numeroTrache` (integer, requis): Numéro de la tranche (1, 2, 3...)
- `montant` (number, requis): Montant à payer (> 0)
- `type` (string, requis): Type de paiement parmi:
  - `ESPECES`
  - `MOBILE_MONEY` (requis avec `referenceTransaction`)
  - `VIREMENT`
  - `CHEQUE`
- `referenceTransaction` (string, optionnel): Obligatoire pour Mobile Money
- `notes` (string, optionnel): Notes sur le paiement

**Exemple de requête:**

```bash
curl -X POST "http://localhost:8000/api/save_paiement.php" \
  -H "Content-Type: application/json" \
  -d '{
    "matricule": "ETU-2025-001",
    "numeroTrache": 2,
    "montant": 50000,
    "type": "MOBILE_MONEY",
    "referenceTransaction": "MTN-2025-002",
    "notes": "Complément de paiement"
  }'
```

**Réponse en cas de succès (200):**

```json
{
  "success": true,
  "message": "Règlement enregistré avec succès",
  "data": {
    "reglement_enregistre": {
      "montant": 50000,
      "type": "MOBILE_MONEY",
      "referenceTransaction": "MTN-2025-002",
      "dateReglement": "2025-05-11 10:35:00",
      "numeroTrache": 2
    },
    "fiche": {
      "id": "550e8400-e29b-41d4-a716-446655440001",
      "annee_academique": 2025,
      "montant_total": "450000.00",
      "montant_regle": "300000.00",
      "reste_a_payer": "150000.00",
      "pourcentage_paiement": 66.67,
      "statut": "PARTIELLEMENT_PAYEE",
      "tranches": [
        {
          "id": "550e8400-e29b-41d4-a716-446655440002",
          "numero": 1,
          "montant_total": "150000.00",
          "montant_regle": "150000.00",
          "reste_a_payer": "0.00",
          "pourcentage_paiement": 100,
          "statut_tranche": "PAYEE"
        },
        {
          "id": "550e8400-e29b-41d4-a716-446655440003",
          "numero": 2,
          "montant_total": "150000.00",
          "montant_regle": "150000.00",
          "reste_a_payer": "0.00",
          "pourcentage_paiement": 100,
          "statut_tranche": "PAYEE"
        },
        {
          "id": "550e8400-e29b-41d4-a716-446655440004",
          "numero": 3,
          "montant_total": "150000.00",
          "montant_regle": "0.00",
          "reste_a_payer": "150000.00",
          "pourcentage_paiement": 0,
          "statut_tranche": "EN_COURS"
        }
      ],
      "reglements": [...]
    }
  },
  "timestamp": "2025-05-11 10:35:00"
}
```

**Erreurs possibles:**

- `400` - Champs manquants ou validation échouée
  - Montant dépasse le montant dû
  - Référence manquante pour Mobile Money
- `404` - Étudiant ou tranche non trouvée
- `500` - Erreur serveur

---

## 🔒 Sécurité

### CORS

Les en-têtes CORS sont automatiquement configurés pour autoriser:
- Origines: `localhost:3000`, `localhost:8080`, `localhost:5000`
- Méthodes: `GET`, `POST`, `PUT`, `DELETE`, `OPTIONS`
- Headers: `Content-Type`, `Authorization`, `X-Requested-With`

**À personnaliser en production** dans `cors.php`:

```php
$allowed_origins = [
    'https://unipay.example.com',
    'https://app.unipay.example.com',
    // ...
];
```

### Transactions Atomiques

Les paiements utilisent des transactions PostgreSQL pour garantir l'intégrité:
- Insertion du règlement
- Mise à jour automatique de la tranche (trigger)
- Mise à jour automatique de la fiche (trigger)

Toutes les opérations sont validées ensemble ou annulées ensemble.

### Validation des entrées

- Sanitization avec `htmlspecialchars()`
- Validation des types (integer, string, numeric, email)
- Vérification des montants (> 0)
- Enumération stricte des types de paiement
- Paramètres liés (prepared statements) contre SQL injection

## 🧪 Tests

### Test avec cURL

```bash
# Test GET
curl -v "http://localhost:8000/backend/api/get_etudiant.php?matricule=ETU-2025-001"

# Test POST
curl -v -X POST "http://localhost:8000/backend/api/save_paiement.php" \
  -H "Content-Type: application/json" \
  -d '{"matricule":"ETU-2025-001","numeroTrache":2,"montant":25000,"type":"ESPECES"}'
```

### Test avec Postman

1. Importer les requêtes via les exemples cURL ci-dessus
2. Ou créer manuellement:
   - **GET** `http://localhost:8000/backend/api/get_etudiant.php?matricule=ETU-2025-001`
   - **POST** `http://localhost:8000/backend/api/save_paiement.php` avec body JSON

### Test avec Flutter

```dart
// Exemple d'intégration Flutter
import 'package:http/http.dart' as http;

Future<void> testAPI() async {
  final response = await http.get(
    Uri.parse('http://localhost:8000/backend/api/get_etudiant.php?matricule=ETU-2025-001'),
  );
  
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print('Étudiant: ${data['data']['etudiant']['prenom']} ${data['data']['etudiant']['nom']}');
  }
}
```

## 📝 Logs

Tous les logs sont stockés dans `backend/logs/api.log`:

```json
{"timestamp":"2025-05-11 10:30:00","action":"GET_ETUDIANT","ip":"127.0.0.1","user_agent":"curl/7.68.0","details":{"matricule":"ETU-2025-001"}}
{"timestamp":"2025-05-11 10:35:00","action":"SAVE_PAIEMENT","ip":"127.0.0.1","user_agent":"curl/7.68.0","details":{"matricule":"ETU-2025-001","numeroTrache":2,"montant":50000,"type":"MOBILE_MONEY"}}
```

## 🔍 Débogage

### Vérifier la connexion à la base de données

```php
<?php
require 'backend/db.php';
echo 'Connexion réussie!';
$result = $db->queryOne("SELECT 1 as test");
var_dump($result);
```

### Consulter les logs

```bash
tail -f backend/logs/api.log
```

### Erreurs communes

| Erreur | Cause | Solution |
|--------|-------|----------|
| `SQLSTATE[08006]` | Connexion PostgreSQL échouée | Vérifier les credentials dans db.php |
| `Étudiant non trouvé` | Matricule incorrect | Vérifier le matricule en base |
| `Access-Control-Allow-Origin` | CORS bloqué | Vérifier l'origine dans cors.php |
| `Montant dépasse le montant dû` | Paiement excessif | Réduire le montant |

## 📞 Support

Pour toute question ou problème, consultez la documentation de:
- [PHP PDO](https://www.php.net/manual/en/book.pdo.php)
- [PostgreSQL](https://www.postgresql.org/docs/)
- [CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
