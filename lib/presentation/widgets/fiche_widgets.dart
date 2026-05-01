import 'package:flutter/material.dart';
import 'package:unipay/core/constants/app_colors.dart';
import 'package:unipay/core/utils/currency_formatter.dart';

/// Carte d'information étudiant avec détails
class StudentInfoCard extends StatelessWidget {
  final String matricule;
  final String nomComplet;
  final String email;
  final String telephone;
  final String niveau;

  const StudentInfoCard({
    Key? key,
    required this.matricule,
    required this.nomComplet,
    required this.email,
    required this.telephone,
    required this.niveau,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppColors.lightShadow],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec titre
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profil Étudiant',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      nomComplet,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.dividerColor),
          const SizedBox(height: 20),
          // Grille d'informations
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.5,
            children: [
              _buildInfoTile('Matricule', matricule),
              _buildInfoTile('Niveau', niveau),
              _buildInfoTile('Email', email, isEmail: true),
              _buildInfoTile('Téléphone', telephone),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, {bool isEmail = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// Carte affichant le résumé de la fiche (Reste à payer, progression)
class FicheResumCard extends StatelessWidget {
  final double montantTotal;
  final double resteAPayer;
  final double pourcentagePaiement;
  final bool estSoldee;

  const FicheResumCard({
    Key? key,
    required this.montantTotal,
    required this.resteAPayer,
    required this.pourcentagePaiement,
    required this.estSoldee,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color statusColor = estSoldee
        ? AppColors.successColor
        : AppColors.errorColor;
    final String statusText = estSoldee ? 'SOLDÉE' : 'NON PAYÉE';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppColors.lightShadow],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre et statut
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fiche d\'Engagement',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Montants
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Montant Total',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.formatFCFA(montantTotal),
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(width: 1, height: 50, color: AppColors.dividerColor),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Reste à Payer',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.formatFCFA(resteAPayer),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Barre de progression
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progression',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${pourcentagePaiement.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pourcentagePaiement / 100,
                  minHeight: 8,
                  backgroundColor: AppColors.backgroundColor,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    estSoldee
                        ? AppColors.successColor
                        : AppColors.secondaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget pour afficher une tranche de paiement
class TrancheWidget extends StatelessWidget {
  final int numero;
  final double montantTotal;
  final double montantRegle;
  final DateTime dateEcheance;
  final bool estPayee;
  final bool estEchue;

  const TrancheWidget({
    Key? key,
    required this.numero,
    required this.montantTotal,
    required this.montantRegle,
    required this.dateEcheance,
    required this.estPayee,
    required this.estEchue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final resteAPayer = (montantTotal - montantRegle).clamp(
      0.0,
      double.infinity,
    );
    final pourcentage = montantTotal > 0
        ? (montantRegle / montantTotal * 100)
        : 0.0;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (estPayee) {
      statusColor = AppColors.successColor;
      statusText = 'Payée';
      statusIcon = Icons.check_circle;
    } else if (estEchue) {
      statusColor = AppColors.errorColor;
      statusText = 'Échue';
      statusIcon = Icons.error;
    } else {
      statusColor = AppColors.warningColor;
      statusText = 'En cours';
      statusIcon = Icons.schedule;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tranche $numero',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textDark,
                ),
              ),
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Montant:',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatFCFA(montantTotal),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Reste:',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatFCFA(resteAPayer),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: resteAPayer > 0
                          ? AppColors.errorColor
                          : AppColors.successColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: pourcentage / 100,
              minHeight: 6,
              backgroundColor: AppColors.backgroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                estPayee ? AppColors.successColor : AppColors.secondaryColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Échéance: ${dateEcheance.day}/${dateEcheance.month}/${dateEcheance.year}',
            style: const TextStyle(fontSize: 11, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}
