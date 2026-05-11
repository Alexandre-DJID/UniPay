<?php
/**
 * Endpoint: POST /api/save_paiement.php
 * Description: Enregistre un nouveau règlement et met à jour les tranches
 * Paramètres: POST JSON {matricule, numeroTrache, montant, type, referenceTransaction, notes}
 * Retour: JSON avec statut et fiche mise à jour
 */

// Inclure les dépendances
require_once __DIR__ . '/../cors.php';
require_once __DIR__ . '/../db.php';

// Configurer les en-têtes
setupCORS();
setupJSON();

// Vérifier que la méthode est POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonError('Seules les requêtes POST sont acceptées', 405);
}

// Récupérer le body JSON
$body = json_decode(file_get_contents('php://input'), true);

// Valider les champs requis
$required_fields = ['matricule', 'numeroTrache', 'montant', 'type'];
$errors = [];

foreach ($required_fields as $field) {
    if (!isset($body[$field]) || empty($body[$field])) {
        $errors[] = "Le champ {$field} est requis";
    }
}

if (!empty($errors)) {
    jsonError('Erreurs de validation', 400, ['errors' => $errors]);
}

// Extraire et sanitizer les données
$matricule = sanitizeInput($body['matricule']);
$numero_tranche = (int)$body['numeroTrache'];
$montant = (float)$body['montant'];
$type = strtoupper(sanitizeInput($body['type']));
$reference = isset($body['referenceTransaction']) ? sanitizeInput($body['referenceTransaction']) : null;
$notes = isset($body['notes']) ? sanitizeInput($body['notes']) : null;

// Valider le montant
if ($montant <= 0) {
    jsonError('Le montant doit être supérieur à 0', 400, ['montant' => $montant]);
}

// Valider le type
$types_valides = ['ESPECES', 'MOBILE_MONEY', 'VIREMENT', 'CHEQUE'];
if (!in_array($type, $types_valides)) {
    jsonError('Type de règlement invalide. Valeurs acceptées: ' . implode(', ', $types_valides), 400);
}

// Valider que référence est fournie pour Mobile Money
if ($type === 'MOBILE_MONEY' && empty($reference)) {
    jsonError('Une référence de transaction est requise pour les paiements Mobile Money', 400);
}

// Logger l'action
logAction('SAVE_PAIEMENT', [
    'matricule' => $matricule,
    'numeroTrache' => $numero_tranche,
    'montant' => $montant,
    'type' => $type
]);

try {
    // Vérifier que l'étudiant existe
    $etudiant = $db->queryOne(
        "SELECT id FROM etudiant WHERE matricule = :matricule AND actif = true",
        [':matricule' => $matricule]
    );

    if (!$etudiant) {
        jsonError('Étudiant non trouvé', 404, ['matricule' => $matricule]);
    }

    $etudiant_id = $etudiant['id'];

    // Récupérer la fiche d'engagement (la plus récente)
    $fiche = $db->queryOne(
        "SELECT id FROM fiche_engagement WHERE etudiant_id = :etudiant_id ORDER BY annee_academique DESC LIMIT 1",
        [':etudiant_id' => $etudiant_id]
    );

    if (!$fiche) {
        jsonError('Fiche d\'engagement non trouvée pour cet étudiant', 404);
    }

    $fiche_id = $fiche['id'];

    // Récupérer la tranche
    $tranche = $db->queryOne(
        "SELECT id, montant_total, montant_regle FROM tranche WHERE fiche_id = :fiche_id AND numero = :numero",
        [':fiche_id' => $fiche_id, ':numero' => $numero_tranche]
    );

    if (!$tranche) {
        jsonError('Tranche non trouvée', 404, ['numeroTrache' => $numero_tranche]);
    }

    $tranche_id = $tranche['id'];
    $montant_total = (float)$tranche['montant_total'];
    $montant_regle = (float)$tranche['montant_regle'];

    // Vérifier que le montant ne dépasse pas le montant dû
    if ($montant + $montant_regle > $montant_total) {
        jsonError(
            'Le montant à payer dépasse le montant dû',
            400,
            [
                'montant_demande' => $montant,
                'montant_regle' => $montant_regle,
                'montant_total' => $montant_total,
                'montant_max_possible' => ($montant_total - $montant_regle)
            ]
        );
    }

    // TRANSACTION ATOMIQUE: Insérer le règlement et mettre à jour la tranche
    try {
        $db->beginTransaction();

        // Insérer le règlement
        $query_insert = "
            INSERT INTO reglement (
                tranche_id,
                montant,
                type_reglement,
                reference_transaction,
                notes,
                utilisateur,
                ip_adresse
            ) VALUES (
                :tranche_id,
                :montant,
                :type,
                :reference,
                :notes,
                :utilisateur,
                :ip_adresse
            )
        ";

        $utilisateur = 'API_' . ($matricule ?? 'UNKNOWN');
        $ip_adresse = $_SERVER['REMOTE_ADDR'] ?? 'UNKNOWN';

        $params = [
            ':tranche_id' => $tranche_id,
            ':montant' => $montant,
            ':type' => $type,
            ':reference' => $reference,
            ':notes' => $notes,
            ':utilisateur' => $utilisateur,
            ':ip_adresse' => $ip_adresse
        ];

        $db->execute($query_insert, $params);

        // La mise à jour de la tranche et de la fiche se fait automatiquement via le trigger
        // update_fiche_on_reglement()

        // Valider la transaction
        $db->commit();

        logAction('PAIEMENT_ENREGISTRE', [
            'matricule' => $matricule,
            'numeroTrache' => $numero_tranche,
            'montant' => $montant,
            'type' => $type
        ]);

    } catch (Exception $e) {
        $db->rollback();
        throw $e;
    }

    // Récupérer la fiche mise à jour pour retourner les données fraîches
    $fiche_mise_a_jour = $db->queryOne(
        "
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
        WHERE id = :fiche_id
        ",
        [':fiche_id' => $fiche_id]
    );

    // Récupérer les tranches mises à jour
    $tranches = $db->query(
        "
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
        ",
        [':fiche_id' => $fiche_id]
    );

    // Récupérer les réglements mis à jour
    $reglements = $db->query(
        "
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
        ",
        [':fiche_id' => $fiche_id]
    );

    $fiche_mise_a_jour['tranches'] = $tranches;
    $fiche_mise_a_jour['reglements'] = $reglements;

    // Retourner le succès avec les données mises à jour
    jsonSuccess(
        [
            'reglement_enregistre' => [
                'montant' => $montant,
                'type' => $type,
                'referenceTransaction' => $reference,
                'dateReglement' => date('Y-m-d H:i:s'),
                'numeroTrache' => $numero_tranche
            ],
            'fiche' => $fiche_mise_a_jour
        ],
        'Règlement enregistré avec succès'
    );

} catch (Exception $e) {
    error_log('Erreur dans save_paiement.php: ' . $e->getMessage());
    logAction('ERROR_SAVE_PAIEMENT', [
        'error' => $e->getMessage(),
        'matricule' => $matricule ?? 'UNKNOWN',
        'numeroTrache' => $numero_tranche ?? 'UNKNOWN'
    ]);
    jsonError('Une erreur est survenue lors de l\'enregistrement du paiement', 500, ['error' => $e->getMessage()]);
}
