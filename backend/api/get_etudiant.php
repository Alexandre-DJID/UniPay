<?php
/**
 * Endpoint: GET /api/get_etudiant.php
 * Description: Récupère les infos d'un étudiant, sa fiche d'engagement et ses tranches
 * Paramètres: GET matricule (requis)
 * Retour: JSON avec étudiant + fiche + tranches + réglements
 */

// Inclure les dépendances
require_once __DIR__ . '/cors.php';
require_once __DIR__ . '/db.php';

// Configurer les en-têtes
setupCORS();
setupJSON();

// Vérifier que la méthode est GET
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    jsonError('Seules les requêtes GET sont acceptées', 405);
}

// Récupérer et valider le matricule
$matricule = isset($_GET['matricule']) ? trim($_GET['matricule']) : null;

if (empty($matricule)) {
    jsonError('Le paramètre matricule est requis', 400, ['required_param' => 'matricule']);
}

// Sanitizer l'entrée
$matricule = sanitizeInput($matricule);

// Logger l'action
logAction('GET_ETUDIANT', ['matricule' => $matricule]);

try {
    // Récupérer l'étudiant
    $query_etudiant = "
        SELECT 
            id,
            matricule,
            nom,
            prenom,
            email,
            telephone,
            niveau,
            date_inscription,
            actif
        FROM etudiant
        WHERE matricule = :matricule AND actif = true
        LIMIT 1
    ";

    $etudiant = $db->queryOne($query_etudiant, [':matricule' => $matricule]);

    if (!$etudiant) {
        logAction('ETUDIANT_NOT_FOUND', ['matricule' => $matricule]);
        jsonError('Étudiant non trouvé', 404, ['matricule' => $matricule]);
    }

    $etudiant_id = $etudiant['id'];

    // Récupérer la fiche d'engagement la plus récente
    $query_fiche = "
        SELECT 
            id,
            annee_academique,
            montant_total,
            montant_regle,
            statut,
            notes,
            date_creation,
            date_modification,
            (montant_total - montant_regle) as reste_a_payer,
            ROUND(
                CASE 
                    WHEN montant_total = 0 THEN 0
                    ELSE (montant_regle::DECIMAL / montant_total * 100)
                END, 
                2
            ) as pourcentage_paiement
        FROM fiche_engagement
        WHERE etudiant_id = :etudiant_id
        ORDER BY annee_academique DESC
        LIMIT 1
    ";

    $fiche = $db->queryOne($query_fiche, [':etudiant_id' => $etudiant_id]);

    // Si pas de fiche trouvée, initialiser une structure vide
    if (!$fiche) {
        $fiche = [
            'id' => null,
            'annee_academique' => null,
            'montant_total' => 0,
            'montant_regle' => 0,
            'statut' => 'NON_PAYEE',
            'notes' => null,
            'date_creation' => null,
            'date_modification' => null,
            'reste_a_payer' => 0,
            'pourcentage_paiement' => 0,
            'tranches' => [],
            'reglements' => []
        ];

        jsonSuccess([
            'etudiant' => $etudiant,
            'fiche' => $fiche
        ]);
    }

    $fiche_id = $fiche['id'];

    // Récupérer les tranches
    $query_tranches = "
        SELECT 
            id,
            numero,
            montant_total,
            montant_regle,
            date_echeance,
            date_creation,
            (montant_total - montant_regle) as reste_a_payer,
            ROUND(
                CASE 
                    WHEN montant_total = 0 THEN 0
                    ELSE (montant_regle::DECIMAL / montant_total * 100)
                END, 
                2
            ) as pourcentage_paiement,
            CASE
                WHEN montant_regle >= montant_total THEN 'PAYEE'
                WHEN CURRENT_DATE > date_echeance AND montant_regle < montant_total THEN 'ECHUE'
                ELSE 'EN_COURS'
            END as statut_tranche
        FROM tranche
        WHERE fiche_id = :fiche_id
        ORDER BY numero ASC
    ";

    $tranches = $db->query($query_tranches, [':fiche_id' => $fiche_id]);

    // Récupérer les réglements (historique global)
    $query_reglements = "
        SELECT 
            r.id,
            r.montant,
            r.type_reglement,
            r.reference_transaction,
            r.notes,
            r.date_reglement,
            r.utilisateur,
            t.numero as numero_tranche
        FROM reglement r
        INNER JOIN tranche t ON r.tranche_id = t.id
        WHERE t.fiche_id = :fiche_id
        ORDER BY r.date_reglement DESC
    ";

    $reglements = $db->query($query_reglements, [':fiche_id' => $fiche_id]);

    // Ajouter les tranches et réglements à la fiche
    $fiche['tranches'] = $tranches;
    $fiche['reglements'] = $reglements;

    // Retourner les données
    jsonSuccess([
        'etudiant' => $etudiant,
        'fiche' => $fiche
    ], 'Données récupérées avec succès');

} catch (Exception $e) {
    error_log('Erreur dans get_etudiant.php: ' . $e->getMessage());
    logAction('ERROR_GET_ETUDIANT', ['error' => $e->getMessage(), 'matricule' => $matricule]);
    jsonError('Une erreur est survenue lors de la récupération des données', 500, ['error' => $e->getMessage()]);
}
