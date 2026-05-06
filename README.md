# 🎓 UniPay - Système de Gestion des Paiements Universitaires

> MVP fonctionnel en Flutter Web (Architecture Clean & Orientée Objet), développé dans le cadre du projet d'Analyse et de Conception du Système d'Information.

![Status](https://img.shields.io/badge/Status-MVP_Livré-success)
![Framework](https://img.shields.io/badge/Flutter-Web-blue)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20%2F%20MVC-orange)

## 🎯 Contexte et Objectifs

UniPay informatise la procédure d'encaissement (PF1) des frais de scolarité. Suite aux recommandations du jury de conception, l'architecture métier a été restructurée pour :
1. **Gérer l'historique :** Rattachement de la Fiche d'Engagement au Niveau académique.
2. **Suivre la dette en temps réel :** Calcul dynamique du `ResteAPayer` et basculement automatique au statut `Soldé`.
3. **Sécuriser les flux :** Traçabilité stricte des paiements en Espèces et Mobile Money (avec référence de transaction obligatoire).

## 📋 Architecture (Clean Architecture)

Le projet respecte une séparation stricte des responsabilités pour garantir l'extensibilité du code :

```text
lib/
├── core/                   # Cœur: branding (AppColors), utils (CurrencyFormatter)
├── data/
│   └── models/             # Logique Objet: Etudiant, FicheEngagement, Reglement
├── presentation/
│   ├── screens/            # UI Web: caissiere_dashboard.dart
│   ├── widgets/            # Composants UI modulaires
│   └── state/              # Gestion d'état: fiche_provider.dart
└── main.dart               # Point d'entrée & Injection de dépendances
