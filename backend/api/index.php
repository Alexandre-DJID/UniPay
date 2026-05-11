<?php
/**
 * API UniPay - Index
 * Documentation des endpoints disponibles
 */

require_once __DIR__ . '/cors.php';

setupCORS();
setupJSON();

// Définir les endpoints disponibles
$endpoints = [
    [
        'method' => 'GET',
        'path' => '/api/get_etudiant.php',
        'description' => 'Récupère les informations d\'un étudiant avec sa fiche d\'engagement et ses tranches',
        'parameters' => [
            'matricule (string, requis)' => 'Le matricule de l\'étudiant'
        ],
        'example_request' => '/api/get_etudiant.php?matricule=ETU-2025-001',
        'example_response' => [
            'etudiant' => [
                'id' => 'uuid',
                'matricule' => 'ETU-2025-001',
                'nom' => 'Kouassi',
                'prenom' => 'Jean',
                'email' => 'jean.kouassi@university.edu',
                'niveau' => 'L2'
            ],
            'fiche' => [
                'montant_total' => 450000,
                'montant_regle' => 250000,
                'reste_a_payer' => 200000,
                'pourcentage_paiement' => 55.56,
                'tranches' => [
                    [
                        'numero' => 1,
                        'montant_total' => 150000,
                        'montant_regle' => 150000,
                        'statut_tranche' => 'PAYEE'
                    ]
                ]
            ]
        ]
    ],
    [
        'method' => 'POST',
        'path' => '/api/save_paiement.php',
        'description' => 'Enregistre un nouveau règlement pour une tranche',
        'parameters' => [
            'matricule (string, requis)' => 'Le matricule de l\'étudiant',
            'numeroTrache (integer, requis)' => 'Le numéro de la tranche',
            'montant (number, requis)' => 'Le montant à payer (> 0)',
            'type (string, requis)' => 'Type: ESPECES, MOBILE_MONEY, VIREMENT, CHEQUE',
            'referenceTransaction (string, optionnel)' => 'Requise pour MOBILE_MONEY',
            'notes (string, optionnel)' => 'Notes sur le paiement'
        ],
        'example_request' => [
            'method' => 'POST',
            'body' => [
                'matricule' => 'ETU-2025-001',
                'numeroTrache' => 2,
                'montant' => 50000,
                'type' => 'MOBILE_MONEY',
                'referenceTransaction' => 'MTN-2025-002',
                'notes' => 'Complément de paiement'
            ]
        ],
        'example_response' => [
            'reglement_enregistre' => [
                'montant' => 50000,
                'type' => 'MOBILE_MONEY',
                'dateReglement' => '2025-05-11 10:35:00'
            ],
            'fiche' => [
                'montant_regle' => 300000,
                'pourcentage_paiement' => 66.67
            ]
        ]
    ]
];

// Si la requête est sur /api/, afficher la documentation
if ($_SERVER['REQUEST_URI'] === '/backend/api/' || $_SERVER['REQUEST_URI'] === '/backend/api' || $_SERVER['REQUEST_URI'] === '/api/') {
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'API UniPay - Documentation',
        'version' => '1.0.0',
        'documentation' => 'Voir README.md pour la documentation complète',
        'endpoints' => $endpoints,
        'base_url' => 'http://' . $_SERVER['HTTP_HOST'] . '/backend/api',
        'timestamp' => date('Y-m-d H:i:s')
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
    exit;
}

// Pour les autres chemins non reconnus
http_response_code(404);
echo json_encode([
    'success' => false,
    'error' => 'Endpoint non trouvé',
    'available_endpoints' => [
        'GET /api/get_etudiant.php?matricule=ETU-2025-001',
        'POST /api/save_paiement.php'
    ],
    'documentation' => 'Voir /api/ pour la documentation complète',
    'timestamp' => date('Y-m-d H:i:s')
]);
