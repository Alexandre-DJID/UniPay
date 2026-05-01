import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unipay/core/constants/app_colors.dart';
import 'package:unipay/core/utils/currency_formatter.dart';
import 'package:unipay/data/models/models.dart';
import 'package:unipay/presentation/state/fiche_provider.dart';
import 'package:unipay/presentation/widgets/fiche_widgets.dart';

/// Écran principal du dashboard caissière
/// Interface pour consulter les fiches d'engagement et enregistrer les encaissements
class CaissiereDashboard extends StatefulWidget {
  const CaissiereDashboard({Key? key}) : super(key: key);

  @override
  State<CaissiereDashboard> createState() => _CaissiereDashboardState();
}

class _CaissiereDashboardState extends State<CaissiereDashboard> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _rechercherEtudiant() {
    final matricule = _searchController.text.trim();
    context.read<FicheEngagementNotifier>().chargerFicheParMatricule(matricule);
  }

  void _showEncaissementModal(BuildContext context, FicheEngagement fiche) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EncaissementModal(fiche: fiche),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'UniPay - Dashboard Caissière',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Université de Cocody',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 12 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section de recherche
            _buildSearchSection(context),
            const SizedBox(height: 24),

            // Contenu principal
            Consumer<FicheEngagementNotifier>(
              builder: (context, ficheNotifier, _) {
                if (ficheNotifier.fiche == null) {
                  return _buildEmptyState();
                }

                final fiche = ficheNotifier.fiche!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Infos étudiant
                    StudentInfoCard(
                      matricule: fiche.etudiant.matricule,
                      nomComplet: fiche.etudiant.nomComplet,
                      email: fiche.etudiant.email,
                      telephone: fiche.etudiant.telephone,
                      niveau: fiche.etudiant.niveau,
                    ),
                    const SizedBox(height: 24),

                    // Résumé de la fiche
                    FicheResumCard(
                      montantTotal: fiche.montantTotal,
                      resteAPayer: fiche.calculerResteAPayer(),
                      pourcentagePaiement: fiche.pourcentagePaiementGlobal,
                      estSoldee: fiche.estSoldee,
                    ),
                    const SizedBox(height: 24),

                    // Bouton Encaisser
                    if (!fiche.estSoldee)
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _showEncaissementModal(context, fiche),
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text(
                            'Enregistrer un Encaissement',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.successColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Tranches de paiement
                    Text(
                      'Tranches de Paiement',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: fiche.tranches.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final tranche = fiche.tranches[index];
                        return TrancheWidget(
                          numero: tranche.numero,
                          montantTotal: tranche.montantTotal,
                          montantRegle: tranche.montantRegle,
                          dateEcheance: tranche.dateEcheance,
                          estPayee: tranche.estPayee,
                          estEchue: tranche.estEchue,
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Historique des réglements
                    _buildHistoriqueSection(context, fiche),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppColors.lightShadow],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rechercher un Étudiant',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Entrez le matricule (ex: ETU-2025-001)',
                    hintStyle: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.borderColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.borderColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.primaryColor,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _rechercherEtudiant(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _rechercherEtudiant,
                icon: const Icon(Icons.search),
                label: const Text('Chercher'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppColors.lightShadow],
      ),
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.search_off,
              color: AppColors.primaryColor,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun Étudiant Trouvé',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Utilisez la barre de recherche pour trouver un étudiant\npar son matricule.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoriqueSection(BuildContext context, FicheEngagement fiche) {
    final historique = fiche.obtenirHistoriqueReglements();

    if (historique.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [AppColors.lightShadow],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Historique des Réglements',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Aucun reglement enregistré',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppColors.lightShadow],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Historique des Réglements',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: historique.length,
            separatorBuilder: (_, __) =>
                const Divider(color: AppColors.dividerColor),
            itemBuilder: (context, index) {
              final reglement = historique[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reglement.type.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${reglement.dateReglement.day}/${reglement.dateReglement.month}/${reglement.dateReglement.year} à '
                          '${reglement.dateReglement.hour.toString().padLeft(2, '0')}:'
                          '${reglement.dateReglement.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        if (reglement.referenceTransaction != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Ref: ${reglement.referenceTransaction}',
                              style: const TextStyle(
                                color: AppColors.textLight,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      CurrencyFormatter.formatFCFA(reglement.montant),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.successColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Modal pour enregistrer un encaissement
class _EncaissementModal extends StatefulWidget {
  final FicheEngagement fiche;

  const _EncaissementModal({Key? key, required this.fiche}) : super(key: key);

  @override
  State<_EncaissementModal> createState() => _EncaissementModalState();
}

class _EncaissementModalState extends State<_EncaissementModal> {
  late int _selectedTrancheNum;
  final _montantController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();
  TypeReglement _typeReglement = TypeReglement.especes;

  @override
  void initState() {
    super.initState();
    // Sélectionner la première tranche non payée
    final tranchesImpayees = widget.fiche.obtenirTranchesImpayees();
    _selectedTrancheNum = tranchesImpayees.isNotEmpty
        ? tranchesImpayees.first.numero
        : widget.fiche.tranches.first.numero;
  }

  @override
  void dispose() {
    _montantController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _enregistrerEncaissement() {
    final montant = double.tryParse(_montantController.text) ?? 0;

    if (montant <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un montant valide')),
      );
      return;
    }

    if (_typeReglement == TypeReglement.mobileMoney &&
        _referenceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La référence transaction est requise pour Mobile Money',
          ),
        ),
      );
      return;
    }

    try {
      final reglement = Reglement(
        montant: montant,
        type: _typeReglement,
        referenceTransaction: _typeReglement == TypeReglement.mobileMoney
            ? _referenceController.text
            : null,
        notes: _notesController.text,
      );

      context.read<FicheEngagementNotifier>().ajouterReglement(
        _selectedTrancheNum,
        reglement,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Encaissement enregistré: ${CurrencyFormatter.formatFCFA(montant)}',
          ),
          backgroundColor: AppColors.successColor,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            // En-tête
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Enregistrer un Encaissement',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 20),

            // Sélection de la tranche
            Text(
              'Tranche',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _selectedTrancheNum,
              items: widget.fiche.tranches
                  .where((t) => !t.estPayee) // Filtrer les tranches payées
                  .map(
                    (t) => DropdownMenuItem(
                      value: t.numero,
                      child: Text(
                        'Tranche ${t.numero} - '
                        '${CurrencyFormatter.formatFCFA(t.resteAPayer)} à payer',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedTrancheNum = value;
                  });
                }
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primaryColor,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Montant
            Text(
              'Montant (FCFA)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _montantController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                hintText: 'Ex: 50000',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primaryColor,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Type de reglement
            Text(
              'Type de Paiement',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<TypeReglement>(
                    title: const Text('Espèces'),
                    value: TypeReglement.especes,
                    groupValue: _typeReglement,
                    onChanged: (value) {
                      setState(() {
                        _typeReglement = value!;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<TypeReglement>(
                    title: const Text('Mobile Money'),
                    value: TypeReglement.mobileMoney,
                    groupValue: _typeReglement,
                    onChanged: (value) {
                      setState(() {
                        _typeReglement = value!;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Référence (si Mobile Money)
            if (_typeReglement == TypeReglement.mobileMoney) ...[
              Text(
                'Référence Transaction',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _referenceController,
                decoration: InputDecoration(
                  hintText: 'Ex: MTN-2025-001',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.primaryColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Notes
            Text(
              'Notes (Optionnel)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Ajouter des notes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primaryColor,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Boutons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _enregistrerEncaissement,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Enregistrer',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
